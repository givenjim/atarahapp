/**
 * Pure helpers for the P1-M12 admin operations screens: dashboard, analytics charts, user overview actions, failed
 * jobs and platform settings. The API repeats every rule; these keep the screens honest and are unit tested.
 */

// ---- shapes (the API's DTOs, kept local so the screens do not depend on a regenerated schema) -----------------

export type Priority = 'URGENT' | 'HIGH' | 'NORMAL' | 'LOW';

export interface AttentionQueue {
  key: string;
  label: string;
  count: number;
  priority: Priority;
  oldestAt: string | null;
  path: string;
}

export interface DashboardCounts {
  newMembers7d: number;
  newMembers30d: number;
  onboardingCompletionRate30d: number;
  activeMembers7d: number;
  activeMembers30d: number;
  posts7d: number;
  opportunitiesSaved7d: number;
  opportunitiesApplied7d: number;
  courseCompletions30d: number;
}

export interface Dashboard {
  generatedAt: string;
  queues: AttentionQueue[];
  counts: DashboardCounts;
}

export interface AnalyticsPoint {
  day: string;
  name: string;
  events: number;
  actors: number;
}
export interface AnalyticsTotal {
  name: string;
  events: number;
  activeMemberDays: number;
}
export interface AnalyticsSeries {
  from: string;
  to: string;
  series: AnalyticsPoint[];
  totals: AnalyticsTotal[];
}

export interface QueueCounts {
  queue: string;
  waiting: number;
  active: number;
  delayed: number;
  failed: number;
  completed: number;
}
export interface FailedJob {
  id: string;
  name: string;
  failedReason: string;
  attemptsMade: number;
  failedAt: string | null;
}

export interface RoleInfo {
  key: string;
  name: string;
  description: string;
  isStaff: boolean;
  permissions: string[];
}

export interface FeatureFlag {
  key: string;
  description: string;
  enabled: boolean;
  phase: number;
}

export type SettingValue = string | number | boolean;
export interface PlatformSetting {
  key: string;
  value: SettingValue;
  description: string | null;
  updatedAt: string;
}

export interface UserOverview {
  user: {
    id: string;
    fullName: string;
    email: string | null;
    phone: string | null;
    status: string;
    statusReason: string | null;
    roles: string[];
    lastLoginAt: string | null;
    createdAt: string;
  };
  suspendedUntil: string | null;
  profile: {
    handle: string | null;
    displayName: string;
    headline: string | null;
    completionPercent: number;
    onboardingCompleted: boolean;
    county: string | null;
    discipline: string | null;
    publishedProjects: number;
  } | null;
  roleGrants: Array<{
    key: string;
    name: string;
    isStaff: boolean;
    grantedAt: string;
    grantedBy: string | null;
  }>;
  membership: {
    plan: string;
    status: string;
    source: string;
    startsAt: string;
    currentPeriodEnd: string | null;
  } | null;
  statusHistory: Array<{
    action: string;
    at: string;
    actorName: string | null;
    reason: string | null;
    from: string | null;
    to: string | null;
  }>;
  sessions: Array<{ id: string; client: string; deviceName: string | null; lastActiveAt: string }>;
  reports: {
    about: number;
    made: number;
    recent: Array<{
      caseId: string;
      targetType: string;
      topReason: string;
      status: string;
      priority: string;
      reportCount: number;
      createdAt: string;
    }>;
  };
}

// ---- time ------------------------------------------------------------------------------------------------------

const DAY_MS = 86_400_000;
const EAT_MS = 3 * 3_600_000;

/** A Nairobi (UTC+3, no daylight saving) date, yyyy-mm-dd. */
export const nairobiDate = (at: Date | number): string =>
  new Date(new Date(at).getTime() + EAT_MS).toISOString().slice(0, 10);

const isDate = (v: string | undefined): v is string =>
  !!v && /^\d{4}-\d{2}-\d{2}$/.test(v) && !Number.isNaN(Date.parse(`${v}T00:00:00Z`));

export const addDays = (date: string, n: number): string =>
  new Date(Date.parse(`${date}T00:00:00Z`) + n * DAY_MS).toISOString().slice(0, 10);

/** Whole days from `a` to `b` (b minus a). */
export const daysBetween = (a: string, b: string): number =>
  Math.round((Date.parse(`${b}T00:00:00Z`) - Date.parse(`${a}T00:00:00Z`)) / DAY_MS);

/** "2026-11-04 14:30 EAT". */
export function formatWhen(iso: string | null | undefined): string {
  if (!iso) return '—';
  const t = new Date(iso).getTime();
  if (Number.isNaN(t)) return '—';
  return `${new Date(t + EAT_MS).toISOString().slice(0, 16).replace('T', ' ')} EAT`;
}

