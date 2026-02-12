import Foundation

extension Aircraft {
    static let bonanzaA36 = Aircraft(
        id: "bonanza-a36",
        name: "Beechcraft Bonanza A36",
        model: "A36",
        manufacturer: "Beech Aircraft Corporation",
        year: "1970",
        category: .singleEngine,
        emptyWeight: SourcedValue(
            value: 2450,
            unit: .lbs,
            source: SourceAttribution(
                primary: SourceAttribution.PrimarySource(
                    document: "POH P/N 36-590001-9B, Beechcraft Bonanza A36",
                    section: "Section 6, Weight & Balance Data",
                    publisher: "Beech Aircraft Corporation",
                    datePublished: "1984-01-01"
                ),
                confidence: .high,
                lastVerified: "2024-02-08",
                notes: "Typical empty weight. Actual varies per serial number and installed equipment."
            )
        ),
        emptyWeightArm: SourcedValue(
            value: 82.0,
            unit: .inches,
            source: SourceAttribution(
                primary: SourceAttribution.PrimarySource(
                    document: "POH P/N 36-590001-9B, Beechcraft Bonanza A36",
                    section: "Section 6, Weight & Balance Data",
                    publisher: "Beech Aircraft Corporation",
                    datePublished: "1984-01-01"
                ),
                confidence: .medium,
                lastVerified: "2024-02-08",
                notes: "Typical value. Use aircraft-specific W&B record for actual CG."
            )
        ),
        maxGrossWeight: SourcedValue(
            value: 3650,
            unit: .lbs,
            source: SourceAttribution(
                primary: SourceAttribution.PrimarySource(
                    document: "FAA Type Certificate Data Sheet 3A15",
                    section: "Limitations",
                    publisher: "FAA Aircraft Certification Office",
                    datePublished: "2024-01-15"
                ),
                secondary: SourceAttribution.SecondarySource(
                    document: "POH Section 2, Limitations",
                    verification: "Confirms TCDS value of 3,650 lbs"
                ),
                confidence: .high,
                lastVerified: "2024-02-08"
            )
        ),
        usefulLoad: SourcedValue(
            value: 1200,
            unit: .lbs,
            source: SourceAttribution(
                primary: SourceAttribution.PrimarySource(
                    document: "POH P/N 36-590001-9B, Beechcraft Bonanza A36",
                    section: "Section 6",
                    publisher: "Beech Aircraft Corporation",
                    datePublished: "1984-01-01"
                ),
                confidence: .high,
                lastVerified: "2024-02-08",
                notes: "Max gross (3,650) minus typical empty weight (2,450). Varies per aircraft."
            )
        ),
        datum: "Leading edge of wing",
        cgRange: CGRange(
            forward: SourcedValue(
                value: 80,
                unit: .inches,
                source: SourceAttribution(
                    primary: SourceAttribution.PrimarySource(
                        document: "FAA Type Certificate Data Sheet 3A15",
                        section: "CG Range",
                        publisher: "FAA Aircraft Certification Office",
                        datePublished: "2024-01-15"
                    ),
                    confidence: .high,
                    lastVerified: "2024-02-08"
                )
            ),
            aft: SourcedValue(
                value: 90,
                unit: .inches,
                source: SourceAttribution(
                    primary: SourceAttribution.PrimarySource(
                        document: "FAA Type Certificate Data Sheet 3A15",
                        section: "CG Range",
                        publisher: "FAA Aircraft Certification Office",
                        datePublished: "2024-01-15"
                    ),
                    confidence: .high,
                    lastVerified: "2024-02-08"
                )
            )
        ),
        cgEnvelope: CGEnvelope(
            points: [
                EnvelopePoint(weight: 2450, cg: 80),
                EnvelopePoint(weight: 3650, cg: 80),
                EnvelopePoint(weight: 3650, cg: 90),
                EnvelopePoint(weight: 2450, cg: 90),
            ],
            source: SourceAttribution(
                primary: SourceAttribution.PrimarySource(
                    document: "POH P/N 36-590001-9B, Beechcraft Bonanza A36",
                    section: "Section 6, CG Envelope Chart",
                    publisher: "Beech Aircraft Corporation",
                    datePublished: "1984-01-01"
                ),
                confidence: .high,
                lastVerified: "2024-02-08",
                notes: "Simplified rectangular envelope. Actual POH envelope may have additional vertices at lower weights."
            )
        ),
        stations: [
            Station(
                id: "front-seats",
                name: "Front Seats",
                arm: SourcedValue(
                    value: 85,
                    unit: .inches,
                    source: SourceAttribution(
                        primary: SourceAttribution.PrimarySource(
                            document: "POH P/N 36-590001-9B, Beechcraft Bonanza A36",
                            section: "Section 6, Loading Arrangements",
                            publisher: "Beech Aircraft Corporation",
                            datePublished: "1984-01-01"
                        ),
                        confidence: .high,
                        lastVerified: "2024-02-08",
                        notes: "Adjustable range 80.5-87 inches. Using 85 in midpoint for calculation."
                    )
                ),
                maxWeight: 400
            ),
            Station(
                id: "rear-seats",
                name: "Rear Seats",
                arm: SourcedValue(
                    value: 118,
                    unit: .inches,
                    source: SourceAttribution(
                        primary: SourceAttribution.PrimarySource(
                            document: "POH P/N 36-590001-9B, Beechcraft Bonanza A36",
                            section: "Section 6, Loading Arrangements",
                            publisher: "Beech Aircraft Corporation",
                            datePublished: "1984-01-01"
                        ),
                        confidence: .high,
                        lastVerified: "2024-02-08"
                    )
                ),
                maxWeight: 400
            ),
            Station(
                id: "baggage",
                name: "Baggage Compartment",
                arm: SourcedValue(
                    value: 142,
                    unit: .inches,
                    source: SourceAttribution(
                        primary: SourceAttribution.PrimarySource(
                            document: "POH P/N 36-590001-9B, Beechcraft Bonanza A36",
                            section: "Section 6, Loading Arrangements",
                            publisher: "Beech Aircraft Corporation",
                            datePublished: "1984-01-01"
                        ),
                        confidence: .high,
                        lastVerified: "2024-02-08"
                    )
                ),
                maxWeight: 400
            ),
        ],
        fuelTanks: [
            FuelTank(
                id: "main-fuel",
                name: "Main Fuel Tanks",
                arm: SourcedValue(
                    value: 75,
                    unit: .inches,
                    source: SourceAttribution(
                        primary: SourceAttribution.PrimarySource(
                            document: "POH P/N 36-590001-9B, Beechcraft Bonanza A36",
                            section: "Section 6, Fuel Loading",
                            publisher: "Beech Aircraft Corporation",
                            datePublished: "1984-01-01"
                        ),
                        confidence: .high,
                        lastVerified: "2024-02-08"
                    )
                ),
                maxGallons: SourcedValue(
                    value: 74,
                    unit: .gallons,
                    source: SourceAttribution(
                        primary: SourceAttribution.PrimarySource(
                            document: "POH P/N 36-590001-9B, Beechcraft Bonanza A36",
                            section: "Section 6, Fuel Capacity",
                            publisher: "Beech Aircraft Corporation",
                            datePublished: "1984-01-01"
                        ),
                        secondary: SourceAttribution.SecondarySource(
                            document: "TCDS 3A15",
                            verification: "Confirms 74 gallons usable"
                        ),
                        confidence: .high,
                        lastVerified: "2024-02-08"
                    )
                ),
                fuelWeightPerGallon: 6.0
            ),
        ],
        regulatory: RegulatoryInfo(
            tcdsNumber: "3A15",
            farBasis: "CAR Part 3"
        )
    )
}
