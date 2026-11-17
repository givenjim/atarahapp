import { deadlineToIso } from './opportunities';

/**
 * Pure helpers for the notification broadcast screens (P1-M11): the form, the audience, scheduling in Nairobi time and
 * the wording of statuses. The API repeats every rule; these only save a round trip and keep the screen honest.
 */

export const TITLE_MAX = 80;
export const BODY_MAX = 400;
export const DEEP_LINK_MAX = 200;

export const BROADCAST_TARGETS = ['ALL', 'ROLE', 'DISCIPLINE', 'COUNTY'] as const;
export type BroadcastTarget = (typeof BROADCAST_TARGETS)[number];

export const TARGET_LABELS: Record<BroadcastTarget, string> = {
  ALL: 'Every member',
  ROLE: 'Members with a role',
  DISCIPLINE: 'Members in a discipline',
  COUNTY: 'Members in a county',
};

/** Role keys of the reference seed (the API checks the key exists). */
export const ROLE_OPTIONS: ReadonlyArray<{ key: string; label: string }> = [
  { key: 'MENTOR', label: 'Mentor' },
  { key: 'SELLER', label: 'Seller' },
  { key: 'OPPORTUNITY_PROVIDER', label: 'Opportunity provider' },
  { key: 'INSTRUCTOR', label: 'Instructor' },
  { key: 'MODERATOR', label: 'Moderator' },
  { key: 'CONTENT_ADMIN', label: 'Content admin' },
  { key: 'PLATFORM_ADMIN', label: 'Platform admin' },
  { key: 'SUPER_ADMIN', label: 'Super admin' },
];

export const CATEGORY_OPTIONS: ReadonlyArray<{ value: string; label: string }> = [
  { value: 'SYSTEM', label: 'Platform news' },
  { value: 'OPPORTUNITIES', label: 'Opportunities' },
  { value: 'COMMUNITY', label: 'Community' },
  { value: 'LEARNING', label: 'Learning' },
  { value: 'PROFILE', label: 'Profile' },
  { value: 'MENTORSHIP', label: 'Mentorship' },
  { value: 'MARKETPLACE', label: 'Marketplace' },
];

type Tone = '' | 'success' | 'warning' | 'danger' | 'muted';

export const BROADCAST_STATUS_META: Record<string, { label: string; tone: Tone }> = {
  SCHEDULED: { label: 'Scheduled', tone: 'warning' },
  SENDING: { label: 'Sending', tone: '' },
  SENT: { label: 'Sent', tone: 'success' },
  CANCELLED: { label: 'Cancelled', tone: 'muted' },
};
export const broadcastStatusMeta = (s: string) =>
  BROADCAST_STATUS_META[s] ?? { label: s.charAt(0) + s.slice(1).toLowerCase(), tone: '' as Tone };

export const BROADCAST_FILTERS: ReadonlyArray<{ value: string; label: string }> = [
  { value: '', label: 'All' },
  { value: 'SCHEDULED', label: 'Scheduled' },
  { value: 'SENDING', label: 'Sending' },
  { value: 'SENT', label: 'Sent' },
  { value: 'CANCELLED', label: 'Cancelled' },
];

export const parseBroadcastStatus = (v: string | undefined): string | undefined =>
  v && v in BROADCAST_STATUS_META ? v : undefined;

/** Only a broadcast that has not started sending can be cancelled. */
export const canCancelBroadcast = (status: string): boolean => status === 'SCHEDULED';

/** Sending to members is irreversible, so it needs the permission and a fresh authenticator code. */
export const canBroadcast = (permissions: readonly string[]): boolean =>
  permissions.includes('notification.broadcast');

export interface BroadcastForm {
  title: string;
  body: string;
  category: string;
  deepLink: string;
  target: BroadcastTarget;
  /** Role key, discipline id or county id (by `target`). Ignored for ALL. */
  targetValue: string;
  when: 'now' | 'later';
  /** A datetime-local value in Nairobi time (used when `when` is `later`). */
  scheduledLocal: string;
}

export const emptyBroadcastForm = (): BroadcastForm => ({
  title: '',
  body: '',
  category: 'SYSTEM',
  deepLink: '',
  target: 'ALL',
  targetValue: '',
  when: 'now',
  scheduledLocal: '',
});