/** How long ago, in the largest sensible unit: "just now", "5 hours", "3 days". */
export function ageLabel(iso: string | null | undefined, now: number = Date.now()): string {
  if (!iso) return '—';
  const t = new Date(iso).getTime();
  if (Number.isNaN(t)) return '—';
  const mins = Math.max(0, Math.floor((now - t) / 60_000));
  if (mins < 1) return 'just now';
  if (mins < 60) return `${mins} ${mins === 1 ? 'minute' : 'minutes'}`;
  const hours = Math.floor(mins / 60);
  if (hours < 24) return `${hours} ${hours === 1 ? 'hour' : 'hours'}`;
  const days = Math.floor(hours / 24);
  return `${days} ${days === 1 ? 'day' : 'days'}`;
}

// ---- dashboard -------------------------------------------------------------------------------------------------

export const PRIORITY_META: Record<
  Priority,
  { label: string; tone: '' | 'warning' | 'danger' | 'muted'; rank: number }
> = {
  URGENT: { label: 'Urgent', tone: 'danger', rank: 4 },
  HIGH: { label: 'High', tone: 'warning', rank: 3 },
  NORMAL: { label: 'Normal', tone: '', rank: 2 },
  LOW: { label: 'Low', tone: 'muted', rank: 1 },
};

export const priorityMeta = (p: string) =>
  PRIORITY_META[p as Priority] ?? { label: p, tone: '' as const, rank: 0 };

/** Most urgent first, then the longest queue, then the oldest waiting item. The API already orders them; this is a guard. */
export const sortQueues = (queues: readonly AttentionQueue[]): AttentionQueue[] =>
  [...queues].sort(
    (a, b) =>
      priorityMeta(b.priority).rank - priorityMeta(a.priority).rank ||
      b.count - a.count ||
      (a.oldestAt ?? '9').localeCompare(b.oldestAt ?? '9'),
  );

/** A console path from the API, only if it stays inside the console (one leading slash, no scheme). */
export const safeConsolePath = (path: string): string =>
  /^\/(?!\/)[^\s\\]*$/.test(path) ? path : '/';

export interface CountTile {
  key: keyof DashboardCounts;
  label: string;
  hint: string;
  percent?: boolean;
}

export const COUNT_TILES: readonly CountTile[] = [
  { key: 'newMembers7d', label: 'New members', hint: 'Last 7 days' },
  { key: 'newMembers30d', label: 'New members', hint: 'Last 30 days' },
  {
    key: 'onboardingCompletionRate30d',
    label: 'Onboarding completion',
    hint: 'Of the last 30 days’ sign-ups',
    percent: true,
  },
  { key: 'activeMembers7d', label: 'Active members', hint: 'Signed in, last 7 days' },
  { key: 'activeMembers30d', label: 'Active members', hint: 'Signed in, last 30 days' },
  { key: 'posts7d', label: 'Posts', hint: 'Last 7 days' },
  { key: 'opportunitiesSaved7d', label: 'Opportunities saved', hint: 'Last 7 days' },
  { key: 'opportunitiesApplied7d', label: 'Opportunities applied', hint: 'Last 7 days' },
  { key: 'courseCompletions30d', label: 'Course completions', hint: 'Last 30 days' },
];

export const formatCount = (n: number, percent = false): string =>
  percent ? `${Math.round(n)}%` : n.toLocaleString('en-KE');

// ---- analytics -------------------------------------------------------------------------------------------------

export const MAX_RANGE_DAYS = 120;

export const EVENT_LABELS: Record<string, string> = {
  registration: 'Registrations',
  onboarding_completed: 'Onboarding completed',
  profile_completed: 'Profiles completed',
  project_created: 'Projects created',
  post_created: 'Posts created',
  connection_created: 'Connections made',
  opportunity_viewed: 'Opportunities viewed',
  opportunity_saved: 'Opportunities saved',
  opportunity_applied: 'Opportunities applied',
  course_started: 'Courses started',
  course_completed: 'Courses completed',
  cv_generated: 'CVs generated',
  cv_downloaded: 'CV PDFs downloaded',
  cv_shared: 'CV share links created',
  cv_viewed: 'CV share links opened',
  search_performed: 'Searches',
};
export const EVENT_NAMES = Object.keys(EVENT_LABELS);

export const eventLabel = (name: string): string =>
  EVENT_LABELS[name] ?? (name.charAt(0).toUpperCase() + name.slice(1).replace(/_/g, ' ')).trim();

export interface Range {
  from: string;
  to: string;
  names: string[];
}

/** The last 30 days, ending today in Nairobi. */
export const defaultRange = (now: number = Date.now()): Omit<Range, 'names'> => {
  const to = nairobiDate(now);
  return { from: addDays(to, -29), to };
};

