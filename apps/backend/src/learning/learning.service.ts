import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { ApiException } from '../common/api.exception';
import { ErrorCode } from '../common/error-codes';
import { DomainEventBus } from '../community-core/domain-events';
import { pageMeta, toSkipTake } from '../common/pagination';
import { AppConfigService } from '../config/app-config.service';
import { readBlocks } from '../content/blocks';
import { MediaService } from '../media/media.service';
import { PrismaService } from '../prisma/prisma.service';
import {
  type CategoryQueryDto,
  type ContinueLearningDto,
  type CourseInfoDto,
  type EnrolmentDto,
  type HubCategoryDto,
  type LearningCardDto,
  type LearningCategoryPageDto,
  type LearningDetailDto,
  type LearningHubDto,
  type LearningItemProgressDto,
  type LearningSearchQueryDto,
  type LearningStatsDto,
  type MyLearningQueryDto,
  type RecommendedDto,
} from './learning.dto';
import { lessonStates, nairobiMonthStart, percentComplete } from './learning.rules';
import {
  CARD_INCLUDE,
  type CardRow,
  LearningViewsService,
  livePublished,
} from './learning-views.service';

const HUB_FEATURED = 6;
const HUB_RECOMMENDED = 6;
const RECOMMEND_CANDIDATES = 120;

/** Which Skill Lab categories answer a "development area" the member picked in onboarding. */
export const DEVELOPMENT_AREA_CATEGORIES: Readonly<Record<string, readonly string[]>> = {
  'pricing-my-work': ['financial-literacy', 'entrepreneurship'],
  'building-a-portfolio': ['portfolio-building'],
  'grant-writing': ['career-development', 'entrepreneurship'],
  'personal-branding': ['branding', 'marketing'],
  'legal-awareness': ['legal-awareness'],
};

const strings = (v: Prisma.JsonValue): string[] =>
  Array.isArray(v) ? v.filter((s): s is string => typeof s === 'string') : [];

const domainOf = (url: string | null): string | null => {
  if (!url) return null;
  try {
    return new URL(url).hostname.replace(/^www\./, '').toLowerCase();
  } catch {
    return null;
  }
};

