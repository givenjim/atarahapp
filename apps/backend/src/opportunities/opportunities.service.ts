import { Injectable } from '@nestjs/common';
import { OpportunityType, Prisma } from '@prisma/client';
import { ApiException } from '../common/api.exception';
import { DomainEventBus } from '../community-core/domain-events';
import { pageMeta, toSkipTake } from '../common/pagination';
import { AppConfigService } from '../config/app-config.service';
import { PrismaService } from '../prisma/prisma.service';
import {
  type MyOpportunitiesQueryDto,
  type OpportunitiesHomeDto,
  type OpportunitiesQueryDto,
  type OpportunityDetailQueryDto,
  type OpportunityDto,
  type TrackOpportunityDto,
} from './opportunities.dto';
import { assertCanUnsave, CLOSING_SOON_DAYS, DAY_MS, nextTracking } from './opportunity-logic';
import {
  CARD_INCLUDE,
  openWhere,
  OpportunityViewsService,
  trackingState,
} from './opportunity-views.service';
import { RuleEngineService } from './rule-engine.service';

const HOME_FEATURED = 5;
const HOME_CLOSING = 6;
const HOME_RECENT = 8;
/** Relevance sorting scores a bounded candidate set, then pages through it. */
const RELEVANCE_CANDIDATES = 300;
/** Category tiles on the Opportunities home, in the order the prototype shows them. */
export const HOME_CATEGORIES: readonly OpportunityType[] = [
  'FUNDING',
  'GRANT',
  'JOB',
  'INTERNSHIP',
  'GIG',
  'COMPETITION',
  'FESTIVAL',
  'PARTNERSHIP',
];

const likeWords = (q: string): string[] =>
  q
    .trim()
    .split(/\s+/)
    .filter((w) => w.length > 0)
    .slice(0, 5);

