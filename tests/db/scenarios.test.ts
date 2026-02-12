import { describe, it, expect, beforeEach } from 'vitest';
import {
  saveScenario,
  getScenario,
  listScenarios,
  deleteScenario,
  getDirtyScenarios,
  markClean,
  applySyncedScenarios,
  getLastSyncAt,
  setLastSyncAt,
} from '../../src/db/scenarios';
import { getDB, type SavedScenario } from '../../src/db';

function makeScenario(overrides: Partial<SavedScenario> = {}): SavedScenario {
  return {
    id: 'sc-1',
    aircraftId: 'cessna-172m',
    name: 'Test Flight',
    stationLoads: [{ stationId: 'pilot', weight: 170 }],
    fuelLoads: [{ tankId: 'main', gallons: 40 }],
    createdAt: '2026-01-01T00:00:00Z',
    updatedAt: '2026-01-01T00:00:00Z',
    dirty: false,
    ...overrides,
  };
}

beforeEach(async () => {
  const db = await getDB();
  const tx = db.transaction(['scenarios', 'syncMeta'], 'readwrite');
  await tx.objectStore('scenarios').clear();
  await tx.objectStore('syncMeta').clear();
  await tx.done;
});

describe('saveScenario / getScenario', () => {
  it('saves and retrieves a scenario by id', async () => {
    const scenario = makeScenario();
    await saveScenario(scenario);

    const result = await getScenario('sc-1');
    expect(result).toBeDefined();
    expect(result!.name).toBe('Test Flight');
    expect(result!.aircraftId).toBe('cessna-172m');
  });

  it('overwrites an existing scenario with same id', async () => {
    await saveScenario(makeScenario({ name: 'Original' }));
    await saveScenario(makeScenario({ name: 'Updated' }));

    const result = await getScenario('sc-1');
    expect(result!.name).toBe('Updated');
  });

  it('returns undefined for nonexistent id', async () => {
    const result = await getScenario('nonexistent');
    expect(result).toBeUndefined();
  });
});

describe('listScenarios', () => {
  it('returns all non-deleted scenarios sorted newest first', async () => {
    await saveScenario(makeScenario({ id: 'sc-1', updatedAt: '2026-01-01T00:00:00Z' }));
    await saveScenario(makeScenario({ id: 'sc-2', updatedAt: '2026-01-03T00:00:00Z' }));
    await saveScenario(makeScenario({ id: 'sc-3', updatedAt: '2026-01-02T00:00:00Z' }));

    const result = await listScenarios();
    expect(result).toHaveLength(3);
    expect(result[0].id).toBe('sc-2');
    expect(result[1].id).toBe('sc-3');
    expect(result[2].id).toBe('sc-1');
  });

  it('filters by aircraftId when provided', async () => {
    await saveScenario(makeScenario({ id: 'sc-1', aircraftId: 'cessna-172m' }));
    await saveScenario(makeScenario({ id: 'sc-2', aircraftId: 'bonanza-a36' }));
    await saveScenario(makeScenario({ id: 'sc-3', aircraftId: 'cessna-172m' }));

    const result = await listScenarios('cessna-172m');
    expect(result).toHaveLength(2);
    expect(result.every(s => s.aircraftId === 'cessna-172m')).toBe(true);
  });

  it('excludes soft-deleted scenarios', async () => {
    await saveScenario(makeScenario({ id: 'sc-1' }));
    await saveScenario(makeScenario({ id: 'sc-2', deletedAt: '2026-01-02T00:00:00Z' }));

    const result = await listScenarios();
    expect(result).toHaveLength(1);
    expect(result[0].id).toBe('sc-1');
  });
});

describe('deleteScenario', () => {
  it('soft-deletes by setting deletedAt and marking dirty', async () => {
    await saveScenario(makeScenario({ id: 'sc-1', dirty: false }));
    await deleteScenario('sc-1');

    const result = await getScenario('sc-1');
    expect(result).toBeDefined();
    expect(result!.deletedAt).toBeTruthy();
    expect(result!.dirty).toBe(true);
  });

  it('is a no-op for nonexistent id', async () => {
    await expect(deleteScenario('nonexistent')).resolves.toBeUndefined();
  });
});

describe('getDirtyScenarios', () => {
  it('returns only scenarios with dirty: true', async () => {
    await saveScenario(makeScenario({ id: 'sc-1', dirty: true }));
    await saveScenario(makeScenario({ id: 'sc-2', dirty: false }));

    const result = await getDirtyScenarios();
    expect(result).toHaveLength(1);
    expect(result[0].id).toBe('sc-1');
  });
});

describe('markClean', () => {
  it('sets dirty to false for specified ids', async () => {
    await saveScenario(makeScenario({ id: 'sc-1', dirty: true }));
    await saveScenario(makeScenario({ id: 'sc-2', dirty: true }));

    await markClean(['sc-1']);

    const dirty = await getDirtyScenarios();
    expect(dirty).toHaveLength(1);
    expect(dirty[0].id).toBe('sc-2');
  });
});

describe('applySyncedScenarios', () => {
  it('inserts new scenarios from server with dirty: false', async () => {
    const server = makeScenario({ id: 'server-1', name: 'From Server' });
    await applySyncedScenarios([server]);

    const result = await getScenario('server-1');
    expect(result).toBeDefined();
    expect(result!.name).toBe('From Server');
    expect(result!.dirty).toBe(false);
  });

  it('overwrites local non-dirty scenario with server version', async () => {
    await saveScenario(makeScenario({ id: 'sc-1', name: 'Local', dirty: false, updatedAt: '2026-01-01T00:00:00Z' }));

    await applySyncedScenarios([
      makeScenario({ id: 'sc-1', name: 'Server', updatedAt: '2026-01-02T00:00:00Z' }),
    ]);

    const result = await getScenario('sc-1');
    expect(result!.name).toBe('Server');
  });

  it('overwrites local dirty scenario when server is newer', async () => {
    await saveScenario(makeScenario({ id: 'sc-1', name: 'Local Dirty', dirty: true, updatedAt: '2026-01-01T00:00:00Z' }));

    await applySyncedScenarios([
      makeScenario({ id: 'sc-1', name: 'Server Newer', updatedAt: '2026-01-02T00:00:00Z' }),
    ]);

    const result = await getScenario('sc-1');
    expect(result!.name).toBe('Server Newer');
    expect(result!.dirty).toBe(false);
  });

  it('preserves local dirty scenario when local is newer', async () => {
    await saveScenario(makeScenario({ id: 'sc-1', name: 'Local Newer', dirty: true, updatedAt: '2026-01-02T00:00:00Z' }));

    await applySyncedScenarios([
      makeScenario({ id: 'sc-1', name: 'Server Older', updatedAt: '2026-01-01T00:00:00Z' }),
    ]);

    const result = await getScenario('sc-1');
    expect(result!.name).toBe('Local Newer');
    expect(result!.dirty).toBe(true);
  });
});

describe('getLastSyncAt / setLastSyncAt', () => {
  it('returns null when no sync has occurred', async () => {
    const result = await getLastSyncAt();
    expect(result).toBeNull();
  });

  it('round-trips a timestamp', async () => {
    await setLastSyncAt('2026-02-10T12:00:00Z');
    const result = await getLastSyncAt();
    expect(result).toBe('2026-02-10T12:00:00Z');
  });
});
