import { useState, useCallback, useEffect } from 'react';
import { v4 as uuidv4 } from 'uuid';
import type { SavedScenario } from '../db';
import { saveScenario, listScenarios, deleteScenario as dbDelete } from '../db/scenarios';
import { syncScenarios } from '../services/sync';
import { useAuth } from '../contexts/AuthContext';
import { useOnlineStatus } from './useOnlineStatus';

// Re-export for convenience
export type { SavedScenario } from '../db';

export function useScenarios(aircraftId?: string) {
  const [scenarios, setScenarios] = useState<SavedScenario[]>([]);
  const [loading, setLoading] = useState(true);
  const { isAuthenticated } = useAuth();
  const isOnline = useOnlineStatus();

  const refresh = useCallback(async () => {
    const list = await listScenarios(aircraftId);
    setScenarios(list);
    setLoading(false);
  }, [aircraftId]);

  useEffect(() => {
    refresh();
  }, [refresh]);

  const save = useCallback(async (
    name: string,
    aircraftId: string,
    stationLoads: { stationId: string; weight: number }[],
    fuelLoads: { tankId: string; gallons: number }[],
    existingId?: string,
  ) => {
    const now = new Date().toISOString();
    const scenario: SavedScenario = {
      id: existingId ?? uuidv4(),
      aircraftId,
      name,
      stationLoads,
      fuelLoads,
      createdAt: existingId ? now : now,
      updatedAt: now,
      dirty: true,
    };

    await saveScenario(scenario);
    await refresh();

    // Sync in background if online and authenticated
    if (isOnline && isAuthenticated) {
      syncScenarios().catch(() => { /* silent fail — will retry next time */ });
    }

    return scenario;
  }, [refresh, isOnline, isAuthenticated]);

  const remove = useCallback(async (id: string) => {
    await dbDelete(id);
    await refresh();

    if (isOnline && isAuthenticated) {
      syncScenarios().catch(() => {});
    }
  }, [refresh, isOnline, isAuthenticated]);

  return { scenarios, loading, save, remove, refresh };
}
