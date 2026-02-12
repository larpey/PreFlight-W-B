import Foundation

// MARK: - Confidence Level

enum Confidence: String, Codable, Sendable {
    case high
    case medium
    case low
}

// MARK: - Source Attribution

/// Source attribution for any aircraft specification value.
struct SourceAttribution: Codable, Sendable {
    let primary: PrimarySource
    let secondary: SecondarySource?
    let confidence: Confidence
    let lastVerified: String
    let notes: String?

    init(primary: PrimarySource, secondary: SecondarySource? = nil, confidence: Confidence, lastVerified: String, notes: String? = nil) {
        self.primary = primary
        self.secondary = secondary
        self.confidence = confidence
        self.lastVerified = lastVerified
        self.notes = notes
    }

    struct PrimarySource: Codable, Sendable {
        let document: String
        let section: String
        let publisher: String
        let datePublished: String
        let tcdsNumber: String?
        let url: String?

        init(document: String, section: String, publisher: String, datePublished: String, tcdsNumber: String? = nil, url: String? = nil) {
            self.document = document
            self.section = section
            self.publisher = publisher
            self.datePublished = datePublished
            self.tcdsNumber = tcdsNumber
            self.url = url
        }
    }

    struct SecondarySource: Codable, Sendable {
        let document: String
        let section: String?
        let publisher: String?
        let verification: String
        let dateVerified: String?

        init(document: String, section: String? = nil, publisher: String? = nil, verification: String, dateVerified: String? = nil) {
            self.document = document
            self.section = section
            self.publisher = publisher
            self.verification = verification
            self.dateVerified = dateVerified
        }
    }
}

// MARK: - Sourced Value

/// A numeric value with unit and source attribution.
struct SourcedValue: Codable, Sendable {
    let value: Double
    let unit: Unit
    let source: SourceAttribution

    enum Unit: String, Codable, Sendable {
        case lbs
        case inches
        case gallons
        case lbsPerGal = "lbs/gal"
        case lbIn = "lb-in"
    }
}

// MARK: - Station

/// A loading station (seat row, baggage area).
struct Station: Codable, Sendable, Identifiable {
    let id: String
    let name: String
    let arm: SourcedValue
    let maxWeight: Double?
    let defaultWeight: Double?

    init(id: String, name: String, arm: SourcedValue, maxWeight: Double? = nil, defaultWeight: Double? = nil) {
        self.id = id
        self.name = name
        self.arm = arm
        self.maxWeight = maxWeight
        self.defaultWeight = defaultWeight
    }
}

// MARK: - Fuel Tank

/// Fuel tank configuration.
struct FuelTank: Codable, Sendable, Identifiable {
    let id: String
    let name: String
    let arm: SourcedValue
    let maxGallons: SourcedValue
    let fuelWeightPerGallon: Double
    let isOptional: Bool?

    init(id: String, name: String, arm: SourcedValue, maxGallons: SourcedValue, fuelWeightPerGallon: Double, isOptional: Bool? = nil) {
        self.id = id
        self.name = name
        self.arm = arm
        self.maxGallons = maxGallons
        self.fuelWeightPerGallon = fuelWeightPerGallon
        self.isOptional = isOptional
    }
}

// MARK: - Envelope Point

/// A point defining the CG envelope boundary.
struct EnvelopePoint: Codable, Sendable {
    let weight: Double
    let cg: Double
}

// MARK: - CG Envelope

/// CG envelope definition.
struct CGEnvelope: Codable, Sendable {
    let points: [EnvelopePoint]
    let source: SourceAttribution
}

// MARK: - CG Range

/// Forward and aft CG limits.
struct CGRange: Codable, Sendable {
    let forward: SourcedValue
    let aft: SourcedValue
}

// MARK: - Regulatory Info

/// FAA regulatory information.
struct RegulatoryInfo: Codable, Sendable {
    let tcdsNumber: String
    let farBasis: String
}

// MARK: - Aircraft Category

enum AircraftCategory: String, Codable, Sendable {
    case singleEngine = "single-engine"
    case multiEngine = "multi-engine"
}

// MARK: - Aircraft

/// Complete aircraft definition.
struct Aircraft: Codable, Sendable, Identifiable {
    let id: String
    let name: String
    let model: String
    let manufacturer: String
    let year: String?
    let category: AircraftCategory

    let emptyWeight: SourcedValue
    let emptyWeightArm: SourcedValue
    let maxGrossWeight: SourcedValue
    let maxRampWeight: SourcedValue?
    let maxLandingWeight: SourcedValue?
    let usefulLoad: SourcedValue

    let datum: String
    let cgRange: CGRange
    let cgEnvelope: CGEnvelope

    let stations: [Station]
    let fuelTanks: [FuelTank]

    let regulatory: RegulatoryInfo

    init(
        id: String, name: String, model: String, manufacturer: String,
        year: String? = nil, category: AircraftCategory,
        emptyWeight: SourcedValue, emptyWeightArm: SourcedValue,
        maxGrossWeight: SourcedValue, maxRampWeight: SourcedValue? = nil,
        maxLandingWeight: SourcedValue? = nil, usefulLoad: SourcedValue,
        datum: String, cgRange: CGRange, cgEnvelope: CGEnvelope,
        stations: [Station], fuelTanks: [FuelTank], regulatory: RegulatoryInfo
    ) {
        self.id = id; self.name = name; self.model = model
        self.manufacturer = manufacturer; self.year = year; self.category = category
        self.emptyWeight = emptyWeight; self.emptyWeightArm = emptyWeightArm
        self.maxGrossWeight = maxGrossWeight; self.maxRampWeight = maxRampWeight
        self.maxLandingWeight = maxLandingWeight; self.usefulLoad = usefulLoad
        self.datum = datum; self.cgRange = cgRange; self.cgEnvelope = cgEnvelope
        self.stations = stations; self.fuelTanks = fuelTanks
        self.regulatory = regulatory
    }
}
