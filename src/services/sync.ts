import { apiFetch } from './api';
import {
  getDirtyScenarios,
  markClean,
  applySyncedScenarios,
  getLastSyncAt,
  setLastSyncAt,
} from '../db/scenarios';
import type { SavedScenario } from '../db';

interface SyncResponse {
  serverChanges: SavedScenario[];
  syncedAt: string;
}

export async function syncScenarios(): Promise<{ synced: number }> {
  const dirty = await getDirtyScenarios();
  const lastSyncAt = await getLastSyncAt();

  const changes = dirty.map(s => ({
    id: s.id,
    aircraftId: s.aircraftId,
    name: s.name,
    stationLoads: s.stationLoads,
    fuelLoads: s.fuelLoads,
    notes: s.notes,
    updatedAt: s.updatedAt,
    deletedAt: s.deletedAt ?? null,
  }));

  const response = await apiFetch<SyncResponse>('/scenarios/sync', {
    method: 'POST',
    body: JSON.stringify({ lastSyncAt, changes }),
  });

  // Mark pushed scenarios as clean
  if (dirty.length > 0) {
    await markClean(dirty.map(s => s.id));
  }

  // Apply server changes locally
  if (response.serverChanges.length > 0) {
    await applySyncedScenarios(response.serverChanges);
  }

  await setLastSyncAt(response.syncedAt);

  return { synced: dirty.length + response.serverChanges.length };
}
