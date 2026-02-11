import { useMemo, useState, useCallback } from 'react';
import type { Aircraft } from '../types/aircraft';
import type { StationLoad, FuelLoad, CalculationResult } from '../types/calculation';
import { calculateWeightAndBalance } from '../engine/calculator';
import type { SavedScenario } from '../db';

export function useCalculation(aircraft: Aircraft, initialScenario?: SavedScenario) {
  const [stationLoads, setStationLoads] = useState<StationLoad[]>(
    initialScenario?.stationLoads ?? aircraft.stations.map(s => ({ stationId: s.id, weight: s.defaultWeight ?? 0 }))
  );
  const [fuelLoads, setFuelLoads] = useState<FuelLoad[]>(
    initialScenario?.fuelLoads ?? aircraft.fuelTanks.map(t => ({ tankId: t.id, gallons: 0 }))
  );

  const result: CalculationResult = useMemo(
    () =>
      calculateWeightAndBalance(aircraft, {
        aircraftId: aircraft.id,
        stationLoads,
        fuelLoads,
      }),
    [aircraft, stationLoads, fuelLoads]
  );

  const updateStation = useCallback((stationId: string, weight: number) => {
    setStationLoads(prev =>
      prev.map(s => (s.stationId === stationId ? { ...s, weight } : s))
    );
  }, []);

  const updateFuel = useCallback((tankId: string, gallons: number) => {
    setFuelLoads(prev =>
      prev.map(f => (f.tankId === tankId ? { ...f, gallons } : f))
    );
  }, []);

  const resetAll = useCallback(() => {
    setStationLoads(aircraft.stations.map(s => ({ stationId: s.id, weight: s.defaultWeight ?? 0 })));
    setFuelLoads(aircraft.fuelTanks.map(t => ({ tankId: t.id, gallons: 0 })));
  }, [aircraft]);

  return { stationLoads, fuelLoads, result, updateStation, updateFuel, resetAll };
}
