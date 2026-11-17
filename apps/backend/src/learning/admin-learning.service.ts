import { randomBytes } from 'node:crypto';
import { Injectable } from '@nestjs/common';
import { type LearningContentType, Prisma } from '@prisma/client';
import { AuditService } from '../audit/audit.service';
import { ApiException } from '../common/api.exception';
import { pageMeta, toSkipTake } from '../common/pagination';
import { normaliseBlocks, readBlocks } from '../content/blocks';
import { PlatformSettingsService } from '../feature-flags/platform-settings.service';
import { MediaService } from '../media/media.service';
import { PrismaService, type TxClient } from '../prisma/prisma.service';
import { slugify } from '../opportunities/opportunity-logic';
import {
  type AdminCategoryDto,
  type AdminContentDto,
  type AdminContentsQueryDto,
  type AdminLessonDto,
  type CategoryFieldsDto,
  type ContentFieldsDto,
  type LearningAnalyticsDto,
  type LessonFieldsDto,
  MAX_LESSONS,
  type ProgressOverrideDto,
  type ReorderLessonsDto,
  type UpdateCategoryDto,
  type UpdateContentDto,
  type UpdateLessonDto,
} from './learning.dto';
import { DEFAULT_EMBED_HOSTS, normaliseEmbedUrl, parseExternalUrl } from './learning.rules';
import { LessonService } from './lesson.service';
import { categoryRef } from './learning-views.service';

export interface AdminActor {
  userId: string;
  ip?: string | undefined;
  requestId?: string | undefined;
}

export const EMBED_HOSTS_SETTING = 'learning.embed_hosts';

const isUnique = (e: unknown) =>
  e instanceof Prisma.PrismaClientKnownRequestError && e.code === 'P2002';

const FULL_INCLUDE = {
  category: true,
  disciplines: { select: { disciplineId: true } },
  skills: { select: { skillId: true } },
  course: {
    include: {
      lessons: { orderBy: { sequence: 'asc' } },
      _count: { select: { enrolments: true } },
    },
  },
  _count: { select: { progress: true } },
} satisfies Prisma.LearningContentInclude;

type FullRow = Prisma.LearningContentGetPayload<{ include: typeof FULL_INCLUDE }>;

const strings = (v: Prisma.JsonValue): string[] =>
  Array.isArray(v) ? v.filter((s): s is string => typeof s === 'string') : [];

