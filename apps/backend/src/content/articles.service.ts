import { Injectable } from '@nestjs/common';
import { type Article, Prisma } from '@prisma/client';
import { ApiException } from '../common/api.exception';
import { pageMeta, toSkipTake } from '../common/pagination';
import { AppConfigService } from '../config/app-config.service';
import { MediaService } from '../media/media.service';
import { PrismaService } from '../prisma/prisma.service';
import { readBlocks } from './blocks';
import {
  type ArticleBlockDto,
  type ArticleCardDto,
  type ArticleDto,
  type ArticlesQueryDto,
  type SavedQueryDto,
} from './content.dto';

/** Members and visitors see an article only once it is published and its publish time has passed. */
export const livePublished = (): Prisma.ArticleWhereInput => ({
  status: 'PUBLISHED',
  publishedAt: { lte: new Date() },
});

@Injectable()
export class ArticlesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly media: MediaService,
    private readonly config: AppConfigService,
  ) {}

  shareUrl(slug: string): string {
    return `${this.config.appLinkBaseUrl.replace(/\/$/, '')}/articles/${slug}`;
  }

  /** Card shape used by lists, Home, search and saved items. */
  async cards(rows: Article[]): Promise<ArticleCardDto[]> {
    return Promise.all(
      rows.map(async (a) => ({
        id: a.id,
        slug: a.slug,
        title: a.title,
        summary: a.summary,
        source: a.source,
        sourceLabel: a.sourceLabel,
        authorName: a.authorName,
        readMinutes: a.readMinutes,
        publishedAt: a.publishedAt ?? a.createdAt,
        heroUrl: await this.media.imageUrl(a.heroMediaId, 600),
        tags: a.tags,
      })),
    );
  }

  async list(q: ArticlesQueryDto) {
    const where: Prisma.ArticleWhereInput = {
      ...livePublished(),
      ...(q.tag ? { tags: { has: q.tag.trim().toLowerCase() } } : {}),
    };
    const [total, rows] = await Promise.all([
      this.prisma.article.count({ where }),
      this.prisma.article.findMany({
        where,
        orderBy: [{ publishedAt: 'desc' }, { id: 'asc' }],
        ...toSkipTake(q),
      }),
    ]);
    return { items: await this.cards(rows), meta: pageMeta(q, total) };
  }

  async detail(slug: string, viewerId: string | undefined): Promise<ArticleDto> {
    const a = await this.prisma.article.findFirst({
      where: { slug: slug.toLowerCase(), ...livePublished() },
    });
    if (!a) throw ApiException.notFound('That article is not available.');
    const blocks = readBlocks(a.body);
    const out: ArticleBlockDto[] = await Promise.all(
      blocks.map(async (b) => ({
        type: b.type,
        text: 'text' in b ? b.text : null,
        title: b.type === 'callout' ? b.title : null,
        imageUrl: b.type === 'image' ? await this.media.imageUrl(b.mediaId, 1200) : null,
        caption: b.type === 'image' ? b.caption : null,
        attribution: b.type === 'quote' ? b.attribution : null,
      })),
    );
    const [card] = await this.cards([a]);
    const saved = viewerId
      ? (await this.prisma.savedItem.count({
          where: { userId: viewerId, type: 'ARTICLE', targetId: a.id },
        })) > 0
      : false;
    return {
      ...card!,
      heroUrl: await this.media.imageUrl(a.heroMediaId, 1200),
      blocks: out,
      saved,
      shareUrl: this.shareUrl(a.slug),
    };
  }

  // ---- saved --------------------------------------------------------------------------------------------

  async save(userId: string, type: 'ARTICLE', id: string): Promise<void> {
    const exists = await this.prisma.article.count({ where: { id, ...livePublished() } });
    if (!exists) throw ApiException.notFound('That article is not available.');
    await this.prisma.savedItem.upsert({
      where: { userId_type_targetId: { userId, type, targetId: id } },
      create: { userId, type, targetId: id },
      update: {},
    });
  }

  async unsave(userId: string, type: 'ARTICLE', id: string): Promise<void> {
    await this.prisma.savedItem.deleteMany({ where: { userId, type, targetId: id } });
  }

  /** Saved articles, newest save first. Articles that are no longer live are left out. */
  async saved(userId: string, q: SavedQueryDto) {
    const type = q.type ?? 'ARTICLE';
    const rows = await this.prisma.savedItem.findMany({
      where: { userId, type },
      orderBy: { createdAt: 'desc' },
    });
    const articles = await this.prisma.article.findMany({
      where: { id: { in: rows.map((r) => r.targetId) }, ...livePublished() },
    });
    const byId = new Map(articles.map((a) => [a.id, a]));
    const live = rows.filter((r) => byId.has(r.targetId));
    const { skip, take } = toSkipTake(q);
    const slice = live.slice(skip, skip + take);
    const cards = await this.cards(slice.map((r) => byId.get(r.targetId)!));
    return {
      items: slice.map((r, i) => ({ savedAt: r.createdAt, article: cards[i]! })),
      meta: pageMeta(q, live.length),
    };
  }
}
