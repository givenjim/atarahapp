/**
 * Two-step sign-in on a new device (P1-M11). A member who turned two-step on must complete the second-factor challenge
 * (an AAL2 session) on any device that is not known yet before the API accepts anything but the routes the challenge
 * itself needs. Pure so the rule can be tested without a database.
 */
export type TwoStepVerdict = 'OK' | 'CHALLENGE' | 'MARK_VERIFIED';

export interface TwoStepInput {
  /** The member switched two-step on. */
  enabled: boolean;
  /** The platform-wide switch (`auth.two_step_enforced`, default on). */
  enforced: boolean;
  aal: 'aal1' | 'aal2';
  /** The device this session registered with, or null when it has not registered one yet. */
  device: { verifiedAt: Date | null } | null;
}

export function twoStepVerdict(i: TwoStepInput): TwoStepVerdict {
  if (!i.enabled || !i.enforced) return 'OK';
  if (i.aal === 'aal2') return i.device && !i.device.verifiedAt ? 'MARK_VERIFIED' : 'OK';
  return i.device?.verifiedAt ? 'OK' : 'CHALLENGE';
}

/** A device registered while two-step is off, or on a session that already passed the second step, is trusted. */
export const deviceStartsVerified = (twoStepEnabled: boolean, aal: 'aal1' | 'aal2'): boolean =>
  !twoStepEnabled || aal === 'aal2';
