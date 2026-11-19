import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { ApiException } from '../common/api.exception';
import { DomainEventBus } from '../community-core/domain-events';
import { postVisibleSql } from '../community/post-sql';
import { ArticlesService } from '../content/articles.service';
import { MarketplaceService } from '../marketplace/marketplace.service';
import { notBlockedSql } from '../community-core/blocks';
import { LearningService } from '../learning/learning.service';
import { OpportunitiesService } from '../opportunities/opportunities.service';
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
    private readonly opportunities: OpportunitiesService,
    private readonly learning: LearningService,
    private readonly marketplace: MarketplaceService,
    private readonly events: DomainEventBus,
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
          : type === 'posts'
            ? await this.postGroup(viewerId, q, page)
            : type === 'opportunities'
              ? await this.opportunityGroup(viewerId, q, page)
              : type === 'learning'
                ? await this.learningGroup(viewerId, q, page)
                : type === 'marketplace'
                  ? await this.marketplaceGroup(viewerId, q, page)
                  : await this.articleGroup(q, page),
      );
    }
    // Counts only: the words searched for are never recorded.
    void this.events.emit({
      type: 'SearchPerformed',
      userId: viewerId,
      scope: dto.type ?? 'all',
      resultCount: groups.reduce((n, g) => n + g.count, 0),
      queryLength: q.length,
    });
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

  /** Community posts the viewer may see (audience, group membership, blocks and status as everywhere else). */
  private async postGroup(
    viewerId: string,
    q: string,
    page: { page: number; limit: number },
  ): Promise<SearchGroupDto> {
    const like = likePattern(q);
    const where = postVisibleSql({ viewerId, openGroupsReadable: true });
    // The text match is a fenced sub-select (OFFSET 0): the trigram and full-text indexes find the matching posts
    // first, and only those are joined to their authors and checked for visibility. Without the fence the planner
    // may start from every member and probe the indexes once each, which is thousands of times slower.
    // The fence also hides how many posts match, so the planner assumes a handful and joins authors with a nested loop,
    // which is quadratic for a word that is in most posts (46 s on 50,000 posts). Hash joins cost the same for few
    // matches and stay flat for many (0.5 s).
    const rows = await this.prisma.$transaction(async (tx) => {
      await tx.$executeRaw`SELECT set_config('enable_nestloop', 'off', true)`;
      return tx.$queryRaw<Array<{ id: string; total: bigint }>>(Prisma.sql`
      SELECT p.id, count(*) OVER() AS total,
        GREATEST(ts_rank(p."searchVector", websearch_to_tsquery('simple', ${q})),
          CASE WHEN p.body ILIKE ${like} THEN 0.2 ELSE 0 END) AS score
      FROM (
        SELECT * FROM posts
        WHERE body ILIKE ${like} OR "searchVector" @@ websearch_to_tsquery('simple', ${q})
        OFFSET 0
      ) p
      JOIN users au ON au.id = p."authorId"
      WHERE ${where}
      ORDER BY score DESC, p."createdAt" DESC, p.id DESC
      LIMIT ${page.limit} OFFSET ${(page.page - 1) * page.limit}`);
    });
    const total = rows.length > 0 ? Number(rows[0]!.total) : 0;
    const found = await this.prisma.post.findMany({
      where: { id: { in: rows.map((r) => r.id) } },
      select: {
        id: true,
        body: true,
        type: true,
        author: { select: { fullName: true, creativeProfile: { select: { displayName: true } } } },
      },
    });
    const byId = new Map(found.map((p) => [p.id, p]));
    const items: SearchHitDto[] = rows.flatMap((r) => {
      const p = byId.get(r.id);
      if (!p) return [];
      const text = p.body.replace(/\s+/g, ' ').trim();
      const name = p.author.creativeProfile?.displayName ?? p.author.fullName;
      return [
        {
          type: 'posts',
          id: p.id,
          title: text.length > 90 ? `${text.slice(0, 89)}…` : text,
          subtitle: `${name} · ${p.type.toLowerCase()}`,
          imageUrl: null,
          verified: false,
          path: `/community/posts/${p.id}`,
        },
      ];
    });
    return { type: 'posts', count: total, items };
  }

  /** Open opportunities matching the words (title, summary, provider), best match first. */
  private async opportunityGroup(
    viewerId: string,
    q: string,
    page: { page: number; limit: number },
  ): Promise<SearchGroupDto> {
    const like = likePattern(q);
    const where = Prisma.sql`o.status::text = 'PUBLISHED' AND (o."deadlineAt" IS NULL OR o."deadlineAt" > now()) AND (
      o.title ILIKE ${like} OR o.summary ILIKE ${like} OR pr.name ILIKE ${like}
      OR similarity(o.title, ${q}) > 0.3 OR word_similarity(${q}, o.title) > 0.5
      OR o."searchVector" @@ websearch_to_tsquery('simple', ${q}))`;
    const from = Prisma.sql`FROM opportunities o JOIN opportunity_providers pr ON pr.id = o."providerId"`;
    const rows = await this.prisma.$queryRaw<Array<{ id: string; total: bigint }>>(Prisma.sql`
      SELECT o.id, count(*) OVER() AS total,
        GREATEST(similarity(o.title, ${q}), word_similarity(${q}, o.title),
          CASE WHEN o.title ILIKE ${like} THEN 0.9 ELSE 0 END,
          CASE WHEN pr.name ILIKE ${like} THEN 0.5 ELSE 0 END,
          CASE WHEN o.summary ILIKE ${like} THEN 0.4 ELSE 0 END,
          ts_rank(o."searchVector", websearch_to_tsquery('simple', ${q}))) AS score
      ${from}
      WHERE ${where}
      ORDER BY score DESC, o."deadlineAt" ASC NULLS LAST, o.id
      LIMIT ${page.limit} OFFSET ${(page.page - 1) * page.limit}`);
    let total = rows.length > 0 ? Number(rows[0]!.total) : 0;
    if (rows.length === 0 && page.page > 1) {
      const [counted] = await this.prisma.$queryRaw<Array<{ n: bigint }>>(
        Prisma.sql`SELECT count(*) AS n ${from} WHERE ${where}`,
      );
      total = Number(counted?.n ?? 0);
    }
    const cards = await this.opportunities.searchCards(
      viewerId,
      rows.map((r) => r.id),
    );
    return {
      type: 'opportunities',
      count: total,
      items: cards.map((c) => ({
        type: 'opportunities',
        id: c.id,
        title: c.title,
        subtitle: `${c.provider.name} · ${c.type.toLowerCase()}`,
        imageUrl: c.provider.logoUrl,
        verified: c.trust === 'VERIFIED',
        path: `/opportunities/${c.id}`,
      })),
    };
  }

  /** Published Skill Labs matching the words (title, summary, provider), best match first. */
  private async learningGroup(
    viewerId: string,
    q: string,
    page: { page: number; limit: number },
  ): Promise<SearchGroupDto> {
    const like = likePattern(q);
    const where = Prisma.sql`c.status::text = 'PUBLISHED' AND (c."publishedAt" IS NULL OR c."publishedAt" <= now()) AND (
      c.title ILIKE ${like} OR c.summary ILIKE ${like} OR c."providerName" ILIKE ${like}
      OR similarity(c.title, ${q}) > 0.3 OR word_similarity(${q}, c.title) > 0.5
      OR c."searchVector" @@ websearch_to_tsquery('simple', ${q}))`;
    const rows = await this.prisma.$queryRaw<Array<{ id: string; total: bigint }>>(Prisma.sql`
      SELECT c.id, count(*) OVER() AS total,
        GREATEST(similarity(c.title, ${q}), word_similarity(${q}, c.title),
          CASE WHEN c.title ILIKE ${like} THEN 0.9 ELSE 0 END,
          CASE WHEN c.summary ILIKE ${like} THEN 0.4 ELSE 0 END,
          ts_rank(c."searchVector", websearch_to_tsquery('simple', ${q}))) AS score
      FROM learning_contents c
      WHERE ${where}
      ORDER BY score DESC, c."publishedAt" DESC NULLS LAST, c.id
      LIMIT ${page.limit} OFFSET ${(page.page - 1) * page.limit}`);
    let total = rows.length > 0 ? Number(rows[0]!.total) : 0;
    if (rows.length === 0 && page.page > 1) {
      const [counted] = await this.prisma.$queryRaw<Array<{ n: bigint }>>(
        Prisma.sql`SELECT count(*) AS n FROM learning_contents c WHERE ${where}`,
      );
      total = Number(counted?.n ?? 0);
    }
    const cards = await this.learning.searchCards(
      viewerId,
      rows.map((r) => r.id),
    );
    return {
      type: 'learning',
      count: total,
      items: cards.map((c) => ({
        type: 'learning',
        id: c.id,
        title: c.title,
        subtitle: `${c.category.name} · ${c.type.toLowerCase()}`,
        imageUrl: c.coverUrl,
        verified: false,
        path: `/learning/courses/${c.id}`,
      })),
    };
  }

  /** Live listings from active sellers matching the words (title, description, category, seller), best match first. */
  private async marketplaceGroup(
    viewerId: string,
    q: string,
    page: { page: number; limit: number },
  ): Promise<SearchGroupDto> {
    const like = likePattern(q);
    const from = Prisma.sql`FROM listings l
      JOIN seller_profiles sp ON sp.id = l."sellerId"
      JOIN users u ON u.id = sp."userId"
      JOIN marketplace_categories mc ON mc.id = l."categoryId"
      LEFT JOIN creative_profiles cp ON cp."userId" = u.id`;
    const where = Prisma.sql`l.status::text = 'PUBLISHED' AND sp.status::text = 'ACTIVE' AND u.status::text = 'ACTIVE'
      AND u."deletedAt" IS NULL AND mc."isActive" AND ${notBlockedSql(viewerId, Prisma.sql`u.id`)} AND (
      l.title ILIKE ${like} OR l.description ILIKE ${like} OR mc.name ILIKE ${like}
      OR COALESCE(cp."displayName", u."fullName") ILIKE ${like}
      OR similarity(l.title, ${q}) > 0.3 OR word_similarity(${q}, l.title) > 0.5
      OR l."searchVector" @@ websearch_to_tsquery('simple', ${q}))`;
    const rows = await this.prisma.$queryRaw<Array<{ id: string; total: bigint }>>(Prisma.sql`
      SELECT l.id, count(*) OVER() AS total,
        GREATEST(similarity(l.title, ${q}), word_similarity(${q}, l.title),
          CASE WHEN l.title ILIKE ${like} THEN 0.9 ELSE 0 END,
          CASE WHEN mc.name ILIKE ${like} THEN 0.5 ELSE 0 END,
          CASE WHEN l.description ILIKE ${like} THEN 0.4 ELSE 0 END,
          ts_rank(l."searchVector", websearch_to_tsquery('simple', ${q}))) AS score
      ${from}
      WHERE ${where}
      ORDER BY score DESC, l."publishedAt" DESC NULLS LAST, l.id
      LIMIT ${page.limit} OFFSET ${(page.page - 1) * page.limit}`);
    let total = rows.length > 0 ? Number(rows[0]!.total) : 0;
    if (rows.length === 0 && page.page > 1) {
      const [counted] = await this.prisma.$queryRaw<Array<{ n: bigint }>>(
        Prisma.sql`SELECT count(*) AS n ${from} WHERE ${where}`,
      );
      total = Number(counted?.n ?? 0);
    }
    const cards = await this.marketplace.searchCards(
      viewerId,
      rows.map((r) => r.id),
    );
    return {
      type: 'marketplace',
      count: total,
      items: cards.map((c) => ({
        type: 'marketplace',
        id: c.id,
        title: c.title,
        subtitle: `${c.categoryName} · ${c.seller.displayName} · ${c.priceLabel}`,
        imageUrl: c.coverUrl,
        verified: c.seller.verified,
        path: `/marketplace/listings/${c.id}`,
      })),
    };
  }

  private async articleGroup(
    q: string,
    page: { page: number; limit: number },
  ): Promise<SearchGroupDto> {
    const like = likePattern(q);
    const where = Prisma.sql`a.status::text = 'PUBLISHED' AND a."publishedAt" <= now() AND (
      a.title ILIKE ${like} OR a.summary ILIKE ${like}
      OR similarity(a.title, ${q}) > 0.3 OR word_similarity(${q}, a.title) > 0.5
      OR a."searchVector" @@ websearch_to_tsquery('simple', ${q})
      OR EXISTS (SELECT 1 FROM unnest(a.tags) t WHERE t ILIKE ${like}))`;
    const rows = await this.prisma.$queryRaw<Array<{ id: string; total: bigint }>>(Prisma.sql`
      SELECT a.id, count(*) OVER() AS total,
        GREATEST(similarity(a.title, ${q}), word_similarity(${q}, a.title),
          CASE WHEN a.title ILIKE ${like} THEN 0.9 ELSE 0 END,
          CASE WHEN a.summary ILIKE ${like} THEN 0.4 ELSE 0 END,
          ts_rank(a."searchVector", websearch_to_tsquery('simple', ${q}))) AS score
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
