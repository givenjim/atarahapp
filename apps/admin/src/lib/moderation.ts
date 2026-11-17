/** Pure helpers for the community moderation, groups and announcements screens (no server imports). */

export const BACKLOG_HOURS = 48;
export const REASON_MAX = 500;
export const ANNOUNCEMENT_MAX = 5000;

export type ModerationAction =
  | 'NO_ACTION'
  | 'WARN_USER'
  | 'HIDE_CONTENT'
  | 'REMOVE_CONTENT'
  | 'RESTORE_CONTENT'
  | 'RESTRICT_ACCOUNT'
  | 'SUSPEND_ACCOUNT'
  | 'ESCALATE';

interface ActionMeta {
  label: string;
  /** Dialog title. */
  verb: string;
  tone: 'primary' | 'danger';
  /** What the decision does, shown in the confirm dialog. */
  effect: string;
}

export const ACTIONS: Record<ModerationAction, ActionMeta> = {
  NO_ACTION: {
    label: 'Dismiss (no action)',
    verb: 'Dismiss report',
    tone: 'primary',
    effect:
      'Nothing changes for the content or the account. The reporters are told it was reviewed.',
  },
  WARN_USER: {
    label: 'Warn author',
    verb: 'Warn author',
    tone: 'primary',
    effect: 'The author is sent a warning. Content stays as it is.',
  },
  HIDE_CONTENT: {
    label: 'Hide content',
    verb: 'Hide content',
    tone: 'danger',
    effect: 'The content disappears for everyone except its author. It can be restored.',
  },
  REMOVE_CONTENT: {
    label: 'Remove content',
    verb: 'Remove content',
    tone: 'danger',
    effect: 'The content is removed for everyone, including its author.',
  },
  RESTORE_CONTENT: {
    label: 'Restore content',
    verb: 'Restore content',
    tone: 'primary',
    effect: 'The content becomes visible again. For an account it also lifts the restriction.',
  },
  RESTRICT_ACCOUNT: {
    label: 'Restrict account',
    verb: 'Restrict account',
    tone: 'danger',
    effect:
      'The author can still sign in and read, but cannot post, comment or send connection requests until the restriction ends.',
  },
  SUSPEND_ACCOUNT: {
    label: 'Suspend account',
    verb: 'Suspend account',
    tone: 'danger',
    effect:
      'The author is signed out everywhere and cannot sign in until reactivated. This needs a fresh authenticator code.',
  },
  ESCALATE: {
    label: 'Escalate',
    verb: 'Escalate case',
    tone: 'primary',
    effect: 'Marks the case as escalated for a senior moderator. No change to the content.',
  },
};

export const actionMeta = (action: string): ActionMeta =>
  (ACTIONS as Record<string, ActionMeta>)[action] ?? {
    label: action,
    verb: action,
    tone: 'primary',
    effect: '',
  };

/** Every decision except a dismissal needs a written reason; it is internal and audited. */
export const actionNeedsReason = (action: string): boolean => action !== 'NO_ACTION';

export const REASON_LABELS: Record<string, string> = {
  INAPPROPRIATE: 'Inappropriate',
  HARASSMENT: 'Harassment',
  SCAM: 'Scam',
  MISLEADING: 'Misleading',
  IMPERSONATION: 'Impersonation',
  IP_INFRINGEMENT: 'IP infringement',
  OTHER: 'Other',
};

export const reasonLabel = (reason: string): string => REASON_LABELS[reason] ?? reason;

export const TARGET_LABELS: Record<string, string> = {
  POST: 'Post',
  COMMENT: 'Comment',
  USER: 'Account',
  GROUP: 'Group',
};

export const CASE_STATUSES = ['SUBMITTED', 'IN_REVIEW', 'RESOLVED', 'DISMISSED', 'ESCALATED'];
export const PRIORITIES = ['URGENT', 'HIGH', 'NORMAL', 'LOW'];

export const statusLabel = (s: string): string =>
  s === 'IN_REVIEW' ? 'In review' : s.charAt(0) + s.slice(1).toLowerCase().replaceAll('_', ' ');

export const statusTone = (s: string): '' | 'success' | 'warning' | 'danger' =>
  s === 'SUBMITTED' ? 'warning' : s === 'ESCALATED' ? 'danger' : s === 'RESOLVED' ? 'success' : '';

export const priorityTone = (p: string): '' | 'success' | 'warning' | 'danger' =>
  p === 'URGENT' ? 'danger' : p === 'HIGH' ? 'warning' : '';

/** A case still waiting after BACKLOG_HOURS is flagged as backlog. */
export const isBacklog = (ageHours: number, status: string): boolean =>
  ageHours >= BACKLOG_HOURS && (status === 'SUBMITTED' || status === 'IN_REVIEW');

export function formatAge(hours: number): string {
  if (hours < 1) return 'under 1 h';
  if (hours < 48) return `${Math.floor(hours)} h`;
  return `${Math.floor(hours / 24)} d`;
}

export interface DecisionInput {
  action: string;
  reason: string;
  restrictDays?: number | null;
}

/** Plain-language problem with a moderation decision, or null when it can be sent. */
export function validateDecision({ action, reason, restrictDays }: DecisionInput): string | null {
  const text = reason.trim();
  if (actionNeedsReason(action) && text.length < 5) {
    return 'Give a reason of at least 5 characters. It is kept internal and recorded in the audit log.';
  }
  if (text.length > REASON_MAX) return `Keep the reason to ${REASON_MAX} characters or fewer.`;
  if (action === 'RESTRICT_ACCOUNT' && restrictDays !== null && restrictDays !== undefined) {
    if (!Number.isInteger(restrictDays) || restrictDays < 1 || restrictDays > 365) {
      return 'Restriction length must be a whole number of days from 1 to 365.';
    }
  }
  return null;
}

export const isUuid = (v: string): boolean =>
  /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(v.trim());

export function validateAnnouncement(body: string, groupId: string): string | null {
  const text = body.trim();
  if (!text) return 'Write the announcement.';
  if (text.length > ANNOUNCEMENT_MAX) {
    return `Keep the announcement to ${ANNOUNCEMENT_MAX} characters or fewer.`;
  }
  if (groupId && !isUuid(groupId)) return 'Choose a group from the list.';
  return null;
}

export const GROUP_TYPES = ['DISCIPLINE', 'LOCATION', 'INTEREST', 'PROGRAMME'] as const;

export interface GroupInput {
  name: string;
  slug?: string;
  description: string;
}

const SLUG = /^[a-z0-9]+(-[a-z0-9]+)*$/;

export function validateGroup(input: GroupInput, creating: boolean): string | null {
  const name = input.name.trim();
  if (name.length < 2 || name.length > 80) return 'Name must be 2 to 80 characters.';
  if (input.description.trim().length > 600) return 'Keep the description to 600 characters.';
  const slug = input.slug?.trim();
  if (creating && slug && !SLUG.test(slug)) {
    return 'The address can use lower-case letters, numbers and single hyphens only.';
  }
  return null;
}

/** Friendly answer to a failed moderation, group or announcement call. */
export function communityMessage(status: number | undefined, fallback: string): string {
  if (status === 403) return 'You do not have permission to do that.';
  if (status === 404) return 'That item no longer exists. Refresh the page.';
  if (status === 409) return fallback || 'The state changed under you. Refresh the page and retry.';
  return fallback;
}