/** The learning CMS: categories, content of every type, courses and lessons, progress overrides and analytics. */
@Injectable()
export class AdminLearningService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
    private readonly media: MediaService,
    private readonly settings: PlatformSettingsService,
    private readonly lessons: LessonService,
  ) {}

  private audited(
    actor: AdminActor,
    action: string,
    entityId: string | null,
    before: unknown,
    after: unknown,
    tx: TxClient,
  ) {
    return this.audit.record(
      {
        actorType: 'ADMIN',
        actorId: actor.userId,
        action,
        entityType: 'learning',
        entityId,
        before,
        after,
        ip: actor.ip ?? null,
        requestId: actor.requestId ?? null,
      },
      tx,
    );
  }

  async embedHosts(): Promise<string[]> {
    const hosts = await this.settings.get<string[]>(EMBED_HOSTS_SETTING, [...DEFAULT_EMBED_HOSTS]);
    return Array.isArray(hosts) && hosts.length > 0 ? hosts : [...DEFAULT_EMBED_HOSTS];
  }

  // ---- categories ---------------------------------------------------------------------------------------------

  async listCategories(): Promise<AdminCategoryDto[]> {
    const [cats, counts] = await Promise.all([
      this.prisma.learningCategory.findMany({ orderBy: [{ group: 'asc' }, { sortOrder: 'asc' }] }),
      this.prisma.learningContent.groupBy({ by: ['categoryId'], _count: { _all: true } }),
    ]);
    const by = new Map(counts.map((c) => [c.categoryId, c._count._all]));
    return cats.map((c) => ({
      id: c.id,
      slug: c.slug,
      name: c.name,
      group: c.group,
      sortOrder: c.sortOrder,
      isActive: c.isActive,
      contentCount: by.get(c.id) ?? 0,
    }));
  }

  async createCategory(actor: AdminActor, dto: CategoryFieldsDto): Promise<AdminCategoryDto> {
    const slug = slugify(dto.name);
    try {
      const row = await this.prisma.$transaction(async (tx) => {
        const c = await tx.learningCategory.create({
          data: {
            slug,
            name: dto.name.trim(),
            group: dto.group,
            sortOrder: dto.sortOrder ?? 99,
            isActive: dto.isActive ?? true,
          },
        });
        await this.audited(
          actor,
          'learning.category.create',
          c.id,
          null,
          { name: c.name, group: c.group },
          tx,
        );
        return c;
      });
      return {
        id: row.id,
        slug: row.slug,
        name: row.name,
        group: row.group,
        sortOrder: row.sortOrder,
        isActive: row.isActive,
        contentCount: 0,
      };
    } catch (e) {
      if (isUnique(e)) throw ApiException.conflict('A category with that name already exists.');
      throw e;
    }
  }

  async updateCategory(
    actor: AdminActor,
    id: string,
    dto: UpdateCategoryDto,
  ): Promise<AdminCategoryDto> {
    const before = await this.prisma.learningCategory.findUnique({ where: { id } });
    if (!before) throw ApiException.notFound('That category does not exist.');
    await this.prisma.$transaction(async (tx) => {
      await tx.learningCategory.update({
        where: { id },
        data: {
          ...(dto.name !== undefined ? { name: dto.name.trim() } : {}),
          ...(dto.group !== undefined ? { group: dto.group } : {}),
          ...(dto.sortOrder !== undefined ? { sortOrder: dto.sortOrder } : {}),
          ...(dto.isActive !== undefined ? { isActive: dto.isActive } : {}),
        },
      });
      await this.audited(
        actor,
        'learning.category.update',
        id,
        { name: before.name, isActive: before.isActive },
        { fields: Object.keys(dto) },
        tx,
      );
    });
    return (await this.listCategories()).find((c) => c.id === id)!;
  }

  // ---- contents -----------------------------------------------------------------------------------------------

  async list(q: AdminContentsQueryDto) {
    const where: Prisma.LearningContentWhereInput = {
      ...(q.status ? { status: q.status } : {}),
      ...(q.type ? { type: q.type } : {}),
      ...(q.categoryId ? { categoryId: q.categoryId } : {}),
      ...(q.brokenLink ? { linkStatus: 'BROKEN' } : {}),
      ...(q.q
        ? {
            OR: [
              { title: { contains: q.q.trim(), mode: 'insensitive' } },
              { providerName: { contains: q.q.trim(), mode: 'insensitive' } },
            ],
          }
        : {}),
    };
    const [total, rows] = await Promise.all([
      this.prisma.learningContent.count({ where }),
      this.prisma.learningContent.findMany({
        where,
        include: FULL_INCLUDE,
        orderBy: [{ updatedAt: 'desc' }, { id: 'asc' }],
        ...toSkipTake(q),
      }),
    ]);
    return { items: await Promise.all(rows.map((r) => this.dto(r))), meta: pageMeta(q, total) };
  }

  async get(id: string): Promise<AdminContentDto> {
    return this.dto(await this.load(id));
  }

  private async load(id: string): Promise<FullRow> {
    const row = await this.prisma.learningContent.findUnique({
      where: { id },
      include: FULL_INCLUDE,
    });
    if (!row) throw ApiException.notFound('That item does not exist.');
    return row;
  }

  private async dto(r: FullRow): Promise<AdminContentDto> {
    const videoIds = (r.course?.lessons ?? []).flatMap((l) =>
      l.videoMediaId ? [l.videoMediaId] : [],
    );
    const videos = new Map(
      (videoIds.length
        ? await this.prisma.mediaAsset.findMany({ where: { id: { in: videoIds } }, select: { id: true, status: true } })
        : []
      ).map((v) => [v.id, v.status]),
    );
    const lessons: AdminLessonDto[] = (r.course?.lessons ?? []).map((l) => ({
      id: l.id,
      sequence: l.sequence,
      title: l.title,
      durationMinutes: l.durationMinutes,
      body: readBlocks(l.body).map((b) => ({
        type: b.type,
        text: 'text' in b ? b.text : null,
        title: b.type === 'callout' ? b.title : null,
        imageUrl: null,
        caption: b.type === 'image' ? b.caption : null,
        attribution: b.type === 'quote' ? b.attribution : null,
        mediaId: b.type === 'image' ? b.mediaId : null,
      })) as AdminLessonDto['body'],
      videoMediaId: l.videoMediaId,
      videoStatus: l.videoMediaId ? (videos.get(l.videoMediaId) ?? 'MISSING') : null,
      embedUrl: l.embedUrl,
      practicePrompt: l.practicePrompt,
      practiceSkillId: l.practiceSkillId,
    }));
    return {
      id: r.id,
      slug: r.slug,
      title: r.title,
      type: r.type,
      summary: r.summary,
      category: categoryRef(r.category),
      level: r.level,
      durationMinutes: r.durationMinutes,
      source: r.source,
      delivery: r.delivery,
      providerName: r.providerName,
      instructorUserId: r.instructorUserId,
      externalUrl: r.externalUrl,
      embedUrl: r.embedUrl,
      coverMediaId: r.coverMediaId,
      coverUrl: await this.media.imageUrl(r.coverMediaId, 600),
      access: r.access,
      status: r.status,
      publishedAt: r.publishedAt,
      featured: r.featured,
      whatYouLearn: strings(r.whatYouLearn),
      whoItsFor: r.whoItsFor,
      disciplineIds: r.disciplines.map((d) => d.disciplineId),
      skillIds: r.skills.map((s) => s.skillId),
      linkStatus: r.linkStatus,
      lastCheckedAt: r.lastCheckedAt,
      sequential: r.course?.sequential ?? null,
      lessons,
      enrolmentCount: (r.course?._count.enrolments ?? 0) + r._count.progress,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    };
  }

  private async checkFields(
    dto: { externalUrl?: string | null | undefined; embedUrl?: string | null | undefined },
    typeNow: LearningContentType,
    deliveryNow: string,
  ): Promise<{ externalUrl?: string | null; embedUrl?: string | null }> {
    const out: { externalUrl?: string | null; embedUrl?: string | null } = {};
    if (dto.externalUrl !== undefined)
      out.externalUrl = dto.externalUrl ? parseExternalUrl(dto.externalUrl) : null;
    if (dto.embedUrl !== undefined) {
      out.embedUrl = dto.embedUrl ? normaliseEmbedUrl(dto.embedUrl, await this.embedHosts()) : null;
    }
    if (typeNow === 'COURSE' && deliveryNow === 'EXTERNAL_LINK') {
      throw ApiException.validation(
        'A course is taught in the app. Use another type for an external resource.',
        { field: 'delivery' },
      );
    }
    return out;
  }

  private async assertCover(mediaId: string | null | undefined): Promise<void> {
    if (!mediaId) return;
    const asset = await this.prisma.mediaAsset.findFirst({
      where: { id: mediaId, kind: 'IMAGE', status: 'READY', deletedAt: null },
    });
    if (!asset)
      throw ApiException.validation('The cover must be a finished image upload.', {
        field: 'coverMediaId',
      });
  }

  private async relations(
    tx: TxClient,
    id: string,
    dto: { disciplineIds?: string[] | undefined; skillIds?: string[] | undefined },
  ) {
    if (dto.disciplineIds !== undefined) {
      const ids = [...new Set(dto.disciplineIds)];
      if ((await tx.discipline.count({ where: { id: { in: ids } } })) !== ids.length) {
        throw ApiException.validation('One of those disciplines does not exist.', {
          field: 'disciplineIds',
        });
      }
      await tx.learningContentDiscipline.deleteMany({ where: { contentId: id } });
      if (ids.length)
        await tx.learningContentDiscipline.createMany({
          data: ids.map((disciplineId) => ({ contentId: id, disciplineId })),
        });
    }
    if (dto.skillIds !== undefined) {
      const ids = [...new Set(dto.skillIds)];
      if ((await tx.skill.count({ where: { id: { in: ids } } })) !== ids.length) {
        throw ApiException.validation('One of those skills does not exist.', { field: 'skillIds' });
      }
      await tx.learningContentSkill.deleteMany({ where: { contentId: id } });
      if (ids.length)
        await tx.learningContentSkill.createMany({
          data: ids.map((skillId) => ({ contentId: id, skillId })),
        });
    }
  }

  async create(actor: AdminActor, dto: ContentFieldsDto): Promise<AdminContentDto> {
    if (!(await this.prisma.learningCategory.count({ where: { id: dto.categoryId } }))) {
      throw ApiException.validation('That category does not exist.', { field: 'categoryId' });
    }
    await this.assertCover(dto.coverMediaId);
    const delivery = dto.delivery ?? (dto.type === 'COURSE' ? 'NATIVE' : 'NATIVE');
    const urls = await this.checkFields(dto, dto.type, delivery);
    if (dto.instructorUserId) await this.assertUser(dto.instructorUserId);
    let created: { id: string } | null = null;
    for (let i = 0; i < 5 && !created; i += 1) {
      try {
        created = await this.prisma.$transaction(async (tx) => {
          const row = await tx.learningContent.create({
            data: {
              slug: `${slugify(dto.title)}-${randomBytes(3).toString('hex')}`,
              type: dto.type,
              title: dto.title.trim(),
              summary: dto.summary.trim(),
              categoryId: dto.categoryId,
              level: dto.level ?? 'BEGINNER',
              durationMinutes: dto.durationMinutes ?? 0,
              source: dto.source ?? 'ATARAH',
              delivery,
              providerName: dto.providerName?.trim() || null,
              instructorUserId: dto.instructorUserId ?? null,
              externalUrl: urls.externalUrl ?? null,
              embedUrl: urls.embedUrl ?? null,
              coverMediaId: dto.coverMediaId ?? null,
              access: dto.access ?? 'FREE',
              featured: dto.featured ?? false,
              whatYouLearn: dto.whatYouLearn ?? [],
              whoItsFor: dto.whoItsFor?.trim() || null,
              createdById: actor.userId,
            },
          });
          if (dto.type === 'COURSE') {
            await tx.course.create({
              data: { contentId: row.id, sequential: dto.sequential ?? true },
            });
          }
          await this.relations(tx, row.id, dto);
          await this.audited(
            actor,
            'learning.content.create',
            row.id,
            null,
            { title: row.title, type: row.type },
            tx,
          );
          return row;
        });
      } catch (e) {
        if (!isUnique(e)) throw e;
      }
    }
    if (!created)
      throw ApiException.conflict('Could not create a unique address for that item. Try again.');
    return this.get(created.id);
  }

  private async assertUser(id: string): Promise<void> {
    if (!(await this.prisma.user.count({ where: { id, deletedAt: null } }))) {
      throw ApiException.validation('That account does not exist.', { field: 'instructorUserId' });
    }
  }

  async update(actor: AdminActor, id: string, dto: UpdateContentDto): Promise<AdminContentDto> {
    const before = await this.load(id);
    const type = dto.type ?? before.type;
    if (dto.type !== undefined && (dto.type === 'COURSE') !== (before.type === 'COURSE')) {
      throw ApiException.invalidState(
        'A course cannot be turned into another type, or the other way round. Create a new item.',
      );
    }
    if (
      dto.categoryId &&
      !(await this.prisma.learningCategory.count({ where: { id: dto.categoryId } }))
    ) {
      throw ApiException.validation('That category does not exist.', { field: 'categoryId' });
    }
    if (dto.coverMediaId !== undefined) await this.assertCover(dto.coverMediaId);
    if (dto.instructorUserId) await this.assertUser(dto.instructorUserId);
    const delivery = dto.delivery ?? before.delivery;
    const urls = await this.checkFields(dto, type, delivery);
    await this.prisma.$transaction(async (tx) => {
      await tx.learningContent.update({
        where: { id },
        data: {
          ...(dto.title !== undefined ? { title: dto.title.trim() } : {}),
          ...(dto.type !== undefined ? { type: dto.type } : {}),
          ...(dto.summary !== undefined ? { summary: dto.summary.trim() } : {}),
          ...(dto.categoryId !== undefined ? { categoryId: dto.categoryId } : {}),
          ...(dto.level !== undefined ? { level: dto.level } : {}),
          ...(dto.durationMinutes !== undefined && before.type !== 'COURSE'
            ? { durationMinutes: dto.durationMinutes }
            : {}),
          ...(dto.source !== undefined ? { source: dto.source } : {}),
          ...(dto.delivery !== undefined ? { delivery: dto.delivery } : {}),
          ...(dto.providerName !== undefined
            ? { providerName: dto.providerName?.trim() || null }
            : {}),
          ...(dto.instructorUserId !== undefined ? { instructorUserId: dto.instructorUserId } : {}),
          ...(dto.coverMediaId !== undefined ? { coverMediaId: dto.coverMediaId } : {}),
          ...(dto.access !== undefined ? { access: dto.access } : {}),
          ...(dto.featured !== undefined ? { featured: dto.featured } : {}),
          ...(dto.whatYouLearn !== undefined ? { whatYouLearn: dto.whatYouLearn } : {}),
          ...(dto.whoItsFor !== undefined ? { whoItsFor: dto.whoItsFor?.trim() || null } : {}),
          ...(urls.externalUrl !== undefined
            ? { externalUrl: urls.externalUrl, linkStatus: 'UNKNOWN' as const, lastCheckedAt: null }
            : {}),
          ...(urls.embedUrl !== undefined
            ? { embedUrl: urls.embedUrl, linkStatus: 'UNKNOWN' as const, lastCheckedAt: null }
            : {}),
        },
      });
      if (dto.sequential !== undefined && before.course) {
        await tx.course.update({ where: { contentId: id }, data: { sequential: dto.sequential } });
      }
      await this.relations(tx, id, dto);
      await this.audited(
        actor,
        'learning.content.update',
        id,
        { title: before.title, status: before.status },
        { fields: Object.keys(dto) },
        tx,
      );
    });
    return this.get(id);
  }

  /** What an item needs before it can go live. A draft may be half-written; a published item may not. */
  private assertPublishable(r: FullRow): void {
    const fail = (message: string, field: string) => {
      throw ApiException.validation(message, { field });
    };
    if (r.type === 'COURSE') {
      const lessons = r.course?.lessons ?? [];
      if (lessons.length === 0) fail('Add at least one lesson before publishing.', 'lessons');
      const empty = lessons.find(
        (l) => readBlocks(l.body).length === 0 && !l.videoMediaId && !l.embedUrl,
      );
      if (empty) fail(`Lesson "${empty.title}" has no text, video or embed.`, 'lessons');
    } else if (r.delivery === 'EXTERNAL_LINK') {
      if (!r.externalUrl) fail('Add the address this resource opens.', 'externalUrl');
    } else if (r.delivery === 'EMBEDDED') {
      if (!r.embedUrl) fail('Add the embedded player address.', 'embedUrl');
    }
  }

  async publish(actor: AdminActor, id: string, opts: { at?: Date } = {}): Promise<AdminContentDto> {
    const before = await this.load(id);
    if (before.status === 'PUBLISHED')
      throw ApiException.invalidState('That item is already published.');
    this.assertPublishable(before);
    await this.prisma.$transaction(async (tx) => {
      await tx.learningContent.update({
        where: { id },
        data: { status: 'PUBLISHED', publishedAt: opts.at ?? before.publishedAt ?? new Date() },
      });
      await this.audited(
        actor,
        'learning.content.publish',
        id,
        { status: before.status },
        { status: 'PUBLISHED' },
        tx,
      );
    });
    return this.get(id);
  }

  async setStatus(
    actor: AdminActor,
    id: string,
    status: 'DRAFT' | 'ARCHIVED',
  ): Promise<AdminContentDto> {
    const before = await this.load(id);
    if (before.status === status)
      throw ApiException.invalidState(`That item is already ${status.toLowerCase()}.`);
    // Members already learning a course keep it, so a course with learners is archived, not taken back to draft.
    if (
      status === 'DRAFT' &&
      (before.course?._count.enrolments ?? 0) + before._count.progress > 0
    ) {
      throw ApiException.invalidState(
        'Members have started this. Archive it instead of unpublishing.',
      );
    }
    await this.prisma.$transaction(async (tx) => {
      await tx.learningContent.update({
        where: { id },
        data: { status, ...(status === 'ARCHIVED' ? { featured: false } : {}) },
      });
      await this.audited(
        actor,
        `learning.content.${status === 'DRAFT' ? 'unpublish' : 'archive'}`,
        id,
        { status: before.status },
        { status },
        tx,
      );
    });
    return this.get(id);
  }

  // ---- lessons ------------------------------------------------------------------------------------------------

  private async course(courseId: string) {
    const course = await this.prisma.course.findUnique({ where: { contentId: courseId } });
    if (!course) throw ApiException.notFound('That course does not exist.');
    return course;
  }

  private async lessonFields(
    dto: Partial<LessonFieldsDto> & { videoMediaId?: string | null; embedUrl?: string | null },
  ) {
    const out: Prisma.LessonUncheckedUpdateInput = {};
    if (dto.title !== undefined) out.title = dto.title.trim();
    if (dto.durationMinutes !== undefined) out.durationMinutes = dto.durationMinutes;
    if (dto.body !== undefined)
      out.body = normaliseBlocks(dto.body) as unknown as Prisma.InputJsonValue;
    if (dto.practicePrompt !== undefined) out.practicePrompt = dto.practicePrompt?.trim() || null;
    if (dto.practiceSkillId !== undefined) {
      if (
        dto.practiceSkillId &&
        !(await this.prisma.skill.count({ where: { id: dto.practiceSkillId } }))
      ) {
        throw ApiException.validation('That skill does not exist.', { field: 'practiceSkillId' });
      }
      out.practiceSkillId = dto.practiceSkillId;
    }
    if (dto.videoMediaId !== undefined) {
      if (dto.videoMediaId) {
        const v = await this.prisma.mediaAsset.findFirst({
          where: { id: dto.videoMediaId, kind: 'VIDEO', deletedAt: null },
        });
        if (!v)
          throw ApiException.validation('That is not an uploaded video.', {
            field: 'videoMediaId',
          });
        if (v.status === 'REJECTED')
          throw ApiException.validation(v.rejectionReason ?? 'That video was refused.', {
            field: 'videoMediaId',
          });
      }
      out.videoMediaId = dto.videoMediaId;
    }
    if (dto.embedUrl !== undefined) {
      out.embedUrl = dto.embedUrl ? normaliseEmbedUrl(dto.embedUrl, await this.embedHosts()) : null;
    }
    if (out.videoMediaId && out.embedUrl) {
      throw ApiException.validation(
        'A lesson plays an uploaded video or an embedded player, not both.',
        { field: 'embedUrl' },
      );
    }
    return out;
  }

  /** Keeps the course's lesson count and total minutes (and the item's duration) in step with its lessons. */
  private async recount(tx: TxClient, courseId: string): Promise<void> {
    const agg = await tx.lesson.aggregate({
      where: { courseId },
      _count: { _all: true },
      _sum: { durationMinutes: true },
    });
    const total = agg._sum.durationMinutes ?? 0;
    await tx.course.update({
      where: { contentId: courseId },
      data: { lessonCount: agg._count._all, totalMinutes: total },
    });
    await tx.learningContent.update({ where: { id: courseId }, data: { durationMinutes: total } });
  }

  async addLesson(
    actor: AdminActor,
    courseId: string,
    dto: LessonFieldsDto,
  ): Promise<AdminContentDto> {
    await this.course(courseId);
    const fields = await this.lessonFields(dto);
    await this.prisma.$transaction(async (tx) => {
      const count = await tx.lesson.count({ where: { courseId } });
      if (count >= MAX_LESSONS)
        throw ApiException.invalidState(`A course can have up to ${MAX_LESSONS} lessons.`);
      const last = await tx.lesson.aggregate({ where: { courseId }, _max: { sequence: true } });
      const lesson = await tx.lesson.create({
        data: {
          courseId,
          sequence: (last._max.sequence ?? 0) + 1,
          title: dto.title.trim(),
          ...(fields as object),
        },
      });
      await this.recount(tx, courseId);
      await this.audited(
        actor,
        'learning.lesson.create',
        lesson.id,
        null,
        { courseId, title: lesson.title },
        tx,
      );
    });
    return this.get(courseId);
  }

  async updateLesson(
    actor: AdminActor,
    courseId: string,
    lessonId: string,
    dto: UpdateLessonDto,
  ): Promise<AdminContentDto> {
    const lesson = await this.prisma.lesson.findFirst({ where: { id: lessonId, courseId } });
    if (!lesson) throw ApiException.notFound('That lesson does not exist.');
    const fields = await this.lessonFields(dto);
    // Switching to one player clears the other.
    if (fields.videoMediaId) fields.embedUrl = null;
    if (fields.embedUrl) fields.videoMediaId = null;
    await this.prisma.$transaction(async (tx) => {
      await tx.lesson.update({ where: { id: lessonId }, data: fields });
      await this.recount(tx, courseId);
      await this.audited(
        actor,
        'learning.lesson.update',
        lessonId,
        { title: lesson.title },
        { fields: Object.keys(dto) },
        tx,
      );
    });
    return this.get(courseId);
  }

  async deleteLesson(
    actor: AdminActor,
    courseId: string,
    lessonId: string,
  ): Promise<AdminContentDto> {
    const lesson = await this.prisma.lesson.findFirst({ where: { id: lessonId, courseId } });
    if (!lesson) throw ApiException.notFound('That lesson does not exist.');
    const content = await this.load(courseId);
    if (content.status === 'PUBLISHED' && (content.course?.lessons.length ?? 0) <= 1) {
      throw ApiException.invalidState(
        'A published course needs at least one lesson. Unpublish or archive it first.',
      );
    }
    await this.prisma.$transaction(async (tx) => {
      await tx.lesson.delete({ where: { id: lessonId } });
      // Close the gap in the numbering (two steps because (courseId, sequence) is unique).
      const rest = await tx.lesson.findMany({
        where: { courseId },
        orderBy: { sequence: 'asc' },
        select: { id: true },
      });
      await this.resequence(
        tx,
        courseId,
        rest.map((l) => l.id),
      );
      await this.recount(tx, courseId);
      await this.audited(
        actor,
        'learning.lesson.delete',
        lessonId,
        { title: lesson.title, courseId },
        null,
        tx,
      );
    });
    return this.get(courseId);
  }

  async reorder(
    actor: AdminActor,
    courseId: string,
    dto: ReorderLessonsDto,
  ): Promise<AdminContentDto> {
    await this.course(courseId);
    const existing = await this.prisma.lesson.findMany({
      where: { courseId },
      select: { id: true },
    });
    const same =
      existing.length === dto.lessonIds.length &&
      new Set(dto.lessonIds).size === dto.lessonIds.length &&
      existing.every((l) => dto.lessonIds.includes(l.id));
    if (!same)
      throw ApiException.validation('Send every lesson of the course exactly once.', {
        field: 'lessonIds',
      });
    await this.prisma.$transaction(async (tx) => {
      await this.resequence(tx, courseId, dto.lessonIds);
      await this.audited(
        actor,
        'learning.lesson.reorder',
        courseId,
        null,
        { order: dto.lessonIds },
        tx,
      );
    });
    return this.get(courseId);
  }

  /** Renumber 1..n in the given order, through temporary high numbers so the unique key is never violated. */
  private async resequence(tx: TxClient, courseId: string, ids: string[]): Promise<void> {
    for (const [i, id] of ids.entries())
      await tx.lesson.update({ where: { id }, data: { sequence: 10_000 + i } });
    for (const [i, id] of ids.entries())
      await tx.lesson.update({ where: { id }, data: { sequence: i + 1 } });
    void courseId;
  }

  // ---- progress overrides -------------------------------------------------------------------------------------

  /**
   * An explicit, reasoned correction to one member's progress, recorded in `learning_progress_overrides` and the audit
   * trail. It never edits what a member watched: it completes or resets a lesson, or resets a course. A certificate that
   * was already issued stays.
   */
  async progressOverride(actor: AdminActor, dto: ProgressOverrideDto) {
    const course = await this.course(dto.courseId);
    const enrolment = await this.prisma.enrolment.findUnique({
      where: { userId_courseId: { userId: dto.userId, courseId: course.contentId } },
    });
    if (!enrolment) throw ApiException.invalidState('That member is not enrolled in this course.');
    if (dto.action !== 'RESET_COURSE') {
      if (!dto.lessonId) throw ApiException.validation('Name the lesson.', { field: 'lessonId' });
      if (
        !(await this.prisma.lesson.count({
          where: { id: dto.lessonId, courseId: course.contentId },
        }))
      ) {
        throw ApiException.notFound('That lesson is not in this course.');
      }
    }
    const now = new Date();
    let courseCompleted = false;
    await this.prisma.$transaction(async (tx) => {
      if (dto.action === 'COMPLETE_LESSON') {
        await tx.lessonProgress.upsert({
          where: { userId_lessonId: { userId: dto.userId, lessonId: dto.lessonId! } },
          create: {
            userId: dto.userId,
            lessonId: dto.lessonId!,
            status: 'COMPLETED',
            completedAt: now,
          },
          update: { status: 'COMPLETED', completedAt: now },
        });
        const total = await tx.lesson.count({ where: { courseId: course.contentId } });
        const done = await tx.lessonProgress.count({
          where: {
            userId: dto.userId,
            status: 'COMPLETED',
            lesson: { courseId: course.contentId },
          },
        });
        if (total > 0 && done >= total) {
          await this.lessons.completeCourse(tx, dto.userId, course.contentId, now);
          courseCompleted = true;
        }
      } else if (dto.action === 'RESET_LESSON') {
        await tx.lessonProgress.deleteMany({
          where: { userId: dto.userId, lessonId: dto.lessonId! },
        });
        await tx.enrolment.updateMany({
          where: { userId: dto.userId, courseId: course.contentId },
          data: { completedAt: null },
        });
      } else {
        await tx.lessonProgress.deleteMany({
          where: { userId: dto.userId, lesson: { courseId: course.contentId } },
        });
        await tx.enrolment.updateMany({
          where: { userId: dto.userId, courseId: course.contentId },
          data: { completedAt: null },
        });
      }
      await tx.learningProgressOverride.create({
        data: {
          userId: dto.userId,
          courseId: course.contentId,
          lessonId: dto.lessonId ?? null,
          action: dto.action,
          reason: dto.reason.trim(),
          actorId: actor.userId,
        },
      });
      await this.audited(
        actor,
        'learning.progress.override',
        course.contentId,
        null,
        {
          userId: dto.userId,
          action: dto.action,
          lessonId: dto.lessonId ?? null,
          reason: dto.reason.trim(),
        },
        tx,
      );
    });
    return { ok: true as const, courseCompleted };
  }

  // ---- analytics ----------------------------------------------------------------------------------------------

  async analytics(): Promise<LearningAnalyticsDto> {
    const [published, enrol, enrolDone, items, itemsDone, certs, contents] = await Promise.all([
      this.prisma.learningContent.count({ where: { status: 'PUBLISHED' } }),
      this.prisma.enrolment.groupBy({ by: ['courseId'], _count: { _all: true } }),
      this.prisma.enrolment.groupBy({
        by: ['courseId'],
        where: { completedAt: { not: null } },
        _count: { _all: true },
      }),
      this.prisma.contentProgress.groupBy({ by: ['contentId'], _count: { _all: true } }),
      this.prisma.contentProgress.groupBy({
        by: ['contentId'],
        where: { status: 'COMPLETED' },
        _count: { _all: true },
      }),
      this.prisma.certificate.count(),
      this.prisma.learningContent.findMany({
        where: { status: { in: ['PUBLISHED', 'ARCHIVED'] } },
        select: { id: true, title: true, type: true },
      }),
    ]);
    const starts = new Map<string, number>();
    const done = new Map<string, number>();
    for (const g of [...enrol, ...items])
      starts.set('courseId' in g ? g.courseId : g.contentId, g._count._all);
    for (const g of [...enrolDone, ...itemsDone])
      done.set('courseId' in g ? g.courseId : g.contentId, g._count._all);
    const rows = contents
      .map((c) => {
        const s = starts.get(c.id) ?? 0;
        const d = done.get(c.id) ?? 0;
        return {
          contentId: c.id,
          title: c.title,
          type: c.type,
          starts: s,
          completions: d,
          completionRate: s === 0 ? 0 : Math.round((d / s) * 100),
        };
      })
      .filter((r) => r.starts > 0)
      .sort((a, b) => b.starts - a.starts)
      .slice(0, 100);
    return {
      publishedItems: published,
      totalStarts: [...starts.values()].reduce((a, b) => a + b, 0),
      totalCompletions: [...done.values()].reduce((a, b) => a + b, 0),
      certificatesIssued: certs,
      items: rows,
    };
  }
}
