import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { ApiException } from '../common/api.exception';
import { pageMeta } from '../common/pagination';
import { notBlockedWhere } from '../community-core/blocks';
import { postVisibleSql, POST_FROM } from '../community/post-sql';
import { ArticlesService, livePublished } from '../content/articles.service';
import { listingVisibleWhere } from '../marketplace/marketplace-views.service';
import { priceLabel } from '../marketplace/marketplace-logic';
import { MediaService } from '../media/media.service';
import { OpportunitiesService } from '../opportunities/opportunities.service';
import { PrismaService } from '../prisma/prisma.service';
import {
  BUILT_SAVED_KINDS,
  MAX_COLLECTION,
  type SavedCountsDto,
  type SavedItemDto,
  type SavedKind,
  type SavedQueryDto,
} from './saved.dto';

const snippet = (s: string, n = 90) => {
  const t = s.replace(/\s+/g, ' ').trim();
  return t.length > n ? `${t.slice(0, n - 1)}…` : t;
};

const isUnique = (e: unknown) =>
  e instanceof Prisma.PrismaClientKnownRequestError && e.code === 'P2002';

/** What each resolver returns before it is stamped with the save time and collection. */
type Resolved = Omit<SavedItemDto, 'savedAt' | 'collection' | 'type' | 'targetId'>;
type TableKind = Exclude<SavedKind, 'OPPORTUNITY' | 'MENTOR'>;
const TABLE_KINDS: readonly TableKind[] = ['ARTICLE', 'POST', 'LEARNING', 'CREATIVE', 'LISTING'];

/**
 * Everything a member saved, whatever it is. One table (`saved_items`) holds articles, posts, learning content and
 * creatives; opportunities are saved as tracking rows (DEC-079) and appear here as the same kind of row. Each kind has
 * a resolver that applies that kind's own visibility rules, so something that was removed or hidden since it was saved
 * is simply left out. LISTING and MENTOR are reserved for Phase 2.
 */