@Injectable()
export class OpportunitiesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly views: OpportunityViewsService,
    private readonly rules: RuleEngineService,
    private readonly config: AppConfigService,
    private readonly bus: DomainEventBus,
  ) {}

  shareUrl(slug: string): string {
    return `${this.config.appLinkBaseUrl.replace(/\/$/, '')}/opportunities/${slug}`;
  }

  // ---- discovery ----------------------------------------------------------------------------------------------

  async home(userId: string, now = new Date()): Promise<OpportunitiesHomeDto> {
    const open = openWhere(now);
    const soonEnd = new Date(now.getTime() + CLOSING_SOON_DAYS * DAY_MS);
    const [savedCount, byType, featured, closing, recent] = await Promise.all([
      this.prisma.opportunityTracking.count({
        where: { userId, status: { in: ['SAVED', 'IN_PROGRESS'] } },
      }),
      this.prisma.opportunity.groupBy({ by: ['type'], where: open, _count: { _all: true } }),
      this.prisma.opportunity.findMany({
        where: { ...open, featuredUntil: { gt: now } },
        include: CARD_INCLUDE,
        orderBy: [{ featuredUntil: 'desc' }, { id: 'asc' }],
        take: HOME_FEATURED,
      }),
      this.prisma.opportunity.findMany({
        where: {
          status: 'PUBLISHED',
          deadlineAt: { gt: now, lte: soonEnd },
          NOT: { trackings: { some: { userId, status: { in: ['APPLIED', 'COMPLETED'] } } } },
        },
        include: CARD_INCLUDE,
        orderBy: [{ deadlineAt: 'asc' }, { id: 'asc' }],
        take: HOME_CLOSING,
      }),
      this.prisma.opportunity.findMany({
        where: open,
        include: CARD_INCLUDE,
        orderBy: [{ publishedAt: { sort: 'desc', nulls: 'last' } }, { id: 'asc' }],
        take: HOME_RECENT,
      }),
    ]);
    const counts = new Map(byType.map((g) => [g.type, g._count._all]));
    return {
      savedCount,
      categories: HOME_CATEGORIES.map((type) => ({ type, count: counts.get(type) ?? 0 })),
      featured: await this.views.cards(featured, userId, now),
      closingSoon: await this.views.cards(closing, userId, now),
      recent: await this.views.cards(recent, userId, now),
    };
  }

  async list(userId: string, q: OpportunitiesQueryDto, now = new Date()) {
    const and: Prisma.OpportunityWhereInput[] = [openWhere(now)];
    if (q.type) and.push({ type: q.type });
    if (q.trust) and.push({ trust: q.trust });
    if (q.remote) and.push({ workMode: 'REMOTE' });
    if (q.deadline) {
      const days = Number.parseInt(q.deadline, 10);
      and.push({ deadlineAt: { gt: now, lte: new Date(now.getTime() + days * DAY_MS) } });
    }
    if (q.disciplineId) {
      // A listing with no discipline is open to everyone.
      and.push({
        OR: [
          { disciplines: { none: {} } },
          { disciplines: { some: { disciplineId: q.disciplineId } } },
        ],
      });
    }
    if (q.countyId) {
      and.push({ OR: [{ countyId: q.countyId }, { countyId: null }, { workMode: 'REMOTE' }] });
    }
    for (const word of likeWords(q.q ?? '')) {
      and.push({
        OR: [
          { title: { contains: word, mode: 'insensitive' } },
          { summary: { contains: word, mode: 'insensitive' } },
          { provider: { name: { contains: word, mode: 'insensitive' } } },
        ],
      });
    }
    const where: Prisma.OpportunityWhereInput = { AND: and };
    const sort = q.sort ?? 'deadline';

    if (sort === 'relevance') {
      const [facts, candidates] = await Promise.all([
        this.rules.facts(userId),
        this.prisma.opportunity.findMany({
          where,
          include: { ...CARD_INCLUDE, disciplines: { select: { disciplineId: true } } },
          orderBy: [{ deadlineAt: { sort: 'asc', nulls: 'last' } }, { id: 'asc' }],
          take: RELEVANCE_CANDIDATES,
        }),
      ]);
      const countyId = await this.prisma.creativeProfile
        .findUnique({ where: { userId }, select: { countyId: true } })
        .then((p) => p?.countyId ?? null);
      const score = (o: (typeof candidates)[number]) =>
        (o.disciplines.some((d) => facts.disciplineIds.has(d.disciplineId)) ? 4 : 0) +
        (o.disciplines.length === 0 ? 1 : 0) +
        (countyId !== null && o.countyId === countyId ? 2 : 0) +
        (o.workMode === 'REMOTE' ? 1 : 0) +
        (o.featuredUntil && o.featuredUntil > now ? 2 : 0) +
        (o.trust === 'VERIFIED' ? 1 : 0);
      const ranked = candidates
        .map((o) => ({ o, s: score(o) }))
        .sort((a, b) => b.s - a.s)
        .map((x) => x.o);
      const { skip, take } = toSkipTake(q);
      const items = await this.views.cards(ranked.slice(skip, skip + take), userId, now);
      return { items, meta: pageMeta(q, ranked.length) };
    }

    const orderBy: Prisma.OpportunityOrderByWithRelationInput[] =
      sort === 'recent'
        ? [{ publishedAt: { sort: 'desc', nulls: 'last' } }, { id: 'asc' }]
        : [{ deadlineAt: { sort: 'asc', nulls: 'last' } }, { id: 'asc' }];
    const [total, rows] = await Promise.all([
      this.prisma.opportunity.count({ where }),
      this.prisma.opportunity.findMany({ where, include: CARD_INCLUDE, orderBy, ...toSkipTake(q) }),
    ]);
    return { items: await this.views.cards(rows, userId, now), meta: pageMeta(q, total) };
  }

  /**
   * A listing is visible while it is published, and also (as closed) to a member who is tracking it, so an expired
   * application stays reachable from Activity. Drafts, removed and archived listings answer 404.
   */
  async detail(
    userId: string,
    id: string,
    opts: OpportunityDetailQueryDto = {},
    now = new Date(),
  ): Promise<OpportunityDto> {
    const row = await this.prisma.opportunity.findFirst({
      where: {
        id,
        OR: [
          { status: 'PUBLISHED' },
          { status: { in: ['CLOSED', 'EXPIRED'] }, trackings: { some: { userId } } },
        ],
      },
      include: {
        ...CARD_INCLUDE,
        disciplines: { include: { discipline: { select: { name: true } } } },
      },
    });
    if (!row) throw ApiException.notFound('That opportunity is not available.');
    const [card] = await this.views.cards([row], userId, now);
    void this.bus.emit({ type: 'OpportunityViewed', opportunityId: id, userId });
    const gap = await this.rules.gap(userId, id, { refresh: opts.refresh === true });
    return {
      ...card!,
      about: row.about,
      requirements: this.strings(row.requirements),
      benefits: this.strings(row.benefits),
      applicationMethod: row.applicationMethod,
      applicationUrl: row.applicationMethod === 'EXTERNAL_WEBSITE' ? row.applicationUrl : null,
      applicationEmail: row.applicationMethod === 'EMAIL' ? row.applicationEmail : null,
      applicationDomain: row.applicationDomain,
      disciplines: row.disciplines.map((d) => d.discipline.name).sort(),
      profileGap: gap,
      shareUrl: this.shareUrl(row.slug),
    };
  }

  private strings(v: Prisma.JsonValue): string[] {
    return Array.isArray(v) ? v.filter((s): s is string => typeof s === 'string') : [];
  }

  // ---- saving and tracking ------------------------------------------------------------------------------------

  /** Saves a listing (idempotent). A new save needs an open listing; an existing record is returned as it is. */
  async save(userId: string, id: string, now = new Date()) {
    const existing = await this.prisma.opportunityTracking.findUnique({
      where: { userId_opportunityId: { userId, opportunityId: id } },
    });
    if (existing) return trackingState(existing);
    await this.assertOpen(id, now);
    const created = await this.prisma.opportunityTracking
      .create({ data: { userId, opportunityId: id, status: 'SAVED', savedAt: now } })
      .catch(async (e: unknown) => {
        // A second tap racing the first: the unique key says it already exists.
        if (e instanceof Prisma.PrismaClientKnownRequestError && e.code === 'P2002') {
          return this.prisma.opportunityTracking.findUniqueOrThrow({
            where: { userId_opportunityId: { userId, opportunityId: id } },
          });
        }
        throw e;
      });
    await this.bus.emit({ type: 'OpportunitySaved', opportunityId: id, userId });
    return trackingState(created);
  }

  /** Un-saving is allowed only from SAVED (nothing else recorded yet) and removes the record. */
  async unsave(userId: string, id: string): Promise<void> {
    const existing = await this.prisma.opportunityTracking.findUnique({
      where: { userId_opportunityId: { userId, opportunityId: id } },
    });
    if (!existing) return;
    assertCanUnsave(existing.status);
    await this.prisma.opportunityTracking.deleteMany({
      where: { userId, opportunityId: id, status: 'SAVED' },
    });
  }

  async track(userId: string, id: string, dto: TrackOpportunityDto, now = new Date()) {
    const existing = await this.prisma.opportunityTracking.findUnique({
      where: { userId_opportunityId: { userId, opportunityId: id } },
    });
    const action = nextTracking(existing?.status ?? null, dto);
    // Starting to track needs a listing that is still open; moving an existing record forward does not (a member can
    // still record that they applied or finished after the deadline has passed).
    if (action === 'create') await this.assertOpen(id, now);
    const notes = dto.notes?.trim() ? dto.notes.trim() : undefined;

    let row;
    if (action === 'same') {
      row = await this.prisma.opportunityTracking.update({
        where: { id: existing!.id },
        data: {
          ...(notes !== undefined ? { notes } : {}),
          ...(dto.status === 'COMPLETED' && dto.outcome ? { outcome: dto.outcome } : {}),
        },
      });
    } else {
      const stamps: Prisma.OpportunityTrackingUncheckedUpdateInput = {
        status: dto.status,
        ...(notes !== undefined ? { notes } : {}),
        ...((existing?.savedAt ?? null) === null && dto.status !== 'COMPLETED' ? { savedAt: now } : {}),
        ...(dto.status === 'APPLIED' ? { appliedAt: now } : {}),
        ...(dto.status === 'COMPLETED'
          ? { completedAt: now, outcome: dto.outcome ?? 'UNKNOWN' }
          : {}),
      };
      row = existing
        ? await this.prisma.opportunityTracking.update({ where: { id: existing.id }, data: stamps })
        : await this.prisma.opportunityTracking.create({
            data: {
              userId,
              opportunityId: id,
              status: dto.status,
              savedAt: now,
              appliedAt: dto.status === 'APPLIED' ? now : null,
              notes: notes ?? null,
            },
          });
      if (dto.status === 'APPLIED') {
        await this.bus.emit({ type: 'OpportunityApplied', opportunityId: id, userId });
      } else if (dto.status === 'COMPLETED') {
        await this.bus.emit({
          type: 'OpportunityCompleted',
          opportunityId: id,
          userId,
          outcome: row.outcome ?? 'UNKNOWN',
        });
      }
    }
    return trackingState(row);
  }

  private async assertOpen(id: string, now: Date): Promise<void> {
    const open = await this.prisma.opportunity.count({ where: { id, ...openWhere(now) } });
    if (!open) throw ApiException.notFound('That opportunity is not available.');
  }

  // ---- my opportunities ---------------------------------------------------------------------------------------

  async mine(userId: string, q: MyOpportunitiesQueryDto, now = new Date()) {
    const tab = q.tab ?? 'all';
    const live: Prisma.OpportunityWhereInput = {
      status: { in: ['PUBLISHED', 'CLOSED', 'EXPIRED'] },
    };
    const soonEnd = new Date(now.getTime() + CLOSING_SOON_DAYS * DAY_MS);
    const tabWhere = (t: typeof tab): Prisma.OpportunityTrackingWhereInput => {
      switch (t) {
        case 'saved':
          return { status: { in: ['SAVED', 'IN_PROGRESS'] } };
        case 'applied':
          return { status: 'APPLIED' };
        case 'completed':
          return { status: 'COMPLETED' };
        case 'closing':
          return {
            status: { in: ['SAVED', 'IN_PROGRESS'] },
            opportunity: { status: 'PUBLISHED', deadlineAt: { gt: now, lte: soonEnd } },
          };
        default:
          return {};
      }
    };
    const base = (t: typeof tab): Prisma.OpportunityTrackingWhereInput => ({
      userId,
      opportunity: live,
      ...tabWhere(t),
    });
    const where = base(tab);
    const order: Prisma.OpportunityTrackingOrderByWithRelationInput[] =
      tab === 'closing'
        ? [{ opportunity: { deadlineAt: 'asc' } }, { id: 'asc' }]
        : [{ updatedAt: 'desc' }, { id: 'asc' }];
    const [total, rows, all, closing, applied, completed, saved] = await Promise.all([
      this.prisma.opportunityTracking.count({ where }),
      this.prisma.opportunityTracking.findMany({
        where,
        include: { opportunity: { include: CARD_INCLUDE } },
        orderBy: order,
        ...toSkipTake(q),
      }),
      this.prisma.opportunityTracking.count({ where: base('all') }),
      this.prisma.opportunityTracking.count({ where: base('closing') }),
      this.prisma.opportunityTracking.count({ where: base('applied') }),
      this.prisma.opportunityTracking.count({ where: base('completed') }),
      this.prisma.opportunityTracking.count({ where: base('saved') }),
    ]);
    const cards = await this.views.cards(
      rows.map((r) => r.opportunity),
      userId,
      now,
    );
    return {
      items: rows.map((r, i) => ({ opportunity: cards[i]!, tracking: trackingState(r) })),
      meta: { ...pageMeta(q, total), counts: { all, closing, applied, completed, saved } },
    };
  }

  /** Used by search: visible listings matching a query, best match first. */
  async searchCards(userId: string, ids: string[], now = new Date()) {
    const rows = await this.prisma.opportunity.findMany({
      where: { id: { in: ids }, ...openWhere(now) },
      include: CARD_INCLUDE,
    });
    const order = new Map(ids.map((id, i) => [id, i]));
    rows.sort((a, b) => (order.get(a.id) ?? 0) - (order.get(b.id) ?? 0));
    return this.views.cards(rows, userId, now);
  }

  /** How many opportunities the member has saved (the badge on the saved button). */
  savedCount(userId: string): Promise<number> {
    return this.prisma.opportunityTracking.count({
      where: { userId, status: { in: ['SAVED', 'IN_PROGRESS'] } },
    });
  }
}
