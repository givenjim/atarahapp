import { type AccountStatus } from '@prisma/client';

/** Claims inside a short-lived access token. */
export interface AccessClaims {
  sub: string;
  /** Session family id. Identifies the device session across refresh-token rotations. */
  fam: string;
  /** True only for tokens issued by the admin sign-in flow. */
  adm: boolean;
  /** True once TOTP was verified. Admin tokens are never issued without it. */
  mfa: boolean;
  typ: 'access';
}

/** Short-lived token between the admin password step and the TOTP step. Grants no API access. */
export interface AdminChallengeClaims {
  sub: string;
  typ: 'admin-challenge';
  /** True when the account has not confirmed TOTP yet and must enrol. */
  enrol: boolean;
}

/** Attached to the request by JwtAuthGuard. */
export interface AuthContext {
  userId: string;
  familyId: string;
  status: AccountStatus;
  isAdminSession: boolean;
  /** Last password+TOTP re-authentication on this session. */
  reauthAt: Date | null;
}

declare global {
  // eslint-disable-next-line @typescript-eslint/no-namespace
  namespace Express {
    interface Request {
      auth?: AuthContext;
    }
  }
}
