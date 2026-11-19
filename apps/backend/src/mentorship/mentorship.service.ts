import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { AccessService } from '../access/access.service';
import { ApiException } from '../common/api.exception';
import { pageMeta } from '../common/pagination';
import { PrismaService } from '../prisma/prisma.service';
import { HORIZON_DAYS, isValidTimeZone, localDateString } from './availability';
import { AvailabilityService } from './availability.service';
import { MentorshipHooks } from './busy-slots';
import {
  type MentorCardDto,
  type MentorDetailDto,
  type MentorsQueryDto,
  type MentorshipHomeDto,
  type SlotsDto,
  type SlotsQueryDto,
} from './mentorship.dto';
import {
  credentialsOf,
  isBookable,
  MentorViewsService,
  sessionTypeDto,
  type MentorWithTypes,
} from './mentor-views.service';

const DAY_MS = 86_400_000;
const DIRECTORY_CAP = 300;
const DEFAULT_VIEWER_ZONE = 'Africa/Nairobi';

/** Mentorship discovery for members: hub, directory, mentor profile and (Pro only) bookable slots. */
@Injectable()
export class MentorshipService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly access: AccessService,
    private readonly views: MentorViewsService,
    private readonly availability: AvailabilityService,
    private readonly hooks: MentorshipHooks,
  ) {}

  /** A mentor is listed when approved, with an active account and at least one bookable session type. */
  private listedWhere(): Prisma.MentorProfileWhereInput {
    return {
      status: 'APPROVED',
      sessionTypes: { some: { active: true, disabledByStaff: false } },
    };
  }

  async home(userId: string): Promise<MentorshipHomeDto> {
    const now = new Date();
    const [canBook, mine, application, next, featured] = await Promise.all([
      this.access.hasEntitlement(userId, 'MENTORSHIP_BOOKING'),
      this.prisma.mentorProfile.findUnique({ where: { userId }, select: { status: true } }),
      this.prisma.mentorApplication.findFirst({
        where: { userId },
        orderBy: { createdAt: 'desc' },
        select: { status: true },
      }),
      this.hooks.nextSession(userId),
      this.prisma.mentorProfile.findMany({
        where: this.listedWhere(),
        include: { sessionTypes: true },
        orderBy: [{ featured: 'desc' }, { ratingAverage: 'desc' }, { sessionsCount: 'desc' }],
        take: 24,
      }),
    ]);
    const people = await this.views.people(featured.map((f) => f.userId));
    const live = featured.filter((f) => people.get(f.userId)?.active).slice(0, 10);
    return {
      canBook,
      isMentor: mine?.status === 'APPROVED' || mine?.status === 'PAUSED',
      applicationStatus: application?.status ?? null,
      nextSession: next,
      topMentors: await this.views.cards(live, now, people),
    };
  }

  async list(userId: string, q: MentorsQueryDto) {
    const now = new Date();
    const and: Prisma.MentorProfileWhereInput[] = [this.listedWhere()];
    if (q.disciplineId) and.push({ disciplineIds: { has: q.disciplineId } });
    if (q.verified) and.push({ verificationStatus: 'VERIFIED' });
    if (q.videoCall)
      and.push({
        sessionTypes: { some: { active: true, disabledByStaff: false, format: 'VIDEO_CALL' } },
      });
    if (q.maxPriceMinor !== undefined)
      and.push({
        sessionTypes: {
          some: { active: true, disabledByStaff: false, priceMinor: { lte: q.maxPriceMinor } },
        },
      });
    const rows = await this.prisma.mentorProfile.findMany({
      where: { AND: and },
      include: { sessionTypes: true },
      orderBy: [{ featured: 'desc' }, { ratingAverage: 'desc' }, { createdAt: 'asc' }],
      take: DIRECTORY_CAP,
    });
    const people = await this.views.people(rows.map((r) => r.userId));
    const needle = q.q?.trim().toLowerCase();
    const candidates = rows.filter((r) => {
      const p = people.get(r.userId);
      if (!p?.active) return false;
      if (r.userId === userId) return false;
      if (!needle) return true;
      return (
        p.displayName.toLowerCase().includes(needle) ||
        r.headline.toLowerCase().includes(needle) ||
        r.expertiseTags.some((t) => t.toLowerCase().includes(needle))
      );
    });
    let cards = await this.views.cards(candidates, now, people);
    if (q.availableThisWeek) {
      const limit = now.getTime() + 7 * DAY_MS;
      cards = cards.filter((c) => c.nextAvailableAt && Date.parse(c.nextAvailableAt) <= limit);
    }
    cards = sortCards(cards, q.sort ?? 'recommended');
    const start = (q.page - 1) * q.limit;
    return { items: cards.slice(start, start + q.limit), meta: pageMeta(q, cards.length) };
  }

  /** A listed mentor, or 404. Paused, removed and unbookable profiles are not discoverable. */
  private async listed(id: string): Promise<MentorWithTypes> {
    const row = await this.prisma.mentorProfile.findFirst({
      where: { id, status: 'APPROVED' },
      include: { sessionTypes: { orderBy: { priceMinor: 'asc' } } },
    });
    const people = row ? await this.views.people([row.userId]) : null;
    if (!row || !people?.get(row.userId)?.active)
      throw ApiException.notFound('That mentor is not available.');
    return row;
  }

  async detail(userId: string, id: string): Promise<MentorDetailDto> {
    const row = await this.listed(id);
    const people = await this.views.people([row.userId]);
    const [card] = await this.views.cards([row], new Date(), people);
    const [disciplines, canBook] = await Promise.all([
      row.disciplineIds.length
        ? this.prisma.discipline.findMany({
            where: { id: { in: row.disciplineIds } },
            select: { id: true, name: true },
          })
        : [],
      this.access.hasEntitlement(userId, 'MENTORSHIP_BOOKING'),
    ]);
    const isSelf = row.userId === userId;
    return {
      ...card!,
      bio: row.bio,
      yearsExperience: row.yearsExperience,
      disciplines,
      credentials: credentialsOf(row.credentials),
      sessionTypes: row.sessionTypes.filter(isBookable).map(sessionTypeDto),
      booking: { allowed: canBook && !isSelf, requiresPro: !canBook && !isSelf, isSelf },
    };
  }

  /**
   * Bookable slots. The route carries `@RequiresEntitlement('MENTORSHIP_BOOKING')`, so a Free member gets the
   * PREMIUM_REQUIRED response before this runs; this only adds the ownership and validity checks.
   */
  async slots(userId: string, id: string, q: SlotsQueryDto): Promise<SlotsDto> {
    const row = await this.listed(id);
    if (row.userId === userId) throw ApiException.forbidden('You cannot book your own sessions.');
    const type = row.sessionTypes.find((t) => t.id === q.sessionTypeId && isBookable(t));
    if (!type) throw ApiException.notFound('That session is not available.');
    const viewerTimeZone = q.timeZone ?? DEFAULT_VIEWER_ZONE;
    if (!isValidTimeZone(viewerTimeZone))
      throw ApiException.validation('That time zone is not valid.', { field: 'timeZone' });
    const now = new Date();
    const from = q.from ? new Date(q.from) : now;
    const to = q.to ? new Date(q.to) : new Date(from.getTime() + 14 * DAY_MS);
    if (to <= from) throw ApiException.validation('"to" must be after "from".', { field: 'to' });
    if (to.getTime() - from.getTime() > HORIZON_DAYS * DAY_MS)
      throw ApiException.validation(`Ask for at most ${HORIZON_DAYS} days at a time.`, {
        field: 'to',
      });
    const schedule = await this.availability.scheduleFor(row.id, row.timeZone, now);
    const starts = await this.availability.slots(
      row.id,
      schedule,
      type.durationMinutes,
      from,
      to,
      now,
    );
    return {
      mentorId: row.id,
      sessionTypeId: type.id,
      durationMinutes: type.durationMinutes,
      mentorTimeZone: row.timeZone,
      viewerTimeZone,
      slots: starts.map((s) => ({
        startsAt: s.toISOString(),
        endsAt: new Date(s.getTime() + type.durationMinutes * 60_000).toISOString(),
        localDate: localDateString(viewerTimeZone, s),
      })),
    };
  }
}

function sortCards(cards: MentorCardDto[], sort: string): MentorCardDto[] {
  const byId = (a: MentorCardDto, b: MentorCardDto) => a.id.localeCompare(b.id);
  const out = [...cards];
  switch (sort) {
    case 'soonest':
      return out.sort(
        (a, b) =>
          (a.nextAvailableAt ? Date.parse(a.nextAvailableAt) : Infinity) -
            (b.nextAvailableAt ? Date.parse(b.nextAvailableAt) : Infinity) || byId(a, b),
      );
    case 'price':
      return out.sort(
        (a, b) => (a.fromPriceMinor ?? Infinity) - (b.fromPriceMinor ?? Infinity) || byId(a, b),
      );
    case 'rating':
      return out.sort(
        (a, b) => b.ratingAverage - a.ratingAverage || b.ratingCount - a.ratingCount || byId(a, b),
      );
    default:
      return out.sort(
        (a, b) =>
          Number(b.featured) - Number(a.featured) ||
          b.ratingAverage - a.ratingAverage ||
          b.sessionsCount - a.sessionsCount ||
          byId(a, b),
      );
  }
}