/** In-app paths only: one leading slash, no spaces or backslashes (the same rule as the API). */
export const isInAppPath = (v: string): boolean => /^\/(?!\/)[^\s\\]*$/.test(v);

/** Plain-language problem with the form, or null when it can be sent. */
export function validateBroadcastForm(f: BroadcastForm, now: number = Date.now()): string | null {
  const title = f.title.trim();
  const body = f.body.trim();
  if (title.length < 3) return 'Give the notification a title of at least 3 characters.';
  if (title.length > TITLE_MAX) return `The title can be up to ${TITLE_MAX} characters.`;
  if (body.length < 3) return 'Write the message members will read.';
  if (body.length > BODY_MAX) return `The message can be up to ${BODY_MAX} characters.`;
  const link = f.deepLink.trim();
  if (link) {
    if (link.length > DEEP_LINK_MAX) return `The link can be up to ${DEEP_LINK_MAX} characters.`;
    if (!isInAppPath(link))
      return 'Use an in-app path that starts with a single slash, like /opportunities.';
  }
  if (f.target !== 'ALL' && !f.targetValue) {
    return f.target === 'ROLE'
      ? 'Choose the role.'
      : f.target === 'DISCIPLINE'
        ? 'Choose the discipline.'
        : 'Choose the county.';
  }
  if (f.when === 'later') {
    const iso = deadlineToIso(f.scheduledLocal);
    if (!iso) return 'Pick the date and time to send it (Nairobi time).';
    if (new Date(iso).getTime() < now + 60_000) return 'Pick a time in the future.';
  }
  return null;
}

/** The body the API wants. Blank optional fields are left out; scheduling converts Nairobi time to an instant. */
export function toBroadcastPayload(f: BroadcastForm): Record<string, unknown> {
  const body: Record<string, unknown> = {
    title: f.title.trim(),
    body: f.body.trim(),
    category: f.category,
    target: f.target,
  };
  if (f.target !== 'ALL') body.targetValue = f.targetValue;
  const link = f.deepLink.trim();
  if (link) body.deepLink = link;
  if (f.when === 'later') {
    const iso = deadlineToIso(f.scheduledLocal);
    if (iso) body.scheduledAt = iso;
  }
  return body;
}

/** The audience for the preview call (same target fields as the create body). */
export function audienceBody(
  f: Pick<BroadcastForm, 'target' | 'targetValue'>,
): Record<string, unknown> {
  return {
    // The preview endpoint takes the whole broadcast body; only the audience matters to it.
    title: 'Preview',
    body: 'Preview',
    target: f.target,
    ...(f.target !== 'ALL' ? { targetValue: f.targetValue } : {}),
  };
}

/** "Every member", "Members with a role: Mentor" … from a broadcast. */
export function targetSummary(b: {
  target: string;
  targetLabel?: string | null;
  targetValue?: string | null;
}): string {
  const base = TARGET_LABELS[b.target as BroadcastTarget] ?? b.target;
  if (b.target === 'ALL') return base;
  const who = b.targetLabel ?? b.targetValue;
  return who ? `${base}: ${who}` : base;
}

/** A Nairobi-time label for a stored instant ("2026-12-01 09:00 EAT"). */
export function formatWhen(iso: string | null | undefined): string {
  if (!iso) return '—';
  const t = new Date(iso).getTime();
  if (Number.isNaN(t)) return '—';
  return `${new Date(t + 3 * 3_600_000).toISOString().slice(0, 16).replace('T', ' ')} EAT`;
}

/** "Sending now", "Scheduled for …" — what the details page says about timing. */
export function timingLine(b: {
  status: string;
  scheduledAt?: string | null;
  sentAt?: string | null;
}): string {
  if (b.status === 'SENT') return `Sent ${formatWhen(b.sentAt)}`;
  if (b.status === 'CANCELLED') return 'Cancelled before it was sent';
  if (b.status === 'SCHEDULED') return `Scheduled for ${formatWhen(b.scheduledAt)}`;
  return b.scheduledAt ? `Sending (scheduled for ${formatWhen(b.scheduledAt)})` : 'Sending now';
}

/** Friendly wording for answers staff can see; anything else keeps the API's own message. */
export function broadcastMessage(status: number | undefined, message: string): string {
  if (status === 403) return 'You do not have permission to do that.';
  if (status === 404) return 'That broadcast no longer exists.';
  if (status === 409) return message || 'That is not possible in the current state.';
  return message;
}
