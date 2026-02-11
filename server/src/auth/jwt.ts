import jwt from 'jsonwebtoken';
import type { JwtPayload } from '../types.js';

const SECRET = process.env.JWT_SECRET ?? 'dev-secret-change-in-production';
const EXPIRY = '90d';

export function signToken(payload: JwtPayload): string {
  return jwt.sign(payload, SECRET, { expiresIn: EXPIRY });
}

export function verifyToken(token: string): JwtPayload {
  return jwt.verify(token, SECRET) as JwtPayload;
}
