import { describe, it, expect, vi, beforeEach } from 'vitest';
import request from 'supertest';

const { mockQuery } = vi.hoisted(() => ({ mockQuery: vi.fn() }));

vi.mock('../../src/db.js', () => ({
  default: { query: mockQuery },
}));

import { signToken } from '../../src/auth/jwt.js';
import app from '../../src/app.js';

const token = signToken({ userId: 'user-1', email: 'test@test.com' });
const auth = `Bearer ${token}`;

function makeDbRow(overrides: Record<string, unknown> = {}) {
  return {
    id: 'sc-1',
    user_id: 'user-1',
    aircraft_id: 'cessna-172m',
    name: 'Test Flight',
    station_loads: [{ stationId: 'pilot', weight: 170 }],
    fuel_loads: [{ tankId: 'main', gallons: 40 }],
    notes: null,
    created_at: '2026-01-01T00:00:00Z',
    updated_at: '2026-01-01T00:00:00Z',
    deleted_at: null,
    ...overrides,
  };
}

function makeChange(overrides: Record<string, unknown> = {}) {
  return {
    id: 'sc-1',
    aircraftId: 'cessna-172m',
    name: 'Test Flight',
    stationLoads: [{ stationId: 'pilot', weight: 170 }],
    fuelLoads: [{ tankId: 'main', gallons: 40 }],
    updatedAt: '2026-01-02T00:00:00Z',
    deletedAt: null,
    ...overrides,
  };
}

describe('POST /scenarios/sync', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('applyChange conflict resolution', () => {
    it('inserts a new scenario when it does not exist on server', async () => {
      // SELECT returns no existing row
      mockQuery.mockResolvedValueOnce({ rows: [] });
      // INSERT
      mockQuery.mockResolvedValueOnce({ rows: [] });
      // Server changes query
      mockQuery.mockResolvedValueOnce({ rows: [] });

      const res = await request(app)
        .post('/scenarios/sync')
        .set('Authorization', auth)
        .send({ lastSyncAt: null, changes: [makeChange({ id: 'new-1' })] });

      expect(res.status).toBe(200);
      // Verify INSERT was called (second query)
      const insertCall = mockQuery.mock.calls[1];
      expect(insertCall[0]).toContain('INSERT INTO scenarios');
      expect(insertCall[1][0]).toBe('new-1');
    });

    it('skips insert for an already-deleted new scenario', async () => {
      // SELECT returns no existing row
      mockQuery.mockResolvedValueOnce({ rows: [] });
      // Server changes query
      mockQuery.mockResolvedValueOnce({ rows: [] });

      const res = await request(app)
        .post('/scenarios/sync')
        .set('Authorization', auth)
        .send({
          lastSyncAt: null,
          changes: [makeChange({ id: 'del-1', deletedAt: '2026-01-01T00:00:00Z' })],
        });

      expect(res.status).toBe(200);
      // Only 2 queries: SELECT for applyChange + SELECT for serverChanges (no INSERT)
      expect(mockQuery).toHaveBeenCalledTimes(2);
    });

    it('updates existing when client timestamp is newer', async () => {
      // SELECT returns row with older timestamp
      mockQuery.mockResolvedValueOnce({
        rows: [{ updated_at: '2026-01-01T00:00:00Z' }],
      });
      // UPDATE
      mockQuery.mockResolvedValueOnce({ rows: [] });
      // Server changes query
      mockQuery.mockResolvedValueOnce({ rows: [] });

      const res = await request(app)
        .post('/scenarios/sync')
        .set('Authorization', auth)
        .send({
          lastSyncAt: null,
          changes: [makeChange({ updatedAt: '2026-01-02T00:00:00Z' })],
        });

      expect(res.status).toBe(200);
      const updateCall = mockQuery.mock.calls[1];
      expect(updateCall[0]).toContain('UPDATE scenarios SET name');
    });

    it('skips update when server is newer (last-write-wins)', async () => {
      // SELECT returns row with newer timestamp
      mockQuery.mockResolvedValueOnce({
        rows: [{ updated_at: '2026-01-03T00:00:00Z' }],
      });
      // Server changes query
      mockQuery.mockResolvedValueOnce({ rows: [] });

      const res = await request(app)
        .post('/scenarios/sync')
        .set('Authorization', auth)
        .send({
          lastSyncAt: null,
          changes: [makeChange({ updatedAt: '2026-01-02T00:00:00Z' })],
        });

      expect(res.status).toBe(200);
      // Only 2 queries: SELECT for applyChange + SELECT for serverChanges (no UPDATE)
      expect(mockQuery).toHaveBeenCalledTimes(2);
    });

    it('skips update when timestamps are equal (server wins ties)', async () => {
      mockQuery.mockResolvedValueOnce({
        rows: [{ updated_at: '2026-01-01T00:00:00Z' }],
      });
      mockQuery.mockResolvedValueOnce({ rows: [] });

      const res = await request(app)
        .post('/scenarios/sync')
        .set('Authorization', auth)
        .send({
          lastSyncAt: null,
          changes: [makeChange({ updatedAt: '2026-01-01T00:00:00Z' })],
        });

      expect(res.status).toBe(200);
      expect(mockQuery).toHaveBeenCalledTimes(2);
    });

    it('applies soft-delete when client has deletedAt and is newer', async () => {
      mockQuery.mockResolvedValueOnce({
        rows: [{ updated_at: '2026-01-01T00:00:00Z' }],
      });
      mockQuery.mockResolvedValueOnce({ rows: [] });
      mockQuery.mockResolvedValueOnce({ rows: [] });

      const res = await request(app)
        .post('/scenarios/sync')
        .set('Authorization', auth)
        .send({
          lastSyncAt: null,
          changes: [makeChange({ updatedAt: '2026-01-02T00:00:00Z', deletedAt: '2026-01-02T00:00:00Z' })],
        });

      expect(res.status).toBe(200);
      const updateCall = mockQuery.mock.calls[1];
      expect(updateCall[0]).toContain('SET deleted_at');
    });
  });

  describe('serverChanges response', () => {
    it('returns all scenarios when lastSyncAt is null', async () => {
      const row = makeDbRow();
      mockQuery.mockResolvedValueOnce({ rows: [row] });

      const res = await request(app)
        .post('/scenarios/sync')
        .set('Authorization', auth)
        .send({ lastSyncAt: null, changes: [] });

      expect(res.status).toBe(200);
      expect(res.body.serverChanges).toHaveLength(1);
      expect(res.body.serverChanges[0].aircraftId).toBe('cessna-172m');
    });

    it('returns only scenarios updated after lastSyncAt', async () => {
      mockQuery.mockResolvedValueOnce({ rows: [makeDbRow()] });

      const res = await request(app)
        .post('/scenarios/sync')
        .set('Authorization', auth)
        .send({ lastSyncAt: '2026-01-01T00:00:00Z', changes: [] });

      expect(res.status).toBe(200);
      const query = mockQuery.mock.calls[0][0];
      expect(query).toContain('updated_at > $2');
    });

    it('returns syncedAt timestamp', async () => {
      mockQuery.mockResolvedValueOnce({ rows: [] });

      const res = await request(app)
        .post('/scenarios/sync')
        .set('Authorization', auth)
        .send({ lastSyncAt: null, changes: [] });

      expect(res.body.syncedAt).toBeDefined();
      expect(new Date(res.body.syncedAt).getTime()).toBeGreaterThan(0);
    });
  });

  it('returns 401 without auth', async () => {
    const res = await request(app)
      .post('/scenarios/sync')
      .send({ lastSyncAt: null, changes: [] });

    expect(res.status).toBe(401);
  });
});
