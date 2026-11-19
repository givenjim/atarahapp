import { Injectable } from '@nestjs/common';
import { Prisma, type MentorProfile } from '@prisma/client';
import { ApiException } from '../common/api.exception';
import { pageMeta } from '../common/pagination';
import { PrismaService } from '../prisma/prisma.service';
import { isValidTimeZone } from './availability';
import { AvailabilityService } from './availability.service';
import { MentorshipHooks } from './busy-slots';
import {
  type AddExceptionDto,
  type AvailabilityDto,
  type ExceptionDto,
  type MyMentorDto,
  type SessionTypeDto,
  type SessionTypeFieldsDto,
  type SetWeeklyAvailabilityDto,
  type UpdateMentorProfileDto,
  type UpdateSessionTypeDto,
  MAX_SESSION_TYPES,
} from './mentorship.dto';
import { dedupe, trimCredential } from './mentor-application.service';
import { credentialsOf, isBookable, sessionTypeDto } from './mentor-views.service';

const DAY_MS = 86_400_000;

/** Mobile clients send `null` for fields they did not change; treat it like absent. */
const has = <T>(v: T | null | undefined): v is T => v !== null && v !== undefined;

const ymdOf = (d: Date) => d.toISOString().slice(0, 10);

/** What a mentor does for themselves: profile, session types, weekly availability, exceptions, booking requests. */
@Injectable()
export class MentorToolsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly availability: AvailabilityService,
    private readonly hooks: MentorshipHooks,
  ) {}

  /** The caller's mentor profile. REMOVED mentors lose the tools even if a stale role lingers. */
  private async own(userId: string, opts: { allowRemoved?: boolean } = {}): Promise<MentorProfile> {
    const p = await this.prisma.mentorProfile.findUnique({ where: { userId } });
    if (!p) throw ApiException.notFound('You are not a mentor yet.');
    if (p.status === 'REMOVED' && !opts.allowRemoved)
      throw ApiException.forbidden('Your mentor profile was removed. You can apply again.');
    return p;
  }

  async me(userId: string): Promise<MyMentorDto> {
    const p = await this.own(userId);
    const [types, disciplines, availability] = await Promise.all([
      this.prisma.mentorSessionType.findMany({
        where: { mentorId: p.id },
        orderBy: [{ active: 'desc' }, { priceMinor: 'asc' }],
      }),
      p.disciplineIds.length
        ? this.prisma.discipline.findMany({
            where: { id: { in: p.disciplineIds } },
            select: { id: true, name: true },
          })
        : [],
      this.availabilityDto(p),
    ]);
    return {
      id: p.id,
      status: p.status,
      statusReason: p.statusReason,
      headline: p.headline,
      bio: p.bio,
      yearsExperience: p.yearsExperience,
      expertiseTags: p.expertiseTags,
      disciplines,
      credentials: credentialsOf(p.credentials),
      timeZone: p.timeZone,
      videoCallLink: p.videoCallLink,
      verified: p.verificationStatus === 'VERIFIED',
      featured: p.featured,
      ratingAverage: p.ratingAverage,
      ratingCount: p.ratingCount,
      sessionsCount: p.sessionsCount,
      sessionTypes: types.map(sessionTypeDto),
      availability,
      listed: p.status === 'APPROVED' && types.some(isBookable),
    };
  }

  async updateProfile(userId: string, dto: UpdateMentorProfileDto): Promise<MyMentorDto> {
    const p = await this.own(userId);
    const data: Prisma.MentorProfileUpdateInput = {};
    if (has(dto.headline)) data.headline = dto.headline.trim();
    if (has(dto.bio)) data.bio = dto.bio.trim();
    if (has(dto.yearsExperience)) data.yearsExperience = dto.yearsExperience;
    if (has(dto.expertiseTags)) data.expertiseTags = dedupe(dto.expertiseTags);
    if (has(dto.credentials))
      data.credentials = dto.credentials.map(trimCredential) as unknown as Prisma.InputJsonValue;
    if (dto.videoCallLink !== undefined) data.videoCallLink = dto.videoCallLink;
    if (has(dto.disciplineIds)) {
      const ids = [...new Set(dto.disciplineIds)];
      if (
        ids.length &&
        (await this.prisma.discipline.count({ where: { id: { in: ids } } })) !== ids.length
      )
        throw ApiException.validation('One of the disciplines is not valid.', {
          field: 'disciplineIds',
        });
      data.disciplineIds = ids;
    }
    const zoneChanged = has(dto.timeZone) && dto.timeZone !== p.timeZone;
    if (has(dto.timeZone)) {
      if (!isValidTimeZone(dto.timeZone))
        throw ApiException.validation('That time zone is not valid.', { field: 'timeZone' });
      data.timeZone = dto.timeZone;
    }
    await this.prisma.$transaction(async (tx) => {
      await tx.mentorProfile.update({ where: { id: p.id }, data });
      // The weekly ranges are wall-clock times: they follow the profile zone.
      if (zoneChanged)
        await tx.mentorAvailability.updateMany({
          where: { mentorId: p.id },
          data: { timeZone: dto.timeZone! },
        });
    });
    return this.me(userId);
  }

  /** Mentor-initiated pause/resume. A pause set by staff (it has a reason) can only be lifted by staff. */
  async setPaused(userId: string, paused: boolean): Promise<MyMentorDto> {
    const p = await this.own(userId);
    if (p.status === 'PAUSED' && p.statusReason)
      throw ApiException.forbidden('Atarah paused your profile. Contact support to resume.');
    const to = paused ? 'PAUSED' : 'APPROVED';
    if (p.status === to) return this.me(userId);
    const res = await this.prisma.mentorProfile.updateMany({
      where: { id: p.id, status: p.status },
      data: { status: to, statusReason: null },
    });
    if (res.count !== 1) throw ApiException.invalidState('Your profile changed. Try again.');
    return this.me(userId);
  }

  // ---- session types -------------------------------------------------------------------------------------------

  async createSessionType(userId: string, dto: SessionTypeFieldsDto): Promise<SessionTypeDto> {
    const p = await this.own(userId);
    const count = await this.prisma.mentorSessionType.count({
      where: { mentorId: p.id, active: true },
    });
    if (count >= MAX_SESSION_TYPES)
      throw ApiException.invalidState(`You can offer up to ${MAX_SESSION_TYPES} session types.`);
    const row = await this.prisma.mentorSessionType.create({
      data: {
        mentorId: p.id,
        name: dto.name.trim(),
        description: dto.description?.trim() || null,
        durationMinutes: dto.durationMinutes,
        priceMinor: dto.priceMinor,
        sessionCount: dto.sessionCount ?? 1,
      },
    });
    return sessionTypeDto(row);
  }

  async updateSessionType(
    userId: string,
    id: string,
    dto: UpdateSessionTypeDto,
  ): Promise<SessionTypeDto> {
    const p = await this.own(userId);
    const t = await this.prisma.mentorSessionType.findFirst({ where: { id, mentorId: p.id } });
    if (!t) throw ApiException.notFound('We could not find that session type.');
    if (dto.active === true && t.disabledByStaff)
      throw ApiException.forbidden('Atarah switched this session off. Contact support.');
    const row = await this.prisma.mentorSessionType.update({
      where: { id },
      data: {
        name: dto.name?.trim(),
        description: dto.description === undefined ? undefined : dto.description?.trim() || null,
        durationMinutes: dto.durationMinutes ?? undefined,
        priceMinor: dto.priceMinor ?? undefined,
        sessionCount: dto.sessionCount ?? undefined,
        active: dto.active ?? undefined,
      },
    });
    return sessionTypeDto(row);
  }

  /** "Delete" only switches a type off: bookings (P2-M5) keep a price snapshot and may still reference it. */
  async deactivateSessionType(userId: string, id: string): Promise<void> {
    const p = await this.own(userId);
    const res = await this.prisma.mentorSessionType.updateMany({
      where: { id, mentorId: p.id },
      data: { active: false },
    });
    if (res.count !== 1) throw ApiException.notFound('We could not find that session type.');
  }

  // ---- availability --------------------------------------------------------------------------------------------

  private async availabilityDto(p: MentorProfile): Promise<AvailabilityDto> {
    const [rows, exceptions, types] = await Promise.all([
      this.prisma.mentorAvailability.findMany({
        where: { mentorId: p.id },
        orderBy: [{ weekday: 'asc' }, { startMinute: 'asc' }],
      }),
      this.prisma.mentorAvailabilityException.findMany({
        where: { mentorId: p.id, date: { gte: new Date(Date.now() - 2 * DAY_MS) } },
        orderBy: { date: 'asc' },
      }),
      this.prisma.mentorSessionType.findMany({
        where: { mentorId: p.id, active: true, disabledByStaff: false },
      }),
    ]);
    const shortest = types.length ? Math.min(...types.map((t) => t.durationMinutes)) : null;
    const schedule = await this.availability.scheduleFor(p.id, p.timeZone);
    const next = await this.availability.nextAvailableAt(p.id, schedule, shortest);
    return {
      timeZone: p.timeZone,
      weekly: rows.map((r) => ({
        weekday: r.weekday,
        startMinute: r.startMinute,
        endMinute: r.endMinute,
      })),
      exceptions: exceptions.map((e) => ({ id: e.id, date: ymdOf(e.date), reason: e.reason })),
      nextAvailableAt: next ? next.toISOString() : null,
    };
  }

  async getAvailability(userId: string): Promise<AvailabilityDto> {
    return this.availabilityDto(await this.own(userId));
  }

  /** Replaces the whole week. Ranges on one weekday must not overlap. */
  async setWeekly(userId: string, dto: SetWeeklyAvailabilityDto): Promise<AvailabilityDto> {
    const p = await this.own(userId);
    const tz = dto.timeZone ?? p.timeZone;
    if (!isValidTimeZone(tz))
      throw ApiException.validation('That time zone is not valid.', { field: 'timeZone' });
    const sorted = [...dto.weekly].sort(
      (a, b) => a.weekday - b.weekday || a.startMinute - b.startMinute,
    );
    for (const [i, r] of sorted.entries()) {
      if (r.startMinute >= r.endMinute)
        throw ApiException.validation('A range must end after it starts.', { field: 'weekly' });
      const prev = sorted[i - 1];
      if (prev && prev.weekday === r.weekday && r.startMinute < prev.endMinute)
        throw ApiException.validation('Time ranges on the same day cannot overlap.', {
          field: 'weekly',
        });
    }
    await this.prisma.$transaction(async (tx) => {
      await tx.mentorAvailability.deleteMany({ where: { mentorId: p.id } });
      if (sorted.length)
        await tx.mentorAvailability.createMany({
          data: sorted.map((r) => ({
            mentorId: p.id,
            weekday: r.weekday,
            startMinute: r.startMinute,
            endMinute: r.endMinute,
            timeZone: tz,
          })),
        });
      if (tz !== p.timeZone)
        await tx.mentorProfile.update({ where: { id: p.id }, data: { timeZone: tz } });
    });
    return this.availabilityDto({ ...p, timeZone: tz });
  }

  async addException(userId: string, dto: AddExceptionDto): Promise<ExceptionDto> {
    const p = await this.own(userId);
    const date = new Date(`${dto.date}T00:00:00.000Z`);
    if (Number.isNaN(date.getTime()) || ymdOf(date) !== dto.date)
      throw ApiException.validation('That date is not valid.', { field: 'date' });
    if (date.getTime() < Date.now() - 2 * DAY_MS)
      throw ApiException.validation('Pick a date that has not passed.', { field: 'date' });
    if (date.getTime() > Date.now() + 400 * DAY_MS)
      throw ApiException.validation('Pick a date within the next year.', { field: 'date' });
    try {
      const row = await this.prisma.mentorAvailabilityException.create({
        data: { mentorId: p.id, date, reason: dto.reason?.trim() || null },
      });
      return { id: row.id, date: ymdOf(row.date), reason: row.reason };
    } catch (e) {
      if (e instanceof Prisma.PrismaClientKnownRequestError && e.code === 'P2002')
        throw ApiException.conflict('You already marked that date off.');
      throw e;
    }
  }

  async removeException(userId: string, id: string): Promise<void> {
    const p = await this.own(userId);
    const res = await this.prisma.mentorAvailabilityException.deleteMany({
      where: { id, mentorId: p.id },
    });
    if (res.count !== 1) throw ApiException.notFound('We could not find that date.');
  }

  // ---- booking requests (P2-M5 fills them) ---------------------------------------------------------------------

  async bookingRequests(userId: string, page: { page: number; limit: number }) {
    await this.own(userId);
    const { items, total } = await this.hooks.bookingRequests(userId, page);
    return { items, meta: pageMeta(page, total) };
  }
}
