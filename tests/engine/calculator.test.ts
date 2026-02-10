import { describe, it, expect } from 'vitest';
import { calculateWeightAndBalance } from '../../src/engine/calculator';
import { isPointInEnvelope } from '../../src/engine/envelope';
import { cessna172m } from '../../src/data/aircraft/cessna172m';
import { bonanzaA36 } from '../../src/data/aircraft/bonanzaA36';
import { cherokee6 } from '../../src/data/aircraft/cherokee6';
import { navajoChieftain } from '../../src/data/aircraft/navajoChieftain';

describe('isPointInEnvelope', () => {
  const envelope = [
    { weight: 1500, cg: 35 },
    { weight: 1950, cg: 35 },
    { weight: 2300, cg: 37 },
    { weight: 2300, cg: 47 },
    { weight: 1500, cg: 47 },
  ];

  it('returns true for a point inside the envelope', () => {
    expect(isPointInEnvelope(1800, 41, envelope)).toBe(true);
  });

  it('returns false for a point outside the envelope (too heavy)', () => {
    expect(isPointInEnvelope(2500, 41, envelope)).toBe(false);
  });

  it('returns false for a point outside the envelope (CG too far forward)', () => {
    expect(isPointInEnvelope(1800, 30, envelope)).toBe(false);
  });

  it('returns false for a point outside the envelope (CG too far aft)', () => {
    expect(isPointInEnvelope(1800, 50, envelope)).toBe(false);
  });

  it('returns true for a point well inside', () => {
    expect(isPointInEnvelope(2000, 42, envelope)).toBe(true);
  });
});

describe('calculateWeightAndBalance - Cessna 172M', () => {
  it('computes correctly with zero payload (empty aircraft below envelope)', () => {
    const result = calculateWeightAndBalance(cessna172m, {
      aircraftId: cessna172m.id,
      stationLoads: cessna172m.stations.map(s => ({ stationId: s.id, weight: 0 })),
      fuelLoads: cessna172m.fuelTanks.map(t => ({ tankId: t.id, gallons: 0 })),
    });

    expect(result.totalWeight).toBe(1466);
    expect(result.cg).toBeCloseTo(40.6, 1);
    expect(result.isWithinWeightLimit).toBe(true);
    // Empty aircraft is below envelope minimum weight (1500 lbs) — CG out of envelope is expected
    expect(result.isWithinCGEnvelope).toBe(false);
  });

  it('computes correctly with two front passengers and full fuel', () => {
    const result = calculateWeightAndBalance(cessna172m, {
      aircraftId: cessna172m.id,
      stationLoads: [
        { stationId: 'front-seats', weight: 340 },
        { stationId: 'rear-seats', weight: 0 },
        { stationId: 'baggage-1', weight: 0 },
        { stationId: 'baggage-2', weight: 0 },
      ],
      fuelLoads: [{ tankId: 'main-fuel', gallons: 43 }],
    });

    // Manual: 1466*40.6 = 59,519.6; 340*37 = 12,580; 258*48 = 12,384
    // Total weight: 1466 + 340 + 258 = 2064
    // Total moment: 59,519.6 + 12,580 + 12,384 = 84,483.6
    // CG: 84,483.6 / 2064 = 40.93...
    expect(result.totalWeight).toBe(2064);
    expect(result.cg).toBeCloseTo(40.93, 1);
    expect(result.isWithinWeightLimit).toBe(true);
    expect(result.isWithinCGEnvelope).toBe(true);
  });

  it('detects over max gross weight', () => {
    const result = calculateWeightAndBalance(cessna172m, {
      aircraftId: cessna172m.id,
      stationLoads: [
        { stationId: 'front-seats', weight: 400 },
        { stationId: 'rear-seats', weight: 400 },
        { stationId: 'baggage-1', weight: 120 },
        { stationId: 'baggage-2', weight: 50 },
      ],
      fuelLoads: [{ tankId: 'main-fuel', gallons: 43 }],
    });

    // Total: 1466 + 400 + 400 + 120 + 50 + 258 = 2694
    expect(result.totalWeight).toBe(2694);
    expect(result.isWithinWeightLimit).toBe(false);
    expect(result.warnings.some(w => w.code === 'OVER_MAX_GROSS')).toBe(true);
  });

  it('detects station overweight', () => {
    const result = calculateWeightAndBalance(cessna172m, {
      aircraftId: cessna172m.id,
      stationLoads: [
        { stationId: 'front-seats', weight: 200 },
        { stationId: 'rear-seats', weight: 0 },
        { stationId: 'baggage-1', weight: 200 }, // max is 120
        { stationId: 'baggage-2', weight: 0 },
      ],
      fuelLoads: [{ tankId: 'main-fuel', gallons: 20 }],
    });

    expect(result.isWithinAllStationLimits).toBe(false);
    expect(result.warnings.some(w => w.code === 'STATION_OVERWEIGHT')).toBe(true);
  });

  it('detects fuel overcapacity', () => {
    const result = calculateWeightAndBalance(cessna172m, {
      aircraftId: cessna172m.id,
      stationLoads: cessna172m.stations.map(s => ({ stationId: s.id, weight: 0 })),
      fuelLoads: [{ tankId: 'main-fuel', gallons: 50 }], // max is 43
    });

    expect(result.warnings.some(w => w.code === 'FUEL_OVERCAPACITY')).toBe(true);
  });
});

