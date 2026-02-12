import { describe, it, expect, vi, beforeEach } from 'vitest';
import request from 'supertest';

const { mockQuery } = vi.hoisted(() => ({ mockQuery: vi.fn() }));

vi.mock('../../src/db.js', () => ({
  default: { query: mockQuery },
}));

vi.mock('../../src/auth/google.js', () => ({
  verifyGoogleToken: vi.fn(),
}));

vi.mock('../../src/auth/magicLink.js', () => ({
  sendVerificationCode: vi.fn(),
  verifyCode: vi.fn(),
}));

import { verifyGoogleToken } from '../../src/auth/google.js';
import { sendVerificationCode, verifyCode } from '../../src/auth/magicLink.js';
import { signToken } from '../../src/auth/jwt.js';
import app from '../../src/app.js';

const mockGoogleVerify = vi.mocked(verifyGoogleToken);
const mockSendCode = vi.mocked(sendVerificationCode);
const mockVerifyCode = vi.mocked(verifyCode);

const userRow = {
  id: 'user-1',
  email: 'pilot@example.com',
  name: 'Test Pilot',
  avatar_url: null,
};

describe('POST /auth/google', () => {
  beforeEach(() => vi.clearAllMocks());

  it('returns 400 when idToken is missing', async () => {
    const res = await request(app).post('/auth/google').send({});
    expect(res.status).toBe(400);
  });

  it('returns JWT and user on valid Google token', async () => {
    mockGoogleVerify.mockResolvedValue({ email: 'pilot@example.com', name: 'Test Pilot', avatarUrl: null });
    mockQuery.mockResolvedValueOnce({ rows: [userRow] });

    const res = await request(app)
      .post('/auth/google')
      .send({ idToken: 'valid-google-token' });

    expect(res.status).toBe(200);
    expect(res.body.token).toBeDefined();
    expect(res.body.user.email).toBe('pilot@example.com');
  });

  it('returns 401 when Google token verification fails', async () => {
    mockGoogleVerify.mockRejectedValue(new Error('Invalid token'));

    const res = await request(app)
      .post('/auth/google')
      .send({ idToken: 'bad-token' });

    expect(res.status).toBe(401);
  });
});

describe('POST /auth/magic-link', () => {
  beforeEach(() => vi.clearAllMocks());

  it('returns 400 when email is missing', async () => {
    const res = await request(app).post('/auth/magic-link').send({});
    expect(res.status).toBe(400);
  });

  it('returns sent: true on success', async () => {
    mockSendCode.mockResolvedValue(undefined);

    const res = await request(app)
      .post('/auth/magic-link')
      .send({ email: 'PILOT@Example.com' });

    expect(res.status).toBe(200);
    expect(res.body.sent).toBe(true);
    expect(mockSendCode).toHaveBeenCalledWith('pilot@example.com');
  });

  it('returns 500 when send fails', async () => {
    mockSendCode.mockRejectedValue(new Error('Resend error'));

    const res = await request(app)
      .post('/auth/magic-link')
      .send({ email: 'pilot@example.com' });

    expect(res.status).toBe(500);
  });
});

describe('POST /auth/verify', () => {
  beforeEach(() => vi.clearAllMocks());

  it('returns 400 when email or code is missing', async () => {
    const res = await request(app).post('/auth/verify').send({ email: 'a@b.com' });
    expect(res.status).toBe(400);
  });

  it('returns 401 when code is invalid', async () => {
    mockVerifyCode.mockResolvedValue(false);

    const res = await request(app)
      .post('/auth/verify')
      .send({ email: 'a@b.com', code: '000000' });

    expect(res.status).toBe(401);
  });

  it('returns JWT and user when code is valid', async () => {
    mockVerifyCode.mockResolvedValue(true);
    mockQuery.mockResolvedValueOnce({ rows: [userRow] });

    const res = await request(app)
      .post('/auth/verify')
      .send({ email: 'pilot@example.com', code: '123456' });

    expect(res.status).toBe(200);
    expect(res.body.token).toBeDefined();
    expect(res.body.user.email).toBe('pilot@example.com');
  });
});

describe('GET /auth/me', () => {
  beforeEach(() => vi.clearAllMocks());

  it('returns 401 without auth header', async () => {
    const res = await request(app).get('/auth/me');
    expect(res.status).toBe(401);
  });

  it('returns user profile with valid JWT', async () => {
    const token = signToken({ userId: 'user-1', email: 'pilot@example.com' });
    mockQuery.mockResolvedValueOnce({ rows: [userRow] });

    const res = await request(app)
      .get('/auth/me')
      .set('Authorization', `Bearer ${token}`);

    expect(res.status).toBe(200);
    expect(res.body.email).toBe('pilot@example.com');
  });

  it('returns 404 when user not found in DB', async () => {
    const token = signToken({ userId: 'gone', email: 'gone@example.com' });
    mockQuery.mockResolvedValueOnce({ rows: [] });

    const res = await request(app)
      .get('/auth/me')
      .set('Authorization', `Bearer ${token}`);

    expect(res.status).toBe(404);
  });
});