/** Plain-language problem with a date range, or null. */
export function rangeProblem(from: string, to: string): string | null {
  if (!isDate(from) || !isDate(to)) return 'Choose a start and an end date.';
  const span = daysBetween(from, to);
  if (span < 0) return 'The end date is before the start date.';
  if (span + 1 > MAX_RANGE_DAYS) return `Choose at most ${MAX_RANGE_DAYS} days.`;
  return null;
}

/** The range from the page's query string; a missing or unusable one falls back to the last 30 days. */
export function parseRange(
  sp: { from?: string; to?: string; names?: string | string[] },
  now: number = Date.now(),
): Range & { problem: string | null } {
  const def = defaultRange(now);
  const raw = Array.isArray(sp.names) ? sp.names.join(',') : (sp.names ?? '');
  const names = [...new Set(raw.split(',').filter((n) => EVENT_NAMES.includes(n)))];
  if (sp.from === undefined && sp.to === undefined) return { ...def, names, problem: null };
  const from = sp.from ?? '';
  const to = sp.to ?? '';
  const problem = rangeProblem(from, to);
  return problem ? { ...def, names, problem } : { from, to, names, problem: null };
}

/** The query string the API wants. */
export const analyticsQuery = (r: Range): Record<string, string> => ({
  from: r.from,
  to: r.to,
  ...(r.names.length ? { names: r.names.join(',') } : {}),
});

export interface ChartDay {
  day: string;
  events: number;
  actors: number;
}
export interface EventChart {
  name: string;
  label: string;
  days: ChartDay[];
  total: number;
  activeMemberDays: number;
  max: number;
}

/** A round upper bound for the y axis: 1, 2, 5 times a power of ten (at least 1 so an empty chart has a scale). */
export function niceMax(value: number): number {
  if (value <= 1) return 1;
  const pow = 10 ** Math.floor(Math.log10(value));
  for (const step of [1, 2, 5, 10]) if (value <= step * pow) return step * pow;
  return 10 * pow;
}

/** Every day in the range, in order, including days with no events (shown as zero, not skipped). */
export const daysIn = (from: string, to: string): string[] =>
  Array.from({ length: Math.max(0, daysBetween(from, to) + 1) }, (_, i) => addDays(from, i));

/** One chart per event name: the series filled to every day of the range. Names with no rows still get a (flat) chart. */
export function buildCharts(data: AnalyticsSeries, names: readonly string[]): EventChart[] {
  const days = daysIn(data.from, data.to);
  const wanted = names.length ? [...names] : EVENT_NAMES;
  const known = new Set(wanted);
  for (const p of data.series) known.add(p.name);
  for (const t of data.totals) known.add(t.name);
  const order = [...known].sort((a, b) => {
    const ia = EVENT_NAMES.indexOf(a);
    const ib = EVENT_NAMES.indexOf(b);
    return (ia < 0 ? 99 : ia) - (ib < 0 ? 99 : ib) || a.localeCompare(b);
  });
  return order.map((name) => {
    const byDay = new Map(data.series.filter((p) => p.name === name).map((p) => [p.day, p]));
    const filled = days.map((day) => ({
      day,
      events: byDay.get(day)?.events ?? 0,
      actors: byDay.get(day)?.actors ?? 0,
    }));
    const total = data.totals.find((t) => t.name === name);
    return {
      name,
      label: eventLabel(name),
      days: filled,
      total: total?.events ?? filled.reduce((s, d) => s + d.events, 0),
      activeMemberDays: total?.activeMemberDays ?? filled.reduce((s, d) => s + d.actors, 0),
      max: niceMax(Math.max(0, ...filled.map((d) => d.events))),
    };
  });
}

/** One sentence a screen reader can use in place of the picture. */
export function chartSummary(c: EventChart): string {
  if (c.days.length === 0) return `${c.label}: no days in range.`;
  const peak = c.days.reduce((a, d) => (d.events > a.events ? d : a), c.days[0]!);
  const first = c.days[0]!.day;
  const last = c.days[c.days.length - 1]!.day;
  if (c.total === 0) return `${c.label}, ${first} to ${last}: no events.`;
  return `${c.label}, ${first} to ${last}: ${c.total} events in total, busiest day ${peak.day} with ${peak.events}.`;
}

// ---- users -----------------------------------------------------------------------------------------------------

/** Roles that can be handed to any member; the rest are staff roles and need a super admin. */
export const MEMBER_ROLE_KEYS = ['MENTOR', 'SELLER', 'OPPORTUNITY_PROVIDER', 'INSTRUCTOR'];

/** Roles this administrator may offer to assign, given what the API reports (`isStaff`) and their permissions. */
export function assignableRoles(
  roles: readonly RoleInfo[],
  permissions: readonly string[],
  held: readonly string[],
): RoleInfo[] {
  if (!permissions.includes('role.assign')) return [];
  const superAdmin = permissions.includes('admin.manage');
  return roles.filter((r) => !held.includes(r.key) && (!r.isStaff || superAdmin));
}

