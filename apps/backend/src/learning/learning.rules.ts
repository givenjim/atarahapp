import { type LessonProgressStatus } from '@prisma/client';
import { ApiException } from '../common/api.exception';

/** Pure rules of Skill Labs (P1-M10): no database, no clock except the one passed in. */

// ---- embedded players ------------------------------------------------------------------------------------------

/** The default allow-list. The live list is `PlatformSetting` `learning.embed_hosts` (staff can change it). */
export const DEFAULT_EMBED_HOSTS: readonly string[] = [
  'www.youtube.com',
  'www.youtube-nocookie.com',
  'player.vimeo.com',
];

const YOUTUBE_HOSTS = new Set(['youtube.com', 'www.youtube.com', 'm.youtube.com', 'youtu.be']);

/**
 * Turns an address a staff member pasted into the address the player iframe loads, and refuses any host that is not on
 * the allow-list. Watch links for YouTube and Vimeo are converted to their embed forms; anything else must already be
 * an https address on an allowed host. Nothing here fetches the page.
 */
export function normaliseEmbedUrl(
  raw: string,
  allowedHosts: readonly string[],
  field = 'embedUrl',
): string {
  let url: URL;
  try {
    url = new URL(raw.trim());
  } catch {
    throw ApiException.validation('That is not a valid web address.', { field });
  }
  if (url.protocol !== 'https:' || url.username || url.password) {
    throw ApiException.validation('Embedded players must use https:// and contain no password.', {
      field,
    });
  }
  const host = url.hostname.toLowerCase();
  let out = url;
  if (YOUTUBE_HOSTS.has(host)) {
    const id =
      host === 'youtu.be'
        ? url.pathname.split('/')[1]
        : url.pathname.startsWith('/embed/')
          ? url.pathname.split('/')[2]
          : url.pathname === '/watch'
            ? url.searchParams.get('v')
            : null;
    if (!id || !/^[A-Za-z0-9_-]{6,20}$/.test(id)) {
      throw ApiException.validation('That YouTube link does not point at a video.', { field });
    }
    out = new URL(`https://www.youtube-nocookie.com/embed/${id}`);
  } else if (host === 'vimeo.com' || host === 'www.vimeo.com') {
    const id = url.pathname.split('/').filter(Boolean)[0];
    if (!id || !/^\d{5,12}$/.test(id)) {
      throw ApiException.validation('That Vimeo link does not point at a video.', { field });
    }
    out = new URL(`https://player.vimeo.com/video/${id}`);
  }
  if (!allowedHosts.map((h) => h.toLowerCase()).includes(out.hostname.toLowerCase())) {
    throw ApiException.validation(
      `Videos from ${out.hostname} cannot be embedded. Allowed: ${allowedHosts.join(', ')}.`,
      { field },
    );
  }
  out.hash = '';
  return out.href;
}

/** A plain external resource address: https, no credentials. */
export function parseExternalUrl(raw: string, field = 'externalUrl'): string {
  let url: URL;
  try {
    url = new URL(raw.trim());
  } catch {
    throw ApiException.validation('That is not a valid web address.', { field });
  }
  if (url.protocol !== 'https:' || url.username || url.password || !url.hostname.includes('.')) {
    throw ApiException.validation('Links must start with https:// and contain no password.', {
      field,
    });
  }
  return url.href;
}

// ---- lesson states ---------------------------------------------------------------------------------------------

export type LessonState = 'DONE' | 'CURRENT' | 'LOCKED' | 'AVAILABLE';

export interface LessonRef {
  id: string;
  sequence: number;
}

/**
 * Done, Current or Locked for each lesson, computed from progress and never stored. In a sequential course the first
 * lesson that is not completed is Current and every lesson after it is Locked. In a non-sequential course nothing is
 * locked: the first unfinished lesson is Current and the others Available. A member who is not enrolled has no Current
 * lesson (the first is Available, the rest Locked when sequential).
 */
export function lessonStates(
  lessons: LessonRef[],
  completed: ReadonlySet<string>,
  sequential: boolean,
  enrolled = true,
): Map<string, LessonState> {
  const out = new Map<string, LessonState>();
  const ordered = [...lessons].sort((a, b) => a.sequence - b.sequence);
  let currentSeen = false;
  for (const l of ordered) {
    if (completed.has(l.id)) {
      out.set(l.id, 'DONE');
    } else if (!currentSeen) {
      currentSeen = true;
      out.set(l.id, enrolled ? 'CURRENT' : 'AVAILABLE');
    } else {
      out.set(l.id, sequential ? 'LOCKED' : 'AVAILABLE');
    }
  }
  return out;
}