describe('calculateWeightAndBalance - Bonanza A36', () => {
  it('computes correctly with zero payload', () => {
    const result = calculateWeightAndBalance(bonanzaA36, {
      aircraftId: bonanzaA36.id,
      stationLoads: bonanzaA36.stations.map(s => ({ stationId: s.id, weight: 0 })),
      fuelLoads: bonanzaA36.fuelTanks.map(t => ({ tankId: t.id, gallons: 0 })),
    });

    expect(result.totalWeight).toBe(2450);
    expect(result.cg).toBeCloseTo(82.0, 1);
    expect(result.isWithinWeightLimit).toBe(true);
  });

  it('computes correctly with typical loading', () => {
    const result = calculateWeightAndBalance(bonanzaA36, {
      aircraftId: bonanzaA36.id,
      stationLoads: [
        { stationId: 'front-seats', weight: 360 },
        { stationId: 'rear-seats', weight: 340 },
        { stationId: 'baggage', weight: 50 },
      ],
      fuelLoads: [{ tankId: 'main-fuel', gallons: 74 }],
    });

    // Weight: 2450 + 360 + 340 + 50 + 444 = 3644
    expect(result.totalWeight).toBe(3644);
    expect(result.isWithinWeightLimit).toBe(true);
    expect(result.isWithinCGEnvelope).toBe(true);
  });
});

describe('calculateWeightAndBalance - Cherokee Six', () => {
  it('computes correctly with zero payload', () => {
    const result = calculateWeightAndBalance(cherokee6, {
      aircraftId: cherokee6.id,
      stationLoads: cherokee6.stations.map(s => ({ stationId: s.id, weight: 0 })),
      fuelLoads: cherokee6.fuelTanks.map(t => ({ tankId: t.id, gallons: 0 })),
    });

    expect(result.totalWeight).toBe(1780);
    expect(result.isWithinWeightLimit).toBe(true);
  });
});

