import { Injectable } from '@nestjs/common';
import { type Article, type ArticleStatus, Prisma } from '@prisma/client';
import { AuditService } from '../audit/audit.service';
import { ApiException } from '../common/api.exception';
import { pageMeta, toSkipTake } from '../common/pagination';
import { MediaService } from '../media/media.service';
import { PrismaService } from '../prisma/prisma.service';
import { slugify } from '../creative/slug';
import { normaliseBlocks, readBlocks, readMinutes, type StoredBlock } from './blocks';
import {
  type AdminArticleDto,
  type AdminArticleListItemDto,
  type AdminArticlesQueryDto,
  type CreateArticleDto,
  type HomeConfigDto,
  type UpdateArticleDto,
} from './content.dto';

export interface AdminActor {
  userId: string;
  ip?: string;
  requestId?: string;
}

/** How far in the past a publish time may be before it is treated as a mistake (clock drift is fine). */
const PAST_GRACE_MS = 5 * 60 * 1000;

/**
 * The articles CMS: draft, in review, published, archived. Every change is audited. A published article with a
 * future publish time is scheduled and stays hidden from members until then.
 */
@Injectable()
export class AdminArticlesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly media: MediaService,
    private readonly audit: AuditService,
  ) {}

  private async pinnedId(): Promise<string | null> {
    return (
      (await this.prisma.homeConfig.findUnique({ where: { id: 'home' } }))?.featuredArticleId ??
      null
    );
  }

  private listItem(a: Article, pinned: string | null): AdminArticleListItemDto {
    return {
      id: a.id,
      slug: a.slug,
      title: a.title,
      authorName: a.authorName,
      status: a.status,
      source: a.source,
      publishedAt: a.publishedAt,
      scheduled: a.status === 'PUBLISHED' && !!a.publishedAt && a.publishedAt > new Date(),
      featured: a.id === pinned,
      updatedAt: a.updatedAt,
    };
  }

  private async full(a: Article): Promise<AdminArticleDto> {
    const blocks = readBlocks(a.body);
    const pinned = await this.pinnedId();
    return {
      ...this.listItem(a, pinned),
      summary: a.summary,
      sourceLabel: a.sourceLabel,
      readMinutes: a.readMinutes,
      tags: a.tags,
      heroMediaId: a.heroMediaId,
      heroUrl: await this.media.imageUrl(a.heroMediaId, 600),
      blocks: await Promise.all(
        blocks.map(async (b) => ({
          type: b.type,
          text: 'text' in b ? b.text : null,
          title: b.type === 'callout' ? b.title : null,
          mediaId: b.type === 'image' ? b.mediaId : null,
          imageUrl: b.type === 'image' ? await this.media.imageUrl(b.mediaId, 600) : null,
          caption: b.type === 'image' ? b.caption : null,
          attribution: b.type === 'quote' ? b.attribution : null,
        })),
      ),
      createdAt: a.createdAt,
    };
  }

  private async load(id: string): Promise<Article> {
    const a = await this.prisma.article.findUnique({ where: { id } });
    if (!a) throw ApiException.notFound('That article does not exist.');
    return a;
  }

  async list(q: AdminArticlesQueryDto) {
    const term = q.q?.trim();
    const where: Prisma.ArticleWhereInput = {
      ...(q.status ? { status: q.status } : {}),
      ...(term
        ? {
            OR: [
              { title: { contains: term, mode: 'insensitive' } },
              { authorName: { contains: term, mode: 'insensitive' } },
            ],
          }
        : {}),
    };
    const [total, rows, pinned] = await Promise.all([
      this.prisma.article.count({ where }),
      this.prisma.article.findMany({
        where,
        orderBy: [{ updatedAt: 'desc' }, { id: 'asc' }],
        ...toSkipTake(q),
      }),
      this.pinnedId(),
    ]);
    return { items: rows.map((a) => this.listItem(a, pinned)), meta: pageMeta(q, total) };
  }

  get(id: string) {
    return this.load(id).then((a) => this.full(a));
  }

  async create(actor: AdminActor, dto: CreateArticleDto): Promise<AdminArticleDto> {
    const title = dto.title.trim();
    const authorName = dto.authorName.trim();
    if (title.length < 3) {
      throw ApiException.validation('Give the article a title of at least 3 characters.', {
        field: 'title',
      });
    }
    if (!authorName) {
      throw ApiException.validation('Add a byline.', { field: 'authorName' });
    }
    const base = slugify(title).slice(0, 80) || 'article';
    let slug = base;
    for (let n = 2; await this.prisma.article.count({ where: { slug } }); n += 1) {
      slug = `${base}-${n}`;
    }
    const a = await this.prisma.article.create({
      data: {
        slug,
        title,
        summary: '',
        authorName,
        readMinutes: readMinutes([], title),
        createdById: actor.userId,
        updatedById: actor.userId,
      },
    });
    await this.record(actor, 'content.article.create', a.id, null, { title, status: a.status });
    return this.full(a);
  }

  async update(actor: AdminActor, id: string, dto: UpdateArticleDto): Promise<AdminArticleDto> {
    const a = await this.load(id);
    if (a.status === 'ARCHIVED') {
      throw ApiException.invalidState('Restore an archived article before editing it.');
    }
    const data: Prisma.ArticleUncheckedUpdateInput = { updatedById: actor.userId };

    if (dto.title !== undefined) {
      const t = dto.title.trim();
      if (t.length < 3) {
        throw ApiException.validation('Give the article a title of at least 3 characters.', {
          field: 'title',
        });
      }
      data.title = t;
    }
    if (dto.summary !== undefined) data.summary = dto.summary.trim();
    if (dto.authorName !== undefined) {
      const n = dto.authorName.trim();
      if (!n) throw ApiException.validation('Add a byline.', { field: 'authorName' });
      data.authorName = n;
    }
    if (dto.source !== undefined) data.source = dto.source;
    if (dto.sourceLabel !== undefined) data.sourceLabel = dto.sourceLabel.trim() || null;
    if (dto.tags !== undefined) {
      const tags = [...new Set(dto.tags.map((t) => slugify(t)).filter(Boolean))];
      data.tags = tags;
    }
    if (dto.heroMediaId !== undefined) {
      if (dto.heroMediaId === '') data.heroMediaId = null;
      else {
        await this.assertPublicImages(actor.userId, [dto.heroMediaId], 'heroMediaId');
        data.heroMediaId = dto.heroMediaId;
      }
    }
    let blocks: StoredBlock[] | undefined;
    if (dto.blocks !== undefined) {
      blocks = normaliseBlocks(dto.blocks);
      await this.assertPublicImages(
        actor.userId,
        blocks.flatMap((b) => (b.type === 'image' ? [b.mediaId] : [])),
        'blocks',
        a,
      );
      data.body = blocks as unknown as Prisma.InputJsonValue;
    }
    if (dto.title !== undefined || dto.summary !== undefined || blocks) {
      data.readMinutes = readMinutes(
        blocks ?? readBlocks(a.body),
        (data.title as string | undefined) ?? a.title,
        (data.summary as string | undefined) ?? a.summary,
      );
    }
    const nextSource = (data.source as string | undefined) ?? a.source;
    const nextLabel =
      data.sourceLabel !== undefined ? (data.sourceLabel as string | null) : a.sourceLabel;
    if (a.status === 'PUBLISHED' && nextSource !== 'ATARAH' && !nextLabel) {
      throw ApiException.validation('Say who this came from.', { field: 'sourceLabel' });
    }
    if (a.status === 'PUBLISHED' && data.summary === '') {
      throw ApiException.validation('A published article needs a summary.', { field: 'summary' });
    }
    const updated = await this.prisma.article.update({ where: { id }, data });
    await this.record(actor, 'content.article.update', id, null, {
      fields: Object.keys(dto),
      status: updated.status,
    });
    return this.full(updated);
  }

  private async assertPublicImages(
    userId: string,
    ids: string[],
    field: string,
    existing?: Article,
  ) {
    if (ids.length === 0) return;
    const unique = [...new Set(ids)];
    // Images already on the article stay valid even if another editor uploaded them.
    const already = new Set(
      existing
        ? [
            ...(existing.heroMediaId ? [existing.heroMediaId] : []),
            ...readBlocks(existing.body).flatMap((b) => (b.type === 'image' ? [b.mediaId] : [])),
          ]
        : [],
    );
    const assets = await this.prisma.mediaAsset.findMany({
      where: { id: { in: unique }, deletedAt: null },
      select: { id: true, ownerId: true, kind: true, bucket: true, status: true },
    });
    if (assets.length !== unique.length) {
      throw ApiException.validation('One of those images could not be found.', { field });
    }
    for (const m of assets) {
      if (m.ownerId !== userId && !already.has(m.id)) {
        throw ApiException.validation('One of those images could not be found.', { field });
      }
      if (m.kind !== 'IMAGE') {
        throw ApiException.validation('Only images can go here.', { field });
      }
      if (m.bucket !== 'PUBLIC') {
        throw ApiException.validation('That image was uploaded as private.', { field });
      }
      if (m.status === 'REJECTED') {
        throw ApiException.validation('One of those images was refused. Use another.', { field });
      }
    }
  }

  // ---- lifecycle ----------------------------------------------------------------------------------------

  private async move(
    actor: AdminActor,
    id: string,
    from: ArticleStatus[],
    to: ArticleStatus,
    action: string,
    extra: Prisma.ArticleUncheckedUpdateInput = {},
    check?: (a: Article) => void,
  ): Promise<AdminArticleDto> {
    const a = await this.load(id);
    if (!from.includes(a.status)) {
      throw ApiException.invalidState(
        `That article is ${a.status.toLowerCase().replace('_', ' ')}.`,
        {
          status: a.status,
        },
      );
    }
    check?.(a);
    const res = await this.prisma.article.updateMany({
      where: { id, status: a.status },
      data: { status: to, updatedById: actor.userId, ...extra },
    });
    if (res.count === 0) throw ApiException.conflict('Someone else just changed this article.');
    await this.record(actor, action, id, { status: a.status }, { status: to });
    return this.get(id);
  }

  private readyToPublish(a: Article) {
    if (!a.summary.trim()) {
      throw ApiException.validation('Add a summary before this goes any further.', {
        field: 'summary',
      });
    }
    if (readBlocks(a.body).length === 0) {
      throw ApiException.validation('Add some content before this goes any further.', {
        field: 'blocks',
      });
    }
    if (a.source !== 'ATARAH' && !a.sourceLabel) {
      throw ApiException.validation('Say who this came from.', { field: 'sourceLabel' });
    }
  }

  submit(actor: AdminActor, id: string) {
    return this.move(actor, id, ['DRAFT'], 'IN_REVIEW', 'content.article.submit', {}, (a) =>
      this.readyToPublish(a),
    );
  }

  returnToDraft(actor: AdminActor, id: string) {
    return this.move(actor, id, ['IN_REVIEW'], 'DRAFT', 'content.article.return');
  }

  async publish(actor: AdminActor, id: string, publishAt?: string) {
    const when = publishAt ? new Date(publishAt) : new Date();
    if (Number.isNaN(when.getTime()) || when.getTime() < Date.now() - PAST_GRACE_MS) {
      throw ApiException.validation('Pick a publish time that has not passed.', {
        field: 'publishAt',
      });
    }
    return this.move(
      actor,
      id,
      ['IN_REVIEW'],
      'PUBLISHED',
      'content.article.publish',
      { publishedAt: when },
      (a) => this.readyToPublish(a),
    );
  }

  async archive(actor: AdminActor, id: string) {
    const out = await this.move(actor, id, ['PUBLISHED'], 'ARCHIVED', 'content.article.archive');
    // An archived article cannot stay pinned on Home.
    await this.prisma.homeConfig.updateMany({
      where: { id: 'home', featuredArticleId: id },
      data: { featuredArticleId: null },
    });
    return out;
  }

  restore(actor: AdminActor, id: string) {
    return this.move(actor, id, ['ARCHIVED'], 'DRAFT', 'content.article.restore', {
      publishedAt: null,
    });
  }

  // ---- Home curation ------------------------------------------------------------------------------------

  async homeConfig(): Promise<HomeConfigDto> {
    const c = await this.prisma.homeConfig.findUnique({
      where: { id: 'home' },
      include: { featuredArticle: { select: { title: true } } },
    });
    return {
      featuredArticleId: c?.featuredArticleId ?? null,
      featuredArticleTitle: c?.featuredArticle?.title ?? null,
      updatedAt: c?.updatedAt ?? null,
    };
  }

  async setHomeConfig(actor: AdminActor, featuredArticleId: string | null) {
    const before = await this.pinnedId();
    if (featuredArticleId) {
      const a = await this.prisma.article.findFirst({
        where: { id: featuredArticleId, status: 'PUBLISHED' },
      });
      if (!a) {
        throw ApiException.validation('Only a published article can be featured.', {
          field: 'featuredArticleId',
        });
      }
    }
    await this.prisma.homeConfig.upsert({
      where: { id: 'home' },
      create: { id: 'home', featuredArticleId, updatedById: actor.userId },
      update: { featuredArticleId, updatedById: actor.userId },
    });
    await this.audit.record({
      actorType: 'ADMIN',
      actorId: actor.userId,
      action: 'content.home.feature',
      entityType: 'home_config',
      entityId: 'home',
      before: { featuredArticleId: before },
      after: { featuredArticleId },
      ip: actor.ip,
      requestId: actor.requestId,
    });
    return this.homeConfig();
  }

  private record(actor: AdminActor, action: string, id: string, before: unknown, after: unknown) {
    return this.audit.record({
      actorType: 'ADMIN',
      actorId: actor.userId,
      action,
      entityType: 'article',
      entityId: id,
      before,
      after,
      ip: actor.ip,
      requestId: actor.requestId,
    });
  }
}