@Injectable()
export class SavedService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly articles: ArticlesService,
    private readonly media: MediaService,
    private readonly opportunities: OpportunitiesService,
  ) {}

  assertBuilt(type: SavedKind): void {
    if (!BUILT_SAVED_KINDS.includes(type)) {
      throw ApiException.validation(
        'That cannot be saved yet. It arrives with Marketplace and Mentorship.',
        { field: 'type', soon: 'P2' },
      );
    }
  }

  private cleanCollection(raw: string | undefined): string | null | undefined {
    if (raw === undefined) return undefined;
    const c = raw.trim().replace(/\s+/g, ' ');
    if (c.length > MAX_COLLECTION) {
      throw ApiException.validation('That collection name is too long.', { field: 'collection' });
    }
    return c === '' ? null : c;
  }

  // ---- add and remove -------------------------------------------------------------------------------------

  async add(userId: string, type: SavedKind, id: string, collection?: string): Promise<void> {
    this.assertBuilt(type);
    if (type === 'OPPORTUNITY') {
      await this.opportunities.save(userId, id);
      return;
    }
    await this.assertSavable(userId, type as TableKind, id);
    const coll = this.cleanCollection(collection);
    try {
      await this.prisma.savedItem.upsert({
        where: { userId_type_targetId: { userId, type: type as TableKind, targetId: id } },
        create: { userId, type: type as TableKind, targetId: id, collection: coll ?? null },
        update: coll !== undefined ? { collection: coll } : {},
      });
    } catch (e) {
      if (!isUnique(e)) throw e; // two taps at once: it is saved either way
    }
  }

  async remove(userId: string, type: SavedKind, id: string): Promise<void> {
    this.assertBuilt(type);
    if (type === 'OPPORTUNITY') {
      await this.opportunities.unsave(userId, id);
      return;
    }
    await this.prisma.savedItem.deleteMany({
      where: { userId, type: type as TableKind, targetId: id },
    });
  }

  /** The thing must exist and be visible to the member; both failures give the same "not available". */
  private async assertSavable(userId: string, type: TableKind, id: string): Promise<void> {
    let ok = false;
    switch (type) {
      case 'ARTICLE':
        ok = (await this.prisma.article.count({ where: { id, ...livePublished() } })) > 0;
        break;
      case 'LEARNING':
        ok = (await this.prisma.learningContent.count({ where: { id, status: 'PUBLISHED' } })) > 0;
        break;
      case 'POST': {
        const rows = await this.prisma.$queryRaw<Array<{ id: string }>>(Prisma.sql`
          SELECT p.id ${POST_FROM}
          WHERE p.id = ${id}::uuid AND ${postVisibleSql({ viewerId: userId, openGroupsReadable: true })}`);
        ok = rows.length > 0;
        break;
      }
      case 'LISTING':
        ok =
          (await this.prisma.listing.count({
            where: { AND: [{ id }, listingVisibleWhere(userId), { seller: { userId: { not: userId } } }] },
          })) > 0;
        break;
      case 'CREATIVE':
        ok =
          (await this.prisma.creativeProfile.count({
            where: {
              id,
              userId: { not: userId },
              handle: { not: null },
              onboardingCompletedAt: { not: null },
              user: { status: 'ACTIVE', deletedAt: null, ...notBlockedWhere(userId) },
            },
          })) > 0;
        break;
    }
    if (!ok) throw ApiException.notFound('That is not available to save.');
  }

  // ---- reading --------------------------------------------------------------------------------------------

  /** Every visible saved row, newest save first (bounded at 500 per source: nobody saves more than that). */
  private async everything(userId: string, q: { type?: SavedKind; collection?: string }) {
    if (q.type) this.assertBuilt(q.type);
    const wantOpp = !q.type || q.type === 'OPPORTUNITY';
    const kinds = q.type ? TABLE_KINDS.filter((k) => k === q.type) : TABLE_KINDS;
    const collection = q.collection?.trim();

    const rows = kinds.length
      ? await this.prisma.savedItem.findMany({
          where: { userId, type: { in: [...kinds] }, ...(collection ? { collection } : {}) },
          orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
          take: 500,
        })
      : [];
    const oppRows =
      wantOpp && !collection
        ? await this.prisma.opportunityTracking.findMany({
            where: {
              userId,
              status: { in: ['SAVED', 'IN_PROGRESS'] },
              opportunity: { status: { in: ['PUBLISHED', 'CLOSED', 'EXPIRED'] } },
            },
            include: { opportunity: { include: { provider: { select: { name: true } } } } },
            orderBy: [{ updatedAt: 'desc' }, { id: 'desc' }],
            take: 500,
          })
        : [];

    const resolved = await this.resolve(userId, rows);
    const items: SavedItemDto[] = [];
    for (const r of rows) {
      const x = resolved.get(`${r.type}:${r.targetId}`);
      if (x) {
        items.push({
          type: r.type as SavedKind,
          targetId: r.targetId,
          savedAt: r.createdAt,
          collection: r.collection,
          ...x,
        });
      }
    }
    for (const t of oppRows) {
      const o = t.opportunity;
      items.push({
        type: 'OPPORTUNITY',
        targetId: o.id,
        savedAt: t.savedAt ?? t.createdAt,
        collection: null,
        title: o.title,
        subtitle: o.deadlineAt
          ? `${o.provider.name} · closes ${o.deadlineAt.toISOString().slice(0, 10)}`
          : o.provider.name,
        imageUrl: null,
        path: `/opportunities/${o.id}`,
        article: null,
      });
    }
    items.sort((a, b) => b.savedAt.getTime() - a.savedAt.getTime());
    return items;
  }

  async list(userId: string, q: SavedQueryDto) {
    const items = await this.everything(userId, q);
    const skip = (q.page - 1) * q.limit;
    return { items: items.slice(skip, skip + q.limit), meta: pageMeta(q, items.length) };
  }

  async counts(userId: string): Promise<SavedCountsDto> {
    const items = await this.everything(userId, {});
    const byType: Record<string, number> = {};
    for (const i of items) byType[i.type] = (byType[i.type] ?? 0) + 1;
    return { total: items.length, byType };
  }

  private async resolve(
    userId: string,
    rows: Array<{ type: string; targetId: string }>,
  ): Promise<Map<string, Resolved>> {
    const out = new Map<string, Resolved>();
    const ids = (t: string) => rows.filter((r) => r.type === t).map((r) => r.targetId);

    const articleIds = ids('ARTICLE');
    if (articleIds.length) {
      const found = await this.prisma.article.findMany({
        where: { id: { in: articleIds }, ...livePublished() },
      });
      const cards = await this.articles.cards(found);
      cards.forEach((c) =>
        out.set(`ARTICLE:${c.id}`, {
          title: c.title,
          subtitle: `${c.authorName} · ${c.readMinutes} min read`,
          imageUrl: c.heroUrl,
          path: `/articles/${c.slug}`,
          article: c,
        }),
      );
    }

    const postIds = ids('POST');
    if (postIds.length) {
      const found = await this.prisma.$queryRaw<
        Array<{ id: string; body: string; type: string; name: string }>
      >(Prisma.sql`
        SELECT p.id, p.body, p.type::text AS type, COALESCE(cp."displayName", au."fullName") AS name
        ${POST_FROM}
        LEFT JOIN creative_profiles cp ON cp."userId" = au.id
        WHERE p.id = ANY(${postIds}::uuid[])
          AND ${postVisibleSql({ viewerId: userId, openGroupsReadable: true })}`);
      found.forEach((p) =>
        out.set(`POST:${p.id}`, {
          title: snippet(p.body || 'A post with a picture'),
          subtitle: `${p.name} · ${p.type.toLowerCase()}`,
          imageUrl: null,
          path: `/posts/${p.id}`,
          article: null,
        }),
      );
    }

    const learningIds = ids('LEARNING');
    if (learningIds.length) {
      const found = await this.prisma.learningContent.findMany({
        where: { id: { in: learningIds }, status: 'PUBLISHED' },
        include: { category: { select: { name: true } } },
      });
      for (const c of found) {
        out.set(`LEARNING:${c.id}`, {
          title: c.title,
          subtitle: `${c.type.charAt(0)}${c.type.slice(1).toLowerCase()} · ${c.category.name}`,
          imageUrl: await this.media.imageUrl(c.coverMediaId, 200),
          path: `/learning/courses/${c.id}`,
          article: null,
        });
      }
    }

    const listingIds = ids('LISTING');
    if (listingIds.length) {
      const found = await this.prisma.listing.findMany({
        where: { id: { in: listingIds }, ...listingVisibleWhere(userId) },
        include: {
          category: { select: { name: true } },
          seller: {
            select: {
              user: { select: { fullName: true, creativeProfile: { select: { displayName: true } } } },
            },
          },
          media: { orderBy: { sortOrder: 'asc' }, take: 1, select: { mediaId: true } },
        },
      });
      for (const l of found) {
        out.set(`LISTING:${l.id}`, {
          title: l.title,
          subtitle: `${l.seller.user.creativeProfile?.displayName ?? l.seller.user.fullName} · ${
            priceLabel(l.pricingType, l.priceMinMinor, l.priceMaxMinor).label
          }`,
          imageUrl: await this.media.imageUrl(l.media[0]?.mediaId ?? null, 200),
          path: `/marketplace/listings/${l.id}`,
          article: null,
        });
      }
    }

    const creativeIds = ids('CREATIVE');
    if (creativeIds.length) {
      const found = await this.prisma.creativeProfile.findMany({
        where: {
          id: { in: creativeIds },
          handle: { not: null },
          userId: { not: userId },
          user: { status: 'ACTIVE', deletedAt: null, ...notBlockedWhere(userId) },
        },
        include: { primaryDiscipline: { select: { name: true } } },
      });
      for (const p of found) {
        out.set(`CREATIVE:${p.id}`, {
          title: p.displayName,
          subtitle: p.headline ?? p.primaryDiscipline?.name ?? null,
          imageUrl: await this.media.imageUrl(p.avatarMediaId, 200),
          path: `/creatives/${encodeURIComponent(p.handle!)}`,
          article: null,
        });
      }
    }
    return out;
  }
}
