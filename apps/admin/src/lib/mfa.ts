import { mfaErrorMessage, signInErrorMessage } from './auth-errors';

/**
 * Sign-in and authenticator steps against Supabase Auth, written against a small structural type so they can
 * be tested with a mock client. Supabase TOTP has no recovery codes: a lost authenticator needs a super admin
 * to remove the factor.
 */
interface AuthError {
  code?: string;
  status?: number;
  message?: string;
}

export interface MfaClient {
  auth: {
    signInWithPassword(c: {
      email: string;
      password: string;
    }): Promise<{ error: AuthError | null }>;
    mfa: {
      getAuthenticatorAssuranceLevel(): Promise<{
        data: { currentLevel: string | null; nextLevel: string | null } | null;
        error: AuthError | null;
      }>;
      listFactors(): Promise<{
        data: {
          totp: { id: string; status: string }[];
          all: { id: string; factor_type: string; status: string }[];
        } | null;
        error: AuthError | null;
      }>;
      enroll(p: { factorType: 'totp'; friendlyName?: string }): Promise<{
        data: { id: string; totp: { qr_code: string; secret: string; uri: string } } | null;
        error: AuthError | null;
      }>;
      unenroll(p: { factorId: string }): Promise<{ error: AuthError | null }>;
      challengeAndVerify(p: {
        factorId: string;
        code: string;
      }): Promise<{ error: AuthError | null }>;
    };
  };
}

export type SignInResult = { ok: true } | { ok: false; error: string };

export async function signInWithPassword(
  client: MfaClient,
  email: string,
  password: string,
): Promise<SignInResult> {
  if (!email || !password) return { ok: false, error: 'Enter your email and password.' };
  const { error } = await client.auth.signInWithPassword({ email, password });
  return error ? { ok: false, error: signInErrorMessage(error) } : { ok: true };
}

export type MfaStep =
  | { step: 'done' }
  /** A verified authenticator exists: ask for a code. */
  | { step: 'verify'; factorId: string }
  /** None yet: show the enrolment screen. */
  | { step: 'enrol' }
  | { step: 'login' };

/** Decides the next screen from the session's assurance level and enrolled factors. */
export async function mfaStep(client: MfaClient): Promise<MfaStep> {
  const { data: aal, error } = await client.auth.mfa.getAuthenticatorAssuranceLevel();
  if (error || !aal) return { step: 'login' };
  if (aal.currentLevel === 'aal2') return { step: 'done' };
  const verified = await verifiedFactorId(client);
  return verified ? { step: 'verify', factorId: verified } : { step: 'enrol' };
}

async function verifiedFactorId(client: MfaClient): Promise<string | null> {
  const { data } = await client.auth.mfa.listFactors();
  // listFactors().totp holds verified TOTP factors only.
  return data?.totp.find((f) => f.status === 'verified')?.id ?? null;
}

export interface Enrolment {
  factorId: string;
  secret: string;
  qrCode: string;
  uri: string;
}

/** Starts enrolment, first discarding unfinished attempts so a page refresh never piles up factors. */
export async function startEnrolment(client: MfaClient): Promise<Enrolment | null> {
  const { data: factors } = await client.auth.mfa.listFactors();
  for (const f of factors?.all ?? []) {
    if (f.factor_type === 'totp' && f.status === 'unverified') {
      await client.auth.mfa.unenroll({ factorId: f.id });
    }
  }
  const { data, error } = await client.auth.mfa.enroll({
    factorType: 'totp',
    friendlyName: 'Authenticator app',
  });
  if (error || !data) return null;
  return {
    factorId: data.id,
    secret: data.totp.secret,
    qrCode: data.totp.qr_code,
    uri: data.totp.uri,
  };
}

export type CodeResult = { ok: true } | { ok: false; error: string };

const CODE = /^\d{6}$/;

/** Verifies a code for a specific factor (sign-in or enrolment). Success raises the session to AAL2. */
export async function verifyCode(
  client: MfaClient,
  factorId: string,
  code: string,
): Promise<CodeResult> {
  const clean = code.replace(/\s/g, '');
  if (!CODE.test(clean))
    return { ok: false, error: 'Enter the 6-digit code from your authenticator app.' };
  const { error } = await client.auth.mfa.challengeAndVerify({ factorId, code: clean });
  return error ? { ok: false, error: mfaErrorMessage(error) } : { ok: true };
}

/**
 * Re-authentication for sensitive actions: verify the signed-in user's own authenticator again. The new
 * access token carries the fresh verification time in its amr claim, which is what the API checks.
 */
export async function reauthenticate(client: MfaClient, code: string): Promise<CodeResult> {
  const factorId = await verifiedFactorId(client);
  if (!factorId) return { ok: false, error: mfaErrorMessage({ code: 'mfa_factor_not_found' }) };
  return verifyCode(client, factorId, code);
}
