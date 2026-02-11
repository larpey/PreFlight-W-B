export interface User {
  id: string;
  email: string;
  name: string | null;
  avatar_url: string | null;
  auth_provider: 'google' | 'magic_link';
  created_at: string;
  last_login: string;
}

export interface Scenario {
  id: string;
  user_id: string;
  aircraft_id: string;
  name: string;
  station_loads: { stationId: string; weight: number }[];
  fuel_loads: { tankId: string; gallons: number }[];
  notes: string | null;
  created_at: string;
  updated_at: string;
  deleted_at: string | null;
}

export interface SyncRequest {
  lastSyncAt: string | null;
  changes: SyncChange[];
}

export interface SyncChange {
  id: string;
  aircraftId: string;
  name: string;
  stationLoads: { stationId: string; weight: number }[];
  fuelLoads: { tankId: string; gallons: number }[];
  notes?: string;
  updatedAt: string;
  deletedAt?: string | null;
}

export interface JwtPayload {
  userId: string;
  email: string;
}
