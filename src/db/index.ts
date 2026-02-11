import { openDB, type DBSchema, type IDBPDatabase } from 'idb';

export interface SavedScenario {
  id: string;
  aircraftId: string;
  name: string;
  stationLoads: { stationId: string; weight: number }[];
  fuelLoads: { tankId: string; gallons: number }[];
  notes?: string;
  createdAt: string;
  updatedAt: string;
  deletedAt?: string;
  dirty: boolean;
}

interface SyncMeta {
  key: string;
  lastSyncAt: string;
  userId: string;
}

interface PreflightDB extends DBSchema {
  scenarios: {
    key: string;
    value: SavedScenario;
    indexes: {
      'by-aircraft': string;
      'by-dirty': number;
    };
  };
  syncMeta: {
    key: string;
    value: SyncMeta;
  };
  auth: {
    key: string;
    value: { key: string; token: string; user: { id: string; email: string; name?: string; avatarUrl?: string } };
  };
}

let dbPromise: Promise<IDBPDatabase<PreflightDB>> | null = null;

export function getDB(): Promise<IDBPDatabase<PreflightDB>> {
  if (!dbPromise) {
    dbPromise = openDB<PreflightDB>('preflight-wb', 1, {
      upgrade(db) {
        const scenarioStore = db.createObjectStore('scenarios', { keyPath: 'id' });
        scenarioStore.createIndex('by-aircraft', 'aircraftId');
        scenarioStore.createIndex('by-dirty', 'dirty');

        db.createObjectStore('syncMeta', { keyPath: 'key' });
        db.createObjectStore('auth', { keyPath: 'key' });
      },
    });
  }
  return dbPromise;
}
