import { type AccountStatus } from '@prisma/client';

/** Attached to the request by SupabaseAuthGuard. Built from the verified Supabase JWT and `public.users`. */
export interface AuthContext {
  userId: string;
  /** Supabase Auth session id (`auth.sessions.id`): one per device sign-in, stable across token refreshes. */
  sessionId: string;
  status: AccountStatus;
  isAdminSession: boolean;
  /** `aal2` once an MFA factor was verified for this session. Admin routes require it. */
  aal: 'aal1' | 'aal2';
  /** Last time an MFA factor was verified on this session (admin sensitive actions). */
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
