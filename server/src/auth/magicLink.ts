import { randomBytes } from 'node:crypto';
import { Resend } from 'resend';
import pool from '../db.js';

const resend = new Resend(process.env.RESEND_API_KEY ?? '');
const BASE_URL = process.env.MAGIC_LINK_BASE_URL ?? 'http://localhost:5173';
const FROM_EMAIL = process.env.FROM_EMAIL ?? 'noreply@preflight.valderis.com';

export async function sendMagicLink(email: string): Promise<void> {
  const token = randomBytes(32).toString('hex');
  const expiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes

  await pool.query(
    `INSERT INTO magic_links (email, token, expires_at) VALUES ($1, $2, $3)`,
    [email, token, expiresAt]
  );

  const link = `${BASE_URL}/auth/verify?token=${token}`;

  await resend.emails.send({
    from: FROM_EMAIL,
    to: email,
    subject: 'Sign in to PreFlight W&B',
    html: `
      <div style="font-family: -apple-system, BlinkMacSystemFont, sans-serif; max-width: 480px; margin: 0 auto; padding: 40px 20px;">
        <h2 style="color: #000; font-size: 24px; margin-bottom: 16px;">Sign in to PreFlight W&B</h2>
        <p style="color: #666; font-size: 16px; line-height: 1.5; margin-bottom: 24px;">
          Tap the button below to sign in. This link expires in 15 minutes.
        </p>
        <a href="${link}" style="display: inline-block; padding: 14px 32px; background: #007AFF; color: #fff; font-size: 16px; font-weight: 600; text-decoration: none; border-radius: 12px;">
          Sign In
        </a>
        <p style="color: #999; font-size: 13px; margin-top: 32px;">
          If you didn't request this, you can safely ignore this email.
        </p>
      </div>
    `,
  });
}

export async function verifyMagicToken(token: string): Promise<string | null> {
  const result = await pool.query(
    `UPDATE magic_links SET used = true
     WHERE token = $1 AND used = false AND expires_at > now()
     RETURNING email`,
    [token]
  );

  if (result.rows.length === 0) return null;
  return result.rows[0].email;
}
