import { describe, expect, it } from 'vitest';
import {
  GENERIC_SIGN_IN_ERROR,
  mfaErrorMessage,
  sessionProblemOf,
  sessionRedirect,
  signInErrorMessage,
} from './auth-errors';

describe('signInErrorMessage', () => {
  it('uses the same words for a wrong password and an unknown account', () => {
    expect(signInErrorMessage({ code: 'invalid_credentials' })).toBe(GENERIC_SIGN_IN_ERROR);
    expect(signInErrorMessage({ code: 'user_not_found' })).toBe(GENERIC_SIGN_IN_ERROR);
  });
  it('explains rate limits and outages', () => {
    expect(signInErrorMessage({ status: 429 })).toMatch(/Too many attempts/);
    expect(signInErrorMessage({ status: 503 })).toMatch(/unavailable/);
  });
});

describe('mfaErrorMessage', () => {
  it('tells the user a wrong code is not valid', () => {
    expect(mfaErrorMessage({ code: 'mfa_verification_failed' })).toMatch(/not valid/);
  });
  it('maps a missing factor and rate limits', () => {
    expect(mfaErrorMessage({ code: 'mfa_factor_not_found' })).toMatch(/Sign in again/);
    expect(mfaErrorMessage({ status: 429 })).toMatch(/Too many attempts/);
  });
});

describe('API session problems', () => {
  it('reads error.details.reason', () => {
    expect(sessionProblemOf({ reason: 'MFA_REQUIRED' })).toBe('MFA_REQUIRED');
    expect(sessionProblemOf({ reason: 'nonsense' })).toBeNull();
    expect(sessionProblemOf(undefined)).toBeNull();
  });
  it('sends MFA_REQUIRED to the code page, idle and non-staff to sign-in with a notice', () => {
    expect(sessionRedirect(403, { reason: 'MFA_REQUIRED' })).toBe('/login/totp');
    expect(sessionRedirect(401, { reason: 'SESSION_IDLE' })).toBe('/auth/exit?reason=idle');
    expect(sessionRedirect(403, { reason: 'ADMIN_ONLY' })).toBe('/auth/exit?reason=not-admin');
  });
  it('leaves REAUTH_REQUIRED to the dialog and plain request errors alone', () => {
    expect(sessionRedirect(401, { reason: 'REAUTH_REQUIRED' })).toBeNull();
    expect(sessionRedirect(403, undefined)).toBeNull();
    expect(sessionRedirect(404, undefined)).toBeNull();
  });
  it('treats an unexplained 401 as an ended session', () => {
    expect(sessionRedirect(401, undefined)).toBe('/auth/exit?reason=expired');
  });
});
