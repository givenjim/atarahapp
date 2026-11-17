import { Injectable, Logger } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { EVENT_RETENTION_DAYS } from './analytics.events';
import { eatDate } from './analytics.service';

const DAY_MS = 86_400_000;

/** Housekeeping for the analytics tables. Runs in the worker; integration tests call the methods directly. */
@Injectable()
export class AnalyticsJobsService {
  private readonly log = new Logger(AnalyticsJobsService.name);

  constructor(private readonly prisma: PrismaService) {}

  /**
   * Nightly: rolls the last few Nairobi days up into `analytics_daily_counts` (idempotent: a day is recomputed and
   * upserted, so a missed night is caught up the next one).
   */
  async aggregate(now = new Date(), days = 3): Promise<{ days: number; rows: number }> {
    let rows = 0;
    for (let i = 1; i <= days; i += 1) {
      const day = eatDate(new Date(now.getTime() - i * DAY_MS));
      rows += await this.aggregateDay(day);
    }
    return { days, rows };
  }

  async aggregateDay(day: string): Promise<number> {
    return this.prisma.$executeRaw(Prisma.sql`
      INSERT INTO analytics_daily_counts ("date", name, events, actors, "updatedAt")
      SELECT ${day}::date, name, count(*)::int, count(DISTINCT "actorHash")::int, now()
      FROM analytics_events
      WHERE "occurredAt" >= (${day}::date::timestamp - interval '3 hours')
        AND "occurredAt" < (${day}::date::timestamp + interval '1 day' - interval '3 hours')
      GROUP BY name
      ON CONFLICT ("date", name) DO UPDATE
        SET events = EXCLUDED.events, actors = EXCLUDED.actors, "updatedAt" = now()`);
  }

  /** Makes sure this month and the next three have partitions (the database function is idempotent). */
  async ensurePartitions(now = new Date()): Promise<number> {
    let ensured = 0;
    for (let i = 0; i <= 3; i += 1) {
      const m = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth() + i, 1));
      await this.prisma.$executeRaw(
        Prisma.sql`SELECT atarah_ensure_analytics_partition(${m.toISOString().slice(0, 10)}::date)`,
      );
      ensured += 1;
    }
    return ensured;
  }

  /** Drops whole monthly partitions past retention and trims strays from the default partition. */
  async purge(now = new Date()): Promise<{ partitionsDropped: number; strayRowsDeleted: number }> {
    const cutoff = new Date(now.getTime() - EVENT_RETENTION_DAYS * DAY_MS);
    const dropped = await this.prisma.$queryRaw<Array<{ n: number }>>(
      Prisma.sql`SELECT atarah_drop_old_analytics_partitions(${cutoff.toISOString().slice(0, 10)}::date) AS n`,
    );
    const strayRowsDeleted = await this.prisma.$executeRaw(
      Prisma.sql`DELETE FROM analytics_events_default WHERE "occurredAt" < ${cutoff}`,
    );
    const partitionsDropped = Number(dropped[0]?.n ?? 0);
    if (partitionsDropped + strayRowsDeleted > 0) {
      this.log.log(
        `Analytics retention: ${partitionsDropped} partitions, ${strayRowsDeleted} rows removed`,
      );
    }
    return { partitionsDropped, strayRowsDeleted };
  }
}
