import {
  type ApplicationMethod,
  type OpportunityOutcome,
  type OpportunityStatus,
  type OpportunityTrackingStatus,
  type OpportunityTrust,
} from '@prisma/client';
import { ApiException } from '../common/api.exception';

/** Pure rules of the Opportunities module: no database, no clock except the one passed in. */

export const DAY_MS = 86_400_000;
/** "Closing soon" window and the two urgency bands (Master Prompt 6.3). */
export const CLOSING_SOON_DAYS = 14;
export const URGENT_DAYS = 7;

export type Urgency = 'URGENT' | 'SOON';

/** Whole days until the deadline, rounded up, so a deadline later today is "1 day left". Null for a rolling deadline. */
export function daysLeft(deadlineAt: Date | null, now: Date): number | null {
  if (!deadlineAt) return null;
  return Math.ceil((deadlineAt.getTime() - now.getTime()) / DAY_MS);
}

/**
 * Closing-soon is computed, never stored: the deadline is within 14 days and the member has not applied or completed.
 * `URGENT` (7 days or fewer) is Coral, `SOON` (8 to 14) is Tangerine.
 */
export function urgencyFor(
  deadlineAt: Date | null,
  now: Date,
  tracking: OpportunityTrackingStatus | null,
): Urgency | null {
  if (tracking === 'APPLIED' || tracking === 'COMPLETED') return null;
  const days = daysLeft(deadlineAt, now);
  if (days === null || days <= 0 || days > CLOSING_SOON_DAYS) return null;
  return days <= URGENT_DAYS ? 'URGENT' : 'SOON';
}

/** An open listing is published and its deadline (if any) has not passed. */
export const isOpen = (
  o: { status: OpportunityStatus; deadlineAt: Date | null },
  now: Date,
): boolean => o.status === 'PUBLISHED' && (o.deadlineAt === null || o.deadlineAt > now);

// ---- tracking state machine ----------------------------------------------------------------------------------

const ORDER: OpportunityTrackingStatus[] = ['SAVED', 'IN_PROGRESS', 'APPLIED', 'COMPLETED'];

export interface TrackingStep {
  status: OpportunityTrackingStatus;
  outcome?: OpportunityOutcome | undefined;
}

/**
 * SAVED to IN_PROGRESS to APPLIED to COMPLETED, forward only. A member may skip forward (leave to apply straight from
 * a saved item) but may not go back, and COMPLETED is reachable only from APPLIED. The same status again is a no-op.
 * Returns what to write, or throws `INVALID_STATE`.
 */
export function nextTracking(
  current: OpportunityTrackingStatus | null,
  step: TrackingStep,
): 'create' | 'advance' | 'same' {
  if (step.outcome && step.status !== 'COMPLETED') {
    throw ApiException.validation(
      'An outcome can only be recorded when you complete an application.',
      {
        field: 'outcome',
      },
    );
  }
  if (current === null) {
    if (step.status === 'COMPLETED') {
      throw ApiException.invalidState('Mark it as applied before you complete it.');
    }
    return 'create';
  }
  if (current === step.status) return 'same';
  if (ORDER.indexOf(step.status) < ORDER.indexOf(current)) {
    throw ApiException.invalidState(
      current === 'COMPLETED'
        ? 'This application is already completed.'
        : 'An application cannot go back to an earlier step.',
    );
  }
  if (step.status === 'COMPLETED' && current !== 'APPLIED') {
    throw ApiException.invalidState('Mark it as applied before you complete it.');
  }
  return 'advance';
}

/** Un-saving removes the record, so it is allowed only while nothing else has been recorded. */
export function assertCanUnsave(current: OpportunityTrackingStatus): void {
  if (current !== 'SAVED') {
    throw ApiException.invalidState(
      current === 'IN_PROGRESS'
        ? 'You have started this one. Mark it applied or completed instead.'
        : 'You have already applied for this one, so it stays in your list.',
    );
  }
}

// ---- trust and publication -------------------------------------------------------------------------------------

/** What a provider (or an admin without `opportunity.verify`) may set. Only VERIFIED needs the verify permission. */
export const STAFF_TRUST_VALUES: readonly OpportunityTrust[] = [
  'SOURCE_CONFIRMED',
  'EXTERNAL_SOURCE',
];

