import { Injectable } from '@nestjs/common';
import { type PostType, Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { type PostViewDto } from './community.dto';
import { decodeFeedCursor, encodeFeedCursor, RANK_BOOST_MINUTES } from './feed-cursor';
import { PostViewsService } from './post-views.service';
import { postNotMutedSql, postVisibleSql } from './post-sql';

export interface PostPageQuery {
  type?: PostType;
  groupId?: string;
  cursor?: string;
  limit: number;
}

export interface PostPage {
  items: PostViewDto[];
  meta: { nextCursor: string | null; limit: number };
}

/**
 * The community feed. Audience, group membership, blocks (both directions), mutes and status are all applied in
 * SQL (`post-sql.ts`); the page is a keyset on (ranking time, id), so it never repeats or skips a post however
 * often new posts arrive. Ranking is recency with a light, per-viewer nudge (`RANK_BOOST_MINUTES`).
 */
@Injectable()
export class FeedService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly views: PostViewsService,
  ) {}

  /** The member's home feed: everything they may see, newest first, lightly boosted by relevance. */
  feed(viewerId: string, q: PostPageQuery): Promise<PostPage> {
    return this.page(viewerId, q, { ranked: true, openGroupsReadable: false, skipMuted: true });
  }

  /** A group's posts, strictly newest first. The caller has already checked the viewer may read the group. */
  groupPosts(
    viewerId: string,
    groupId: string,
    q: Omit<PostPageQuery, 'groupId'>,
  ): Promise<PostPage> {
    return this.page(
      viewerId,
      { ...q, groupId },
      { ranked: false, openGroupsReadable: true, skipMuted: true },
    );
  }

  private async page(
    viewerId: string,
    q: PostPageQuery,
    mode: { ranked: boolean; openGroupsReadable: boolean; skipMuted: boolean },
  ): Promise<PostPage> {
    const cursor = q.cursor ? decodeFeedCursor(q.cursor) : null;
    const me = mode.ranked
      ? await this.prisma.creativeProfile.findUnique({
          where: { userId: viewerId },
          select: { primaryDisciplineId: true, countyId: true },
        })
      : null;
    const B = RANK_BOOST_MINUTES;
    const boost = mode.ranked
      ? Prisma.sql`(
          CASE WHEN p."groupId" IS NOT NULL AND EXISTS (SELECT 1 FROM group_memberships gb
            WHERE gb."groupId" = p."groupId" AND gb."userId" = ${viewerId}::uuid) THEN ${B.group}::int ELSE 0 END
          + CASE WHEN EXISTS (SELECT 1 FROM connections cb WHERE cb.status::text = 'ACCEPTED'
              AND ((cb."requesterId" = ${viewerId}::uuid AND cb."addresseeId" = p."authorId")
                OR (cb."requesterId" = p."authorId" AND cb."addresseeId" = ${viewerId}::uuid)))
              THEN ${B.connection}::int ELSE 0 END
          + CASE WHEN ${me?.primaryDisciplineId ?? null}::uuid IS NOT NULL
              AND ap."primaryDisciplineId" = ${me?.primaryDisciplineId ?? null}::uuid
              THEN ${B.discipline}::int ELSE 0 END
          + CASE WHEN ${me?.countyId ?? null}::uuid IS NOT NULL
              AND ap."countyId" = ${me?.countyId ?? null}::uuid AND ap."locationVisibility"::text <> 'PRIVATE'
              THEN ${B.county}::int ELSE 0 END
          + CASE WHEN p."isStaffAnnouncement" THEN ${B.announcement}::int ELSE 0 END)`
      : Prisma.sql`0`;

    const filters: Prisma.Sql[] = [
      postVisibleSql({ viewerId, openGroupsReadable: mode.openGroupsReadable }),
    ];
    if (mode.skipMuted) filters.push(postNotMutedSql(viewerId));
    const where = Prisma.join(filters, ' AND ');
    // The cheap, selective filters go inside the candidate "fence" below, where an index can serve them.
    const fence: Prisma.Sql[] = [
      Prisma.sql`p.status = 'VISIBLE'`,
      Prisma.sql`p."deletedAt" IS NULL`,
    ];
    if (q.type) fence.push(Prisma.sql`p.type::text = ${q.type}`);
    if (q.groupId) fence.push(Prisma.sql`p."groupId" = ${q.groupId}::uuid`);
    const fenceWhere = Prisma.join(fence, ' AND ');

    // Ranking by (createdAt + boost) must not rank every post the viewer can see on every request. The boost is at
    // most `maxBoost` minutes, so with k = limit + 1:
    //  - X is the k-th newest createdAt among the posts that are certainly still ahead of the cursor (all of them
    //    without a cursor; those older than cursor - maxBoost with one). Those k posts all rank at or after X, so
    //    the k-th best rank is at least X.
    //  - A post created before X - maxBoost can therefore never make the page, so only newer posts are ranked.
    // The result is exactly the full ranking's page. X is found among the newest few hundred posts (growing to a few
    // thousand), and the posts are read through a fenced sub-select so the planner walks the createdAt index in order
    // instead of joining and sorting everything; a feed with fewer than k visible posts among the newest 5,000 simply
    // ranks everything it has.
    const maxBoost = mode.ranked
      ? B.group + B.connection + B.discipline + B.county + B.announcement
      : 0;
    const k = q.limit + 1;
    // Measured on the volume seed: the plan Postgres makes for the actual cursor values (a custom plan) walks far more
    // posts than the generic plan, which it also adopts on its own after a few executions. Pinning the generic plan
    // makes the first request as fast as the sixth instead of leaving it to chance. The first page (no cursor) is faster
    // with the default planner, so only paging past a cursor is pinned.
    const rows = await this.prisma.$transaction(async (tx) => {
      if (cursor)
        await tx.$executeRaw`SELECT set_config('plan_cache_mode', 'force_generic_plan', true)`;
      const lowerBound = await this.rankWindowStart(
        tx,
        where,
        fenceWhere,
        cursor?.t ?? null,
        maxBoost,
        k,
      );
      // The ranking time is never earlier than `createdAt`, so older posts are the only candidates past a cursor.
      const afterCursor = cursor
        ? Prisma.sql`AND p."createdAt" <= ${cursor.t}::timestamp`
        : Prisma.empty;
      const fromBound = lowerBound
        ? Prisma.sql`AND p."createdAt" >= ${lowerBound}::timestamp`
        : Prisma.empty;
      return tx.$queryRaw<Array<{ id: string; rank_at: Date }>>(Prisma.sql`
        SELECT t.id, t.rank_at FROM (
          SELECT p.id, p."createdAt" + (${boost}) * interval '1 minute' AS rank_at
          FROM (SELECT * FROM posts p WHERE ${fenceWhere} ${afterCursor} ${fromBound} OFFSET 0) p
          JOIN users au ON au.id = p."authorId"
          LEFT JOIN creative_profiles ap ON ap."userId" = p."authorId"
          WHERE ${where}
        ) t
        ${cursor ? Prisma.sql`WHERE (t.rank_at, t.id) < (${cursor.t}::timestamp, ${cursor.id}::uuid)` : Prisma.empty}
        ORDER BY t.rank_at DESC, t.id DESC
        LIMIT ${k}`);
    });

    const hasMore = rows.length > q.limit;
    const page = hasMore ? rows.slice(0, q.limit) : rows;
    const last = page[page.length - 1];
    return {
      items: await this.views.views(
        viewerId,
        page.map((r) => r.id),
      ),
      meta: {
        nextCursor: hasMore && last ? encodeFeedCursor(last.rank_at, last.id) : null,
        limit: q.limit,
      },
    };
  }

  /**
   * The oldest `createdAt` a post can have and still make the page (see `page`): X - maxBoost, as an ISO string, or
   * null when there is no bound to apply (fewer than k visible posts among the newest 5,000).
   */
  private async rankWindowStart(
    db: Pick<Prisma.TransactionClient, '$queryRaw'>,
    where: Prisma.Sql,
    fenceWhere: Prisma.Sql,
    cursorTime: string | null,
    maxBoost: number,
    k: number,
  ): Promise<string | null> {
    const upper = new Date(
      cursorTime ? Date.parse(cursorTime) - maxBoost * 60_000 : Date.now() + 60_000,
    ).toISOString();
    for (const candidates of [200, 1_000, 5_000]) {
      const [row] = await db.$queryRaw<Array<{ x: Date | null }>>(Prisma.sql`
        SELECT min(c."createdAt") AS x FROM (
          SELECT p."createdAt"
          FROM (
            SELECT * FROM posts p WHERE ${fenceWhere} AND p."createdAt" < ${upper}::timestamp
            ORDER BY p."createdAt" DESC LIMIT ${candidates}::int
          ) p
          JOIN users au ON au.id = p."authorId"
          WHERE ${where}
          ORDER BY p."createdAt" DESC LIMIT ${k}::int
        ) c HAVING count(*) = ${k}::int`);
      if (row?.x) return new Date(row.x.getTime() - maxBoost * 60_000).toISOString();
    }
    return null;
  }
}
