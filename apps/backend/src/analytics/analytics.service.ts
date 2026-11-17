import { createHmac } from 'node:crypto';
import { Injectable, Logger } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { AppConfigService } from '../config/app-config.service';
import { PrismaService } from '../prisma/prisma.service';
import {
  type AnalyticsEventName,
  type AnalyticsProps,
  EVENT_NAMES,
  EVENT_SCHEMAS,
  isAnonymousEvent,
} from './analytics.events';

/** Nairobi calendar date of an instant, as `YYYY-MM-DD` (UTC+3, no daylight saving). */
export const eatDate = (d: Date): string =>
  new Date(d.getTime() + 3 * 3_600_000).toISOString().slice(0, 10);

interface DayRow {
  day: string;
  name: string;
  events: number;
  actors: number;
}

/**
 * Writes analytics events. `track` is fire-and-forget: it validates against the event's allow-list, hashes the member
 * id and inserts in the background, and it can never fail or slow the request that raised it. The hash is an HMAC
 * keyed from the backend's secret, so the stored value cannot be reversed or matched to a member without that secret
 * (rotating the secret starts new pseudonyms).
 */
@Injectable()
export class AnalyticsService {
  private readonly log = new Logger(AnalyticsService.name);
  private readonly key: Buffer;

  constructor(
    private readonly prisma: PrismaService,
    config: AppConfigService,
  ) {
    this.key = createHmac('sha256', config.supabase.secretKey)
      .update('atarah-analytics-v1')
      .digest();
  }

  hash(userId: string): string {
    return createHmac('sha256', this.key).update(userId).digest('hex').slice(0, 32);
  }

  /** Fire and forget. Never throws. */
  track<N extends AnalyticsEventName>(
    name: N,
    props: AnalyticsProps<N>,
    actorId?: string | null,
  ): void {
    void this.record(name, props, actorId).catch(() => undefined);
  }

  /** The awaitable form (tests, jobs). Resolves false when the event was refused or could not be stored. */
  async record<N extends AnalyticsEventName>(
    name: N,
    props: AnalyticsProps<N>,
    actorId?: string | null,
    at: Date = new Date(),
  ): Promise<boolean> {
    try {
      const parsed = EVENT_SCHEMAS[name].safeParse(props);
      if (!parsed.success) {
        this.log.warn(`Dropped analytics event "${name}": props do not match the allow-list`);
        return false;
      }
      const actorHash = !isAnonymousEvent(name) && actorId ? this.hash(actorId) : null;
      await this.prisma.$executeRaw(Prisma.sql`
        INSERT INTO analytics_events (id, "occurredAt", name, "actorHash", props)
        VALUES (gen_random_uuid(), ${at}, ${name}, ${actorHash}, ${JSON.stringify(parsed.data)}::jsonb)`);
      return true;
    } catch (e) {
      this.log.warn(
        `Analytics event "${name}" not stored: ${e instanceof Error ? e.message : String(e)}`,
      );
      return false;
    }
  }

  // ---- reads (admin charts) -----------------------------------------------------------------------------------

  /**
   * Events per day and name over a Nairobi date range. Days before today come from the nightly roll-up; today (and any
   * day the roll-up has not covered yet) is counted live from the raw events.
   */
  async series(
    from: string,
    to: string,
    names: readonly string[] = EVENT_NAMES,
  ): Promise<DayRow[]> {
    const today = eatDate(new Date());
    const list = [...names];
    const rolled = await this.prisma.$queryRaw<DayRow[]>(Prisma.sql`
      SELECT to_char("date", 'YYYY-MM-DD') AS day, name, events, actors
      FROM analytics_daily_counts
      WHERE "date" BETWEEN ${from}::date AND ${to}::date AND "date" < ${today}::date
        AND name = ANY(${list}::text[])`);
    const covered = new Set(rolled.map((r) => r.day));
    const live = await this.prisma.$queryRaw<DayRow[]>(Prisma.sql`
      SELECT to_char(("occurredAt" + interval '3 hours')::date, 'YYYY-MM-DD') AS day, name,
             count(*)::int AS events, count(DISTINCT "actorHash")::int AS actors
      FROM analytics_events
      WHERE "occurredAt" >= (${from}::date::timestamp - interval '3 hours')
        AND "occurredAt" < (${to}::date::timestamp + interval '1 day' - interval '3 hours')
        AND name = ANY(${list}::text[])
      GROUP BY 1, 2`);
    const rows = [...rolled, ...live.filter((r) => !covered.has(r.day))];
    rows.sort((a, b) =>
      a.day === b.day ? a.name.localeCompare(b.name) : a.day.localeCompare(b.day),
    );
    return rows;
  }

  /** Totals per event over a range, from the same sources as `series`. */
  async totals(from: string, to: string) {
    const rows = await this.series(from, to);
    const out = new Map<string, { events: number; activeMemberDays: number }>();
    for (const r of rows) {
      const t = out.get(r.name) ?? { events: 0, activeMemberDays: 0 };
      t.events += r.events;
      // Daily distinct members cannot be summed into period distinct members: this is "member-days".
      t.activeMemberDays += r.actors;
      out.set(r.name, t);
    }
    return EVENT_NAMES.map((name) => ({
      name,
      events: out.get(name)?.events ?? 0,
      activeMemberDays: out.get(name)?.activeMemberDays ?? 0,
    }));
  }
}
