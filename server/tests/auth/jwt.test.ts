import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import jwt from 'jsonwebtoken';
import { signToken, verifyToken } from '../../src/auth/jwt.js';

const TEST_SECRET = 'test-jwt-secret-for-tests';

describe('JWT helpers', () => {
  let originalSecret: string | undefined;

  beforeEach(() => {
    originalSecret = process.env.JWT_SECRET;
    process.env.JWT_SECRET = TEST_SECRET;
  });

  afterEach(() => {
    if (originalSecret !== undefined) {
      process.env.JWT_SECRET = originalSecret;
    } else {
      delete process.env.JWT_SECRET;
    }
  });

  describe('signToken + verifyToken round-trip', () => {
    it('returns the original payload', () => {
      const payload = { userId: 'user-1', email: 'pilot@example.com' };
      const token = signToken(payload);
      const decoded = verifyToken(token);

      expect(decoded.userId).toBe('user-1');
      expect(decoded.email).toBe('pilot@example.com');
    });

    it('includes iat and exp claims', () => {
      const token = signToken({ userId: 'u', email: 'e@e.com' });
      const decoded = verifyToken(token);

      expect(decoded).toHaveProperty('iat');
      expect(decoded).toHaveProperty('exp');
    });
  });

  describe('verifyToken error cases', () => {
    it('throws on a tampered token', () => {
      const token = signToken({ userId: 'u', email: 'e@e.com' });
      const tampered = token.slice(0, -4) + 'XXXX';

      expect(() => verifyToken(tampered)).toThrow();
    });

    it('throws on an expired token', () => {
      // Sign with 0 seconds expiry using jsonwebtoken directly
      const token = jwt.sign(
        { userId: 'u', email: 'e@e.com' },
        TEST_SECRET,
        { expiresIn: '0s' }
      );

      expect(() => verifyToken(token)).toThrow();
    });

    it('throws when secret does not match', () => {
      const token = jwt.sign(
        { userId: 'u', email: 'e@e.com' },
        'different-secret',
        { expiresIn: '1h' }
      );

      expect(() => verifyToken(token)).toThrow();
    });
  });
});
