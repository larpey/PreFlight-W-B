import { describe, it, expect, vi, beforeEach } from 'vitest';
import { syncScenarios } from '../../src/services/sync';
import type { SavedScenario } from '../../src/db';

vi.mock('../../src/db/scenarios', () => ({
  getDirtyScenarios: vi.fn(),
  markClean: vi.fn(),
  applySyncedScenarios: vi.fn(),
  getLastSyncAt: vi.fn(),
  setLastSyncAt: vi.fn(),
}));

vi.mock('../../src/services/api', () => ({
  apiFetch: vi.fn(),
}));

import {
  getDirtyScenarios,
  markClean,
  applySyncedScenarios,
  getLastSyncAt,
  setLastSyncAt,
} from '../../src/db/scenarios';
import { apiFetch } from '../../src/services/api';

const mockGetDirty = vi.mocked(getDirtyScenarios);
const mockMarkClean = vi.mocked(markClean);
const mockApplySync = vi.mocked(applySyncedScenarios);
const mockGetLastSync = vi.mocked(getLastSyncAt);
const mockSetLastSync = vi.mocked(setLastSyncAt);
const mockApiFetch = vi.mocked(apiFetch);

function makeScenario(overrides: Partial<SavedScenario> = {}): SavedScenario {
  return {
    id: 'sc-1',
    aircraftId: 'cessna-172m',
    name: 'Test Flight',
    stationLoads: [{ stationId: 'pilot', weight: 170 }],
    fuelLoads: [{ tankId: 'main', gallons: 40 }],
    createdAt: '2026-01-01T00:00:00Z',
    updatedAt: '2026-01-01T00:00:00Z',
    dirty: true,
    ...overrides,
  };
}

describe('syncScenarios', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockGetLastSync.mockResolvedValue('2026-01-01T00:00:00Z');
  });

  it('sends dirty scenarios to the server and marks them clean', async () => {
    const dirty = [makeScenario({ id: 'sc-1' }), makeScenario({ id: 'sc-2' })];
    mockGetDirty.mockResolvedValue(dirty);
    mockApiFetch.mockResolvedValue({ serverChanges: [], syncedAt: '2026-01-02T00:00:00Z' });

    await syncScenarios();

    expect(mockApiFetch).toHaveBeenCalledWith('/scenarios/sync', {
      method: 'POST',
      body: expect.stringContaining('"sc-1"'),
    });
    expect(mockMarkClean).toHaveBeenCalledWith(['sc-1', 'sc-2']);
  });

  it('applies server changes locally', async () => {
    mockGetDirty.mockResolvedValue([]);
    const serverScenario = makeScenario({ id: 'server-1', dirty: false });
    mockApiFetch.mockResolvedValue({ serverChanges: [serverScenario], syncedAt: '2026-01-02T00:00:00Z' });

    await syncScenarios();

    expect(mockApplySync).toHaveBeenCalledWith([serverScenario]);
  });

  it('does not call markClean when there are no dirty scenarios', async () => {
    mockGetDirty.mockResolvedValue([]);
    mockApiFetch.mockResolvedValue({ serverChanges: [], syncedAt: '2026-01-02T00:00:00Z' });

    await syncScenarios();

    expect(mockMarkClean).not.toHaveBeenCalled();
  });

  it('does not call applySyncedScenarios when server returns no changes', async () => {
    mockGetDirty.mockResolvedValue([]);
    mockApiFetch.mockResolvedValue({ serverChanges: [], syncedAt: '2026-01-02T00:00:00Z' });

    await syncScenarios();

    expect(mockApplySync).not.toHaveBeenCalled();
  });

  it('returns count of total synced items', async () => {
    mockGetDirty.mockResolvedValue([makeScenario({ id: 'sc-1' }), makeScenario({ id: 'sc-2' })]);
    mockApiFetch.mockResolvedValue({
      serverChanges: [makeScenario({ id: 'server-1', dirty: false })],
      syncedAt: '2026-01-02T00:00:00Z',
    });

    const result = await syncScenarios();

    expect(result.synced).toBe(3);
  });

  it('updates lastSyncAt after sync', async () => {
    mockGetDirty.mockResolvedValue([]);
    mockApiFetch.mockResolvedValue({ serverChanges: [], syncedAt: '2026-02-01T00:00:00Z' });

    await syncScenarios();

    expect(mockSetLastSync).toHaveBeenCalledWith('2026-02-01T00:00:00Z');
  });

  it('propagates apiFetch errors', async () => {
    mockGetDirty.mockResolvedValue([]);
    mockGetLastSync.mockResolvedValue(null);
    mockApiFetch.mockRejectedValue(new Error('Network error'));

    await expect(syncScenarios()).rejects.toThrow('Network error');
  });
});
