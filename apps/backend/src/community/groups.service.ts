import { Injectable } from '@nestjs/common';
import { type Group, type GroupMembership, Prisma } from '@prisma/client';
import { ApiException } from '../common/api.exception';
import { pageMeta, toSkipTake } from '../common/pagination';
import { MediaService } from '../media/media.service';
import { PrismaService } from '../prisma/prisma.service';
import {
  type GroupCardDto,
  type GroupDetailDto,
  type GroupMembershipStateDto,
  type GroupPostBodyDto,
  type GroupPostsQueryDto,
  type GroupsQueryDto,
  type PostViewDto,
} from './community.dto';
import { FeedService } from './feed.service';
import { PostViewsService } from './post-views.service';
import { PostsService } from './posts.service';

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const RECENT_DISCUSSIONS = 5;

const GROUP_INCLUDE = {
  discipline: { select: { name: true } },
  county: { select: { name: true } },
} satisfies Prisma.GroupInclude;

type GroupRow = Prisma.GroupGetPayload<{ include: typeof GROUP_INCLUDE }>;

/** The member-facing side of groups: discover, join, leave, read and post. Management is in AdminGroupsService. */
@Injectable()
export class GroupsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly media: MediaService,
    private readonly feed: FeedService,
    private readonly views: PostViewsService,
    private readonly posts: PostsService,
  ) {}

  async list(viewerId: string, q: GroupsQueryDto) {
    const where: Prisma.GroupWhereInput = {
      archivedAt: null,
      ...(q.type ? { type: q.type } : {}),
      ...(q.q?.trim() ? { name: { contains: q.q.trim(), mode: 'insensitive' } } : {}),
      ...(q.scope === 'mine'
        ? { memberships: { some: { userId: viewerId } } }
        : q.scope === 'discover'
          ? { visibility: 'OPEN', memberships: { none: { userId: viewerId } } }
          : { OR: [{ visibility: 'OPEN' }, { memberships: { some: { userId: viewerId } } }] }),
    };
    const [rows, total] = await this.prisma.$transaction([
      this.prisma.group.findMany({
        where,
        include: GROUP_INCLUDE,
        orderBy: [{ isOfficial: 'desc' }, { memberCount: 'desc' }, { name: 'asc' }, { id: 'asc' }],
        ...toSkipTake(q),
      }),
      this.prisma.group.count({ where }),
    ]);
    const memberships = await this.membershipsOf(
      viewerId,
      rows.map((r) => r.id),
    );
    const items = await Promise.all(rows.map((g) => this.card(g, memberships.get(g.id) ?? null)));
    return { items, meta: pageMeta(q, total) };
  }

  async detail(viewerId: string, ref: string): Promise<GroupDetailDto> {
    const { group, membership } = await this.readable(viewerId, ref);
    const card = await this.card(group, membership);

    // The latest pinned post that is still visible to this viewer.
    const pins = await this.prisma.groupPin.findMany({
      where: { groupId: group.id },
      orderBy: { createdAt: 'desc' },
      take: 10,
      select: { postId: true },
    });
    const visible = await this.views.filterVisible(
      viewerId,
      pins.map((p) => p.postId),
    );
    const pinnedId = pins.map((p) => p.postId).find((id) => visible.has(id));
    const pinned = pinnedId ? await this.views.view(viewerId, pinnedId) : null;

    const recent = await this.feed.groupPosts(viewerId, group.id, {
      limit: RECENT_DISCUSSIONS + 1,
    });
    const recentDiscussions = recent.items
      .filter((p) => p.id !== pinned?.id)
      .slice(0, RECENT_DISCUSSIONS);
    return {
      ...card,
      visibility: group.visibility,
      pinned,
      recentDiscussions,
      viewer: { joined: !!membership, role: membership?.role ?? null, canPost: !!membership },
    };
  }

  async join(userId: string, ref: string): Promise<GroupMembershipStateDto> {
    const { group, membership } = await this.readable(userId, ref);
    // A private group is only joined by invitation, and a non-member never learns it exists.
    if (!membership && group.visibility !== 'OPEN') {
      throw ApiException.notFound('We could not find that group.');
    }
    if (!membership) {
      await this.prisma.$transaction(async (tx) => {
        const res = await tx.groupMembership.createMany({
          data: [{ groupId: group.id, userId }],
          skipDuplicates: true,
        });
        if (res.count === 1) {
          await tx.group.update({
            where: { id: group.id },
            data: { memberCount: { increment: 1 } },
          });
        }
      });
    }
    return this.state(group.id, true);
  }

  async leave(userId: string, ref: string): Promise<GroupMembershipStateDto> {
    const { group, membership } = await this.readable(userId, ref);
    if (membership?.role === 'OWNER') {
      throw ApiException.invalidState(
        'Owners cannot leave their group. Ask Atarah to hand it over.',
      );
    }
    if (membership) {
      await this.prisma.$transaction(async (tx) => {
        const res = await tx.groupMembership.deleteMany({ where: { groupId: group.id, userId } });
        if (res.count === 1) {
          await tx.group.update({
            where: { id: group.id },
            data: { memberCount: { decrement: 1 } },
          });
        }
      });
    }
    return this.state(group.id, false);
  }

  async postsOf(viewerId: string, ref: string, q: GroupPostsQueryDto) {
    const { group } = await this.readable(viewerId, ref);
    return this.feed.groupPosts(viewerId, group.id, {
      type: q.type,
      cursor: q.cursor,
      limit: q.limit,
    });
  }

  async createPost(userId: string, ref: string, dto: GroupPostBodyDto): Promise<PostViewDto> {
    const { group } = await this.readable(userId, ref);
    return this.posts.create(userId, { ...dto, groupId: group.id });
  }

  // ---- helpers -----------------------------------------------------------------------------------------------

  /** The group when the viewer may see it (open, or they belong), otherwise a 404. */
  async readable(
    viewerId: string,
    ref: string,
  ): Promise<{ group: GroupRow; membership: GroupMembership | null }> {
    const group = await this.prisma.group.findFirst({
      where: { archivedAt: null, ...(UUID.test(ref) ? { id: ref } : { slug: ref.toLowerCase() }) },
      include: GROUP_INCLUDE,
    });
    const membership = group
      ? await this.prisma.groupMembership.findUnique({
          where: { groupId_userId: { groupId: group.id, userId: viewerId } },
        })
      : null;
    if (!group || (group.visibility !== 'OPEN' && !membership)) {
      throw ApiException.notFound('We could not find that group.');
    }
    return { group, membership };
  }

  private async state(groupId: string, joined: boolean): Promise<GroupMembershipStateDto> {
    const g = await this.prisma.group.findUniqueOrThrow({
      where: { id: groupId },
      select: { memberCount: true },
    });
    return { groupId, joined, memberCount: g.memberCount };
  }

  private async membershipsOf(userId: string, groupIds: string[]) {
    const rows = groupIds.length
      ? await this.prisma.groupMembership.findMany({ where: { userId, groupId: { in: groupIds } } })
      : [];
    return new Map(rows.map((m) => [m.groupId, m]));
  }

  async card(
    g:
      | GroupRow
      | (Group & { discipline?: { name: string } | null; county?: { name: string } | null }),
    m: GroupMembership | null,
  ): Promise<GroupCardDto> {
    return {
      id: g.id,
      slug: g.slug,
      type: g.type,
      name: g.name,
      description: g.description,
      coverUrl: await this.media.imageUrl(g.coverMediaId, 600),
      memberCount: g.memberCount,
      isOfficial: g.isOfficial,
      focus: g.discipline?.name ?? g.county?.name ?? null,
      joined: !!m,
      role: m?.role ?? null,
    };
  }
}
