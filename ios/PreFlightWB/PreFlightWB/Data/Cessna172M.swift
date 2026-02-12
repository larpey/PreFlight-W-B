import Foundation

extension Aircraft {
    static let cessna172m = Aircraft(
        id: "cessna-172m",
        name: "Cessna 172M Skyhawk",
        model: "172M",
        manufacturer: "Cessna Aircraft Company",
        year: "1974",
        category: .singleEngine,
        emptyWeight: SourcedValue(
            value: 1466,
            unit: .lbs,
            source: SourceAttribution(
                primary: SourceAttribution.PrimarySource(
                    document: "POH D1016-13, Cessna Model 172M Skyhawk",
                    section: "Section 6, Page 6-2",
                    publisher: "Cessna Aircraft Company",
                    datePublished: "1975-01-01"
                ),
                confidence: .high,
                lastVerified: "2024-02-08",
                notes: "Typical empty weight. Actual varies per serial number \u{2014} always use aircraft-specific W&B record."
            )
        ),
        emptyWeightArm: SourcedValue(
            value: 40.6,
            unit: .inches,
            source: SourceAttribution(
                primary: SourceAttribution.PrimarySource(
                    document: "POH D1016-13, Cessna Model 172M Skyhawk",
                    section: "Section 6, Weight & Balance Data",
                    publisher: "Cessna Aircraft Company",
                    datePublished: "1975-01-01"
                ),
                confidence: .medium,
                lastVerified: "2024-02-08",
                notes: "Typical value. Actual empty weight CG varies per aircraft. Use data from aircraft W&B record."
            )
        ),
        maxGrossWeight: SourcedValue(
            value: 2300,
            unit: .lbs,
            source: SourceAttribution(
                primary: SourceAttribution.PrimarySource(
                    document: "FAA Type Certificate Data Sheet 3A12",
                    section: "Limitations",
                    publisher: "FAA Aircraft Certification Office",
                    datePublished: "2024-01-15"
                ),
                secondary: SourceAttribution.SecondarySource(
                    document: "POH Section 2, Limitations",
                    verification: "Confirms TCDS value of 2,300 lbs"
                ),
                confidence: .high,
                lastVerified: "2024-02-08"
            )
        ),
        usefulLoad: SourcedValue(
            value: 834,
            unit: .lbs,
            source: SourceAttribution(
                primary: SourceAttribution.PrimarySource(
                    document: "POH D1016-13, Cessna Model 172M Skyhawk",
                    section: "Section 6",
                    publisher: "Cessna Aircraft Company",
                    datePublished: "1975-01-01"
                ),
                confidence: .high,
                lastVerified: "2024-02-08",
                notes: "Max gross (2,300) minus typical empty weight (1,466). Varies per aircraft."
            )
        ),
        datum: "Firewall (leading edge of wing on some references)",
        cgRange: CGRange(
            forward: SourcedValue(
                value: 35,
                unit: .inches,
                source: SourceAttribution(
                    primary: SourceAttribution.PrimarySource(
                        document: "FAA Type Certificate Data Sheet 3A12",
                        section: "CG Range",
                        publisher: "FAA Aircraft Certification Office",
                        datePublished: "2024-01-15"
                    ),
                    confidence: .high,
                    lastVerified: "2024-02-08"
                )
            ),
            aft: SourcedValue(
                value: 47,
                unit: .inches,
                source: SourceAttribution(
                    primary: SourceAttribution.PrimarySource(
                        document: "FAA Type Certificate Data Sheet 3A12",
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
                EnvelopePoint(weight: 1500, cg: 35),
                EnvelopePoint(weight: 1950, cg: 35),
                EnvelopePoint(weight: 2300, cg: 37),
                EnvelopePoint(weight: 2300, cg: 47),
                EnvelopePoint(weight: 1500, cg: 47),
            ],
            source: SourceAttribution(
                primary: SourceAttribution.PrimarySource(
                    document: "POH D1016-13, Cessna Model 172M Skyhawk",
                    section: "Section 6, Figure 6-1, CG Envelope",
                    publisher: "Cessna Aircraft Company",
                    datePublished: "1975-01-01"
                ),
                confidence: .high,
                lastVerified: "2024-02-08",
                notes: "Envelope simplified to key vertices. Refer to actual POH chart for precise limits."
            )
        ),
        stations: [
            Station(
                id: "front-seats",
                name: "Front Seats",
                arm: SourcedValue(
                    value: 37,
                    unit: .inches,
                    source: SourceAttribution(
                        primary: SourceAttribution.PrimarySource(
                            document: "POH D1016-13, Cessna Model 172M Skyhawk",
                            section: "Section 6, Loading Arrangements",
                            publisher: "Cessna Aircraft Company",
                            datePublished: "1975-01-01"
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
                    value: 73,
                    unit: .inches,
                    source: SourceAttribution(
                        primary: SourceAttribution.PrimarySource(
                            document: "POH D1016-13, Cessna Model 172M Skyhawk",
                            section: "Section 6, Loading Arrangements",
                            publisher: "Cessna Aircraft Company",
                            datePublished: "1975-01-01"
                        ),
                        confidence: .high,
                        lastVerified: "2024-02-08"
                    )
                ),
                maxWeight: 400
            ),
            Station(
                id: "baggage-1",
                name: "Baggage Area 1",
                arm: SourcedValue(
                    value: 95,
                    unit: .inches,
                    source: SourceAttribution(
                        primary: SourceAttribution.PrimarySource(
                            document: "POH D1016-13, Cessna Model 172M Skyhawk",
                            section: "Section 6, Loading Arrangements",
                            publisher: "Cessna Aircraft Company",
                            datePublished: "1975-01-01"
                        ),
                        confidence: .high,
                        lastVerified: "2024-02-08"
                    )
                ),
                maxWeight: 120
            ),
            Station(
                id: "baggage-2",
                name: "Baggage Area 2",
                arm: SourcedValue(
                    value: 123,
                    unit: .inches,
                    source: SourceAttribution(
                        primary: SourceAttribution.PrimarySource(
                            document: "POH D1016-13, Cessna Model 172M Skyhawk",
                            section: "Section 6, Loading Arrangements",
                            publisher: "Cessna Aircraft Company",
                            datePublished: "1975-01-01"
                        ),
                        confidence: .high,
                        lastVerified: "2024-02-08"
                    )
                ),
                maxWeight: 50
            ),
        ],
        fuelTanks: [
            FuelTank(
                id: "main-fuel",
                name: "Main Tanks (Both)",
                arm: SourcedValue(
                    value: 48,
                    unit: .inches,
                    source: SourceAttribution(
                        primary: SourceAttribution.PrimarySource(
                            document: "POH D1016-13, Cessna Model 172M Skyhawk",
                            section: "Section 6, Fuel Loading",
                            publisher: "Cessna Aircraft Company",
                            datePublished: "1975-01-01"
                        ),
                        confidence: .high,
                        lastVerified: "2024-02-08"
                    )
                ),
                maxGallons: SourcedValue(
                    value: 43,
                    unit: .gallons,
                    source: SourceAttribution(
                        primary: SourceAttribution.PrimarySource(
                            document: "POH D1016-13, Cessna Model 172M Skyhawk",
                            section: "Section 6, Fuel Capacity",
                            publisher: "Cessna Aircraft Company",
                            datePublished: "1975-01-01"
                        ),
                        secondary: SourceAttribution.SecondarySource(
                            document: "TCDS 3A12",
                            verification: "Confirms 43 gallons usable"
                        ),
                        confidence: .high,
                        lastVerified: "2024-02-08"
                    )
                ),
                fuelWeightPerGallon: 6.0
            ),
        ],
        regulatory: RegulatoryInfo(
            tcdsNumber: "3A12",
            farBasis: "CAR Part 3"
        )
    )
}
