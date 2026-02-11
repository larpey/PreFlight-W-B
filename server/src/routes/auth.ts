import { Router } from 'express';
import pool from '../db.js';
import { signToken } from '../auth/jwt.js';
import { verifyGoogleToken } from '../auth/google.js';
import { sendVerificationCode, verifyCode } from '../auth/magicLink.js';
import { requireAuth } from '../auth/middleware.js';

const router = Router();

// Exchange Google ID token for JWT
router.post('/google', async (req, res) => {
  try {
    const { idToken } = req.body;
    if (!idToken) {
      res.status(400).json({ error: 'Missing idToken' });
      return;
    }

    const googleUser = await verifyGoogleToken(idToken);

    // Upsert user
    const result = await pool.query(
      `INSERT INTO users (email, name, avatar_url, auth_provider)
       VALUES ($1, $2, $3, 'google')
       ON CONFLICT (email) DO UPDATE SET
         name = COALESCE(EXCLUDED.name, users.name),
         avatar_url = COALESCE(EXCLUDED.avatar_url, users.avatar_url),
         last_login = now()
       RETURNING id, email, name, avatar_url`,
      [googleUser.email, googleUser.name, googleUser.avatarUrl]
    );

    const user = result.rows[0];
    const token = signToken({ userId: user.id, email: user.email });

    res.json({
      token,
      user: { id: user.id, email: user.email, name: user.name, avatarUrl: user.avatar_url },
    });
  } catch (err) {
    console.error('Google auth error:', err);
    res.status(401).json({ error: 'Invalid Google token' });
  }
});

// Send verification code email
router.post('/magic-link', async (req, res) => {
  try {
    const { email } = req.body;
    if (!email || typeof email !== 'string') {
      res.status(400).json({ error: 'Missing email' });
      return;
    }

    await sendVerificationCode(email.toLowerCase().trim());
    res.json({ sent: true });
  } catch (err) {
    console.error('Send code error:', err);
    res.status(500).json({ error: 'Failed to send verification code' });
  }
});

// Verify 6-digit code → JWT
router.post('/verify', async (req, res) => {
  try {
    const { email, code } = req.body;
    if (!email || !code) {
      res.status(400).json({ error: 'Missing email or code' });
      return;
    }

    const valid = await verifyCode(email.toLowerCase().trim(), code.trim());
    if (!valid) {
      res.status(401).json({ error: 'Invalid or expired code' });
      return;
    }

    // Upsert user
    const result = await pool.query(
      `INSERT INTO users (email, auth_provider)
       VALUES ($1, 'magic_link')
       ON CONFLICT (email) DO UPDATE SET last_login = now()
       RETURNING id, email, name, avatar_url`,
      [email.toLowerCase().trim()]
    );

    const user = result.rows[0];
    const jwt = signToken({ userId: user.id, email: user.email });

    res.json({
      token: jwt,
      user: { id: user.id, email: user.email, name: user.name, avatarUrl: user.avatar_url },
    });
  } catch (err) {
    console.error('Verify error:', err);
    res.status(500).json({ error: 'Verification failed' });
  }
});

// Get current user profile
router.get('/me', requireAuth, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT id, email, name, avatar_url FROM users WHERE id = $1`,
      [req.user!.userId]
    );

    if (result.rows.length === 0) {
      res.status(404).json({ error: 'User not found' });
      return;
    }

    const user = result.rows[0];
    res.json({ id: user.id, email: user.email, name: user.name, avatarUrl: user.avatar_url });
  } catch (err) {
    console.error('Get user error:', err);
    res.status(500).json({ error: 'Failed to get user' });
  }
});

export default router;