export const percentComplete = (done: number, total: number): number =>
  total <= 0 ? 0 : Math.min(100, Math.round((done / total) * 100));

// ---- progress writes -------------------------------------------------------------------------------------------

export interface ProgressWrite {
  positionSeconds?: number | undefined;
  completed?: boolean | undefined;
  /** Start the lesson over: position goes back to zero and the lesson is not completed. */
  restart?: boolean | undefined;
}

export interface ProgressRow {
  status: LessonProgressStatus;
  lastPositionSeconds: number;
  completedAt: Date | null;
}

export interface ProgressResult {
  status: LessonProgressStatus;
  lastPositionSeconds: number;
  completedAt: Date | null;
  /** Seconds the position moved forward by this write (used for "hours this month"). */
  advancedSeconds: number;
  /** The lesson became completed by this write. */
  newlyCompleted: boolean;
}

/**
 * Idempotent and monotonic: the saved position only moves forward unless the member restarts the lesson, `completedAt`
 * is set once and never cleared (except by an explicit restart), and writing the same thing twice changes nothing.
 * A late, out-of-order write with an earlier position is ignored rather than rewinding the member.
 */
export function applyProgress(
  prev: ProgressRow | null,
  w: ProgressWrite,
  now: Date,
  maxSeconds: number,
): ProgressResult {
  const base: ProgressRow = prev ?? {
    status: 'NOT_STARTED',
    lastPositionSeconds: 0,
    completedAt: null,
  };
  if (w.restart) {
    return {
      status: 'IN_PROGRESS',
      lastPositionSeconds: 0,
      completedAt: null,
      advancedSeconds: 0,
      newlyCompleted: false,
    };
  }
  const requested = Math.max(0, Math.min(Math.floor(w.positionSeconds ?? 0), maxSeconds));
  const position = Math.max(base.lastPositionSeconds, requested);
  const completing = w.completed === true && base.completedAt === null;
  const completedAt = base.completedAt ?? (w.completed === true ? now : null);
  // Any write means the member has started the lesson.
  const started = position > 0 || w.positionSeconds !== undefined || w.completed !== undefined;
  const status: LessonProgressStatus = completedAt
    ? 'COMPLETED'
    : started || base.status === 'IN_PROGRESS'
      ? 'IN_PROGRESS'
      : base.status;
  return {
    status,
    lastPositionSeconds: position,
    completedAt,
    advancedSeconds: position - base.lastPositionSeconds,
    newlyCompleted: completing,
  };
}

// ---- time and certificates -------------------------------------------------------------------------------------

const EAT_MS = 3 * 3_600_000;

/** The calendar date (as a UTC-midnight Date) that an instant falls on in Nairobi. */
export function nairobiDate(d: Date): Date {
  const shifted = new Date(d.getTime() + EAT_MS);
  return new Date(Date.UTC(shifted.getUTCFullYear(), shifted.getUTCMonth(), shifted.getUTCDate()));
}

const MONTHS = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/** "Atarah Skill Lab certificate · October 2026" (Master Prompt P1-M10). */
export function certificateTitle(d: Date): string {
  const n = nairobiDate(d);
  return `Atarah Skill Lab certificate · ${MONTHS[n.getUTCMonth()]} ${n.getUTCFullYear()}`;
}

/** ATC-2026-000123 */
export const certificateNumber = (year: number, sequence: number): string =>
  `ATC-${year}-${String(sequence).padStart(6, '0')}`;

/** First day of the Nairobi month containing `d`, as a UTC-midnight Date. */
export function nairobiMonthStart(d: Date): Date {
  const n = nairobiDate(d);
  return new Date(Date.UTC(n.getUTCFullYear(), n.getUTCMonth(), 1));
}

/** Minutes a forward move of `seconds` counts for: whole minutes, and one write never counts more than 15. */
export const minutesFor = (seconds: number): number =>
  Math.min(15, Math.floor(Math.max(0, seconds) / 60));

/** No lesson is longer than this, whatever the declared length (a guard against nonsense positions). */
export const MAX_LESSON_SECONDS = 6 * 3600;
