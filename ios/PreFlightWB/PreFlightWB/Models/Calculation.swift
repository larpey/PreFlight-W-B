import Foundation

// MARK: - Station Load

/// Weight entered at a single station.
struct StationLoad: Codable, Sendable {
    let stationId: String
    let weight: Double
}

// MARK: - Fuel Load

/// Fuel loaded in a tank.
struct FuelLoad: Codable, Sendable {
    let tankId: String
    let gallons: Double
}

// MARK: - Loading Scenario

/// Complete loading scenario for an aircraft.
struct LoadingScenario: Codable, Sendable {
    let aircraftId: String
    let stationLoads: [StationLoad]
    let fuelLoads: [FuelLoad]
}

// MARK: - Station Detail

/// Detailed breakdown of a single station in calculation output.
struct StationDetail: Codable, Sendable {
    let stationId: String
    let name: String
    let weight: Double
    let arm: Double
    let moment: Double
}

// MARK: - Fuel Detail

/// Detailed breakdown of a single fuel tank in calculation output.
struct FuelDetail: Codable, Sendable {
    let tankId: String
    let name: String
    let gallons: Double
    let weight: Double
    let arm: Double
    let moment: Double
}

// MARK: - Warning Level

enum WarningLevel: String, Codable, Sendable {
    case caution
    case warning
    case danger
}

// MARK: - Warning Code

enum WarningCode: String, Codable, Sendable {
    case negativeWeight = "NEGATIVE_WEIGHT"
    case negativeFuel = "NEGATIVE_FUEL"
    case stationOverweight = "STATION_OVERWEIGHT"
    case fuelOvercapacity = "FUEL_OVERCAPACITY"
    case overMaxGross = "OVER_MAX_GROSS"
    case overMaxRamp = "OVER_MAX_RAMP"
    case overMaxLanding = "OVER_MAX_LANDING"
    case nearMaxGross = "NEAR_MAX_GROSS"
    case cgOutOfEnvelope = "CG_OUT_OF_ENVELOPE"
    case cgNearLimit = "CG_NEAR_LIMIT"
}

// MARK: - Calculation Warning

/// A warning generated during weight & balance calculation.
struct CalculationWarning: Codable, Sendable {
    let level: WarningLevel
    let code: WarningCode
    let message: String
    let detail: String?
    let regulatoryRef: String?
}

// MARK: - Calculation Result

/// Result of a weight & balance calculation.
struct CalculationResult: Codable, Sendable {
    let totalWeight: Double
    let totalMoment: Double
    let cg: Double

    let isWithinWeightLimit: Bool
    let isWithinCGEnvelope: Bool
    let isWithinAllStationLimits: Bool

    let weightMargin: Double
    let cgForwardMargin: Double
    let cgAftMargin: Double

    let stationDetails: [StationDetail]
    let fuelDetails: [FuelDetail]

    let warnings: [CalculationWarning]
}
