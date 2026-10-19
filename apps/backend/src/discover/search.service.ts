import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { ApiException } from '../common/api.exception';
import { ArticlesService } from '../content/articles.service';
import { PrismaService } from '../prisma/prisma.service';
import { cleanQuery, CreativesDiscoveryService, likePattern } from './creatives-discovery.service';
import {
  BUILT_SEARCH_TYPES,
  GROUP_PREVIEW,
  MAX_RECENT,
  type SearchGroupDto,
  type SearchHitDto,
  type SearchQueryDto,
  type SearchType,
} from './discover.dto';

/**
 * Grouped search across what exists today (creatives and articles). Each group applies its own visibility rules;
 * kinds whose features are not built yet return no group at all rather than an empty one.
 */
@Injectable()
export class SearchService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly creatives: CreativesDiscoveryService,
    private readonly articles: ArticlesService,
  ) {}

  async search(viewerId: string, dto: SearchQueryDto) {
    const q = cleanQuery(dto.q, true)!;
    if (dto.type && !BUILT_SEARCH_TYPES.includes(dto.type)) return { query: q, groups: [] };

    const types: SearchType[] = dto.type ? [dto.type] : [...BUILT_SEARCH_TYPES];
    // One type is paged; "all" shows a short preview of each.
    const page = dto.type
      ? { page: dto.page, limit: dto.limit }
      : { page: 1, limit: GROUP_PREVIEW };

    const groups: SearchGroupDto[] = [];
    for (const type of types) {
      groups.push(
        type === 'creatives'
          ? await this.creativeGroup(viewerId, q, page)
          : await this.articleGroup(q, page),
      );
    }
    return { query: q, groups };
  }

  private async creativeGroup(
    viewerId: string,
    q: string,
    page: { page: number; limit: number },
  ): Promise<SearchGroupDto> {
    const { ids, total } = await this.creatives.find(viewerId, { q }, page);
    const cards = await this.creatives.cardsFor(ids);
    const items: SearchHitDto[] = cards.map((c) => ({
      type: 'creatives',
      id: c.handle,
      title: c.displayName,
      subtitle: c.headline ?? c.discipline?.name ?? null,
      imageUrl: c.avatarUrl,
      verified: c.verified,
      path: `/creatives/${encodeURIComponent(c.handle)}`,
    }));
    return { type: 'creatives', count: total, items };
  }

  private async articleGroup(
    q: string,
    page: { page: number; limit: number },
  ): Promise<SearchGroupDto> {
    const like = likePattern(q);
    const where = Prisma.sql`a.status::text = 'PUBLISHED' AND a."publishedAt" <= now() AND (
      a.title ILIKE ${like} OR a.summary ILIKE ${like}
      OR similarity(a.title, ${q}) > 0.3 OR word_similarity(${q}, a.title) > 0.5
      OR EXISTS (SELECT 1 FROM unnest(a.tags) t WHERE t ILIKE ${like}))`;
    const rows = await this.prisma.$queryRaw<Array<{ id: string; total: bigint }>>(Prisma.sql`
      SELECT a.id, count(*) OVER() AS total,
        GREATEST(similarity(a.title, ${q}), word_similarity(${q}, a.title),
          CASE WHEN a.title ILIKE ${like} THEN 0.9 ELSE 0 END,
          CASE WHEN a.summary ILIKE ${like} THEN 0.4 ELSE 0 END) AS score
      FROM articles a
      WHERE ${where}
      ORDER BY score DESC, a."publishedAt" DESC, a.id
      LIMIT ${page.limit} OFFSET ${(page.page - 1) * page.limit}`);
    let total = rows.length > 0 ? Number(rows[0]!.total) : 0;
    if (rows.length === 0 && page.page > 1) {
      const [counted] = await this.prisma.$queryRaw<Array<{ n: bigint }>>(
        Prisma.sql`SELECT count(*) AS n FROM articles a WHERE ${where}`,
      );
      total = Number(counted?.n ?? 0);
    }
    const found = await this.prisma.article.findMany({
      where: { id: { in: rows.map((r) => r.id) } },
    });
    const byId = new Map(found.map((a) => [a.id, a]));
    const ordered = rows.flatMap((r) => (byId.has(r.id) ? [byId.get(r.id)!] : []));
    const cards = await this.articles.cards(ordered);
    return {
      type: 'articles',
      count: total,
      items: cards.map((c) => ({
        type: 'articles',
        id: c.id,
        title: c.title,
        subtitle: `${c.authorName} · ${c.readMinutes} min read`,
        imageUrl: c.heroUrl,
        verified: false,
        path: `/articles/${c.slug}`,
      })),
    };
  }

  // ---- recent searches ----------------------------------------------------------------------------------

  recent(userId: string) {
    return this.prisma.recentSearch
      .findMany({
        where: { userId },
        orderBy: { usedAt: 'desc' },
        take: MAX_RECENT,
        select: { id: true, query: true },
      })
      .then((rows) => rows);
  }

  /** Remembers a search the member submitted. The same words again move to the top; only the latest ten stay. */
  async record(userId: string, raw: string) {
    const query = cleanQuery(raw, true)!;
    const normalized = query.toLowerCase();
    const row = await this.prisma.recentSearch.upsert({
      where: { userId_normalized: { userId, normalized } },
      create: { userId, query, normalized },
      update: { query, usedAt: new Date() },
      select: { id: true, query: true },
    });
    const keep = await this.prisma.recentSearch.findMany({
      where: { userId },
      orderBy: { usedAt: 'desc' },
      take: MAX_RECENT,
      select: { id: true },
    });
    await this.prisma.recentSearch.deleteMany({
      where: { userId, id: { notIn: keep.map((k) => k.id) } },
    });
    return row;
  }

  async remove(userId: string, id: string): Promise<void> {
    const res = await this.prisma.recentSearch.deleteMany({ where: { id, userId } });
    if (res.count === 0) throw ApiException.notFound('That search is already gone.');
  }

  async clear(userId: string): Promise<void> {
    await this.prisma.recentSearch.deleteMany({ where: { userId } });
  }
}
