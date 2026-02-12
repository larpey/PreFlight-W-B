import Foundation

// MARK: - W&B Calculator

/// Pure-function weight and balance calculator.
/// Ported from calculator.ts — safety-critical, do not modify without verification.
enum Calculator {

    /// Perform a complete weight and balance calculation for the given aircraft
    /// and loading scenario.
    ///
    /// The calculation follows these steps:
    /// 1. Start with the aircraft empty weight and moment.
    /// 2. Accumulate station loads (passengers, baggage).
    /// 3. Accumulate fuel loads (converted from gallons to lbs).
    /// 4. Compute CG = totalMoment / totalWeight.
    /// 5. Check all weight limits, station limits, fuel capacity limits.
    /// 6. Check CG against the envelope polygon.
    /// 7. Generate warnings for every violation and near-limit condition.
    ///
    /// - Parameters:
    ///   - aircraft: The aircraft definition with all specs and limits.
    ///   - stationLoads: Weight placed at each station (passengers, baggage).
    ///   - fuelLoads: Fuel loaded in each tank, in gallons.
    /// - Returns: A complete `CalculationResult` with totals, margins, details,
    ///   and any applicable warnings.
    static func calculate(
        aircraft: Aircraft,
        stationLoads: [StationLoad],
        fuelLoads: [FuelLoad]
    ) -> CalculationResult {
        var warnings: [CalculationWarning] = []

        // -----------------------------------------------------------------
        // 1. Start with empty weight
        // -----------------------------------------------------------------
        var totalWeight = aircraft.emptyWeight.value
        var totalMoment = aircraft.emptyWeight.value * aircraft.emptyWeightArm.value

        // -----------------------------------------------------------------
        // 2. Process station loads
        // -----------------------------------------------------------------
        var stationDetails: [StationDetail] = []

        for load in stationLoads {
            guard let station = aircraft.stations.first(where: { $0.id == load.stationId }) else {
                // TypeScript throws here; in Swift we use a precondition failure
                // for programmer errors during development.
                preconditionFailure("Unknown station: \(load.stationId)")
            }

            let arm = station.arm.value
            let moment = load.weight * arm

            // Validate: negative weight
            if load.weight < 0 {
                warnings.append(CalculationWarning(
                    level: .danger,
                    code: .negativeWeight,
                    message: "\(station.name) has negative weight",
                    detail: "Weight values must be zero or positive",
                    regulatoryRef: nil
                ))
            }

            // Validate: station overweight
            if let maxWeight = station.maxWeight, load.weight > maxWeight {
                warnings.append(CalculationWarning(
                    level: .danger,
                    code: .stationOverweight,
                    message: "\(station.name) exceeds maximum weight",
                    detail: "\(formatDecimal(load.weight, decimals: 0)) lbs exceeds limit of \(formatDecimal(maxWeight, decimals: 0)) lbs",
                    regulatoryRef: nil
                ))
            }

            totalWeight += load.weight
            totalMoment += moment

            stationDetails.append(StationDetail(
                stationId: load.stationId,
                name: station.name,
                weight: load.weight,
                arm: arm,
                moment: moment
            ))
        }

        // -----------------------------------------------------------------
        // 3. Process fuel loads
        // -----------------------------------------------------------------
        var fuelDetails: [FuelDetail] = []

        for load in fuelLoads {
            guard let tank = aircraft.fuelTanks.first(where: { $0.id == load.tankId }) else {
                preconditionFailure("Unknown fuel tank: \(load.tankId)")
            }

            // Validate: negative fuel
            if load.gallons < 0 {
                warnings.append(CalculationWarning(
                    level: .danger,
                    code: .negativeFuel,
                    message: "\(tank.name) has negative fuel",
                    detail: "Fuel values must be zero or positive",
                    regulatoryRef: nil
                ))
            }

            // Validate: fuel overcapacity
            if load.gallons > tank.maxGallons.value {
                warnings.append(CalculationWarning(
                    level: .danger,
                    code: .fuelOvercapacity,
                    message: "\(tank.name) exceeds fuel capacity",
                    detail: "\(formatDecimal(load.gallons, decimals: 0)) gal exceeds maximum of \(formatDecimal(tank.maxGallons.value, decimals: 0)) gal",
                    regulatoryRef: nil
                ))
            }

            let weight = load.gallons * tank.fuelWeightPerGallon
            let arm = tank.arm.value
            let moment = weight * arm

            totalWeight += weight
            totalMoment += moment

            fuelDetails.append(FuelDetail(
                tankId: load.tankId,
                name: tank.name,
                gallons: load.gallons,
                weight: weight,
                arm: arm,
                moment: moment
            ))
        }

        // -----------------------------------------------------------------
        // 4. Compute CG
        // -----------------------------------------------------------------
        let cg = totalWeight > 0 ? totalMoment / totalWeight : 0

        // -----------------------------------------------------------------
        // 5. Check weight limits
        // -----------------------------------------------------------------
        let maxGross = aircraft.maxGrossWeight.value
        let isWithinWeightLimit = totalWeight <= maxGross
        let weightMargin = maxGross - totalWeight

        // -----------------------------------------------------------------
        // 6. Check CG limits
        // -----------------------------------------------------------------
        let fwdLimit = aircraft.cgRange.forward.value
        let aftLimit = aircraft.cgRange.aft.value
        let cgForwardMargin = cg - fwdLimit
        let cgAftMargin = aftLimit - cg

        let isWithinCGEnvelope = Envelope.isPointInEnvelope(
            weight: totalWeight,
            cg: cg,
            envelope: aircraft.cgEnvelope
        )

        let isWithinAllStationLimits = !warnings.contains { $0.code == .stationOverweight }

        // -----------------------------------------------------------------
        // 7. Generate weight warnings
        // -----------------------------------------------------------------

        // OVER_MAX_GROSS or NEAR_MAX_GROSS
        if !isWithinWeightLimit {
            warnings.append(CalculationWarning(
                level: .danger,
                code: .overMaxGross,
                message: "Aircraft exceeds maximum takeoff weight",
                detail: "\(formatDecimal(totalWeight, decimals: 1)) lbs exceeds limit of \(formatWithComma(maxGross)) lbs by \(formatDecimal(totalWeight - maxGross, decimals: 1)) lbs",
                regulatoryRef: "FAR 91.103"
            ))
        } else if weightMargin < maxGross * 0.05 {
            warnings.append(CalculationWarning(
                level: .caution,
                code: .nearMaxGross,
                message: "Approaching maximum takeoff weight",
                detail: "\(formatDecimal(weightMargin, decimals: 1)) lbs remaining (\(formatDecimal((weightMargin / maxGross) * 100, decimals: 1))% margin)",
                regulatoryRef: nil
            ))
        }

        // OVER_MAX_RAMP
        if let maxRampWeight = aircraft.maxRampWeight {
            let maxRamp = maxRampWeight.value
            if totalWeight > maxRamp {
                warnings.append(CalculationWarning(
                    level: .danger,
                    code: .overMaxRamp,
                    message: "Aircraft exceeds maximum ramp weight",
                    detail: "\(formatDecimal(totalWeight, decimals: 1)) lbs exceeds ramp limit of \(formatWithComma(maxRamp)) lbs by \(formatDecimal(totalWeight - maxRamp, decimals: 1)) lbs",
                    regulatoryRef: nil
                ))
            }
        }

        // OVER_MAX_LANDING
        if let maxLandingWeight = aircraft.maxLandingWeight {
            let maxLanding = maxLandingWeight.value
            if totalWeight > maxLanding {
                warnings.append(CalculationWarning(
                    level: .warning,
                    code: .overMaxLanding,
                    message: "Current weight exceeds max landing weight",
                    detail: "\(formatDecimal(totalWeight, decimals: 1)) lbs exceeds landing limit of \(formatWithComma(maxLanding)) lbs \u{2014} plan fuel burn before landing",
                    regulatoryRef: nil
                ))
            }
        }

        // -----------------------------------------------------------------
        // 8. Generate CG warnings
        // -----------------------------------------------------------------
        let envelopeLimits = Envelope.getLimitsAtWeight(totalWeight, envelope: aircraft.cgEnvelope)

        if !isWithinCGEnvelope {
            let limitDetail: String
            if let limits = envelopeLimits {
                limitDetail = "forward limit: \(formatDecimal(limits.forward, decimals: 1))\" / aft limit: \(formatDecimal(limits.aft, decimals: 1))\" at \(formatDecimal(totalWeight, decimals: 0)) lbs"
            } else {
                limitDetail = "approved range: \(formatDecimal(fwdLimit, decimals: 0))\u{2013}\(formatDecimal(aftLimit, decimals: 0)) in"
            }

            warnings.append(CalculationWarning(
                level: .danger,
                code: .cgOutOfEnvelope,
                message: "Center of gravity outside approved envelope",
                detail: "CG at \(formatDecimal(cg, decimals: 2)) in \u{2014} \(limitDetail)",
                regulatoryRef: "FAR 91.103"
            ))
        } else if let limits = envelopeLimits,
                  (cg - limits.forward < 1 || limits.aft - cg < 1) {
            warnings.append(CalculationWarning(
                level: .caution,
                code: .cgNearLimit,
                message: "CG is near envelope boundary",
                detail: "CG at \(formatDecimal(cg, decimals: 2)) in \u{2014} forward limit: \(formatDecimal(limits.forward, decimals: 1))\" / aft limit: \(formatDecimal(limits.aft, decimals: 1))\" at this weight",
                regulatoryRef: nil
            ))
        }

        // -----------------------------------------------------------------
        // 9. Build result
        // -----------------------------------------------------------------
        return CalculationResult(
            totalWeight: totalWeight,
            totalMoment: totalMoment,
            cg: cg,
            isWithinWeightLimit: isWithinWeightLimit,
            isWithinCGEnvelope: isWithinCGEnvelope,
            isWithinAllStationLimits: isWithinAllStationLimits,
            weightMargin: weightMargin,
            cgForwardMargin: cgForwardMargin,
            cgAftMargin: cgAftMargin,
            stationDetails: stationDetails,
            fuelDetails: fuelDetails,
            warnings: warnings
        )
    }

    // MARK: - Formatting Helpers

    /// Format a number with a fixed number of decimal places.
    /// Matches JavaScript's `Number.toFixed(n)`.
    private static func formatDecimal(_ value: Double, decimals: Int) -> String {
        String(format: "%.\(decimals)f", value)
    }

    /// Format a number with thousands separators and no decimal places.
    /// Matches JavaScript's `Number.toLocaleString()` for integer-like weights.
    private static func formatWithComma(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: NSNumber(value: value)) ?? formatDecimal(value, decimals: 0)
    }
}
