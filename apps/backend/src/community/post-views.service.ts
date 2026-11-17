import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { ApiException } from '../common/api.exception';
import { MediaService } from '../media/media.service';
import { PrismaService } from '../prisma/prisma.service';
import { type PostAuthorDto, type PostViewDto } from './community.dto';
import { POST_FROM, postVisibleSql } from './post-sql';

const POST_INCLUDE = {
  group: { select: { id: true, slug: true, name: true } },
  media: { orderBy: { sortOrder: 'asc' }, select: { mediaAssetId: true } },
  link: true,
} satisfies Prisma.PostInclude;

export interface VisiblePost {
  id: string;
  authorId: string;
  groupId: string | null;
  type: string;
  status: string;
}

/**
 * Turns post ids into the post cards the apps render, and answers "may this viewer see this post" for every
 * feature that acts on a post (comments, reactions, saves, mutes, reports). Visibility is decided in SQL by
 * `postVisibleSql`; the cards are only built for ids that already passed it.
 */
@Injectable()
export class PostViewsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly media: MediaService,
  ) {}

  /** The post when `viewerId` may see it, otherwise a 404 (the same answer as "does not exist"). */
  async visiblePost(
    viewerId: string,
    postId: string,
    opts: { ownHiddenVisible?: boolean } = {},
  ): Promise<VisiblePost> {
    const rows = await this.prisma.$queryRaw<
      Array<{ id: string; authorId: string; groupId: string | null; type: string; status: string }>
    >(Prisma.sql`
      SELECT p.id, p."authorId", p."groupId", p.type::text AS type, p.status::text AS status
      ${POST_FROM}
      WHERE p.id = ${postId}::uuid
        AND ${postVisibleSql({ viewerId, openGroupsReadable: true, ownHiddenVisible: opts.ownHiddenVisible })}`);
    if (rows.length === 0) throw ApiException.notFound('We could not find that post.');
    return rows[0]!;
  }

  /** Of these ids, the ones the viewer may see. */
  async filterVisible(viewerId: string, ids: string[]): Promise<Set<string>> {
    if (ids.length === 0) return new Set();
    const rows = await this.prisma.$queryRaw<Array<{ id: string }>>(Prisma.sql`
      SELECT p.id ${POST_FROM}
      WHERE p.id IN (${Prisma.join(ids.map((i) => Prisma.sql`${i}::uuid`))})
        AND ${postVisibleSql({ viewerId, openGroupsReadable: true })}`);
    return new Set(rows.map((r) => r.id));
  }

  /** Cards for the given post ids, in the order given. Missing ids are skipped. */
  async views(viewerId: string, ids: string[]): Promise<PostViewDto[]> {
    if (ids.length === 0) return [];
    const [rows, reacted, saved, muted] = await Promise.all([
      this.prisma.post.findMany({ where: { id: { in: ids } }, include: POST_INCLUDE }),
      this.prisma.reaction.findMany({
        where: { userId: viewerId, postId: { in: ids } },
        select: { postId: true },
      }),
      this.prisma.savedItem.findMany({
        where: { userId: viewerId, type: 'POST', targetId: { in: ids } },
        select: { targetId: true },
      }),
      this.prisma.mute.findMany({
        where: { userId: viewerId, targetType: 'POST', targetId: { in: ids } },
        select: { targetId: true },
      }),
    ]);
    const reactedSet = new Set(reacted.map((r) => r.postId));
    const savedSet = new Set(saved.map((s) => s.targetId));
    const mutedSet = new Set(muted.map((m) => m.targetId));
    const byId = new Map(rows.map((r) => [r.id, r]));
    const authors = await this.authors([...new Set(rows.map((r) => r.authorId))]);
    const mediaViews = await this.media.viewMany(
      rows.flatMap((r) => r.media.map((m) => m.mediaAssetId)),
    );

    const out: PostViewDto[] = [];
    for (const id of ids) {
      const r = byId.get(id);
      const author = r ? authors.get(r.authorId) : undefined;
      if (!r || !author) continue;
      out.push({
        id: r.id,
        type: r.type,
        body: r.body,
        audience: r.audience,
        group: r.group,
        author,
        media: r.media.flatMap((m) => {
          const v = mediaViews.get(m.mediaAssetId);
          if (!v || (v.kind !== 'IMAGE' && v.kind !== 'VIDEO')) return [];
          return [
            {
              id: v.id,
              kind: v.kind,
              url: v.url,
              thumbUrl: v.variants?.['600'] ?? v.url,
              width: v.width,
              height: v.height,
            },
          ];
        }),
        link: r.link
          ? {
              url: r.link.url,
              title: r.link.title,
              description: r.link.description,
              image: r.link.image,
              siteName: r.link.siteName,
            }
          : null,
        reactionCount: r.reactionCount,
        replyCount: r.replyCount,
        isStaffAnnouncement: r.isStaffAnnouncement,
        status: r.status === 'HIDDEN' ? 'HIDDEN' : 'VISIBLE',
        viewer: {
          reacted: reactedSet.has(r.id),
          saved: savedSet.has(r.id),
          muted: mutedSet.has(r.id),
          isAuthor: r.authorId === viewerId,
        },
        createdAt: r.createdAt,
        editedAt: r.editedAt,
      });
    }
    return out;
  }

  async view(viewerId: string, id: string): Promise<PostViewDto> {
    const [v] = await this.views(viewerId, [id]);
    if (!v) throw ApiException.notFound('We could not find that post.');
    return v;
  }

  /** Name, handle, picture and tick for each member. Staff without a profile fall back to their account name. */
  async authors(userIds: string[]): Promise<Map<string, PostAuthorDto>> {
    if (userIds.length === 0) return new Map();
    const users = await this.prisma.user.findMany({
      where: { id: { in: userIds } },
      select: {
        id: true,
        fullName: true,
        creativeProfile: {
          select: {
            handle: true,
            displayName: true,
            headline: true,
            avatarMediaId: true,
            verification: { select: { status: true } },
          },
        },
      },
    });
    const out = new Map<string, PostAuthorDto>();
    for (const u of users) {
      const p = u.creativeProfile;
      out.set(u.id, {
        id: u.id,
        handle: p?.handle ?? null,
        displayName: p?.displayName ?? u.fullName,
        avatarUrl: await this.media.imageUrl(p?.avatarMediaId ?? null, 200),
        headline: p?.headline ?? null,
        verified: p?.verification?.status === 'VERIFIED',
      });
    }
    return out;
  }
}
