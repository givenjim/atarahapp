import { Injectable } from '@nestjs/common';
import { type ReportTargetType, Prisma } from '@prisma/client';
import { ApiException } from '../common/api.exception';
import { pageMeta, toSkipTake } from '../common/pagination';
import { DomainEventBus } from '../community-core/domain-events';
import { MediaService } from '../media/media.service';
import { PrismaService } from '../prisma/prisma.service';
import {
  type BlockedMemberDto,
  type BlockedQueryDto,
  type BlockMemberDto,
  type CreateReportDto,
  type MuteStateDto,
  type MuteTargetDto,
  type MyReportDto,
  type MyReportsQueryDto,
} from './community.dto';
import { PostViewsService } from './post-views.service';
import { higherPriority, priorityFor, publicReportStatus, reportOutcome } from './rules';

const isUnique = (err: unknown) =>
  err instanceof Prisma.PrismaClientKnownRequestError && err.code === 'P2002';

/** Blocks, mutes and reports: what a member does to protect themselves and the community. */
@Injectable()
export class SafetyService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly views: PostViewsService,
    private readonly media: MediaService,
    private readonly events: DomainEventBus,
  ) {}

  /** A user id from either an id or a handle. The same 404 whether the member exists or not. */
  private async resolveUser(
    ref: { userId?: string; handle?: string },
    field: string,
  ): Promise<string> {
    if (!ref.userId === !ref.handle) {
      throw ApiException.validation('Say who, with a user id or a handle.', { field });
    }
    const user = ref.userId
      ? await this.prisma.user.findFirst({
          where: { id: ref.userId, deletedAt: null },
          select: { id: true },
        })
      : await this.prisma.creativeProfile
          .findFirst({
            where: { handle: ref.handle!.toLowerCase(), user: { deletedAt: null } },
            select: { userId: true },
          })
          .then((p) => (p ? { id: p.userId } : null));
    if (!user) throw ApiException.notFound('We could not find that member.');
    return user.id;
  }

  // ---- blocks ----------------------------------------------------------------------------------------------

  async block(userId: string, dto: BlockMemberDto): Promise<BlockedMemberDto> {
    const blockedId = await this.resolveUser(dto, 'userId');
    if (blockedId === userId) throw ApiException.invalidState('You cannot block yourself.');
    await this.prisma.$transaction(async (tx) => {
      // skipDuplicates: a repeated block is a no-op (a caught unique violation would abort the transaction).
      await tx.block.createMany({ data: [{ blockerId: userId, blockedId }], skipDuplicates: true });
      // Blocking ends any connection or pending request between the two, in both directions.
      await tx.connection.updateMany({
        where: {
          status: { in: ['PENDING', 'ACCEPTED'] },
          OR: [
            { requesterId: userId, addresseeId: blockedId },
            { requesterId: blockedId, addresseeId: userId },
          ],
        },
        data: { status: 'REMOVED', respondedAt: new Date() },
      });
    });
    const row = await this.prisma.block.findUniqueOrThrow({
      where: { blockerId_blockedId: { blockerId: userId, blockedId } },
    });
    return (await this.blockedViews([row]))[0]!;
  }

  async unblock(userId: string, blockedId: string): Promise<void> {
    await this.prisma.block.deleteMany({ where: { blockerId: userId, blockedId } });
  }

  async blocked(userId: string, q: BlockedQueryDto) {
    const where = { blockerId: userId };
    const [rows, total] = await this.prisma.$transaction([
      this.prisma.block.findMany({
        where,
        orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
        ...toSkipTake(q),
      }),
      this.prisma.block.count({ where }),
    ]);
    return { items: await this.blockedViews(rows), meta: pageMeta(q, total) };
  }

  private async blockedViews(
    rows: Array<{ blockedId: string; createdAt: Date }>,
  ): Promise<BlockedMemberDto[]> {
    const users = await this.prisma.user.findMany({
      where: { id: { in: rows.map((r) => r.blockedId) } },
      select: {
        id: true,
        fullName: true,
        creativeProfile: { select: { handle: true, displayName: true, avatarMediaId: true } },
      },
    });
    const byId = new Map(users.map((u) => [u.id, u]));
    const out: BlockedMemberDto[] = [];
    for (const r of rows) {
      const u = byId.get(r.blockedId);
      if (!u) continue;
      out.push({
        userId: u.id,
        handle: u.creativeProfile?.handle ?? null,
        displayName: u.creativeProfile?.displayName ?? u.fullName,
        avatarUrl: await this.media.imageUrl(u.creativeProfile?.avatarMediaId ?? null, 200),
        blockedAt: r.createdAt,
      });
    }
    return out;
  }

  // ---- mutes -------------------------------------------------------------------------------------------------

  async mute(userId: string, dto: MuteTargetDto): Promise<MuteStateDto> {
    let targetId: string;
    if (dto.targetType === 'USER') {
      targetId = await this.resolveUser({ userId: dto.targetId, handle: dto.handle }, 'targetId');
      if (targetId === userId) throw ApiException.invalidState('You cannot mute yourself.');
    } else {
      if (!dto.targetId) throw ApiException.validation('Say which post.', { field: 'targetId' });
      await this.views.visiblePost(userId, dto.targetId, { ownHiddenVisible: true });
      targetId = dto.targetId;
    }
    try {
      await this.prisma.mute.create({ data: { userId, targetType: dto.targetType, targetId } });
    } catch (err) {
      if (!isUnique(err)) throw err; // already muted
    }
    return { targetType: dto.targetType, targetId, muted: true };
  }

  async unmute(
    userId: string,
    targetType: 'USER' | 'POST',
    targetId: string,
  ): Promise<MuteStateDto> {
    await this.prisma.mute.deleteMany({ where: { userId, targetType, targetId } });
    return { targetType, targetId, muted: false };
  }

  // ---- reports -----------------------------------------------------------------------------------------------

  async report(userId: string, dto: CreateReportDto): Promise<MyReportDto> {
    const target = await this.resolveTarget(userId, dto);
    if (target.authorId === userId) {
      throw ApiException.invalidState('You cannot report your own content.');
    }
    const existing = await this.prisma.report.findUnique({
      where: {
        reporterId_targetType_targetId: {
          reporterId: userId,
          targetType: dto.targetType,
          targetId: target.id,
        },
      },
    });
    // Reporting the same thing twice is a no-op, not an error.
    if (existing) return this.toMine(existing);

    const note = dto.note?.trim() || null;
    const { report, caseId } = await this.prisma.$transaction(async (tx) => {
      const found = await tx.moderationCase.findUnique({
        where: { targetType_targetId: { targetType: dto.targetType, targetId: target.id } },
      });
      let caseRow;
      if (found) {
        const reportCount = found.reportCount + 1;
        const closed = found.status === 'RESOLVED' || found.status === 'DISMISSED';
        caseRow = await tx.moderationCase.update({
          where: { id: found.id },
          data: {
            reportCount,
            priority: higherPriority(found.priority, priorityFor(dto.reason, reportCount)),
            // A new report on a closed case reopens it.
            ...(closed ? { status: 'SUBMITTED', resolvedAt: null, alertedAt: null } : {}),
          },
        });
      } else {
        caseRow = await tx.moderationCase.create({
          data: {
            targetType: dto.targetType,
            targetId: target.id,
            targetAuthorId: target.authorId,
            topReason: dto.reason,
            priority: priorityFor(dto.reason, 1),
          },
        });
      }
      const created = await tx.report.create({
        data: {
          reporterId: userId,
          targetType: dto.targetType,
          targetId: target.id,
          reason: dto.reason,
          note,
          caseId: caseRow.id,
        },
      });
      return { report: created, caseId: caseRow.id };
    });
    await this.events.emit({
      type: 'ReportSubmitted',
      reportId: report.id,
      caseId,
      reporterId: userId,
      targetType: dto.targetType,
      targetId: target.id,
    });
    return this.toMine(report);
  }

  async myReports(userId: string, q: MyReportsQueryDto) {
    const where = { reporterId: userId };
    const [rows, total] = await this.prisma.$transaction([
      this.prisma.report.findMany({
        where,
        orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
        ...toSkipTake(q),
      }),
      this.prisma.report.count({ where }),
    ]);
    return { items: rows.map((r) => this.toMine(r)), meta: pageMeta(q, total) };
  }

  private toMine(r: {
    id: string;
    targetType: ReportTargetType;
    reason: string;
    status: Parameters<typeof publicReportStatus>[0];
    createdAt: Date;
    updatedAt: Date;
  }): MyReportDto {
    const status = publicReportStatus(r.status);
    return {
      id: r.id,
      targetType: r.targetType,
      reason: r.reason,
      status,
      outcome: reportOutcome(r.status),
      createdAt: r.createdAt,
      reviewedAt: status === 'REVIEWED' ? r.updatedAt : null,
    };
  }

  /** The thing being reported, when the reporter may see it. */
  private async resolveTarget(
    userId: string,
    dto: CreateReportDto,
  ): Promise<{ id: string; authorId: string | null }> {
    switch (dto.targetType) {
      case 'POST': {
        if (!dto.targetId) throw ApiException.validation('Say which post.', { field: 'targetId' });
        const p = await this.views.visiblePost(userId, dto.targetId);
        return { id: p.id, authorId: p.authorId };
      }
      case 'COMMENT': {
        if (!dto.targetId)
          throw ApiException.validation('Say which comment.', { field: 'targetId' });
        const c = await this.prisma.comment.findFirst({
          where: { id: dto.targetId, deletedAt: null, status: 'VISIBLE' },
          select: { id: true, postId: true, authorId: true },
        });
        if (!c) throw ApiException.notFound('We could not find that comment.');
        await this.views.visiblePost(userId, c.postId);
        const blocked = await this.prisma.block.count({
          where: {
            OR: [
              { blockerId: userId, blockedId: c.authorId },
              { blockerId: c.authorId, blockedId: userId },
            ],
          },
        });
        if (blocked) throw ApiException.notFound('We could not find that comment.');
        return { id: c.id, authorId: c.authorId };
      }
      case 'USER': {
        const id = await this.resolveUser({ userId: dto.targetId, handle: dto.handle }, 'targetId');
        return { id, authorId: id };
      }
      case 'GROUP': {
        if (!dto.targetId) throw ApiException.validation('Say which group.', { field: 'targetId' });
        const g = await this.prisma.group.findFirst({
          where: {
            id: dto.targetId,
            archivedAt: null,
            OR: [{ visibility: 'OPEN' }, { memberships: { some: { userId } } }],
          },
          select: { id: true },
        });
        if (!g) throw ApiException.notFound('We could not find that group.');
        return { id: g.id, authorId: null };
      }
    }
  }
}
