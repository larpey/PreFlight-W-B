import * as jose from 'jose';

const APPLE_ISSUER = 'https://appleid.apple.com';
const BUNDLE_ID = process.env.APPLE_BUNDLE_ID ?? 'com.valderis.preflightwb';

const JWKS = jose.createRemoteJWKSet(
  new URL('https://appleid.apple.com/auth/keys')
);

export interface AppleUser {
  appleUserId: string;
  email: string | null;
  isPrivateEmail: boolean;
}

export async function verifyAppleToken(identityToken: string): Promise<AppleUser> {
  const { payload } = await jose.jwtVerify(identityToken, JWKS, {
    issuer: APPLE_ISSUER,
    audience: BUNDLE_ID,
  });

  const appleUserId = payload.sub;
  if (!appleUserId) {
    throw new Error('Apple identity token missing sub claim');
  }

  return {
    appleUserId,
    email: (payload.email as string) ?? null,
    isPrivateEmail: (payload.is_private_email as boolean) ?? false,
  };
}
