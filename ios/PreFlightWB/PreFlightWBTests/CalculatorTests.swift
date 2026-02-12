import Testing
@testable import PreFlightWB

// MARK: - Cessna 172M Tests

@Suite("Cessna 172M Calculator")
struct Cessna172MTests {
    let aircraft = Aircraft.cessna172m

    @Test("Empty aircraft is within limits")
    func emptyAircraft() {
        let result = Calculator.calculate(
            aircraft: aircraft,
            stationLoads: aircraft.stations.map { StationLoad(stationId: $0.id, weight: 0) },
            fuelLoads: aircraft.fuelTanks.map { FuelLoad(tankId: $0.id, gallons: 0) }
        )

        #expect(result.totalWeight == 1466)
        #expect(result.isWithinWeightLimit)
        #expect(result.warnings.allSatisfy { $0.code != .overMaxGross })
    }

    @Test("Typical loading is within limits")
    func typicalLoading() {
        let result = Calculator.calculate(
            aircraft: aircraft,
            stationLoads: [
                StationLoad(stationId: "front-seats", weight: 340),
                StationLoad(stationId: "rear-seats", weight: 170),
                StationLoad(stationId: "baggage-1", weight: 30),
                StationLoad(stationId: "baggage-2", weight: 0),
            ],
            fuelLoads: [
                FuelLoad(tankId: "main-fuel", gallons: 40),
            ]
        )

        #expect(result.isWithinWeightLimit)
        #expect(result.isWithinCGEnvelope)
        #expect(result.isWithinAllStationLimits)
        #expect(result.warnings.allSatisfy { $0.level != .danger })
    }

    @Test("Over max gross weight triggers danger warning")
    func overMaxGross() {
        let result = Calculator.calculate(
            aircraft: aircraft,
            stationLoads: [
                StationLoad(stationId: "front-seats", weight: 400),
                StationLoad(stationId: "rear-seats", weight: 400),
                StationLoad(stationId: "baggage-1", weight: 120),
                StationLoad(stationId: "baggage-2", weight: 50),
            ],
            fuelLoads: [
                FuelLoad(tankId: "main-fuel", gallons: 43),
            ]
        )

        #expect(!result.isWithinWeightLimit)
        #expect(result.warnings.contains { $0.code == .overMaxGross })
    }

    @Test("Station overweight triggers warning")
    func stationOverweight() {
        let result = Calculator.calculate(
            aircraft: aircraft,
            stationLoads: [
                StationLoad(stationId: "front-seats", weight: 170),
                StationLoad(stationId: "rear-seats", weight: 170),
                StationLoad(stationId: "baggage-1", weight: 150), // max is 120
                StationLoad(stationId: "baggage-2", weight: 0),
            ],
            fuelLoads: [
                FuelLoad(tankId: "main-fuel", gallons: 20),
            ]
        )

        #expect(!result.isWithinAllStationLimits)
        #expect(result.warnings.contains { $0.code == .stationOverweight })
    }

    @Test("Fuel overcapacity triggers warning")
    func fuelOvercapacity() {
        let result = Calculator.calculate(
            aircraft: aircraft,
            stationLoads: aircraft.stations.map { StationLoad(stationId: $0.id, weight: 0) },
            fuelLoads: [
                FuelLoad(tankId: "main-fuel", gallons: 50), // max is 43
            ]
        )

        #expect(result.warnings.contains { $0.code == .fuelOvercapacity })
    }

    @Test("CG calculation is correct for known loading")
    func cgCalculation() {
        // Empty weight: 1466 lbs at arm 40.6 → moment 59527.6
        // Front seats: 340 lbs at arm 37 → moment 12580
        // Fuel: 40 gal × 6.0 = 240 lbs at arm 48 → moment 11520
        // Total weight: 2046, total moment: 83627.6
        // CG: 83627.6 / 2046 = 40.87 (approx)
        let result = Calculator.calculate(
            aircraft: aircraft,
            stationLoads: [
                StationLoad(stationId: "front-seats", weight: 340),
                StationLoad(stationId: "rear-seats", weight: 0),
                StationLoad(stationId: "baggage-1", weight: 0),
                StationLoad(stationId: "baggage-2", weight: 0),
            ],
            fuelLoads: [
                FuelLoad(tankId: "main-fuel", gallons: 40),
            ]
        )

        #expect(result.totalWeight == 2046)
        #expect(abs(result.cg - 40.87) < 0.1)
    }
}

// MARK: - Envelope Tests

@Suite("CG Envelope")
struct EnvelopeTests {
    let envelope = Aircraft.cessna172m.cgEnvelope

    @Test("Point inside envelope returns true")
    func pointInside() {
        // Center of envelope: weight ~1900, CG ~41
        #expect(Envelope.isPointInEnvelope(weight: 1900, cg: 41, envelope: envelope))
    }

    @Test("Point outside envelope returns false")
    func pointOutside() {
        // Way outside: weight 2300, CG 50 (aft limit is 47)
        #expect(!Envelope.isPointInEnvelope(weight: 2300, cg: 50, envelope: envelope))
    }

    @Test("Point below minimum weight is outside")
    func belowMinWeight() {
        #expect(!Envelope.isPointInEnvelope(weight: 1000, cg: 41, envelope: envelope))
    }

    @Test("Point above max weight is outside")
    func aboveMaxWeight() {
        #expect(!Envelope.isPointInEnvelope(weight: 2500, cg: 41, envelope: envelope))
    }

    @Test("getLimitsAtWeight returns correct bounds")
    func limitsAtWeight() {
        let limits = Envelope.getLimitsAtWeight(2000, envelope: envelope)
        #expect(limits != nil)
        if let limits {
            // At 2000 lbs, forward limit interpolates between (1950,35) and (2300,37)
            #expect(limits.forward > 34)
            #expect(limits.forward < 38)
            #expect(limits.aft == 47)
        }
    }

    @Test("getLimitsAtWeight returns nil for out-of-range weight")
    func limitsOutOfRange() {
        let limits = Envelope.getLimitsAtWeight(3000, envelope: envelope)
        #expect(limits == nil)
    }
}

// MARK: - All Aircraft Build Tests

@Suite("All Aircraft")
struct AllAircraftTests {
    @Test("Every aircraft calculates without crash", arguments: AircraftDatabase.all)
    func basicCalculation(aircraft: Aircraft) {
        let result = Calculator.calculate(
            aircraft: aircraft,
            stationLoads: aircraft.stations.map { StationLoad(stationId: $0.id, weight: 0) },
            fuelLoads: aircraft.fuelTanks.map { FuelLoad(tankId: $0.id, gallons: 0) }
        )

        #expect(result.totalWeight == aircraft.emptyWeight.value)
        #expect(result.isWithinWeightLimit)
    }
}