@Injectable()
export class LearningService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly views: LearningViewsService,
    private readonly media: MediaService,
    private readonly config: AppConfigService,
    private readonly bus: DomainEventBus,
  ) {}

  shareUrl(slug: string): string {
    return `${this.config.appLinkBaseUrl.replace(/\/$/, '')}/learning/${slug}`;
  }

  // ---- hub ----------------------------------------------------------------------------------------------------

  async hub(userId: string, now = new Date()): Promise<LearningHubDto> {
    const live = livePublished(now);
    const [continueLearning, featured, categories, recommended] = await Promise.all([
      this.continueCard(userId, now),
      this.prisma.learningContent
        .findMany({
          where: { ...live, featured: true },
          include: CARD_INCLUDE,
          orderBy: [{ publishedAt: { sort: 'desc', nulls: 'last' } }, { id: 'asc' }],
          take: HUB_FEATURED,
        })
        .then((rows) => this.views.cards(userId, rows)),
      this.hubCategories(now),
      this.recommended(userId, now),
    ]);
    return { continueLearning, featured, categories, recommended };
  }

  private async hubCategories(now: Date): Promise<HubCategoryDto[]> {
    const [cats, counts] = await Promise.all([
      this.prisma.learningCategory.findMany({
        where: { isActive: true },
        orderBy: [{ group: 'asc' }, { sortOrder: 'asc' }],
      }),
      this.prisma.learningContent.groupBy({
        by: ['categoryId'],
        where: livePublished(now),
        _count: { _all: true },
      }),
    ]);
    const byCat = new Map(counts.map((c) => [c.categoryId, c._count._all]));
    return cats.map((c) => ({
      id: c.id,
      slug: c.slug,
      name: c.name,
      group: c.group,
      count: byCat.get(c.id) ?? 0,
    }));
  }

  /** The unfinished course the member touched last: the dark "Continue learning" card with a real percentage. */
  private async continueCard(userId: string, now: Date): Promise<ContinueLearningDto | null> {
    const enrolments = await this.prisma.enrolment.findMany({
      where: { userId, completedAt: null, course: { content: livePublished(now) } },
      include: {
        course: {
          include: {
            content: { include: CARD_INCLUDE },
            lessons: { orderBy: { sequence: 'asc' } },
          },
        },
      },
      orderBy: { enrolledAt: 'desc' },
      take: 12,
    });
    if (enrolments.length === 0) return null;
    const progress = await this.prisma.lessonProgress.findMany({
      where: { userId, lesson: { courseId: { in: enrolments.map((e) => e.courseId) } } },
      select: {
        status: true,
        updatedAt: true,
        lessonId: true,
        lesson: { select: { courseId: true } },
      },
    });
    const last = new Map<string, Date>();
    for (const p of progress) {
      const cur = last.get(p.lesson.courseId);
      if (!cur || p.updatedAt > cur) last.set(p.lesson.courseId, p.updatedAt);
    }
    const best = [...enrolments].sort(
      (a, b) =>
        (last.get(b.courseId) ?? b.enrolledAt).getTime() -
        (last.get(a.courseId) ?? a.enrolledAt).getTime(),
    )[0]!;
    const done = new Set(
      progress
        .filter((p) => p.status === 'COMPLETED' && p.lesson.courseId === best.courseId)
        .map((p) => p.lessonId),
    );
    const lessons = best.course.lessons;
    const states = lessonStates(lessons, done, best.course.sequential);
    const next = lessons.find((l) => states.get(l.id) === 'CURRENT') ?? null;
    const [card] = await this.views.cards(userId, [best.course.content]);
    return {
      content: card!,
      percent: percentComplete(done.size, lessons.length),
      lessonsDone: done.size,
      lessonCount: lessons.length,
      nextLessonId: next?.id ?? null,
      nextLessonTitle: next?.title ?? null,
    };
  }

  /** Recommendations with a reason line drawn from the member's own areas to develop, skills and disciplines. */
  private async recommended(userId: string, now: Date): Promise<RecommendedDto[]> {
    const profile = await this.prisma.creativeProfile.findUnique({
      where: { userId },
      select: {
        disciplines: { select: { disciplineId: true, discipline: { select: { name: true } } } },
        skills: { select: { skillId: true, skill: { select: { name: true } } } },
        developmentAreas: { select: { developmentArea: { select: { slug: true, name: true } } } },
      },
    });
    if (!profile) return [];
    const mine = await this.prisma.enrolment.findMany({
      where: { userId },
      select: { courseId: true },
    });
    const taken = new Set(mine.map((e) => e.courseId));
    const areas = profile.developmentAreas.map((d) => d.developmentArea);
    const wantedSlugs = new Map<string, string>();
    for (const a of areas) {
      for (const slug of DEVELOPMENT_AREA_CATEGORIES[a.slug] ?? []) wantedSlugs.set(slug, a.name);
    }
    const skillIds = new Set(profile.skills.map((s) => s.skillId));
    const skillName = new Map(profile.skills.map((s) => [s.skillId, s.skill.name]));
    const disciplineIds = new Set(profile.disciplines.map((d) => d.disciplineId));
    const disciplineName = new Map(
      profile.disciplines.map((d) => [d.disciplineId, d.discipline.name]),
    );

    const rows = await this.prisma.learningContent.findMany({
      where: livePublished(now),
      include: {
        ...CARD_INCLUDE,
        skills: { select: { skillId: true } },
        disciplines: { select: { disciplineId: true } },
      },
      orderBy: [
        { featured: 'desc' },
        { publishedAt: { sort: 'desc', nulls: 'last' } },
        { id: 'asc' },
      ],
      take: RECOMMEND_CANDIDATES,
    });
    const scored = rows
      .filter((r) => !taken.has(r.id))
      .map((r) => {
        const area = wantedSlugs.get(r.category.slug);
        const sharedSkill = r.skills.find((s) => skillIds.has(s.skillId));
        const sharedDiscipline = r.disciplines.find((d) => disciplineIds.has(d.disciplineId));
        const reason = area
          ? `Because you want to develop ${area}`
          : sharedSkill
            ? `Builds on your ${skillName.get(sharedSkill.skillId)}`
            : sharedDiscipline
              ? `For ${disciplineName.get(sharedDiscipline.disciplineId)} creatives`
              : null;
        return {
          r,
          reason,
          score: (area ? 3 : 0) + (sharedSkill ? 2 : 0) + (sharedDiscipline ? 1 : 0),
        };
      })
      .filter((x) => x.reason !== null)
      .sort((a, b) => b.score - a.score)
      .slice(0, HUB_RECOMMENDED);
    const cards = await this.views.cards(
      userId,
      scored.map((s) => s.r),
    );
    return scored.map((s, i) => ({ content: cards[i]!, reason: s.reason! }));
  }

  // ---- categories and search ----------------------------------------------------------------------------------

  async category(userId: string, slug: string, q: CategoryQueryDto, now = new Date()) {
    const category = await this.prisma.learningCategory.findFirst({
      where: { slug: slug.toLowerCase(), isActive: true },
    });
    if (!category) throw ApiException.notFound('That category does not exist.');
    const live = livePublished(now);
    const where: Prisma.LearningContentWhereInput = {
      ...live,
      categoryId: category.id,
      ...(q.type ? { type: q.type } : {}),
    };
    const [byType, total, rows] = await Promise.all([
      this.prisma.learningContent.groupBy({
        by: ['type'],
        where: { ...live, categoryId: category.id },
        _count: { _all: true },
      }),
      this.prisma.learningContent.count({ where }),
      this.prisma.learningContent.findMany({
        where,
        include: CARD_INCLUDE,
        orderBy: [
          { featured: 'desc' },
          { publishedAt: { sort: 'desc', nulls: 'last' } },
          { id: 'asc' },
        ],
        ...toSkipTake(q),
      }),
    ]);
    const page: LearningCategoryPageDto = {
      category: {
        id: category.id,
        slug: category.slug,
        name: category.name,
        group: category.group,
      },
      total: byType.reduce((n, g) => n + g._count._all, 0),
      types: byType.map((g) => ({ type: g.type, count: g._count._all })),
    };
    return { page, items: await this.views.cards(userId, rows), meta: pageMeta(q, total) };
  }

  async search(userId: string, q: LearningSearchQueryDto, now = new Date()) {
    const and: Prisma.LearningContentWhereInput[] = [livePublished(now)];
    if (q.type) and.push({ type: q.type });
    for (const word of (q.q ?? '').trim().split(/\s+/).filter(Boolean).slice(0, 5)) {
      and.push({
        OR: [
          { title: { contains: word, mode: 'insensitive' } },
          { summary: { contains: word, mode: 'insensitive' } },
          { providerName: { contains: word, mode: 'insensitive' } },
        ],
      });
    }
    const where: Prisma.LearningContentWhereInput = { AND: and };
    const [total, rows] = await Promise.all([
      this.prisma.learningContent.count({ where }),
      this.prisma.learningContent.findMany({
        where,
        include: CARD_INCLUDE,
        orderBy: [
          { featured: 'desc' },
          { publishedAt: { sort: 'desc', nulls: 'last' } },
          { id: 'asc' },
        ],
        ...toSkipTake(q),
      }),
    ]);
    return { items: await this.views.cards(userId, rows), meta: pageMeta(q, total) };
  }

  /** Cards for ids found by the search service, in the order given (visible ones only). */
  async searchCards(userId: string, ids: string[], now = new Date()): Promise<LearningCardDto[]> {
    const rows = await this.prisma.learningContent.findMany({
      where: { id: { in: ids }, ...livePublished(now) },
      include: CARD_INCLUDE,
    });
    const order = new Map(ids.map((id, i) => [id, i]));
    rows.sort((a, b) => (order.get(a.id) ?? 0) - (order.get(b.id) ?? 0));
    return this.views.cards(userId, rows);
  }

  // ---- detail -------------------------------------------------------------------------------------------------

  /** An item is open to a member while published; a member already learning it keeps access to an archived course. */
  async findVisible(userId: string, idOrSlug: string, now = new Date()) {
    const isId = /^[0-9a-f-]{36}$/i.test(idOrSlug);
    const row = await this.prisma.learningContent.findFirst({
      where: {
        ...(isId ? { id: idOrSlug } : { slug: idOrSlug.toLowerCase() }),
        OR: [
          livePublished(now),
          {
            status: 'ARCHIVED',
            OR: [
              { course: { enrolments: { some: { userId } } } },
              { progress: { some: { userId } } },
            ],
          },
        ],
      },
      include: {
        ...CARD_INCLUDE,
        instructor: {
          select: { fullName: true, creativeProfile: { select: { displayName: true } } },
        },
        disciplines: { include: { discipline: { select: { name: true } } } },
        skills: { include: { skill: { select: { id: true, name: true } } } },
        course: { include: { lessons: { orderBy: { sequence: 'asc' } } } },
      },
    });
    if (!row) throw ApiException.notFound('That Skill Lab is not available.');
    return row;
  }

  async detail(userId: string, idOrSlug: string): Promise<LearningDetailDto> {
    const row = await this.findVisible(userId, idOrSlug);
    const [card] = await this.views.cards(userId, [row as unknown as CardRow]);
    let course: CourseInfoDto | null = null;
    let itemProgress: LearningItemProgressDto | null = null;

    if (row.course) {
      const lessons = row.course.lessons;
      const [enrolment, progress, certificate] = await Promise.all([
        this.prisma.enrolment.findUnique({
          where: { userId_courseId: { userId, courseId: row.id } },
        }),
        this.prisma.lessonProgress.findMany({
          where: { userId, lessonId: { in: lessons.map((l) => l.id) } },
        }),
        this.prisma.certificate.findUnique({
          where: { userId_courseId: { userId, courseId: row.id } },
        }),
      ]);
      const done = new Set(progress.filter((p) => p.status === 'COMPLETED').map((p) => p.lessonId));
      const states = lessonStates(lessons, done, row.course.sequential, enrolment !== null);
      const next = lessons.find((l) => states.get(l.id) === 'CURRENT') ?? null;
      course = {
        lessonCount: lessons.length,
        totalMinutes: row.course.totalMinutes,
        sequential: row.course.sequential,
        enrolled: enrolment !== null,
        completedLessons: done.size,
        percent: enrolment?.completedAt ? 100 : percentComplete(done.size, lessons.length),
        nextLessonId:
          enrolment && !enrolment.completedAt ? (next?.id ?? null) : (lessons[0]?.id ?? null),
        lessons: lessons.map((l) => ({
          id: l.id,
          sequence: l.sequence,
          title: l.title,
          durationMinutes: l.durationMinutes,
          state: states.get(l.id)!,
          hasVideo: l.videoMediaId !== null,
          hasEmbed: l.embedUrl !== null,
        })),
        certificate: certificate
          ? {
              certificateNumber: certificate.certificateNumber,
              issuedAt: certificate.issuedAt,
              achievementId: certificate.achievementId,
            }
          : null,
      };
    } else {
      itemProgress = card!.progress;
    }

    const locked = card!.premiumLocked;
    const instructor =
      row.instructor?.creativeProfile?.displayName ?? row.instructor?.fullName ?? null;
    return {
      ...card!,
      whatYouLearn: strings(row.whatYouLearn),
      whoItsFor: row.whoItsFor,
      instructorName: instructor,
      disciplines: row.disciplines.map((d) => d.discipline.name).sort(),
      skills: row.skills.map((s) => ({ id: s.skill.id, name: s.skill.name })),
      course,
      // Addresses are not handed to a member who cannot open the item.
      externalUrl: !locked && row.delivery === 'EXTERNAL_LINK' ? row.externalUrl : null,
      externalDomain: row.delivery === 'EXTERNAL_LINK' ? domainOf(row.externalUrl) : null,
      embedUrl: !locked && row.delivery === 'EMBEDDED' && !row.course ? row.embedUrl : null,
      linkStatus: row.linkStatus,
      itemProgress,
      shareUrl: this.shareUrl(row.slug),
    };
  }

  // ---- enrolment and single items -----------------------------------------------------------------------------

  /** Premium content answers PREMIUM_REQUIRED to a member without Pro. The guard UI is AtPremiumGate. */
  async assertAccess(userId: string, access: 'FREE' | 'PREMIUM_CONTENT'): Promise<void> {
    if (access === 'PREMIUM_CONTENT' && !(await this.views.hasPremium(userId))) {
      throw new ApiException(ErrorCode.PREMIUM_REQUIRED, 'This is part of Atarah Pro.', 403, {
        entitlement: 'PREMIUM_CONTENT',
      });
    }
  }

  async enrol(userId: string, id: string): Promise<EnrolmentDto> {
    const row = await this.findVisible(userId, id);
    if (!row.course)
      throw ApiException.invalidState('Only courses can be enrolled in. Start this one instead.');
    await this.assertAccess(userId, row.access);
    const existing = await this.prisma.enrolment.findUnique({
      where: { userId_courseId: { userId, courseId: row.id } },
    });
    const enrolment =
      existing ??
      (await this.prisma.enrolment
        .create({ data: { userId, courseId: row.id } })
        .catch(async (e: unknown) => {
          // A second tap racing the first.
          if (e instanceof Prisma.PrismaClientKnownRequestError && e.code === 'P2002') {
            return this.prisma.enrolment.findUniqueOrThrow({
              where: { userId_courseId: { userId, courseId: row.id } },
            });
          }
          throw e;
        }));
    if (!existing) await this.bus.emit({ type: 'CourseStarted', userId, courseId: row.id });
    const done = await this.prisma.lessonProgress.findMany({
      where: { userId, status: 'COMPLETED', lesson: { courseId: row.id } },
      select: { lessonId: true },
    });
    const states = lessonStates(
      row.course.lessons,
      new Set(done.map((d) => d.lessonId)),
      row.course.sequential,
    );
    return {
      courseId: row.id,
      enrolledAt: enrolment.enrolledAt,
      nextLessonId: row.course.lessons.find((l) => states.get(l.id) === 'CURRENT')?.id ?? null,
    };
  }

  /** Non-course items: opening one marks it started. Opening again changes nothing. */
  async start(userId: string, id: string): Promise<LearningItemProgressDto> {
    const row = await this.findVisible(userId, id);
    if (row.course) throw ApiException.invalidState('Courses are started by enrolling.');
    await this.assertAccess(userId, row.access);
    const p = await this.prisma.contentProgress.upsert({
      where: { userId_contentId: { userId, contentId: row.id } },
      create: { userId, contentId: row.id, status: 'IN_PROGRESS' },
      update: {},
    });
    return { status: p.status, percent: p.status === 'COMPLETED' ? 100 : 0 };
  }

  /** The member marks an external or single item complete by hand. Completed once; its duration counts as time spent. */
  async completeItem(
    userId: string,
    id: string,
    now = new Date(),
  ): Promise<LearningItemProgressDto> {
    const row = await this.findVisible(userId, id);
    if (row.course) throw ApiException.invalidState('Courses finish when every lesson is done.');
    await this.assertAccess(userId, row.access);
    const existing = await this.prisma.contentProgress.findUnique({
      where: { userId_contentId: { userId, contentId: row.id } },
    });
    if (existing?.status === 'COMPLETED') return { status: 'COMPLETED', percent: 100 };
    await this.prisma.$transaction(async (tx) => {
      await tx.contentProgress.upsert({
        where: { userId_contentId: { userId, contentId: row.id } },
        create: { userId, contentId: row.id, status: 'COMPLETED', completedAt: now },
        update: { status: 'COMPLETED', completedAt: now },
      });
      if (row.durationMinutes > 0) {
        await this.addMinutes(tx, userId, row.durationMinutes, now);
      }
    });
    return { status: 'COMPLETED', percent: 100 };
  }

  async addMinutes(
    db: Pick<Prisma.TransactionClient, '$executeRaw'>,
    userId: string,
    minutes: number,
    now: Date,
  ): Promise<void> {
    if (minutes <= 0) return;
    const date = new Date(Date.UTC(0, 0, 1));
    const n = new Date(now.getTime() + 3 * 3_600_000);
    date.setUTCFullYear(n.getUTCFullYear(), n.getUTCMonth(), n.getUTCDate());
    await db.$executeRaw(Prisma.sql`
      INSERT INTO learning_activity_daily ("userId", "date", "minutes") VALUES (${userId}::uuid, ${date}::date, ${minutes})
      ON CONFLICT ("userId", "date") DO UPDATE SET "minutes" = learning_activity_daily."minutes" + EXCLUDED."minutes"`);
  }

  // ---- saving -------------------------------------------------------------------------------------------------

  async save(userId: string, id: string): Promise<void> {
    const row = await this.findVisible(userId, id);
    await this.prisma.savedItem.upsert({
      where: { userId_type_targetId: { userId, type: 'LEARNING', targetId: row.id } },
      create: { userId, type: 'LEARNING', targetId: row.id },
      update: {},
    });
  }

  async unsave(userId: string, id: string): Promise<void> {
    await this.prisma.savedItem.deleteMany({ where: { userId, type: 'LEARNING', targetId: id } });
  }

  // ---- my learning --------------------------------------------------------------------------------------------

  async mine(userId: string, q: MyLearningQueryDto, now = new Date()) {
    const tab = q.tab ?? 'active';
    type Entry = { id: string; at: Date | null };
    let entries: Entry[] = [];

    if (tab === 'saved') {
      const saved = await this.prisma.savedItem.findMany({
        where: { userId, type: 'LEARNING' },
        orderBy: { createdAt: 'desc' },
      });
      entries = saved.map((s) => ({ id: s.targetId, at: s.createdAt }));
    } else {
      const completed = tab === 'completed';
      const [enrolments, items, activity] = await Promise.all([
        this.prisma.enrolment.findMany({
          where: { userId, completedAt: completed ? { not: null } : null },
        }),
        this.prisma.contentProgress.findMany({
          where: { userId, status: completed ? 'COMPLETED' : 'IN_PROGRESS' },
        }),
        this.prisma.lessonProgress.findMany({
          where: { userId },
          select: { updatedAt: true, lesson: { select: { courseId: true } } },
        }),
      ]);
      const lastLesson = new Map<string, Date>();
      for (const a of activity) {
        const cur = lastLesson.get(a.lesson.courseId);
        if (!cur || a.updatedAt > cur) lastLesson.set(a.lesson.courseId, a.updatedAt);
      }
      entries = [
        ...enrolments.map((e) => ({
          id: e.courseId,
          at: completed ? e.completedAt : (lastLesson.get(e.courseId) ?? e.enrolledAt),
        })),
        ...items.map((p) => ({ id: p.contentId, at: completed ? p.completedAt : p.updatedAt })),
      ];
    }
    entries.sort((a, b) => (b.at?.getTime() ?? 0) - (a.at?.getTime() ?? 0));
    // Items that are gone or no longer visible are left out (an archived course the member is on stays).
    const rows = await this.prisma.learningContent.findMany({
      where: {
        id: { in: entries.map((e) => e.id) },
        OR: [livePublished(now), { status: 'ARCHIVED' }],
      },
      include: CARD_INCLUDE,
    });
    const byId = new Map(rows.map((r) => [r.id, r]));
    const live = entries.filter((e) => byId.has(e.id));
    const { skip, take } = toSkipTake(q);
    const slice = live.slice(skip, skip + take);
    const cards = await this.views.cards(
      userId,
      slice.map((e) => byId.get(e.id)!),
    );
    return {
      items: slice.map((e, i) => ({ content: cards[i]!, lastActivityAt: e.at })),
      meta: pageMeta(q, live.length),
    };
  }

  async stats(userId: string, now = new Date()): Promise<LearningStatsDto> {
    const monthStart = nairobiMonthStart(now);
    const [activeCourses, doneCourses, activeItems, doneItems, minutes] = await Promise.all([
      this.prisma.enrolment.count({ where: { userId, completedAt: null } }),
      this.prisma.enrolment.count({ where: { userId, completedAt: { not: null } } }),
      this.prisma.contentProgress.count({ where: { userId, status: 'IN_PROGRESS' } }),
      this.prisma.contentProgress.count({ where: { userId, status: 'COMPLETED' } }),
      this.prisma.learningActivityDaily.aggregate({
        where: { userId, date: { gte: monthStart } },
        _sum: { minutes: true },
      }),
    ]);
    const total = minutes._sum.minutes ?? 0;
    return {
      inProgress: activeCourses + activeItems,
      completed: doneCourses + doneItems,
      minutesThisMonth: total,
      hoursThisMonth: Math.round((total / 60) * 10) / 10,
    };
  }

  /** A short text of a lesson body, for tests and list previews. */
  static bodyText(body: Prisma.JsonValue): string {
    return readBlocks(body)
      .map((b) => ('text' in b ? b.text : ''))
      .join(' ');
  }
}
