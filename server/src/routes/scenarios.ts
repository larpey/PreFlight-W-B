import { Router } from 'express';
import pool from '../db.js';
import { requireAuth } from '../auth/middleware.js';
import type { SyncRequest, SyncChange } from '../types.js';

const router = Router();

// All scenario routes require auth
router.use(requireAuth);

// List scenarios
router.get('/', async (req, res) => {
  try {
    const since = req.query.since as string | undefined;
    const userId = req.user!.userId;

    let query: string;
    let params: (string | null)[];

    if (since) {
      query = `SELECT * FROM scenarios WHERE user_id = $1 AND updated_at > $2 ORDER BY updated_at DESC`;
      params = [userId, since];
    } else {
      query = `SELECT * FROM scenarios WHERE user_id = $1 AND deleted_at IS NULL ORDER BY updated_at DESC`;
      params = [userId];
    }

    const result = await pool.query(query, params);
    res.json(result.rows.map(formatScenario));
  } catch (err) {
    console.error('List scenarios error:', err);
    res.status(500).json({ error: 'Failed to list scenarios' });
  }
});

// Create scenario
router.post('/', async (req, res) => {
  try {
    const { id, aircraftId, name, stationLoads, fuelLoads, notes } = req.body;
    const userId = req.user!.userId;

    const result = await pool.query(
      `INSERT INTO scenarios (id, user_id, aircraft_id, name, station_loads, fuel_loads, notes)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING *`,
      [id, userId, aircraftId, name, JSON.stringify(stationLoads), JSON.stringify(fuelLoads), notes ?? null]
    );

    res.status(201).json(formatScenario(result.rows[0]));
  } catch (err) {
    console.error('Create scenario error:', err);
    res.status(500).json({ error: 'Failed to create scenario' });
  }
});

// Update scenario
router.put('/:id', async (req, res) => {
  try {
    const { name, stationLoads, fuelLoads, notes } = req.body;
    const userId = req.user!.userId;

    const result = await pool.query(
      `UPDATE scenarios SET name = $1, station_loads = $2, fuel_loads = $3, notes = $4, updated_at = now()
       WHERE id = $5 AND user_id = $6
       RETURNING *`,
      [name, JSON.stringify(stationLoads), JSON.stringify(fuelLoads), notes ?? null, req.params.id, userId]
    );

    if (result.rows.length === 0) {
      res.status(404).json({ error: 'Scenario not found' });
      return;
    }

    res.json(formatScenario(result.rows[0]));
  } catch (err) {
    console.error('Update scenario error:', err);
    res.status(500).json({ error: 'Failed to update scenario' });
  }
});

// Soft-delete scenario
router.delete('/:id', async (req, res) => {
  try {
    const userId = req.user!.userId;

    const result = await pool.query(
      `UPDATE scenarios SET deleted_at = now(), updated_at = now()
       WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL
       RETURNING id`,
      [req.params.id, userId]
    );

    if (result.rows.length === 0) {
      res.status(404).json({ error: 'Scenario not found' });
      return;
    }

    res.json({ deleted: true });
  } catch (err) {
    console.error('Delete scenario error:', err);
    res.status(500).json({ error: 'Failed to delete scenario' });
  }
});

// Batch sync
router.post('/sync', async (req, res) => {
  try {
    const { lastSyncAt, changes } = req.body as SyncRequest;
    const userId = req.user!.userId;
    const syncedAt = new Date().toISOString();

    // Apply client changes
    for (const change of changes) {
      await applyChange(userId, change);
    }

    // Fetch server changes since last sync
    let serverChanges;
    if (lastSyncAt) {
      const result = await pool.query(
        `SELECT * FROM scenarios WHERE user_id = $1 AND updated_at > $2 ORDER BY updated_at`,
        [userId, lastSyncAt]
      );
      serverChanges = result.rows.map(formatScenario);
    } else {
      const result = await pool.query(
        `SELECT * FROM scenarios WHERE user_id = $1 ORDER BY updated_at`,
        [userId]
      );
      serverChanges = result.rows.map(formatScenario);
    }

    res.json({ serverChanges, syncedAt });
  } catch (err) {
    console.error('Sync error:', err);
    res.status(500).json({ error: 'Sync failed' });
  }
});

async function applyChange(userId: string, change: SyncChange): Promise<void> {
  const existing = await pool.query(
    `SELECT updated_at FROM scenarios WHERE id = $1 AND user_id = $2`,
    [change.id, userId]
  );

  if (existing.rows.length > 0) {
    // Conflict resolution: last-write-wins
    const serverTime = new Date(existing.rows[0].updated_at).getTime();
    const clientTime = new Date(change.updatedAt).getTime();
    if (clientTime <= serverTime) return; // Server version is newer, skip

    if (change.deletedAt) {
      await pool.query(
        `UPDATE scenarios SET deleted_at = $1, updated_at = $2 WHERE id = $3 AND user_id = $4`,
        [change.deletedAt, change.updatedAt, change.id, userId]
      );
    } else {
      await pool.query(
        `UPDATE scenarios SET name = $1, aircraft_id = $2, station_loads = $3, fuel_loads = $4, notes = $5, updated_at = $6
         WHERE id = $7 AND user_id = $8`,
        [change.name, change.aircraftId, JSON.stringify(change.stationLoads), JSON.stringify(change.fuelLoads), change.notes ?? null, change.updatedAt, change.id, userId]
      );
    }
  } else {
    // New scenario from client
    if (!change.deletedAt) {
      await pool.query(
        `INSERT INTO scenarios (id, user_id, aircraft_id, name, station_loads, fuel_loads, notes, updated_at)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
        [change.id, userId, change.aircraftId, change.name, JSON.stringify(change.stationLoads), JSON.stringify(change.fuelLoads), change.notes ?? null, change.updatedAt]
      );
    }
  }
}

function formatScenario(row: Record<string, unknown>) {
  return {
    id: row.id,
    aircraftId: row.aircraft_id,
    name: row.name,
    stationLoads: row.station_loads,
    fuelLoads: row.fuel_loads,
    notes: row.notes,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
    deletedAt: row.deleted_at,
  };
}

export default router;
