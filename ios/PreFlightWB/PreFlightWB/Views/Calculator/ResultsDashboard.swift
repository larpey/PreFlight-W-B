import SwiftUI

/// Cockpit-style summary dashboard displayed at the top of the calculator screen.
/// Shows instrument gauges for weight and CG, margin cards, and overall status with animated transitions.
struct ResultsDashboard: View {
    let result: CalculationResult
    let aircraft: Aircraft
    var landingResult: LandingResult? = nil

    /// Tracks the previous within-limits state for haptic feedback on transitions.
    @State private var wasWithinLimits: Bool?

    private var isWithinLimits: Bool {
        result.isWithinWeightLimit && result.isWithinCGEnvelope
    }

    private var weightFraction: Double {
        min(result.totalWeight / aircraft.maxGrossWeight.value, 1.5)
    }

    private var statusLevel: StatusLevel {
        if !result.isWithinWeightLimit || !result.isWithinCGEnvelope {
            return .danger
        } else if weightFraction > 0.95 {
            return .caution
        } else {
            return .safe
        }
    }

    private var statusText: String {
        if !result.isWithinWeightLimit {
            return "OVER WEIGHT"
        } else if !result.isWithinCGEnvelope {
            return "CG OUT OF RANGE"
        } else if weightFraction > 0.95 {
            return "Near Limits"
        } else {
            return "Within Limits"
        }
    }

    // MARK: - CG Gauge Range

    /// Compute CG range from the result margins so the gauge spans forward limit to aft limit.
    private var cgForwardLimit: Double {
        result.cg - result.cgForwardMargin
    }

    private var cgAftLimit: Double {
        result.cg + result.cgAftMargin
    }

    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Status badge
            HStack {
                AnimatedStatusBadge(status: statusLevel, text: statusText)
                Spacer()
            }

            // Instrument gauges row
            HStack(spacing: Spacing.md) {
                InstrumentGauge(
                    value: result.totalWeight,
                    range: 0...aircraft.maxGrossWeight.value,
                    cautionThreshold: 0.9,
                    dangerThreshold: 0.95,
                    label: "WEIGHT",
                    unit: "lbs"
                )

                InstrumentGauge(
                    value: result.cg,
                    range: cgForwardLimit...cgAftLimit,
                    cautionThreshold: 0.85,
                    dangerThreshold: 0.95,
                    label: "CG",
                    unit: "in",
                    decimals: 1
                )
            }
            .frame(maxWidth: .infinity)

            // Weight progress bar
            VStack(spacing: Spacing.xxs) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track
                        RoundedRectangle(cornerRadius: CornerRadius.xs)
                            .fill(Color.cockpitBezel)
                            .frame(height: 12)

                        // Fill bar
                        RoundedRectangle(cornerRadius: CornerRadius.xs)
                            .fill(weightBarColor)
                            .shadow(color: weightBarColor.opacity(0.5), radius: 6)
                            .frame(
                                width: max(0, min(geometry.size.width, geometry.size.width * weightFraction)),
                                height: 12
                            )
                            .animation(.spring(response: 0.4), value: weightFraction)
                    }
                }
                .frame(height: 12)

                HStack {
                    Text("0 lbs")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.cockpitLabelDim)
                    Spacer()
                    Text("Max \(formatted(aircraft.maxGrossWeight.value, decimals: 0)) lbs")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.cockpitLabelDim)
                }
            }

            // Margins row
            HStack(spacing: Spacing.xs) {
                marginCard(
                    icon: "scalemass",
                    label: "Weight",
                    value: "\(formatted(result.weightMargin, decimals: 0)) lbs",
                    isPositive: result.weightMargin >= 0
                )

                marginCard(
                    icon: "arrow.left",
                    label: "Fwd CG",
                    value: "\(formatted(result.cgForwardMargin, decimals: 1))\"",
                    isPositive: result.cgForwardMargin >= 0
                )

                marginCard(
                    icon: "arrow.right",
                    label: "Aft CG",
                    value: "\(formatted(result.cgAftMargin, decimals: 1))\"",
                    isPositive: result.cgAftMargin >= 0
                )
            }

            // Landing section (if fuel burn specified)
            if let landing = landingResult {
                Rectangle()
                    .fill(Color.cockpitBezel)
                    .frame(height: 1)

                HStack {
                    Image(systemName: "airplane.arrival")
                        .font(.caption)
                        .foregroundStyle(Color.cockpitLabel)
                    Text("Landing")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.cockpitLabel)
                    Spacer()
                    Text("\(formatted(landing.landingWeight, decimals: 0)) lbs")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(landing.isWithinWeightLimit ? Color.readoutWhite : Color.readoutRed)
                        .monospacedDigit()
                    Text("CG \(formatted(landing.landingCG, decimals: 2))\"")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(landing.isWithinCGEnvelope ? Color.readoutWhite : Color.readoutRed)
                        .monospacedDigit()
                }

                HStack(spacing: Spacing.xs) {
                    marginCard(
                        icon: "fuelpump",
                        label: "Burn",
                        value: "-\(formatted(landing.fuelBurnGallons, decimals: 0)) gal",
                        isPositive: true
                    )
                    marginCard(
                        icon: "scalemass",
                        label: "Ldg Wt",
                        value: "\(formatted(landing.landingWeight, decimals: 0))",
                        isPositive: landing.isWithinWeightLimit
                    )
                    marginCard(
                        icon: "scope",
                        label: "Ldg CG",
                        value: "\(formatted(landing.landingCG, decimals: 1))\"",
                        isPositive: landing.isWithinCGEnvelope
                    )
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.cockpitSurface)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .strokeBorder(Color.cockpitBezel, lineWidth: 1)
        )
        .onChange(of: isWithinLimits) { oldValue, newValue in
            guard let wasIn = wasWithinLimits else {
                wasWithinLimits = newValue
                return
            }
            if !wasIn && newValue {
                // Transitioned INTO limits
                Haptic.success()
            } else if wasIn && !newValue {
                // Transitioned OUT of limits
                Haptic.error()
            }
            wasWithinLimits = newValue
        }
        .onAppear {
            wasWithinLimits = isWithinLimits
        }
    }

    // MARK: - Helpers

    private var weightBarColor: Color {
        if weightFraction > 1.0 {
            return .readoutRed
        } else if weightFraction > 0.95 {
            return .readoutAmber
        } else {
            return .readoutGreen
        }
    }

    private func marginCard(icon: String, label: String, value: String, isPositive: Bool) -> some View {
        VStack(spacing: Spacing.xxs) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(isPositive ? Color.cockpitLabel : Color.readoutRed)

            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(Color.cockpitLabel)

            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(isPositive ? Color.readoutGreen : Color.readoutRed)
                .monospacedDigit()
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xs)
        .padding(.horizontal, Spacing.xxs)
        .background(Color.cockpitSurface)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.sm)
                .strokeBorder(Color.cockpitBezel, lineWidth: 0.5)
        )
    }

    private func formatted(_ value: Double, decimals: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = decimals
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.\(decimals)f", value)
    }
}

#Preview {
    ResultsDashboard(
        result: CalculationResult(
            totalWeight: 2100,
            totalMoment: 189000,
            cg: 40.5,
            isWithinWeightLimit: true,
            isWithinCGEnvelope: true,
            isWithinAllStationLimits: true,
            weightMargin: 200,
            cgForwardMargin: 5.0,
            cgAftMargin: 6.5,
            stationDetails: [],
            fuelDetails: [],
            warnings: []
        ),
        aircraft: .cessna172m
    )
    .padding()
    .background(Color.cockpitBackground)
}
