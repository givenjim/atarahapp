import { Prisma } from '@prisma/client';
import { notBlockedSql } from '../community-core/blocks';

export interface PostVisibility {
  viewerId: string;
  /**
   * Group posts of an OPEN group are readable by every member (group page, single post, search). The feed passes
   * false: it only shows groups the member has joined.
   */
  openGroupsReadable: boolean;
  /** The author may still open their own post after a moderator hid it (so they can see why it vanished). */
  ownHiddenVisible?: boolean;
}

/**
 * The one definition of "this viewer may see this post", applied **in SQL** by the feed, group pages, single post,
 * saved posts and search. Expects the aliases `p` (posts) and `au` (the author's users row).
 *
 * Audience, group membership, blocks (both directions) and status live here and nowhere else.
 */
export function postVisibleSql(o: PostVisibility): Prisma.Sql {
  const v = o.viewerId;
  const statusOk = o.ownHiddenVisible
    ? Prisma.sql`(p.status = 'VISIBLE' OR (p.status = 'HIDDEN' AND p."authorId" = ${v}::uuid))`
    : Prisma.sql`p.status = 'VISIBLE'`;
  const openGroup = o.openGroupsReadable
    ? Prisma.sql`OR EXISTS (SELECT 1 FROM groups gr WHERE gr.id = p."groupId" AND gr.visibility::text = 'OPEN')`
    : Prisma.empty;
  return Prisma.sql`(
    p."deletedAt" IS NULL AND ${statusOk}
    AND au.status::text = 'ACTIVE' AND au."deletedAt" IS NULL
    AND ${notBlockedSql(v, Prisma.sql`p."authorId"`)}
    AND (
      p."authorId" = ${v}::uuid
      OR p.audience::text IN ('PUBLIC', 'MEMBERS')
      OR (p.audience::text = 'CONNECTIONS' AND EXISTS (SELECT 1 FROM connections c
          WHERE c.status::text = 'ACCEPTED'
            AND ((c."requesterId" = ${v}::uuid AND c."addresseeId" = p."authorId")
              OR (c."requesterId" = p."authorId" AND c."addresseeId" = ${v}::uuid))))
      OR (p.audience::text = 'GROUP'
          AND EXISTS (SELECT 1 FROM groups gx WHERE gx.id = p."groupId" AND gx."archivedAt" IS NULL)
          AND (EXISTS (SELECT 1 FROM group_memberships gm
                WHERE gm."groupId" = p."groupId" AND gm."userId" = ${v}::uuid) ${openGroup}))
    ))`;
}

/** SQL: the viewer has not muted this post's author or this thread. Expects the alias `p`. */
export const postNotMutedSql = (viewerId: string): Prisma.Sql =>
  Prisma.sql`NOT EXISTS (SELECT 1 FROM mutes m WHERE m."userId" = ${viewerId}::uuid AND (
    (m."targetType"::text = 'USER' AND m."targetId" = p."authorId")
    OR (m."targetType"::text = 'POST' AND m."targetId" = p.id)))`;

/** The base every post query shares: posts and their author's account row. */
export const POST_FROM = Prisma.sql`FROM posts p JOIN users au ON au.id = p."authorId"`;
