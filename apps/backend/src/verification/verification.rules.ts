import { createHash, randomBytes } from 'node:crypto';
import {
  type VerificationEvidenceType,
  type VerificationStatus,
  type VerificationSubjectType,
} from '@prisma/client';

/**
 * Pure rules for verification cases (P2-M6, DEC-150): the state machine, requirement checks, working-day arithmetic and
 * the reference token. Nothing here touches the database.
 */

/** Statuses a member can still change evidence in. */
export const OPEN_STATUSES: readonly VerificationStatus[] = ['NOT_SUBMITTED', 'SUBMITTED', 'UNDER_REVIEW'];
/** Statuses that count as in front of a reviewer. */
export const REVIEW_STATUSES: readonly VerificationStatus[] = ['SUBMITTED', 'UNDER_REVIEW'];
/** Case types a member can apply for today. The others are decided by staff through the same case model. */
export const MEMBER_SUBJECTS: readonly VerificationSubjectType[] = ['CREATIVE_IDENTITY', 'SKILL'];

export type CaseAction =
  | 'SUBMIT'
  | 'RESUBMIT'
  | 'CLAIM'
  | 'RELEASE'
  | 'REQUEST_INFO'
  | 'APPROVE'
  | 'REJECT'
  | 'REVOKE'
  | 'EXPIRE';

/** The allowed moves of the state machine: action, from status, to status. */
export const TRANSITIONS: Readonly<Record<CaseAction, { from: readonly VerificationStatus[]; to: VerificationStatus }>> = {
  SUBMIT: { from: ['NOT_SUBMITTED'], to: 'SUBMITTED' },
  // A reviewer asked for more; the applicant answers and the case goes back in front of the same reviewer.
  RESUBMIT: { from: ['UNDER_REVIEW'], to: 'UNDER_REVIEW' },
  CLAIM: { from: ['SUBMITTED'], to: 'UNDER_REVIEW' },
  RELEASE: { from: ['UNDER_REVIEW'], to: 'SUBMITTED' },
  REQUEST_INFO: { from: ['UNDER_REVIEW'], to: 'UNDER_REVIEW' },
  APPROVE: { from: ['UNDER_REVIEW'], to: 'VERIFIED' },
  REJECT: { from: ['UNDER_REVIEW'], to: 'REJECTED' },
  REVOKE: { from: ['VERIFIED'], to: 'REVOKED' },
  EXPIRE: { from: ['VERIFIED'], to: 'EXPIRED' },
};

export const canDo = (action: CaseAction, status: VerificationStatus): boolean =>
  TRANSITIONS[action].from.includes(status);

export const nextStatus = (action: CaseAction): VerificationStatus => TRANSITIONS[action].to;

export interface RequirementRow {
  key: string;
  label: string;
  description: string;
  evidenceTypes: readonly VerificationEvidenceType[];
  minCount: number;
}

export interface RequirementState {
  key: string;
  label: string;
  description: string;
  minCount: number;
  count: number;
  met: boolean;
}

/** Each requirement is met when enough evidence of the types it accepts is attached. Evidence is counted once per row. */
export function evaluateRequirements(
  requirements: readonly RequirementRow[],
  evidenceTypes: readonly VerificationEvidenceType[],
): RequirementState[] {
  return requirements.map((r) => {
    const count = evidenceTypes.filter((t) => r.evidenceTypes.includes(t)).length;
    return {
      key: r.key,
      label: r.label,
      description: r.description,
      minCount: r.minCount,
      count: Math.min(count, r.minCount),
      met: count >= r.minCount,
    };
  });
}

/** Adds working days (Monday to Friday) to a date, keeping the time of day. Weekends are skipped, public holidays are not. */
export function addWorkingDays(from: Date, days: number): Date {
  const d = new Date(from.getTime());
  let left = Math.max(0, Math.floor(days));
  while (left > 0) {
    d.setUTCDate(d.getUTCDate() + 1);
    const wd = d.getUTCDay();
    if (wd !== 0 && wd !== 6) left -= 1;
  }
  return d;
}

export function addMonths(from: Date, months: number): Date {
  const d = new Date(from.getTime());
  const day = d.getUTCDate();
  d.setUTCMonth(d.getUTCMonth() + months);
  // 31 January plus one month is not 3 March.
  if (d.getUTCDate() !== day) d.setUTCDate(0);
  return d;
}

/** A reference link is sent once; only its hash is stored. */
export function newReferenceToken(): { token: string; hash: string } {
  const token = randomBytes(32).toString('base64url');
  return { token, hash: hashToken(token) };
}
export const hashToken = (token: string): string => createHash('sha256').update(token).digest('hex');

/** `ab***@gmail.com`: enough for the applicant to recognise their referee, not enough to harvest. */
export function maskEmail(email: string): string {
  const [local = '', domain = ''] = email.split('@');
  return `${local.slice(0, 2)}${local.length > 2 ? '***' : '*'}@${domain}`;
}

/** The text stamped on evidence a reviewer opens: who looked, when, and on which case. */
export function watermarkText(reviewerId: string, caseId: string, at: Date): string {
  return `Reviewer ${reviewerId.slice(0, 8)} · case ${caseId.slice(0, 8)} · ${at.toISOString().slice(0, 16).replace('T', ' ')} UTC`;
}

/** Only web links a reviewer could safely open. */
export function isHttpsUrl(value: string): boolean {
  try {
    const u = new URL(value);
    return u.protocol === 'https:' && !u.username && !u.password;
  } catch {
    return false;
  }
}
