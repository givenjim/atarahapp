import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import {
  DEFAULT_STEP_MINUTES,
  HORIZON_DAYS,
  MIN_NOTICE_MINUTES,
  generateSlots,
  nextAvailability,
  ymd,
  type SlotQuery,
  type WeeklyRule,
} from './availability';
import { MentorshipHooks } from './busy-slots';

export interface MentorSchedule {
  timeZone: string;
  rules: WeeklyRule[];
  exceptionDates: Set<string>;
}

const DAY_MS = 86_400_000;

/**
 * Availability for a mentor: weekly ranges and date exceptions from the database, minus bookings read through the
 * `MentorshipHooks` busy-slot providers (P2-M5 registers one). This is the one place P2-M5 asks for free slots, so
 * the booking screen and the directory can never disagree.
 */
@Injectable()
export class AvailabilityService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly hooks: MentorshipHooks,
  ) {}

  /** Schedules for many mentors in three queries. Mentors with no rows get an empty rule list. */
  async schedules(
    mentors: Array<{ id: string; timeZone: string }>,
    now = new Date(),
  ): Promise<Map<string, MentorSchedule>> {
    const ids = mentors.map((m) => m.id);
    const out = new Map<string, MentorSchedule>();
    for (const m of mentors)
      out.set(m.id, { timeZone: m.timeZone, rules: [], exceptionDates: new Set() });
    if (ids.length === 0) return out;
    const [rows, exceptions] = await Promise.all([
      this.prisma.mentorAvailability.findMany({ where: { mentorId: { in: ids } } }),
      this.prisma.mentorAvailabilityException.findMany({
        where: { mentorId: { in: ids }, date: { gte: new Date(now.getTime() - 2 * DAY_MS) } },
      }),
    ]);
    for (const r of rows) {
      out
        .get(r.mentorId)
        ?.rules.push({ weekday: r.weekday, startMinute: r.startMinute, endMinute: r.endMinute });
    }
    for (const e of exceptions) {
      out
        .get(e.mentorId)
        ?.exceptionDates.add(
          ymd(e.date.getUTCFullYear(), e.date.getUTCMonth() + 1, e.date.getUTCDate()),
        );
    }
    return out;
  }

  private query(
    schedule: MentorSchedule,
    durationMinutes: number,
    from: Date,
    to: Date,
    busy: SlotQuery['busy'],
    now: Date,
  ): SlotQuery {
    return {
      rules: schedule.rules,
      timeZone: schedule.timeZone,
      exceptionDates: schedule.exceptionDates,
      busy,
      durationMinutes,
      from,
      to,
      now,
      minNoticeMinutes: MIN_NOTICE_MINUTES,
      stepMinutes: DEFAULT_STEP_MINUTES,
    };
  }

  /** The first bookable slot start for a session of this length, or null when none in the horizon. */
  async nextAvailableAt(
    mentorId: string,
    schedule: MentorSchedule,
    durationMinutes: number | null,
    now = new Date(),
  ): Promise<Date | null> {
    if (durationMinutes === null || schedule.rules.length === 0) return null;
    const to = new Date(now.getTime() + HORIZON_DAYS * DAY_MS);
    const busy = await this.hooks.busySlots(mentorId, now, to);
    return nextAvailability(this.query(schedule, durationMinutes, now, to, busy, now));
  }

  /** Every bookable slot start in [from, to) for a session of this length. */
  async slots(
    mentorId: string,
    schedule: MentorSchedule,
    durationMinutes: number,
    from: Date,
    to: Date,
    now = new Date(),
  ): Promise<Date[]> {
    const busy = await this.hooks.busySlots(mentorId, from, to);
    return generateSlots(this.query(schedule, durationMinutes, from, to, busy, now));
  }

  async scheduleFor(mentorId: string, timeZone: string, now = new Date()): Promise<MentorSchedule> {
    return (await this.schedules([{ id: mentorId, timeZone }], now)).get(mentorId)!;
  }
}
