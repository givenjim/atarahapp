import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { AuditService } from '../audit/audit.service';
import { ApiException } from '../common/api.exception';
import { pageMeta, toSkipTake } from '../common/pagination';
import { slugify } from '../creative/slug';
import { MediaService } from '../media/media.service';
import { PrismaService } from '../prisma/prisma.service';
import {
  type AdminAnnouncementsQueryDto,
  type AdminGroupDto,
  type AdminGroupsQueryDto,
  type CreateAnnouncementDto,
  type CreateGroupDto,
  type GroupModeratorBodyDto,
  type UpdateGroupDto,
} from './community-admin.dto';
import { PostViewsService } from './post-views.service';
import { PostsService } from './posts.service';

export interface AdminActor {
  userId: string;
  ip?: string;
  requestId?: string;
}

const isUnique = (err: unknown) =>
  err instanceof Prisma.PrismaClientKnownRequestError && err.code === 'P2002';

const GROUP_INCLUDE = {
  discipline: { select: { name: true } },
  county: { select: { name: true } },
  memberships: {
    where: { role: { in: ['MODERATOR', 'OWNER'] } },
    select: {
      role: true,
      user: {
        select: {
          id: true,
          fullName: true,
          creativeProfile: { select: { handle: true, displayName: true } },
        },
      },
    },
  },
  pins: { orderBy: { createdAt: 'desc' }, select: { postId: true } },
} satisfies Prisma.GroupInclude;

type GroupRow = Prisma.GroupGetPayload<{ include: typeof GROUP_INCLUDE }>;

