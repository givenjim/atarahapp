import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { AccessService } from '../access/access.service';
import { MediaService } from '../media/media.service';
import { PrismaService } from '../prisma/prisma.service';
import {
  type LearningCardDto,
  type LearningCategoryRefDto,
  type LearningItemProgressDto,
} from './learning.dto';
import { percentComplete } from './learning.rules';

export const CARD_INCLUDE = {
  category: true,
  course: { select: { lessonCount: true } },
} satisfies Prisma.LearningContentInclude;

export type CardRow = Prisma.LearningContentGetPayload<{ include: typeof CARD_INCLUDE }>;

/** What members may see: published, and not scheduled for later. */
export const livePublished = (now = new Date()): Prisma.LearningContentWhereInput => ({
  status: 'PUBLISHED',
  OR: [{ publishedAt: null }, { publishedAt: { lte: now } }],
});

export const categoryRef = (c: CardRow['category']): LearningCategoryRefDto => ({
  id: c.id,
  slug: c.slug,
  name: c.name,
  group: c.group,
});

/** The per-member facts a card needs, for a batch of items at once (no query per card). */
export interface CardContext {
  premium: boolean;
  saved: ReadonlySet<string>;
  progress: ReadonlyMap<string, LearningItemProgressDto>;
  covers: ReadonlyMap<string, string | null>;
}

/** Builds the card shape shared by the hub, categories, search, My learning and Home. */
@Injectable()
export class LearningViewsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly media: MediaService,
    private readonly access: AccessService,
  ) {}

  async hasPremium(userId: string): Promise<boolean> {
    return this.access.hasEntitlement(userId, 'PREMIUM_CONTENT');
  }

  /** Per-item progress for a member: a course's completed lessons over its lessons; a single item's status. */
  async progressFor(
    userId: string,
    rows: CardRow[],
  ): Promise<Map<string, LearningItemProgressDto>> {
    const out = new Map<string, LearningItemProgressDto>();
    if (rows.length === 0) return out;
    const courseIds = rows.filter((r) => r.type === 'COURSE').map((r) => r.id);
    const otherIds = rows.filter((r) => r.type !== 'COURSE').map((r) => r.id);

    if (courseIds.length > 0) {
      const [enrolments, done] = await Promise.all([
        this.prisma.enrolment.findMany({ where: { userId, courseId: { in: courseIds } } }),
        this.prisma.lessonProgress.groupBy({
          by: ['lessonId'],
          where: { userId, status: 'COMPLETED', lesson: { courseId: { in: courseIds } } },
        }),
      ]);
      const lessonCourse = done.length
        ? await this.prisma.lesson.findMany({
            where: { id: { in: done.map((d) => d.lessonId) } },
            select: { id: true, courseId: true },
          })
        : [];
      const doneBy = new Map<string, number>();
      for (const l of lessonCourse) doneBy.set(l.courseId, (doneBy.get(l.courseId) ?? 0) + 1);
      for (const e of enrolments) {
        const total = rows.find((r) => r.id === e.courseId)?.course?.lessonCount ?? 0;
        const percent = e.completedAt ? 100 : percentComplete(doneBy.get(e.courseId) ?? 0, total);
        out.set(e.courseId, {
          status: e.completedAt ? 'COMPLETED' : 'IN_PROGRESS',
          percent,
        });
      }
    }
    if (otherIds.length > 0) {
      const items = await this.prisma.contentProgress.findMany({
        where: { userId, contentId: { in: otherIds } },
      });
      for (const p of items) {
        out.set(p.contentId, { status: p.status, percent: p.status === 'COMPLETED' ? 100 : 0 });
      }
    }
    return out;
  }

  async context(userId: string, rows: CardRow[]): Promise<CardContext> {
    const [premium, saved, progress] = await Promise.all([
      this.hasPremium(userId),
      this.prisma.savedItem.findMany({
        where: { userId, type: 'LEARNING', targetId: { in: rows.map((r) => r.id) } },
        select: { targetId: true },
      }),
      this.progressFor(userId, rows),
    ]);
    const covers = new Map<string, string | null>();
    for (const r of rows) covers.set(r.id, await this.media.imageUrl(r.coverMediaId, 600));
    return { premium, saved: new Set(saved.map((s) => s.targetId)), progress, covers };
  }

  async cards(userId: string, rows: CardRow[]): Promise<LearningCardDto[]> {
    if (rows.length === 0) return [];
    const ctx = await this.context(userId, rows);
    return rows.map((r) => this.card(r, ctx));
  }

  card(r: CardRow, ctx: CardContext): LearningCardDto {
    return {
      id: r.id,
      slug: r.slug,
      type: r.type,
      title: r.title,
      summary: r.summary,
      category: categoryRef(r.category),
      level: r.level,
      durationMinutes: r.durationMinutes,
      lessonCount: r.course?.lessonCount ?? null,
      source: r.source,
      delivery: r.delivery,
      providerName: r.providerName,
      coverUrl: ctx.covers.get(r.id) ?? null,
      access: r.access,
      premiumLocked: r.access === 'PREMIUM_CONTENT' && !ctx.premium,
      featured: r.featured,
      saved: ctx.saved.has(r.id),
      progress: ctx.progress.get(r.id) ?? null,
    };
  }
}
