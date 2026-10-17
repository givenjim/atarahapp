import 'server-only';
import { cookies } from 'next/headers';

/**
 * Admin sessions live in httpOnly cookies set by this Next server (the BFF, DEC-018). The browser never
 * sees a token. Mutations are Server Actions, which Next protects with an Origin check, and the cookies are
 * SameSite=Lax, so cross-site requests cannot ride the session.
 */
export const ACCESS_COOKIE = 'atarah_admin_at';
export const REFRESH_COOKIE = 'atarah_admin_rt';
export const CHALLENGE_COOKIE = 'atarah_admin_challenge';
export const RECOVERY_COOKIE = 'atarah_admin_recovery';

const base = {
  httpOnly: true,
  sameSite: 'lax' as const,
  secure: process.env.NODE_ENV === 'production',
  path: '/',
};

export interface TokenPair {
  accessToken: string;
  accessTokenExpiresAt: string;
  refreshToken: string;
  refreshTokenExpiresAt: string;
}

export const cookieOptions = (expiresAt: string) => ({ ...base, expires: new Date(expiresAt) });

export async function setSessionCookies(tokens: TokenPair): Promise<void> {
  const jar = await cookies();
  jar.set(ACCESS_COOKIE, tokens.accessToken, cookieOptions(tokens.accessTokenExpiresAt));
  jar.set(REFRESH_COOKIE, tokens.refreshToken, cookieOptions(tokens.refreshTokenExpiresAt));
  jar.delete(CHALLENGE_COOKIE);
}

export async function clearSessionCookies(): Promise<void> {
  const jar = await cookies();
  jar.delete(ACCESS_COOKIE);
  jar.delete(REFRESH_COOKIE);
  jar.delete(CHALLENGE_COOKIE);
}

export async function setChallengeCookie(token: string, step: string): Promise<void> {
  const jar = await cookies();
  // Five minutes: long enough to open an authenticator app, short enough to be harmless if stolen.
  const options = { ...base, maxAge: 5 * 60 };
  jar.set(CHALLENGE_COOKIE, `${step}:${token}`, options);
}

export async function readChallenge(): Promise<{ step: string; token: string } | null> {
  const raw = (await cookies()).get(CHALLENGE_COOKIE)?.value;
  if (!raw) return null;
  const at = raw.indexOf(':');
  if (at < 1) return null;
  return { step: raw.slice(0, at), token: raw.slice(at + 1) };
}

export async function accessToken(): Promise<string | undefined> {
  return (await cookies()).get(ACCESS_COOKIE)?.value;
}

export async function refreshToken(): Promise<string | undefined> {
  return (await cookies()).get(REFRESH_COOKIE)?.value;
}

/**
 * Recovery codes are shown once, right after enrolment. A cookie (httpOnly, two minutes) carries them to the
 * page that displays them, because a Server Action that sets cookies re-renders the route it was called from.
 */
export async function setRecoveryCookie(codes: string[]): Promise<void> {
  (await cookies()).set(RECOVERY_COOKIE, codes.join(','), { ...base, maxAge: 2 * 60 });
}

export async function readRecoveryCodes(): Promise<string[]> {
  const raw = (await cookies()).get(RECOVERY_COOKIE)?.value;
  return raw ? raw.split(',').filter(Boolean) : [];
}

export async function clearRecoveryCookie(): Promise<void> {
  (await cookies()).delete(RECOVERY_COOKIE);
}
