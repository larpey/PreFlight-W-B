import Foundation

extension Aircraft {
    static let cherokee6 = Aircraft(
        id: "cherokee-six-pa32",
        name: "Piper Cherokee Six PA-32-300",
        model: "PA-32-300",
        manufacturer: "Piper Aircraft Corporation",
        year: "1966",
        category: .singleEngine,
        emptyWeight: SourcedValue(
            value: 1780,
            unit: .lbs,
            source: SourceAttribution(
                primary: SourceAttribution.PrimarySource(
                    document: "POH VB-753, Piper Cherokee Six PA-32-300",
                    section: "Section 6, Weight & Balance Data",
                    publisher: "Piper Aircraft Corporation",
                    datePublished: "1972-01-01"
                ),
                confidence: .high,
                lastVerified: "2024-02-08",
                notes: "Typical empty weight. Actual varies per serial number and installed equipment."
            )
        ),
        emptyWeightArm: SourcedValue(
            value: 87.0,
            unit: .inches,
            source: SourceAttribution(
                primary: SourceAttribution.PrimarySource(
                    document: "POH VB-753, Piper Cherokee Six PA-32-300",
                    section: "Section 6, Weight & Balance Data",
                    publisher: "Piper Aircraft Corporation",
                    datePublished: "1972-01-01"
                ),
                confidence: .medium,
                lastVerified: "2024-02-08",
                notes: "Typical value. Use aircraft-specific W&B record."
            )
        ),
        maxGrossWeight: SourcedValue(
            value: 3400,
            unit: .lbs,
            source: SourceAttribution(
                primary: SourceAttribution.PrimarySource(
                    document: "FAA Type Certificate Data Sheet 2A13",
                    section: "Limitations",
                    publisher: "FAA Aircraft Certification Office",
                    datePublished: "2024-01-15"
                ),
                secondary: SourceAttribution.SecondarySource(
                    document: "POH Section 2, Limitations",
                    verification: "Confirms TCDS value of 3,400 lbs"
                ),
                confidence: .high,
                lastVerified: "2024-02-08"
            )
        ),
        usefulLoad: SourcedValue(
            value: 1620,
            unit: .lbs,
            source: SourceAttribution(
                primary: SourceAttribution.PrimarySource(
                    document: "POH VB-753, Piper Cherokee Six PA-32-300",
                    section: "Section 6",
                    publisher: "Piper Aircraft Corporation",
                    datePublished: "1972-01-01"
                ),
                confidence: .high,
                lastVerified: "2024-02-08",
                notes: "Max gross (3,400) minus typical empty weight (1,780). Varies per aircraft."
            )
        ),
        datum: "78.4 inches ahead of wing leading edge",
        cgRange: CGRange(
            forward: SourcedValue(
                value: 83,
                unit: .inches,
                source: SourceAttribution(
                    primary: SourceAttribution.PrimarySource(
                        document: "FAA Type Certificate Data Sheet 2A13",
                        section: "CG Range",
                        publisher: "FAA Aircraft Certification Office",
                        datePublished: "2024-01-15"
                    ),
                    confidence: .high,
                    lastVerified: "2024-02-08"
                )
            ),
            aft: SourcedValue(
                value: 95,
                unit: .inches,
                source: SourceAttribution(
                    primary: SourceAttribution.PrimarySource(
                        document: "FAA Type Certificate Data Sheet 2A13",
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
                EnvelopePoint(weight: 1780, cg: 83),
                EnvelopePoint(weight: 3400, cg: 83),
                EnvelopePoint(weight: 3400, cg: 95),
                EnvelopePoint(weight: 1780, cg: 95),
            ],
            source: SourceAttribution(
                primary: SourceAttribution.PrimarySource(
                    document: "POH VB-753, Piper Cherokee Six PA-32-300",
                    section: "Section 6, CG Envelope Chart",
                    publisher: "Piper Aircraft Corporation",
                    datePublished: "1972-01-01"
                ),
                confidence: .high,
                lastVerified: "2024-02-08",
                notes: "Simplified rectangular envelope. Refer to actual POH for precise limits."
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
                            document: "POH VB-753, Piper Cherokee Six PA-32-300",
                            section: "Section 6, Loading Arrangements",
                            publisher: "Piper Aircraft Corporation",
                            datePublished: "1972-01-01"
                        ),
                        confidence: .high,
                        lastVerified: "2024-02-08"
                    )
                ),
                maxWeight: 400
            ),
            Station(
                id: "middle-seats",
                name: "Middle Seats",
                arm: SourcedValue(
                    value: 117,
                    unit: .inches,
                    source: SourceAttribution(
                        primary: SourceAttribution.PrimarySource(
                            document: "POH VB-753, Piper Cherokee Six PA-32-300",
                            section: "Section 6, Loading Arrangements",
                            publisher: "Piper Aircraft Corporation",
                            datePublished: "1972-01-01"
                        ),
                        confidence: .high,
                        lastVerified: "2024-02-08"
                    )
                ),
                maxWeight: 400
            ),
            Station(
                id: "rear-seats",
                name: "Rear Seats",
                arm: SourcedValue(
                    value: 142,
                    unit: .inches,
                    source: SourceAttribution(
                        primary: SourceAttribution.PrimarySource(
                            document: "POH VB-753, Piper Cherokee Six PA-32-300",
                            section: "Section 6, Loading Arrangements",
                            publisher: "Piper Aircraft Corporation",
                            datePublished: "1972-01-01"
                        ),
                        confidence: .high,
                        lastVerified: "2024-02-08"
                    )
                ),
                maxWeight: 400
            ),
            Station(
                id: "baggage",
                name: "Baggage Area",
                arm: SourcedValue(
                    value: 150,
                    unit: .inches,
                    source: SourceAttribution(
                        primary: SourceAttribution.PrimarySource(
                            document: "POH VB-753, Piper Cherokee Six PA-32-300",
                            section: "Section 6, Loading Arrangements",
                            publisher: "Piper Aircraft Corporation",
                            datePublished: "1972-01-01"
                        ),
                        confidence: .high,
                        lastVerified: "2024-02-08"
                    )
                ),
                maxWeight: 200
            ),
        ],
        fuelTanks: [
            FuelTank(
                id: "main-fuel",
                name: "Main Fuel Tanks",
                arm: SourcedValue(
                    value: 95,
                    unit: .inches,
                    source: SourceAttribution(
                        primary: SourceAttribution.PrimarySource(
                            document: "POH VB-753, Piper Cherokee Six PA-32-300",
                            section: "Section 6, Fuel Loading",
                            publisher: "Piper Aircraft Corporation",
                            datePublished: "1972-01-01"
                        ),
                        confidence: .high,
                        lastVerified: "2024-02-08"
                    )
                ),
                maxGallons: SourcedValue(
                    value: 84,
                    unit: .gallons,
                    source: SourceAttribution(
                        primary: SourceAttribution.PrimarySource(
                            document: "POH VB-753, Piper Cherokee Six PA-32-300",
                            section: "Section 6, Fuel Capacity",
                            publisher: "Piper Aircraft Corporation",
                            datePublished: "1972-01-01"
                        ),
                        secondary: SourceAttribution.SecondarySource(
                            document: "TCDS 2A13",
                            verification: "Confirms 84 gallons usable"
                        ),
                        confidence: .high,
                        lastVerified: "2024-02-08"
                    )
                ),
                fuelWeightPerGallon: 6.0
            ),
        ],
        regulatory: RegulatoryInfo(
            tcdsNumber: "2A13",
            farBasis: "FAR Part 23"
        )
    )
}
