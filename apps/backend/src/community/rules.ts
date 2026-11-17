import {
  type ModerationAction,
  type ModerationPriority,
  type ReportReason,
  type ReportStatus,
  type ReportTargetType,
} from '@prisma/client';
import { ApiException } from '../common/api.exception';

export const MAX_POST_BODY = 5_000;
export const MAX_COMMENT_BODY = 2_000;
export const MAX_POST_MEDIA = 10;
export const MAX_LINK_LENGTH = 2_048;
export const MODERATION_BACKLOG_HOURS = 48;

/** Trim, normalise line breaks and drop control characters (except newline and tab). */
export function cleanText(raw: string): string {
  return (
    raw
      .replace(/\r\n?/g, '\n')
      // eslint-disable-next-line no-control-regex
      .replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/g, '')
      .trim()
  );
}

const PRIVATE_HOST = /^(localhost|.*\.localhost|.*\.local|.*\.internal|.*\.home\.arpa)$/i;

/**
 * A link a member may attach: http(s), no credentials, no raw private or loopback host name. This is the first,
 * cheap check at post time; the fetcher repeats the full check for every hop and again after DNS resolution.
 */
export function parseSafeLink(raw: string): URL {
  let url: URL;
  try {
    url = new URL(raw.trim());
  } catch {
    throw ApiException.validation('That link is not a valid web address.', { field: 'linkUrl' });
  }
  if (!/^https?:$/.test(url.protocol) || url.username || url.password) {
    throw ApiException.validation(
      'Links must start with http:// or https:// and contain no password.',
      { field: 'linkUrl' },
    );
  }
  if (url.href.length > MAX_LINK_LENGTH) {
    throw ApiException.validation('That link is too long.', { field: 'linkUrl' });
  }
  const bare = !url.hostname.includes('.') && !url.hostname.includes(':');
  if (PRIVATE_HOST.test(url.hostname) || bare) {
    throw ApiException.validation('That link cannot be attached.', { field: 'linkUrl' });
  }
  return url;
}

/** Priority from the reason and how many members reported the same thing. */
export function priorityFor(reason: ReportReason, reportCount: number): ModerationPriority {
  if (reportCount >= 10) return 'URGENT';
  const serious: ReportReason[] = ['HARASSMENT', 'SCAM', 'IMPERSONATION'];
  if (reportCount >= 3 || serious.includes(reason)) return 'HIGH';
  if (reason === 'OTHER' && reportCount === 1) return 'LOW';
  return 'NORMAL';
}

const PRIORITY_ORDER: ModerationPriority[] = ['LOW', 'NORMAL', 'HIGH', 'URGENT'];
export const higherPriority = (a: ModerationPriority, b: ModerationPriority): ModerationPriority =>
  PRIORITY_ORDER.indexOf(a) >= PRIORITY_ORDER.indexOf(b) ? a : b;

/** What a reporter may be told: never who decided, which action, or why. */
export type PublicReportStatus = 'SUBMITTED' | 'UNDER_REVIEW' | 'REVIEWED';
export const publicReportStatus = (s: ReportStatus): PublicReportStatus =>
  s === 'SUBMITTED'
    ? 'SUBMITTED'
    : s === 'IN_REVIEW' || s === 'ESCALATED'
      ? 'UNDER_REVIEW'
      : 'REVIEWED';

export type ReportOutcome = 'ACTION_TAKEN' | 'NO_ACTION' | null;
export const reportOutcome = (s: ReportStatus): ReportOutcome =>
  s === 'RESOLVED' ? 'ACTION_TAKEN' : s === 'DISMISSED' ? 'NO_ACTION' : null;

/** The case and report status a decision leads to. */
export function statusAfter(action: ModerationAction): ReportStatus {
  return action === 'NO_ACTION' ? 'DISMISSED' : action === 'ESCALATE' ? 'ESCALATED' : 'RESOLVED';
}

const CONTENT_ACTIONS: ModerationAction[] = [
  'NO_ACTION',
  'WARN_USER',
  'HIDE_CONTENT',
  'REMOVE_CONTENT',
  'RESTORE_CONTENT',
  'RESTRICT_ACCOUNT',
  'SUSPEND_ACCOUNT',
  'ESCALATE',
];
const ALLOWED: Record<ReportTargetType, ModerationAction[]> = {
  POST: CONTENT_ACTIONS,
  COMMENT: CONTENT_ACTIONS,
  USER: [
    'NO_ACTION',
    'WARN_USER',
    'RESTORE_CONTENT',
    'RESTRICT_ACCOUNT',
    'SUSPEND_ACCOUNT',
    'ESCALATE',
  ],
  GROUP: ['NO_ACTION', 'REMOVE_CONTENT', 'RESTORE_CONTENT', 'ESCALATE'],
};
export const allowedActions = (t: ReportTargetType): ModerationAction[] => ALLOWED[t];
