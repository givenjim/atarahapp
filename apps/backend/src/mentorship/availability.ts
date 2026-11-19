/**
 * Time-zone-correct availability maths for mentors (P2-M4). Pure functions: no database, no clock except what is
 * passed in, so every case (zones, DST, exceptions, bookings) is unit-testable.
 *
 * A mentor states weekly ranges as local wall-clock minutes in their own IANA zone (`weekday` ISO 1..7). A slot is
 * generated per local date, converted to UTC with the zone's real offset on that date, then filtered by date
 * exceptions, the minimum notice, and busy intervals supplied by the booking side (P2-M5).
 */

export interface WeeklyRule {
  /** ISO weekday: 1 = Monday ... 7 = Sunday. */
  weekday: number;
  /** Minutes after local midnight. */
  startMinute: number;
  endMinute: number;
}

export interface BusyInterval {
  start: Date;
  end: Date;
}

export interface SlotQuery {
  rules: readonly WeeklyRule[];
  timeZone: string;
  /** Local dates (`YYYY-MM-DD`, in `timeZone`) the mentor is off. */
  exceptionDates: ReadonlySet<string>;
  busy: readonly BusyInterval[];
  durationMinutes: number;
  from: Date;
  to: Date;
  now: Date;
  minNoticeMinutes: number;
  stepMinutes: number;
  /** Stop after the local date on which this many slots were found (for "next availability" lookups). */
  maxSlots?: number;
}

export const DEFAULT_STEP_MINUTES = 30;
export const MIN_NOTICE_MINUTES = 12 * 60;
export const HORIZON_DAYS = 60;

export function isValidTimeZone(tz: string): boolean {
  try {
    new Intl.DateTimeFormat('en-US', { timeZone: tz });
    return true;
  } catch {
    return false;
  }
}

const partsCache = new Map<string, Intl.DateTimeFormat>();
function formatter(tz: string): Intl.DateTimeFormat {
  let f = partsCache.get(tz);
  if (!f) {
    f = new Intl.DateTimeFormat('en-US', {
      timeZone: tz,
      hourCycle: 'h23',
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
    });
    partsCache.set(tz, f);
  }
  return f;
}

export interface LocalParts {
  year: number;
  month: number;
  day: number;
  hour: number;
  minute: number;
}

export function localParts(tz: string, at: Date): LocalParts {
  const get: Record<string, number> = {};
  for (const p of formatter(tz).formatToParts(at)) {
    if (p.type !== 'literal') get[p.type] = Number(p.value);
  }
  return {
    year: get.year!,
    month: get.month!,
    day: get.day!,
    hour: get.hour === 24 ? 0 : get.hour!,
    minute: get.minute!,
  };
}

/** `local - UTC` in minutes at the instant `utcMs`. */
function offsetMinutes(tz: string, utcMs: number): number {
  const p = localParts(tz, new Date(utcMs));
  const asUtc = Date.UTC(p.year, p.month - 1, p.day, p.hour, p.minute);
  return Math.round((asUtc - Math.floor(utcMs / 60_000) * 60_000) / 60_000);
}

/** The UTC instant at which the wall clock in `tz` reads `minute` on the given local date. */
export function localToUtc(
  year: number,
  month: number,
  day: number,
  minute: number,
  tz: string,
): Date {
  const naive = Date.UTC(year, month - 1, day, 0, minute);
  const first = naive - offsetMinutes(tz, naive) * 60_000;
  const second = naive - offsetMinutes(tz, first) * 60_000;
  return new Date(second);
}

export const ymd = (year: number, month: number, day: number): string =>
  `${String(year).padStart(4, '0')}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;

/** ISO weekday of a calendar date (independent of any zone). */
export function isoWeekday(year: number, month: number, day: number): number {
  const d = new Date(Date.UTC(year, month - 1, day)).getUTCDay();
  return d === 0 ? 7 : d;
}

/** Calendar date `YYYY-MM-DD` of an instant as seen in `tz`. */
export function localDateString(tz: string, at: Date): string {
  const p = localParts(tz, at);
  return ymd(p.year, p.month, p.day);
}

export const overlaps = (aStart: number, aEnd: number, b: BusyInterval): boolean =>
  aStart < b.end.getTime() && b.start.getTime() < aEnd;

/** Start instants of every bookable slot in [from, to), ascending and de-duplicated. */
export function generateSlots(q: SlotQuery): Date[] {
  const earliest = Math.max(q.from.getTime(), q.now.getTime() + q.minNoticeMinutes * 60_000);
  const latest = q.to.getTime();
  if (earliest >= latest || q.rules.length === 0) return [];

  // Walk local dates from a day before `from` to a day after `to` so zone offsets never skip a date.
  const first = localParts(q.timeZone, new Date(q.from.getTime() - 24 * 3_600_000));
  const cursor = Date.UTC(first.year, first.month - 1, first.day);
  const lastMs = q.to.getTime() + 24 * 3_600_000;
  const out = new Set<number>();
  const durationMs = q.durationMinutes * 60_000;

  for (let c = cursor; ; c += 24 * 3_600_000) {
    const d = new Date(c);
    const y = d.getUTCFullYear();
    const m = d.getUTCMonth() + 1;
    const day = d.getUTCDate();
    const dayStartUtc = localToUtc(y, m, day, 0, q.timeZone).getTime();
    if (dayStartUtc > lastMs) break;
    if (q.exceptionDates.has(ymd(y, m, day))) continue;
    const wd = isoWeekday(y, m, day);
    for (const r of q.rules) {
      if (r.weekday !== wd) continue;
      for (
        let minute = r.startMinute;
        minute + q.durationMinutes <= r.endMinute;
        minute += q.stepMinutes
      ) {
        const start = localToUtc(y, m, day, minute, q.timeZone).getTime();
        if (start < earliest || start >= latest) continue;
        const end = start + durationMs;
        if (q.busy.some((b) => overlaps(start, end, b))) continue;
        out.add(start);
      }
    }
    if (q.maxSlots !== undefined && out.size >= q.maxSlots) break;
  }
  return [...out].sort((a, b) => a - b).map((ms) => new Date(ms));
}

/** First bookable slot start, or null. */
export function nextAvailability(q: SlotQuery): Date | null {
  return generateSlots({ ...q, maxSlots: 1 })[0] ?? null;
}
