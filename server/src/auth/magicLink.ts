import { randomInt } from 'node:crypto';
import { Resend } from 'resend';
import pool from '../db.js';

let resend: Resend | null = null;
function getResend(): Resend {
  if (!resend) {
    const key = process.env.RESEND_API_KEY;
    if (!key) throw new Error('RESEND_API_KEY not configured');
    resend = new Resend(key);
  }
  return resend;
}

const FROM_EMAIL = process.env.FROM_EMAIL ?? 'noreply@valderis.com';

function generateCode(): string {
  return String(randomInt(100000, 999999));
}

export async function sendVerificationCode(email: string): Promise<void> {
  const code = generateCode();
  const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

  // Invalidate any existing unused codes for this email
  await pool.query(
    `UPDATE magic_links SET used = true WHERE email = $1 AND used = false`,
    [email]
  );

  await pool.query(
    `INSERT INTO magic_links (email, token, expires_at) VALUES ($1, $2, $3)`,
    [email, code, expiresAt]
  );

  const emailPayload = {
    from: FROM_EMAIL,
    to: email,
    subject: 'Your PreFlight W&B sign-in code',
    html: `
      <div style="font-family: -apple-system, BlinkMacSystemFont, sans-serif; max-width: 480px; margin: 0 auto; padding: 40px 20px;">
        <h2 style="color: #000; font-size: 24px; margin-bottom: 16px;">Your sign-in code</h2>
        <p style="color: #666; font-size: 16px; line-height: 1.5; margin-bottom: 24px;">
          Enter this code in PreFlight W&B to sign in. It expires in 10 minutes.
        </p>
        <div style="background: #F2F2F7; border-radius: 12px; padding: 20px; text-align: center; margin-bottom: 24px;">
          <span style="font-size: 36px; font-weight: 700; letter-spacing: 8px; color: #000;">${code}</span>
        </div>
        <p style="color: #999; font-size: 13px;">
          If you didn't request this, you can safely ignore this email.
        </p>
      </div>
    `,
  };

  const MAX_RETRIES = 3;
  for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
    try {
      await getResend().emails.send(emailPayload);
      return;
    } catch (err) {
      if (attempt === MAX_RETRIES) throw err;
      await new Promise(r => setTimeout(r, 1000 * attempt));
    }
  }
}

export async function verifyCode(email: string, code: string): Promise<boolean> {
  const result = await pool.query(
    `UPDATE magic_links SET used = true
     WHERE email = $1 AND token = $2 AND used = false AND expires_at > now()
     RETURNING email`,
    [email, code]
  );

  return result.rows.length > 0;
}
