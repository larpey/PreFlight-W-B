import { OAuth2Client } from 'google-auth-library';

const GOOGLE_CLIENT_ID = process.env.GOOGLE_CLIENT_ID ?? '';

const client = new OAuth2Client(GOOGLE_CLIENT_ID);

export interface GoogleUser {
  email: string;
  name: string | null;
  avatarUrl: string | null;
}

export async function verifyGoogleToken(idToken: string): Promise<GoogleUser> {
  const ticket = await client.verifyIdToken({
    idToken,
    audience: GOOGLE_CLIENT_ID,
  });

  const payload = ticket.getPayload();
  if (!payload?.email) {
    throw new Error('Google token missing email');
  }

  return {
    email: payload.email,
    name: payload.name ?? null,
    avatarUrl: payload.picture ?? null,
  };
}
