import Foundation

extension Aircraft {
    static let navajoChieftain = Aircraft(
        id: "navajo-chieftain-pa31",
        name: "Piper PA-31-350 Chieftain (Super Chieftain I \u{2014} N800LP)",
        model: "PA-31-350",
        manufacturer: "Piper Aircraft Corporation",
        year: "1983",
        category: .multiEngine,
        emptyWeight: SourcedValue(
            value: 5082,
            unit: .lbs,
            source: SourceAttribution(
                primary: SourceAttribution.PrimarySource(
                    document: "Weight & Balance Report \u{2014} Colemill Enterprises Inc, Nashville TN",
                    section: "Corrected Empty Weight",
                    publisher: "Albert T MacMillan, A&P/IA (AP 506843185 IA)",
                    datePublished: "2008-05-01"
                ),
                secondary: SourceAttribution.SecondarySource(
                    document: "W&B Report Scale Data",
                    verification: "Weighed 26 Mar 2008 at Cornelia Fort Airpark. Total as weighed: 6,206.00 lbs. Less main fuel (-672), aux fuel (-480), plus unusable fuel (+28.20) = 5,082.20 lbs corrected empty weight.",
                    dateVerified: "2008-05-01"
                ),
                confidence: .high,
                lastVerified: "2026-02-10",
                notes: "Aircraft-specific empty weight from official weighing. Seven seats, one toilet, four dividers, two side tables. BLR VGs, stall fences, winglets, 4-blade props installed. Includes 10 gal unusable fuel."
            )
        ),
        emptyWeightArm: SourcedValue(
            value: 122.5,
            unit: .inches,
            source: SourceAttribution(
                primary: SourceAttribution.PrimarySource(
                    document: "PA-31-350 Navajo Chieftain Weight & Balance Loading Form (N800LP)",
                    section: "Empty Weight Entry",
                    publisher: "Aircraft Owner / Operator",
                    datePublished: "2025-01-01"
                ),
                secondary: SourceAttribution.SecondarySource(
                    document: "W&B Report \u{2014} Colemill Enterprises",
                    verification: "W&B report shows CG of 125.26\" \u{2014} loading form uses 122.5\". Using owner-provided loading form value.",
                    dateVerified: "2026-02-10"
                ),
                confidence: .high,
                lastVerified: "2026-02-10",
                notes: "Per owner's loading form. W&B report (Colemill, May 2008) shows 125.26\" \u{2014} discrepancy noted."
            )
        ),
        maxGrossWeight: SourcedValue(
            value: 7368,
            unit: .lbs,
            source: SourceAttribution(
                primary: SourceAttribution.PrimarySource(
                    document: "PA-31-350 Navajo Chieftain Weight & Balance Loading Form (N800LP)",
                    section: "Performance \u{2014} Maximum take-off weight",
                    publisher: "Aircraft Owner / Operator",
                    datePublished: "2025-01-01"
                ),
                secondary: SourceAttribution.SecondarySource(
                    document: "Super Chieftain I STC \u{2014} Boundary Layer Research, Inc.",
                    verification: "BLR Super Chieftain I STC increases max takeoff weight from standard 7,000 to 7,368 lbs"
                ),
                confidence: .high,
                lastVerified: "2026-02-10",
                notes: "Max TAKEOFF weight per Super Chieftain I STC. Standard PA-31-350 is 7,000 lbs."
            )
        ),
        maxRampWeight: SourcedValue(
            value: 7448,
            unit: .lbs,
            source: SourceAttribution(
                primary: SourceAttribution.PrimarySource(
                    document: "PA-31-350 Navajo Chieftain Weight & Balance Loading Form (N800LP)",
                    section: "Performance \u{2014} Maximum ramp weight",
                    publisher: "Aircraft Owner / Operator",
                    datePublished: "2025-01-01"
                ),
                confidence: .high,
                lastVerified: "2026-02-10",
                notes: "Max ramp weight per Super Chieftain I STC. 80 lb allowance for taxi fuel burn."
            )
        ),
        maxLandingWeight: SourcedValue(
            value: 7000,
            unit: .lbs,
            source: SourceAttribution(
                primary: SourceAttribution.PrimarySource(
                    document: "PA-31-350 Navajo Chieftain Weight & Balance Loading Form (N800LP)",
                    section: "Performance \u{2014} Maximum landing weight",
                    publisher: "Aircraft Owner / Operator",
                    datePublished: "2025-01-01"
                ),
                secondary: SourceAttribution.SecondarySource(
                    document: "FAA TCDS A20SO",
                    verification: "Standard PA-31-350 max landing weight of 7,000 lbs confirmed"
                ),
                confidence: .high,
                lastVerified: "2026-02-10"
            )
        ),
        usefulLoad: SourcedValue(
            value: 2286,
            unit: .lbs,
            source: SourceAttribution(
                primary: SourceAttribution.PrimarySource(
                    document: "PA-31-350 Navajo Chieftain Weight & Balance Loading Form (N800LP)",
                    section: "Derived from max takeoff minus empty weight",
                    publisher: "Aircraft Owner / Operator",
                    datePublished: "2025-01-01"
                ),
                confidence: .high,
                lastVerified: "2026-02-10",
                notes: "Max takeoff (7,368) minus empty weight (5,082) = 2,286 lbs. W&B report shows 2,163 lbs based on earlier 7,245 gross weight."
            )
        ),
        datum: "137 inches ahead of wing main spar centerline",
        cgRange: CGRange(
            forward: SourcedValue(
                value: 119,
                unit: .inches,
                source: SourceAttribution(
                    primary: SourceAttribution.PrimarySource(
                        document: "Super Chieftain I Modification CG Envelope \u{2014} Boundary Layer Research, Inc.",
                        section: "Forward CG Limit",
                        publisher: "Boundary Layer Research, Inc.",
                        datePublished: "2008-01-01"
                    ),
                    confidence: .medium,
                    lastVerified: "2026-02-10",
                    notes: "Weight-dependent forward limit: ~119\" at \u{2264}5,200 lbs, increasing to ~128\" at max ramp (7,448 lbs). See CG envelope for precise limits. Values adjusted from initial chart readings per owner verification."
                )
            ),
            aft: SourcedValue(
                value: 135,
                unit: .inches,
                source: SourceAttribution(
                    primary: SourceAttribution.PrimarySource(
                        document: "Super Chieftain I Modification CG Envelope \u{2014} Boundary Layer Research, Inc.",
                        section: "Aft CG Limit",
                        publisher: "Boundary Layer Research, Inc.",
                        datePublished: "2008-01-01"
                    ),
                    confidence: .high,
                    lastVerified: "2026-02-10"
                )
            )
        ),
        cgEnvelope: CGEnvelope(
            points: [
                EnvelopePoint(weight: 4000, cg: 119),
                EnvelopePoint(weight: 5200, cg: 119),
                EnvelopePoint(weight: 5600, cg: 120),
                EnvelopePoint(weight: 6200, cg: 121),
                EnvelopePoint(weight: 6800, cg: 123),
                EnvelopePoint(weight: 7000, cg: 125),
                EnvelopePoint(weight: 7200, cg: 126),
                EnvelopePoint(weight: 7448, cg: 128),
                EnvelopePoint(weight: 7448, cg: 135),
                EnvelopePoint(weight: 4000, cg: 135),
            ],
            source: SourceAttribution(
                primary: SourceAttribution.PrimarySource(
                    document: "Super Chieftain I Modification CG Envelope \u{2014} Boundary Layer Research, Inc.",
                    section: "Section 6 - Weight and Balance, CHIEFTAINT-1020 PA-31-350",
                    publisher: "Boundary Layer Research, Inc.",
                    datePublished: "2008-01-01"
                ),
                secondary: SourceAttribution.SecondarySource(
                    document: "Owner-provided CG Envelope Chart (photographed)",
                    verification: "Envelope points traced from Super Chieftain I chart. Initial readings adjusted ~1\" forward after owner verified manual CG calculations against original chart.",
                    dateVerified: "2026-02-10"
                ),
                confidence: .medium,
                lastVerified: "2026-02-10",
                notes: "Traced from Super Chieftain I CG envelope chart (Boundary Layer Research). Forward limits adjusted ~1\" from initial photo readings per owner cross-check. Pilot should verify against original chart for critical operations."
            )
        ),
        stations: [
            Station(
                id: "pilot",
                name: "Pilot",
                arm: SourcedValue(
                    value: 95.0,
                    unit: .inches,
                    source: SourceAttribution(
                        primary: SourceAttribution.PrimarySource(
                            document: "PA-31-350 Navajo Chieftain Weight & Balance Loading Form (N800LP)",
                            section: "Pilot Station",
                            publisher: "Aircraft Owner / Operator",
                            datePublished: "2025-01-01"
                        ),
                        confidence: .high,
                        lastVerified: "2026-02-10"
                    )
                ),
                maxWeight: 300
            ),
            Station(
                id: "copilot",
                name: "Copilot",
                arm: SourcedValue(
                    value: 95.0,
                    unit: .inches,
                    source: SourceAttribution(
                        primary: SourceAttribution.PrimarySource(
                            document: "PA-31-350 Navajo Chieftain Weight & Balance Loading Form (N800LP)",
                            section: "Copilot Station",
                            publisher: "Aircraft Owner / Operator",
                            datePublished: "2025-01-01"
                        ),
                        confidence: .high,
                        lastVerified: "2026-02-10"
                    )
                ),
                maxWeight: 300
            ),
            Station(
                id: "fwd-baggage",
                name: "A \u{2014} Forward Baggage",
                arm: SourcedValue(
                    value: 19.0,
                    unit: .inches,
                    source: SourceAttribution(
                        primary: SourceAttribution.PrimarySource(
                            document: "PA-31-350 Navajo Chieftain Weight & Balance Loading Form (N800LP)",
                            section: "Station A",
                            publisher: "Aircraft Owner / Operator",
                            datePublished: "2025-01-01"
                        ),
                        confidence: .high,
                        lastVerified: "2026-02-10"
                    )
                ),
                maxWeight: 200
            ),
            Station(
                id: "aft-cockpit",
                name: "B \u{2014} Aft Cockpit Storage",
                arm: SourcedValue(
                    value: 131.5,
                    unit: .inches,
                    source: SourceAttribution(
                        primary: SourceAttribution.PrimarySource(
                            document: "PA-31-350 Navajo Chieftain Weight & Balance Loading Form (N800LP)",
                            section: "Station B",
                            publisher: "Aircraft Owner / Operator",
                            datePublished: "2025-01-01"
                        ),
                        confidence: .high,
                        lastVerified: "2026-02-10"
                    )
                ),
                maxWeight: 100
            ),
            Station(
                id: "front-pax",
                name: "C1 \u{2014} Front Passengers",
                arm: SourcedValue(
                    value: 104.0,
                    unit: .inches,
                    source: SourceAttribution(
                        primary: SourceAttribution.PrimarySource(
                            document: "PA-31-350 Navajo Chieftain Weight & Balance Loading Form (N800LP)",
                            section: "Station C1",
                            publisher: "Aircraft Owner / Operator",
                            datePublished: "2025-01-01"
                        ),
                        confidence: .high,
                        lastVerified: "2026-02-10"
                    )
                ),
                maxWeight: 400
            ),
            Station(
                id: "rear-pax",
                name: "C2 \u{2014} Rear Passengers",
                arm: SourcedValue(
                    value: 174.0,
                    unit: .inches,
                    source: SourceAttribution(
                        primary: SourceAttribution.PrimarySource(
                            document: "PA-31-350 Navajo Chieftain Weight & Balance Loading Form (N800LP)",
                            section: "Station C2",
                            publisher: "Aircraft Owner / Operator",
                            datePublished: "2025-01-01"
                        ),
                        confidence: .high,
                        lastVerified: "2026-02-10"
                    )
                ),
                maxWeight: 400
            ),
            Station(
                id: "back-pax",
                name: "D \u{2014} Back Passengers",
                arm: SourcedValue(
                    value: 218.0,
                    unit: .inches,
                    source: SourceAttribution(
                        primary: SourceAttribution.PrimarySource(
                            document: "PA-31-350 Navajo Chieftain Weight & Balance Loading Form (N800LP)",
                            section: "Station D",
                            publisher: "Aircraft Owner / Operator",
                            datePublished: "2025-01-01"
                        ),
                        confidence: .high,
                        lastVerified: "2026-02-10"
                    )
                ),
                maxWeight: 400
            ),
            Station(
                id: "rear-baggage",
                name: "E \u{2014} Rear Baggage",
                arm: SourcedValue(
                    value: 255.0,
                    unit: .inches,
                    source: SourceAttribution(
                        primary: SourceAttribution.PrimarySource(
                            document: "PA-31-350 Navajo Chieftain Weight & Balance Loading Form (N800LP)",
                            section: "Station E",
                            publisher: "Aircraft Owner / Operator",
                            datePublished: "2025-01-01"
                        ),
                        confidence: .high,
                        lastVerified: "2026-02-10"
                    )
                ),
                maxWeight: 200
            ),
            Station(
                id: "r-nacelle",
                name: "F1 \u{2014} Right Nacelle Baggage",
                arm: SourcedValue(
                    value: 192.0,
                    unit: .inches,
                    source: SourceAttribution(
                        primary: SourceAttribution.PrimarySource(
                            document: "PA-31-350 Navajo Chieftain Weight & Balance Loading Form (N800LP)",
                            section: "Station F1",
                            publisher: "Aircraft Owner / Operator",
                            datePublished: "2025-01-01"
                        ),
                        confidence: .high,
                        lastVerified: "2026-02-10"
                    )
                ),
                maxWeight: 150
            ),
            Station(
                id: "l-nacelle",
                name: "F2 \u{2014} Left Nacelle Baggage",
                arm: SourcedValue(
                    value: 192.0,
                    unit: .inches,
                    source: SourceAttribution(
                        primary: SourceAttribution.PrimarySource(
                            document: "PA-31-350 Navajo Chieftain Weight & Balance Loading Form (N800LP)",
                            section: "Station F2",
                            publisher: "Aircraft Owner / Operator",
                            datePublished: "2025-01-01"
                        ),
                        confidence: .high,
                        lastVerified: "2026-02-10"
                    )
                ),
                maxWeight: 150
            ),
        ],
        fuelTanks: [
            FuelTank(
                id: "main-fuel",
                name: "Main Fuel (Inboard L+R)",
                arm: SourcedValue(
                    value: 126.8,
                    unit: .inches,
                    source: SourceAttribution(
                        primary: SourceAttribution.PrimarySource(
                            document: "PA-31-350 Navajo Chieftain Weight & Balance Loading Form (N800LP)",
                            section: "Main fuel (usable)",
                            publisher: "Aircraft Owner / Operator",
                            datePublished: "2025-01-01"
                        ),
                        confidence: .high,
                        lastVerified: "2026-02-10"
                    )
                ),
                maxGallons: SourcedValue(
                    value: 106,
                    unit: .gallons,
                    source: SourceAttribution(
                        primary: SourceAttribution.PrimarySource(
                            document: "PA-31-350 Navajo Chieftain Weight & Balance Loading Form (N800LP)",
                            section: "Main fuel capacity",
                            publisher: "Aircraft Owner / Operator",
                            datePublished: "2025-01-01"
                        ),
                        confidence: .high,
                        lastVerified: "2026-02-10",
                        notes: "106 gal usable. Total capacity 112 gal (56 per side). 6 gal unusable included in empty weight. [(56 gal x 2 x 6 lbs) - (6 x 6 lbs)]"
                    )
                ),
                fuelWeightPerGallon: 6.0
            ),
            FuelTank(
                id: "aux-fuel",
                name: "Aux Fuel (Outboard L+R)",
                arm: SourcedValue(
                    value: 148.0,
                    unit: .inches,
                    source: SourceAttribution(
                        primary: SourceAttribution.PrimarySource(
                            document: "PA-31-350 Navajo Chieftain Weight & Balance Loading Form (N800LP)",
                            section: "Aux fuel (usable)",
                            publisher: "Aircraft Owner / Operator",
                            datePublished: "2025-01-01"
                        ),
                        confidence: .high,
                        lastVerified: "2026-02-10"
                    )
                ),
                maxGallons: SourcedValue(
                    value: 76,
                    unit: .gallons,
                    source: SourceAttribution(
                        primary: SourceAttribution.PrimarySource(
                            document: "PA-31-350 Navajo Chieftain Weight & Balance Loading Form (N800LP)",
                            section: "Aux fuel capacity",
                            publisher: "Aircraft Owner / Operator",
                            datePublished: "2025-01-01"
                        ),
                        confidence: .high,
                        lastVerified: "2026-02-10",
                        notes: "76 gal usable. Total capacity 80 gal (40 per side). 4 gal unusable included in empty weight. [(40 gal x 2 x 6 lbs) - (4 x 6 lbs)]"
                    )
                ),
                fuelWeightPerGallon: 6.0
            ),
        ],
        regulatory: RegulatoryInfo(
            tcdsNumber: "A20SO",
            farBasis: "FAR Part 23"
        )
    )
}
