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

describe('GET /scenarios', () => {
  beforeEach(() => vi.clearAllMocks());

  it('returns all non-deleted scenarios for the user', async () => {
    mockQuery.mockResolvedValueOnce({ rows: [makeDbRow(), makeDbRow({ id: 'sc-2' })] });

    const res = await request(app)
      .get('/scenarios')
      .set('Authorization', auth);

    expect(res.status).toBe(200);
    expect(res.body).toHaveLength(2);
    expect(res.body[0].aircraftId).toBe('cessna-172m');
  });

  it('filters by since parameter', async () => {
    mockQuery.mockResolvedValueOnce({ rows: [makeDbRow()] });

    const res = await request(app)
      .get('/scenarios?since=2026-01-01T00:00:00Z')
      .set('Authorization', auth);

    expect(res.status).toBe(200);
    const query = mockQuery.mock.calls[0][0];
    expect(query).toContain('updated_at > $2');
  });

  it('formats DB columns to camelCase', async () => {
    mockQuery.mockResolvedValueOnce({ rows: [makeDbRow()] });

    const res = await request(app)
      .get('/scenarios')
      .set('Authorization', auth);

    const scenario = res.body[0];
    expect(scenario).toHaveProperty('aircraftId');
    expect(scenario).toHaveProperty('stationLoads');
    expect(scenario).toHaveProperty('fuelLoads');
    expect(scenario).toHaveProperty('createdAt');
    expect(scenario).toHaveProperty('updatedAt');
    expect(scenario).not.toHaveProperty('aircraft_id');
  });

  it('returns 401 without auth', async () => {
    const res = await request(app).get('/scenarios');
    expect(res.status).toBe(401);
  });
});

describe('POST /scenarios', () => {
  beforeEach(() => vi.clearAllMocks());

  it('creates a scenario and returns 201', async () => {
    mockQuery.mockResolvedValueOnce({ rows: [makeDbRow()] });

    const res = await request(app)
      .post('/scenarios')
      .set('Authorization', auth)
      .send({
        id: 'sc-1',
        aircraftId: 'cessna-172m',
        name: 'Test Flight',
        stationLoads: [{ stationId: 'pilot', weight: 170 }],
        fuelLoads: [{ tankId: 'main', gallons: 40 }],
      });

    expect(res.status).toBe(201);
    expect(res.body.name).toBe('Test Flight');
  });

  it('assigns the authenticated user as owner', async () => {
    mockQuery.mockResolvedValueOnce({ rows: [makeDbRow()] });

    await request(app)
      .post('/scenarios')
      .set('Authorization', auth)
      .send({
        id: 'sc-1',
        aircraftId: 'cessna-172m',
        name: 'Test',
        stationLoads: [],
        fuelLoads: [],
      });

    // Second param should be user-1 (from JWT)
    expect(mockQuery.mock.calls[0][1][1]).toBe('user-1');
  });
});

describe('PUT /scenarios/:id', () => {
  beforeEach(() => vi.clearAllMocks());

  it('updates a scenario owned by the user', async () => {
    mockQuery.mockResolvedValueOnce({ rows: [makeDbRow({ name: 'Updated' })] });

    const res = await request(app)
      .put('/scenarios/sc-1')
      .set('Authorization', auth)
      .send({
        name: 'Updated',
        stationLoads: [],
        fuelLoads: [],
      });

    expect(res.status).toBe(200);
    expect(res.body.name).toBe('Updated');
  });

  it('returns 404 when scenario not found or not owned', async () => {
    mockQuery.mockResolvedValueOnce({ rows: [] });

    const res = await request(app)
      .put('/scenarios/nonexistent')
      .set('Authorization', auth)
      .send({ name: 'X', stationLoads: [], fuelLoads: [] });

    expect(res.status).toBe(404);
  });
});

describe('DELETE /scenarios/:id', () => {
  beforeEach(() => vi.clearAllMocks());

  it('soft-deletes a scenario', async () => {
    mockQuery.mockResolvedValueOnce({ rows: [{ id: 'sc-1' }] });

    const res = await request(app)
      .delete('/scenarios/sc-1')
      .set('Authorization', auth);

    expect(res.status).toBe(200);
    expect(res.body.deleted).toBe(true);

    // Verify it's an UPDATE (soft delete), not a DELETE
    const sql = mockQuery.mock.calls[0][0];
    expect(sql).toContain('UPDATE scenarios SET deleted_at');
    expect(sql).not.toContain('DELETE FROM');
  });

  it('returns 404 when not found', async () => {
    mockQuery.mockResolvedValueOnce({ rows: [] });

    const res = await request(app)
      .delete('/scenarios/nonexistent')
      .set('Authorization', auth);

    expect(res.status).toBe(404);
  });
});