/** Whether to show Revoke for a role the member holds. */
export const canRevokeRole = (
  role: { isStaff: boolean },
  permissions: readonly string[],
  isSelf: boolean,
): boolean =>
  !isSelf &&
  permissions.includes('role.assign') &&
  (!role.isStaff || permissions.includes('admin.manage'));

export const SUSPEND_REASON_MIN = 5;
export const SUSPEND_REASON_MAX = 500;
export const ROLE_REASON_MAX = 300;
export const SUSPEND_MAX_DAYS = 365;

export interface SuspendForm {
  reason: string;
  /** Blank means until staff lift it. */
  days: string;
}

export function validateSuspend(f: SuspendForm): string | null {
  const reason = f.reason.trim();
  if (reason.length < SUSPEND_REASON_MIN)
    return `Give a reason of at least ${SUSPEND_REASON_MIN} characters.`;
  if (reason.length > SUSPEND_REASON_MAX)
    return `The reason can be up to ${SUSPEND_REASON_MAX} characters.`;
  const days = f.days.trim();
  if (days && (!/^\d+$/.test(days) || +days < 1 || +days > SUSPEND_MAX_DAYS))
    return `Days must be a whole number from 1 to ${SUSPEND_MAX_DAYS}, or left blank.`;
  return null;
}

export const suspendPayload = (f: SuspendForm): { reason: string; durationDays?: number } => {
  const days = f.days.trim();
  return { reason: f.reason.trim(), ...(days ? { durationDays: Number(days) } : {}) };
};

/** "action" strings of the audit trail in words: user.suspend becomes "Suspended". */
const HISTORY_LABELS: Record<string, string> = {
  'user.suspend': 'Suspended',
  'user.reactivate': 'Reactivated',
  'user.role.assign': 'Role added',
  'user.role.revoke': 'Role removed',
  'user.suspension.expire': 'Suspension ended',
};
export const historyLabel = (action: string): string =>
  HISTORY_LABELS[action] ?? action.replace(/[._]/g, ' ').replace(/^\w/, (c) => c.toUpperCase());

export const roleLabel = (key: string): string =>
  key.charAt(0) + key.slice(1).toLowerCase().replace(/_/g, ' ');

/** Friendly wording for answers staff can see; anything else keeps the API's own message. */
export function opsMessage(status: number | undefined, message: string): string {
  if (status === 403) return 'You do not have permission to do that.';
  if (status === 404) return 'That no longer exists.';
  return message;
}

// ---- settings --------------------------------------------------------------------------------------------------

export type SettingKind = 'string' | 'number' | 'boolean';
export const settingKind = (v: SettingValue): SettingKind =>
  typeof v === 'number' ? 'number' : typeof v === 'boolean' ? 'boolean' : 'string';

/** The text field's value as the kind the setting already holds, or an error. Only same-kind values are accepted. */
export function coerceSetting(
  kind: SettingKind,
  text: string,
): { ok: true; value: SettingValue } | { ok: false; error: string } {
  if (kind === 'boolean') {
    if (text === 'true' || text === 'false') return { ok: true, value: text === 'true' };
    return { ok: false, error: 'Choose true or false.' };
  }
  if (kind === 'number') {
    const t = text.trim();
    if (t === '' || !Number.isFinite(Number(t))) return { ok: false, error: 'Enter a number.' };
    return { ok: true, value: Number(t) };
  }
  if (text.trim() === '') return { ok: false, error: 'This setting cannot be blank.' };
  return { ok: true, value: text };
}

export const settingChanged = (current: SettingValue, next: SettingValue): boolean =>
  current !== next;

export const displaySetting = (v: SettingValue): string => String(v);

/** Group keys by their first dotted segment: "membership.pro.price_minor" belongs to "membership". */
export function groupSettings(settings: readonly PlatformSetting[]): Array<{
  group: string;
  items: PlatformSetting[];
}> {
  const map = new Map<string, PlatformSetting[]>();
  for (const s of settings) {
    const g = s.key.includes('.') ? s.key.slice(0, s.key.indexOf('.')) : 'general';
    map.set(g, [...(map.get(g) ?? []), s]);
  }
  return [...map.entries()]
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([group, items]) => ({ group, items }));
}

// ---- jobs ------------------------------------------------------------------------------------------------------

export const jobKey = (queue: string, id: string): string => `${queue}:${id}`;

/** The API never returns payloads; reasons are still cut so one huge stack trace cannot break the layout. */
export const shortReason = (reason: string, max = 160): string => {
  const line = (reason.split('\n')[0] ?? '').trim();
  return line.length > max ? `${line.slice(0, max - 1)}…` : line;
};
