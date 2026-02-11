import { getDB, type SavedScenario } from './index';

export async function saveScenario(scenario: SavedScenario): Promise<void> {
  const db = await getDB();
  await db.put('scenarios', scenario);
}

export async function getScenario(id: string): Promise<SavedScenario | undefined> {
  const db = await getDB();
  return db.get('scenarios', id);
}

export async function listScenarios(aircraftId?: string): Promise<SavedScenario[]> {
  const db = await getDB();
  let all: SavedScenario[];

  if (aircraftId) {
    all = await db.getAllFromIndex('scenarios', 'by-aircraft', aircraftId);
  } else {
    all = await db.getAll('scenarios');
  }

  return all
    .filter(s => !s.deletedAt)
    .sort((a, b) => new Date(b.updatedAt).getTime() - new Date(a.updatedAt).getTime());
}

export async function deleteScenario(id: string): Promise<void> {
  const db = await getDB();
  const scenario = await db.get('scenarios', id);
  if (!scenario) return;

  // Soft-delete — mark dirty so it syncs
  scenario.deletedAt = new Date().toISOString();
  scenario.updatedAt = new Date().toISOString();
  scenario.dirty = true;
  await db.put('scenarios', scenario);
}

export async function getDirtyScenarios(): Promise<SavedScenario[]> {
  const db = await getDB();
  const all = await db.getAll('scenarios');
  return all.filter(s => s.dirty);
}

export async function markClean(ids: string[]): Promise<void> {
  const db = await getDB();
  const tx = db.transaction('scenarios', 'readwrite');
  for (const id of ids) {
    const scenario = await tx.store.get(id);
    if (scenario) {
      scenario.dirty = false;
      await tx.store.put(scenario);
    }
  }
  await tx.done;
}

export async function applySyncedScenarios(scenarios: SavedScenario[]): Promise<void> {
  const db = await getDB();
  const tx = db.transaction('scenarios', 'readwrite');
  for (const scenario of scenarios) {
    const local = await tx.store.get(scenario.id);
    // Only apply if no local dirty version or server is newer
    if (!local || !local.dirty || new Date(scenario.updatedAt) > new Date(local.updatedAt)) {
      await tx.store.put({ ...scenario, dirty: false });
    }
  }
  await tx.done;
}

export async function getLastSyncAt(): Promise<string | null> {
  const db = await getDB();
  const meta = await db.get('syncMeta', 'sync');
  return meta?.lastSyncAt ?? null;
}

export async function setLastSyncAt(timestamp: string): Promise<void> {
  const db = await getDB();
  await db.put('syncMeta', { key: 'sync', lastSyncAt: timestamp, userId: '' });
}