/** Lifecycle moves staff can make, by action. Anything else is `INVALID_STATE`. */
export const TRANSITIONS = {
  publish: { from: ['DRAFT', 'PENDING_REVIEW', 'CLOSED', 'EXPIRED'], to: 'PUBLISHED' },
  close: { from: ['PUBLISHED'], to: 'CLOSED' },
  archive: { from: ['DRAFT', 'PENDING_REVIEW', 'PUBLISHED', 'CLOSED', 'EXPIRED'], to: 'ARCHIVED' },
  remove: {
    from: ['DRAFT', 'PENDING_REVIEW', 'PUBLISHED', 'CLOSED', 'EXPIRED', 'ARCHIVED'],
    to: 'REMOVED',
  },
  reject: { from: ['PENDING_REVIEW'], to: 'DRAFT' },
} as const satisfies Record<string, { from: readonly OpportunityStatus[]; to: OpportunityStatus }>;

export type TransitionName = keyof typeof TRANSITIONS;

export function assertTransition(name: TransitionName, from: OpportunityStatus): OpportunityStatus {
  const t = TRANSITIONS[name];
  if (!(t.from as readonly OpportunityStatus[]).includes(from)) {
    throw ApiException.invalidState(
      `A ${from.toLowerCase().replace('_', ' ')} listing cannot be ${name}d.`,
    );
  }
  return t.to;
}

// ---- display ---------------------------------------------------------------------------------------------------

const fmtNumber = (minor: bigint | number): string => {
  const major = Number(minor) / 100;
  return major.toLocaleString('en-KE', { maximumFractionDigits: 0 });
};

/** "KES 500,000", "KES 100,000 to 500,000" or the free text ("Paid stipend"). Null when nothing is stated. */
export function valueLabel(o: {
  valueMinMinor: bigint | null;
  valueMaxMinor: bigint | null;
  valueCurrency: string | null;
  valueText: string | null;
}): string | null {
  const cur = o.valueCurrency ?? 'KES';
  const { valueMinMinor: min, valueMaxMinor: max } = o;
  if (min !== null && max !== null) {
    return min === max
      ? `${cur} ${fmtNumber(max)}`
      : `${cur} ${fmtNumber(min)} to ${fmtNumber(max)}`;
  }
  if (max !== null) return `Up to ${cur} ${fmtNumber(max)}`;
  if (min !== null) return `From ${cur} ${fmtNumber(min)}`;
  return o.valueText?.trim() || null;
}

/** The host a member is about to leave Atarah for, shown in the modal ("Atarah doesn't receive this application"). */
export function applicationDomain(
  method: ApplicationMethod,
  url: string | null,
  email: string | null,
): string | null {
  if (method === 'EMAIL') return email ? (email.split('@')[1]?.toLowerCase() ?? null) : null;
  if (!url) return null;
  try {
    return new URL(url).hostname.replace(/^www\./, '').toLowerCase();
  } catch {
    return null;
  }
}

/** Only https (and http for tests of old listings) web addresses with no credentials may be application links. */
export function parseApplicationUrl(raw: string): URL {
  let url: URL;
  try {
    url = new URL(raw.trim());
  } catch {
    throw ApiException.validation('That is not a valid web address.', { field: 'applicationUrl' });
  }
  if (url.protocol !== 'https:' || url.username || url.password) {
    throw ApiException.validation(
      'Application links must start with https:// and contain no password.',
      {
        field: 'applicationUrl',
      },
    );
  }
  if (!url.hostname.includes('.')) {
    throw ApiException.validation('That is not a valid web address.', { field: 'applicationUrl' });
  }
  return url;
}

export function slugify(title: string): string {
  const base = title
    .toLowerCase()
    .normalize('NFKD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 60)
    .replace(/-+$/g, '');
  return base || 'opportunity';
}

// ---- East Africa Time (UTC+3, no daylight saving) ---------------------------------------------------------------

const EAT_MS = 3 * 3_600_000;
/** The calendar day (as a UTC midnight timestamp) that an instant falls on in Nairobi. */
export const eatDay = (d: Date): number => Math.floor((d.getTime() + EAT_MS) / DAY_MS);

/** Calendar days from today to the deadline in Nairobi: 0 is "closes today", 1 is "closes tomorrow". */
export const eatDaysUntil = (deadlineAt: Date, now: Date): number =>
  eatDay(deadlineAt) - eatDay(now);

/** The reminder offsets, in Nairobi calendar days before the deadline. */
export const REMINDER_DAYS = [7, 1] as const;