/** Group management and staff announcements. Every change is audited. */
@Injectable()
export class AdminGroupsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
    private readonly media: MediaService,
    private readonly views: PostViewsService,
    private readonly posts: PostsService,
  ) {}

  async list(q: AdminGroupsQueryDto) {
    const where: Prisma.GroupWhereInput = {
      ...(q.includeArchived ? {} : { archivedAt: null }),
      ...(q.type ? { type: q.type } : {}),
      ...(q.q?.trim() ? { name: { contains: q.q.trim(), mode: 'insensitive' } } : {}),
    };
    const [rows, total] = await this.prisma.$transaction([
      this.prisma.group.findMany({
        where,
        include: GROUP_INCLUDE,
        orderBy: [{ isOfficial: 'desc' }, { name: 'asc' }, { id: 'asc' }],
        ...toSkipTake(q),
      }),
      this.prisma.group.count({ where }),
    ]);
    return { items: await Promise.all(rows.map((g) => this.view(g))), meta: pageMeta(q, total) };
  }

  async get(id: string): Promise<AdminGroupDto> {
    return this.view(await this.row(id));
  }

  async create(actor: AdminActor, dto: CreateGroupDto): Promise<AdminGroupDto> {
    const slug = dto.slug ?? slugify(dto.name);
    if (!slug)
      throw ApiException.validation('Give the group a name with letters or numbers.', {
        field: 'name',
      });
    await this.assertRefs(dto);
    let id: string;
    try {
      const created = await this.prisma.$transaction(async (tx) => {
        const g = await tx.group.create({
          data: {
            slug,
            name: dto.name.trim(),
            type: dto.type,
            description: dto.description?.trim() ?? '',
            disciplineId: dto.disciplineId ?? null,
            countyId: dto.countyId ?? null,
            coverMediaId: dto.coverMediaId ?? null,
            isOfficial: dto.isOfficial ?? true,
            visibility: dto.visibility ?? 'OPEN',
            createdById: actor.userId,
            memberCount: 1,
          },
        });
        // The creator owns it and counts as its first member.
        await tx.groupMembership.create({
          data: { groupId: g.id, userId: actor.userId, role: 'OWNER' },
        });
        await this.audit.record(
          {
            actorType: 'ADMIN',
            actorId: actor.userId,
            action: 'group.create',
            entityType: 'group',
            entityId: g.id,
            after: {
              slug,
              name: g.name,
              type: g.type,
              visibility: g.visibility,
              isOfficial: g.isOfficial,
            },
            ip: actor.ip,
            requestId: actor.requestId,
          },
          tx,
        );
        return g;
      });
      id = created.id;
    } catch (err) {
      if (isUnique(err))
        throw ApiException.conflict('A group with that web name already exists.', {
          field: 'slug',
        });
      throw err;
    }
    return this.get(id);
  }

  async update(actor: AdminActor, id: string, dto: UpdateGroupDto): Promise<AdminGroupDto> {
    const before = await this.row(id);
    await this.assertRefs(dto);
    const data: Prisma.GroupUncheckedUpdateInput = {
      ...(dto.name !== undefined ? { name: dto.name.trim() } : {}),
      ...(dto.description !== undefined ? { description: dto.description.trim() } : {}),
      ...(dto.disciplineId !== undefined ? { disciplineId: dto.disciplineId } : {}),
      ...(dto.countyId !== undefined ? { countyId: dto.countyId } : {}),
      ...(dto.coverMediaId !== undefined ? { coverMediaId: dto.coverMediaId } : {}),
      ...(dto.isOfficial !== undefined ? { isOfficial: dto.isOfficial } : {}),
      ...(dto.visibility !== undefined ? { visibility: dto.visibility } : {}),
    };
    await this.prisma.$transaction(async (tx) => {
      await tx.group.update({ where: { id }, data });
      await this.audit.record(
        {
          actorType: 'ADMIN',
          actorId: actor.userId,
          action: 'group.update',
          entityType: 'group',
          entityId: id,
          before: {
            name: before.name,
            visibility: before.visibility,
            isOfficial: before.isOfficial,
          },
          after: dto,
          ip: actor.ip,
          requestId: actor.requestId,
        },
        tx,
      );
    });
    return this.get(id);
  }

  /** Groups are archived, never deleted: their posts and memberships stay for moderation history. */
  async archive(actor: AdminActor, id: string): Promise<void> {
    await this.row(id);
    await this.prisma.$transaction(async (tx) => {
      await tx.group.update({ where: { id }, data: { archivedAt: new Date() } });
      await this.audit.record(
        {
          actorType: 'ADMIN',
          actorId: actor.userId,
          action: 'group.archive',
          entityType: 'group',
          entityId: id,
          ip: actor.ip,
          requestId: actor.requestId,
        },
        tx,
      );
    });
  }

  async addModerator(
    actor: AdminActor,
    id: string,
    dto: GroupModeratorBodyDto,
  ): Promise<AdminGroupDto> {
    await this.row(id);
    const user = await this.prisma.user.findFirst({
      where: { id: dto.userId, status: 'ACTIVE', deletedAt: null },
      select: { id: true },
    });
    if (!user) throw ApiException.notFound('We could not find that member.');
    const role = dto.role ?? 'MODERATOR';
    await this.prisma.$transaction(async (tx) => {
      const existing = await tx.groupMembership.findUnique({
        where: { groupId_userId: { groupId: id, userId: dto.userId } },
      });
      if (existing) {
        await tx.groupMembership.update({ where: { id: existing.id }, data: { role } });
      } else {
        await tx.groupMembership.create({ data: { groupId: id, userId: dto.userId, role } });
        await tx.group.update({ where: { id }, data: { memberCount: { increment: 1 } } });
      }
      await this.audit.record(
        {
          actorType: 'ADMIN',
          actorId: actor.userId,
          action: 'group.moderator.assign',
          entityType: 'group',
          entityId: id,
          before: { role: existing?.role ?? null },
          after: { userId: dto.userId, role },
          ip: actor.ip,
          requestId: actor.requestId,
        },
        tx,
      );
    });
    return this.get(id);
  }

  async removeModerator(actor: AdminActor, id: string, userId: string): Promise<AdminGroupDto> {
    await this.row(id);
    const m = await this.prisma.groupMembership.findUnique({
      where: { groupId_userId: { groupId: id, userId } },
    });
    if (!m || m.role === 'MEMBER')
      throw ApiException.notFound('That member does not moderate this group.');
    await this.prisma.$transaction(async (tx) => {
      await tx.groupMembership.update({ where: { id: m.id }, data: { role: 'MEMBER' } });
      await this.audit.record(
        {
          actorType: 'ADMIN',
          actorId: actor.userId,
          action: 'group.moderator.remove',
          entityType: 'group',
          entityId: id,
          before: { userId, role: m.role },
          after: { userId, role: 'MEMBER' },
          ip: actor.ip,
          requestId: actor.requestId,
        },
        tx,
      );
    });
    return this.get(id);
  }

  async pin(actor: AdminActor, id: string, postId: string): Promise<AdminGroupDto> {
    await this.row(id);
    const post = await this.prisma.post.findFirst({
      where: { id: postId, groupId: id, deletedAt: null, status: 'VISIBLE' },
      select: { id: true },
    });
    if (!post) throw ApiException.notFound('We could not find that post in this group.');
    await this.prisma.$transaction(async (tx) => {
      await tx.groupPin.createMany({
        data: [{ groupId: id, postId, pinnedById: actor.userId }],
        skipDuplicates: true,
      });
      await this.audit.record(
        {
          actorType: 'ADMIN',
          actorId: actor.userId,
          action: 'group.pin',
          entityType: 'group',
          entityId: id,
          after: { postId },
          ip: actor.ip,
          requestId: actor.requestId,
        },
        tx,
      );
    });
    return this.get(id);
  }

  async unpin(actor: AdminActor, id: string, postId: string): Promise<AdminGroupDto> {
    await this.row(id);
    await this.prisma.$transaction(async (tx) => {
      const res = await tx.groupPin.deleteMany({ where: { groupId: id, postId } });
      if (res.count === 0) throw ApiException.notFound('That post is not pinned in this group.');
      await this.audit.record(
        {
          actorType: 'ADMIN',
          actorId: actor.userId,
          action: 'group.unpin',
          entityType: 'group',
          entityId: id,
          before: { postId },
          ip: actor.ip,
          requestId: actor.requestId,
        },
        tx,
      );
    });
    return this.get(id);
  }

  // ---- announcements -----------------------------------------------------------------------------------------

  /** A staff announcement to every member, or to one group. The caller holds community.announce. */
  async announce(actor: AdminActor, dto: CreateAnnouncementDto) {
    if (dto.groupId) {
      const g = await this.prisma.group.findFirst({
        where: { id: dto.groupId, archivedAt: null },
        select: { id: true },
      });
      if (!g) throw ApiException.notFound('We could not find that group.');
    }
    const post = await this.posts.create(actor.userId, {
      type: 'ANNOUNCEMENT',
      body: dto.body,
      audience: dto.groupId ? 'GROUP' : 'MEMBERS',
      groupId: dto.groupId,
    });
    await this.audit.record({
      actorType: 'ADMIN',
      actorId: actor.userId,
      action: 'announcement.create',
      entityType: 'post',
      entityId: post.id,
      after: { groupId: dto.groupId ?? null },
      ip: actor.ip,
      requestId: actor.requestId,
    });
    return post;
  }

  async announcements(viewerId: string, q: AdminAnnouncementsQueryDto) {
    const where: Prisma.PostWhereInput = {
      isStaffAnnouncement: true,
      deletedAt: null,
      status: { not: 'REMOVED' },
    };
    const [rows, total] = await this.prisma.$transaction([
      this.prisma.post.findMany({
        where,
        select: { id: true },
        orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
        ...toSkipTake(q),
      }),
      this.prisma.post.count({ where }),
    ]);
    return {
      items: await this.views.views(
        viewerId,
        rows.map((r) => r.id),
      ),
      meta: pageMeta(q, total),
    };
  }

  // ---- helpers -----------------------------------------------------------------------------------------------

  private async row(id: string): Promise<GroupRow> {
    const g = await this.prisma.group.findUnique({ where: { id }, include: GROUP_INCLUDE });
    if (!g) throw ApiException.notFound('We could not find that group.');
    return g;
  }

  private async assertRefs(dto: {
    disciplineId?: string | null;
    countyId?: string | null;
    coverMediaId?: string | null;
  }) {
    if (
      dto.disciplineId &&
      !(await this.prisma.discipline.count({ where: { id: dto.disciplineId } }))
    ) {
      throw ApiException.validation('That discipline does not exist.', { field: 'disciplineId' });
    }
    if (dto.countyId && !(await this.prisma.county.count({ where: { id: dto.countyId } }))) {
      throw ApiException.validation('That county does not exist.', { field: 'countyId' });
    }
    if (dto.coverMediaId) {
      const m = await this.prisma.mediaAsset.count({
        where: { id: dto.coverMediaId, kind: 'IMAGE', deletedAt: null },
      });
      if (!m)
        throw ApiException.validation('That cover image does not exist.', {
          field: 'coverMediaId',
        });
    }
  }

  private async view(g: GroupRow): Promise<AdminGroupDto> {
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
      joined: false,
      role: null,
      visibility: g.visibility,
      disciplineId: g.disciplineId,
      countyId: g.countyId,
      coverMediaId: g.coverMediaId,
      archivedAt: g.archivedAt,
      moderators: g.memberships.map((m) => ({
        role: m.role,
        person: {
          id: m.user.id,
          displayName: m.user.creativeProfile?.displayName ?? m.user.fullName,
          handle: m.user.creativeProfile?.handle ?? null,
        },
      })),
      pinnedPostIds: g.pins.map((p) => p.postId),
      createdAt: g.createdAt,
    };
  }
}
