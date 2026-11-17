import { describe, expect, it, vi } from 'vitest';
import {
  mfaStep,
  reauthenticate,
  signInWithPassword,
  startEnrolment,
  verifyCode,
  type MfaClient,
} from './mfa';

interface Factor {
  id: string;
  factor_type: string;
  status: string;
}

function client(over: {
  signIn?: { error: { code?: string; status?: number } | null };
  aal?: { currentLevel: string; nextLevel: string } | null;
  totp?: { id: string; status: string }[];
  all?: Factor[];
  verifyError?: { code?: string } | null;
}) {
  const mfa = {
    getAuthenticatorAssuranceLevel: vi.fn(async () => ({
      data: over.aal === undefined ? { currentLevel: 'aal1', nextLevel: 'aal1' } : over.aal,
      error: null,
    })),
    listFactors: vi.fn(async () => ({
      data: {
        totp: over.totp ?? [],
        all: over.all ?? (over.totp ?? []).map((f) => ({ ...f, factor_type: 'totp' })),
      },
      error: null,
    })),
    enroll: vi.fn(async () => ({
      data: {
        id: 'new-factor',
        totp: { qr_code: 'data:image/svg+xml;utf8,<svg/>', secret: 'ABC', uri: 'otpauth://x' },
      },
      error: null,
    })),
    unenroll: vi.fn(async () => ({ error: null })),
    challengeAndVerify: vi.fn(async () => ({ error: over.verifyError ?? null })),
  };
  const signIn = vi.fn(async () => over.signIn ?? { error: null });
  const c = { auth: { signInWithPassword: signIn, mfa } };
  return { c: c as unknown as MfaClient, mfa, signIn };
}

describe('signInWithPassword', () => {
  it('requires both fields without calling Supabase', async () => {
    const { c, signIn } = client({});
    expect(await signInWithPassword(c, '', 'x')).toEqual({
      ok: false,
      error: 'Enter your email and password.',
    });
    expect(signIn).not.toHaveBeenCalled();
  });
  it('maps a rejected password to the generic message', async () => {
    const { c } = client({ signIn: { error: { code: 'invalid_credentials' } } });
    const r = await signInWithPassword(c, 'a@b.c', 'bad');
    expect(r).toMatchObject({ ok: false, error: expect.stringContaining('do not match') });
  });
  it('succeeds with valid credentials', async () => {
    const { c } = client({});
    expect(await signInWithPassword(c, 'a@b.c', 'pw')).toEqual({ ok: true });
  });
});

describe('mfaStep (AAL handling)', () => {
  it('is done at AAL2', async () => {
    const { c } = client({ aal: { currentLevel: 'aal2', nextLevel: 'aal2' } });
    expect(await mfaStep(c)).toEqual({ step: 'done' });
  });
  it('asks for a code at AAL1 when a verified factor exists', async () => {
    const { c } = client({
      aal: { currentLevel: 'aal1', nextLevel: 'aal2' },
      totp: [{ id: 'f1', status: 'verified' }],
    });
    expect(await mfaStep(c)).toEqual({ step: 'verify', factorId: 'f1' });
  });
  it('enrols when there is no verified factor (an unverified one does not count)', async () => {
    const { c } = client({
      aal: { currentLevel: 'aal1', nextLevel: 'aal1' },
      totp: [{ id: 'f9', status: 'unverified' }],
    });
    expect(await mfaStep(c)).toEqual({ step: 'enrol' });
  });
  it('goes back to sign-in without a session', async () => {
    const { c } = client({ aal: null });
    expect(await mfaStep(c)).toEqual({ step: 'login' });
  });
});

describe('startEnrolment', () => {
  it('discards unfinished attempts, then enrols a fresh TOTP factor', async () => {
    const { c, mfa } = client({
      all: [
        { id: 'old', factor_type: 'totp', status: 'unverified' },
        { id: 'keep', factor_type: 'totp', status: 'verified' },
      ],
    });
    const e = await startEnrolment(c);
    expect(mfa.unenroll).toHaveBeenCalledTimes(1);
    expect(mfa.unenroll).toHaveBeenCalledWith({ factorId: 'old' });
    expect(e).toMatchObject({ factorId: 'new-factor', secret: 'ABC' });
  });
});

describe('verifyCode and reauthenticate', () => {
  it('rejects a malformed code without a network call', async () => {
    const { c, mfa } = client({});
    const r = await verifyCode(c, 'f1', '12 34');
    expect(r.ok).toBe(false);
    expect(mfa.challengeAndVerify).not.toHaveBeenCalled();
  });
  it('strips spaces and verifies', async () => {
    const { c, mfa } = client({});
    expect(await verifyCode(c, 'f1', '123 456')).toEqual({ ok: true });
    expect(mfa.challengeAndVerify).toHaveBeenCalledWith({ factorId: 'f1', code: '123456' });
  });
  it('maps a wrong code', async () => {
    const { c } = client({ verifyError: { code: 'mfa_verification_failed' } });
    expect(await verifyCode(c, 'f1', '123456')).toMatchObject({
      ok: false,
      error: expect.stringContaining('not valid'),
    });
  });
  it('re-authenticates against the verified factor', async () => {
    const { c, mfa } = client({ totp: [{ id: 'f1', status: 'verified' }] });
    expect(await reauthenticate(c, '654321')).toEqual({ ok: true });
    expect(mfa.challengeAndVerify).toHaveBeenCalledWith({ factorId: 'f1', code: '654321' });
  });
  it('cannot re-authenticate without an authenticator', async () => {
    const { c } = client({ totp: [] });
    expect(await reauthenticate(c, '654321')).toMatchObject({ ok: false });
  });
});