describe('calculateWeightAndBalance - Navajo Chieftain N800LP', () => {
  it('computes correctly with zero payload', () => {
    const result = calculateWeightAndBalance(navajoChieftain, {
      aircraftId: navajoChieftain.id,
      stationLoads: navajoChieftain.stations.map(s => ({ stationId: s.id, weight: 0 })),
      fuelLoads: navajoChieftain.fuelTanks.map(t => ({ tankId: t.id, gallons: 0 })),
    });

    expect(result.totalWeight).toBe(5082);
    expect(result.cg).toBeCloseTo(122.5, 1);
    expect(result.isWithinWeightLimit).toBe(true);
    expect(result.isWithinCGEnvelope).toBe(true);
  });

  it('computes typical loading matching owner loading form', () => {
    const result = calculateWeightAndBalance(navajoChieftain, {
      aircraftId: navajoChieftain.id,
      stationLoads: [
        { stationId: 'pilot', weight: 175 },
        { stationId: 'copilot', weight: 200 },
        { stationId: 'fwd-baggage', weight: 25 },
        { stationId: 'aft-cockpit', weight: 0 },
        { stationId: 'front-pax', weight: 0 },
        { stationId: 'rear-pax', weight: 0 },
        { stationId: 'back-pax', weight: 0 },
        { stationId: 'rear-baggage', weight: 200 },
        { stationId: 'r-nacelle', weight: 25 },
        { stationId: 'l-nacelle', weight: 25 },
      ],
      fuelLoads: [
        { tankId: 'main-fuel', gallons: 106 },
        { tankId: 'aux-fuel', gallons: 76 },
      ],
    });

    // Weight: 5082 + 175+200+25+200+25+25 + 636+456 = 6824
    // Moment: 5082*122.5 + 175*95 + 200*95 + 25*19 + 200*255 + 25*192 + 25*192 + 636*126.8 + 456*148
    //       = 622545 + 16625 + 19000 + 475 + 51000 + 4800 + 4800 + 80644.8 + 67488 = 867377.8
    // CG: 867377.8 / 6824 = 127.11
    expect(result.totalWeight).toBe(6824);
    expect(result.cg).toBeCloseTo(127.11, 0);
    expect(result.isWithinWeightLimit).toBe(true);
    expect(result.isWithinCGEnvelope).toBe(true);
    expect(result.fuelDetails).toHaveLength(2);
  });

  it('detects over max takeoff weight and max ramp weight', () => {
    const result = calculateWeightAndBalance(navajoChieftain, {
      aircraftId: navajoChieftain.id,
      stationLoads: [
        { stationId: 'pilot', weight: 300 },
        { stationId: 'copilot', weight: 300 },
        { stationId: 'fwd-baggage', weight: 200 },
        { stationId: 'aft-cockpit', weight: 100 },
        { stationId: 'front-pax', weight: 400 },
        { stationId: 'rear-pax', weight: 400 },
        { stationId: 'back-pax', weight: 400 },
        { stationId: 'rear-baggage', weight: 200 },
        { stationId: 'r-nacelle', weight: 150 },
        { stationId: 'l-nacelle', weight: 150 },
      ],
      fuelLoads: [
        { tankId: 'main-fuel', gallons: 106 },
        { tankId: 'aux-fuel', gallons: 76 },
      ],
    });

    // Weight: 5082 + 300+300+200+100+400+400+400+200+150+150 + 636+456 = 8774
    expect(result.totalWeight).toBe(8774);
    expect(result.isWithinWeightLimit).toBe(false);
    expect(result.warnings.some(w => w.code === 'OVER_MAX_GROSS')).toBe(true);
    expect(result.warnings.some(w => w.code === 'OVER_MAX_RAMP')).toBe(true);
    expect(result.warnings.some(w => w.code === 'OVER_MAX_LANDING')).toBe(true);
  });

  it('warns when over max landing weight but under max takeoff', () => {
    const result = calculateWeightAndBalance(navajoChieftain, {
      aircraftId: navajoChieftain.id,
      stationLoads: [
        { stationId: 'pilot', weight: 175 },
        { stationId: 'copilot', weight: 200 },
        { stationId: 'fwd-baggage', weight: 0 },
        { stationId: 'aft-cockpit', weight: 0 },
        { stationId: 'front-pax', weight: 0 },
        { stationId: 'rear-pax', weight: 350 },
        { stationId: 'back-pax', weight: 0 },
        { stationId: 'rear-baggage', weight: 200 },
        { stationId: 'r-nacelle', weight: 0 },
        { stationId: 'l-nacelle', weight: 0 },
      ],
      fuelLoads: [
        { tankId: 'main-fuel', gallons: 106 },
        { tankId: 'aux-fuel', gallons: 76 },
      ],
    });

    // Weight: 5082 + 175+200+350+200 + 636+456 = 7099
    // Over max landing (7000) but under max takeoff (7368)
    expect(result.totalWeight).toBe(7099);
    expect(result.isWithinWeightLimit).toBe(true);
    expect(result.warnings.some(w => w.code === 'OVER_MAX_GROSS')).toBe(false);
    expect(result.warnings.some(w => w.code === 'OVER_MAX_LANDING')).toBe(true);
  });
});
