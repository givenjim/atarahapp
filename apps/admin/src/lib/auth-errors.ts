/** Maps what Supabase Auth and the API say to wording an administrator can act on. */

interface AuthLikeError {
  code?: string;
  status?: number;
  message?: string;
}

export const GENERIC_SIGN_IN_ERROR =
  'That email and password do not match an administrator account.';

const RATE_LIMITED = 'Too many attempts. Wait a few minutes and try again.';

export function signInErrorMessage(error: AuthLikeError): string {
  switch (error.code) {
    case 'invalid_credentials':
    case 'user_not_found':
      // The same words for both: a wrong password never reveals whether the account exists.
      return GENERIC_SIGN_IN_ERROR;
    case 'email_not_confirmed':
      return 'Confirm your email address before signing in.';
    case 'over_request_rate_limit':
    case 'over_email_send_rate_limit':
      return RATE_LIMITED;
    case 'user_banned':
      return 'This account is suspended.';
    default:
      if (error.status === 429) return RATE_LIMITED;
      if (error.status && error.status >= 500) {
        return 'Sign-in is unavailable right now. Try again shortly.';
      }
      return GENERIC_SIGN_IN_ERROR;
  }
}

export function mfaErrorMessage(error: AuthLikeError): string {
  switch (error.code) {
    case 'mfa_verification_failed':
    case 'mfa_challenge_expired':
      return 'That code is not valid. Check your authenticator app and try the new code.';
    case 'over_request_rate_limit':
      return RATE_LIMITED;
    case 'mfa_factor_not_found':
      return 'No authenticator is set up for this account. Sign in again to set one up.';
    default:
      return error.status === 429 ? RATE_LIMITED : 'We could not check that code. Try again.';
  }
}

/** Why the API turned a session away (error.details.reason). */
export type SessionProblem = 'MFA_REQUIRED' | 'SESSION_IDLE' | 'ADMIN_ONLY' | 'REAUTH_REQUIRED';

export function sessionProblemOf(details: unknown): SessionProblem | null {
  const reason = (details as { reason?: unknown } | undefined)?.reason;
  return reason === 'MFA_REQUIRED' ||
    reason === 'SESSION_IDLE' ||
    reason === 'ADMIN_ONLY' ||
    reason === 'REAUTH_REQUIRED'
    ? reason
    : null;
}

/** Notices on the sign-in page, keyed by `?reason=`. */
export const LOGIN_NOTICES: Record<string, string> = {
  idle: 'You were signed out after 30 minutes of inactivity. Sign in again.',
  'not-admin': 'That account is not an administrator account.',
  expired: 'Your session ended. Sign in again.',
};

/** Where the console sends a session the API has rejected. REAUTH_REQUIRED is handled by the dialog instead. */
export function destinationFor(problem: SessionProblem | null): string {
  switch (problem) {
    case 'MFA_REQUIRED':
      return '/login/totp';
    case 'SESSION_IDLE':
      return '/auth/exit?reason=idle';
    case 'ADMIN_ONLY':
      return '/auth/exit?reason=not-admin';
    default:
      return '/auth/exit?reason=expired';
  }
}

/**
 * Where to send a session the API rejected: the code page for an AAL1 session, sign-in (with a notice) for an
 * idle or non-staff one. Null when the error is about the request (including a re-auth prompt), not the session.
 */
export function sessionRedirect(status: number | undefined, details: unknown): string | null {
  const problem = sessionProblemOf(details);
  if (problem === 'REAUTH_REQUIRED') return null;
  if (problem) return destinationFor(problem);
  return status === 401 ? destinationFor(null) : null;
}
