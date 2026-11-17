import { Injectable } from '@nestjs/common';
import {
  type ModerationCase,
  type ModerationAction,
  Prisma,
  type ReportTargetType,
} from '@prisma/client';
import { AccessService } from '../access/access.service';
import { AdminService } from '../admin/admin.service';
import { AuditService } from '../audit/audit.service';
import { ApiException } from '../common/api.exception';
import { ErrorCode } from '../common/error-codes';
import { pageMeta, toSkipTake } from '../common/pagination';
import { DomainEventBus } from '../community-core/domain-events';
import { PrismaService } from '../prisma/prisma.service';
import { type AdminActor } from './admin-groups.service';
import { recountReplies } from './comments.service';
import {
  type AdminCaseDetailDto,
  type AdminCaseDto,
  type AdminCasesQueryDto,
  type AdminPersonRefDto,
  type AdminReportDto,
  type AdminReportsQueryDto,
  type AssignCaseBodyDto,
  type ModerationActionBodyDto,
} from './community-admin.dto';
import { allowedActions, statusAfter } from './rules';

const PREVIEW_CHARS = 140;
const REAUTH_MINUTES = 5;
const excerpt = (s: string | null | undefined) =>
  s ? (s.length > PREVIEW_CHARS ? `${s.slice(0, PREVIEW_CHARS - 1)}…` : s) : null;

export interface ModerationActor extends AdminActor {
  reauthAt: Date | null;
}

/**
 * The moderation queue and the only way staff change community content: a decision (`ModerationAction`) recorded
 * in the append-only log, with its effect applied in the same transaction. Staff never edit posts or comments.
 */
@Injectable()
export class ModerationService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
    private readonly access: AccessService,
    private readonly admin: AdminService,
    private readonly events: DomainEventBus,
  ) {}

  // ---- reading -----------------------------------------------------------------------------------------------

  async reports(q: AdminReportsQueryDto) {
    const where: Prisma.ReportWhereInput = {
      ...(q.status ? { status: q.status } : {}),
      ...(q.targetType ? { targetType: q.targetType } : {}),
    };
    const [rows, total] = await this.prisma.$transaction([
      this.prisma.report.findMany({
        where,
        orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
        ...toSkipTake(q),
      }),
      this.prisma.report.count({ where }),
    ]);
    const people = await this.people(rows.map((r) => r.reporterId));
    const items: AdminReportDto[] = rows.map((r) => ({
      id: r.id,
      targetType: r.targetType,
      targetId: r.targetId,
      reason: r.reason,
      note: r.note,
      status: r.status,
      caseId: r.caseId,
      reporter: people.get(r.reporterId) ?? null,
      createdAt: r.createdAt,
    }));
    return { items, meta: pageMeta(q, total) };
  }

  async cases(q: AdminCasesQueryDto) {
    const where: Prisma.ModerationCaseWhereInput = {
      ...(q.status ? { status: q.status } : {}),
      ...(q.priority ? { priority: q.priority } : {}),
      ...(q.targetType ? { targetType: q.targetType } : {}),
      ...(q.assigneeId ? { assigneeId: q.assigneeId } : {}),
      ...(q.open ? { status: { in: ['SUBMITTED', 'IN_REVIEW', 'ESCALATED'] } } : {}),
      ...(q.olderThanHours
        ? { createdAt: { lt: new Date(Date.now() - q.olderThanHours * 3_600_000) } }
        : {}),
    };
    const [rows, total] = await this.prisma.$transaction([
      this.prisma.moderationCase.findMany({
        where,
        // Most urgent first, then oldest first: the queue is worked from the top.
        orderBy: [{ priority: 'desc' }, { createdAt: 'asc' }, { id: 'asc' }],
        ...toSkipTake(q),
      }),
      this.prisma.moderationCase.count({ where }),
    ]);
    return { items: await this.caseViews(rows), meta: pageMeta(q, total) };
  }

  async caseDetail(id: string): Promise<AdminCaseDetailDto> {
    const c = await this.load(id);
    const [view] = await this.caseViews([c]);
    const [reports, actions] = await Promise.all([
      this.prisma.report.findMany({ where: { caseId: id }, orderBy: { createdAt: 'asc' } }),
      this.prisma.moderationActionLog.findMany({
        where: { caseId: id },
        orderBy: { createdAt: 'asc' },
      }),
    ]);
    const people = await this.people([
      ...reports.map((r) => r.reporterId),
      ...actions.map((a) => a.actorId),
    ]);
    return {
      ...view!,
      content: await this.content(c.targetType, c.targetId),
      reports: reports.map((r) => ({
        id: r.id,
        reason: r.reason,
        note: r.note,
        status: r.status,
        reporter: people.get(r.reporterId) ?? null,
        createdAt: r.createdAt,
      })),
      history: actions.map((a) => ({
        id: a.id,
        action: a.action,
        reason: a.reason,
        actor: people.get(a.actorId) ?? null,
        createdAt: a.createdAt,
      })),
      allowedActions: allowedActions(c.targetType),
    };
  }

  // ---- deciding ----------------------------------------------------------------------------------------------

  async assign(actor: AdminActor, id: string, dto: AssignCaseBodyDto): Promise<AdminCaseDto> {
    const c = await this.load(id);
    const assigneeId = dto.assigneeId ?? null;
    if (assigneeId) {
      const user = await this.prisma.user.findFirst({
        where: { id: assigneeId, status: 'ACTIVE', deletedAt: null },
        select: { status: true },
      });
      const ok =
        user && (await this.access.hasPermission(assigneeId, user.status, 'report.resolve'));
      if (!ok) {
        throw ApiException.validation('That person cannot handle reports.', {
          field: 'assigneeId',
        });
      }
    }
    await this.prisma.$transaction(async (tx) => {
      await tx.moderationCase.update({
        where: { id },
        data: {
          assigneeId,
          // Taking a case moves it out of the untouched pile.
          ...(assigneeId && c.status === 'SUBMITTED' ? { status: 'IN_REVIEW' } : {}),
        },
      });
      if (assigneeId && c.status === 'SUBMITTED') {
        await tx.report.updateMany({
          where: { caseId: id, status: 'SUBMITTED' },
          data: { status: 'IN_REVIEW' },
        });
      }
      await this.audit.record(
        {
          actorType: 'ADMIN',
          actorId: actor.userId,
          action: 'moderation.case.assign',
          entityType: 'moderation_case',
          entityId: id,
          before: { assigneeId: c.assigneeId },
          after: { assigneeId },
          ip: actor.ip,
          requestId: actor.requestId,
        },
        tx,
      );
    });
    return (await this.caseViews([await this.load(id)]))[0]!;
  }

  async act(
    actor: ModerationActor,
    id: string,
    dto: ModerationActionBodyDto,
  ): Promise<AdminCaseDetailDto> {
    const c = await this.load(id);
    const { action } = dto;
    if (!allowedActions(c.targetType).includes(action)) {
      throw ApiException.validation('That decision does not apply to this kind of report.', {
        field: 'action',
        allowed: allowedActions(c.targetType),
      });
    }
    const reason = dto.reason?.trim() || null;
    if (action !== 'NO_ACTION' && !reason) {
      throw ApiException.validation('Say why, for the record.', { field: 'reason' });
    }
    if (c.targetAuthorId === actor.userId) {
      throw ApiException.forbidden(
        'You cannot decide on a case about your own account or content.',
      );
    }

    if (action === 'SUSPEND_ACCOUNT') {
      if (!c.targetAuthorId)
        throw ApiException.validation('There is no account to suspend.', { field: 'action' });
      await this.assertMaySuspend(actor);
      // Audited and enforced (Supabase sign-in ban, live sessions revoked) by the same path as the Users screen.
      await this.admin.suspend(
        { userId: actor.userId, ip: actor.ip, requestId: actor.requestId },
        c.targetAuthorId,
        reason!,
      );
    }

    const { closedReportIds } = await this.prisma.$transaction(async (tx) => {
      await this.applyEffect(tx, c, action, reason, actor, dto.restrictDays);
      const next = statusAfter(action);
      const closing = next === 'RESOLVED' || next === 'DISMISSED';
      await tx.moderationActionLog.create({
        data: {
          caseId: id,
          action,
          reason,
          actorId: actor.userId,
          targetType: c.targetType,
          targetId: c.targetId,
        },
      });
      await tx.moderationCase.update({
        where: { id },
        data: {
          status: next,
          resolvedAt: closing ? new Date() : null,
          ...(next === 'ESCALATED' ? { priority: 'URGENT' } : {}),
        },
      });
      await tx.report.updateMany({ where: { caseId: id }, data: { status: next } });
      const closed = closing
        ? await tx.report.findMany({
            where: { caseId: id, notifiedAt: null },
            select: { id: true },
          })
        : [];
      await this.audit.record(
        {
          actorType: 'ADMIN',
          actorId: actor.userId,
          action: `moderation.${action.toLowerCase()}`,
          entityType: 'moderation_case',
          entityId: id,
          before: { status: c.status },
          after: { status: next, targetType: c.targetType, targetId: c.targetId, reason },
          ip: actor.ip,
          requestId: actor.requestId,
        },
        tx,
      );
      return { closedReportIds: closed.map((r) => r.id) };
    });

    await this.events.emit({
      type: 'ModerationActionTaken',
      caseId: id,
      action,
      actorId: actor.userId,
      targetType: c.targetType,
      targetId: c.targetId,
      targetAuthorId: c.targetAuthorId,
      closedReportIds,
    });
    return this.caseDetail(id);
  }

  // ---- effects ---------------------------------------------------------------------------------------------

  private async applyEffect(
    tx: Prisma.TransactionClient,
    c: ModerationCase,
    action: ModerationAction,
    reason: string | null,
    actor: AdminActor,
    restrictDays?: number,
  ): Promise<void> {
    const status =
      action === 'HIDE_CONTENT'
        ? 'HIDDEN'
        : action === 'REMOVE_CONTENT'
          ? 'REMOVED'
          : action === 'RESTORE_CONTENT'
            ? 'VISIBLE'
            : null;
    if (status && c.targetType === 'POST') {
      const res = await tx.post.updateMany({ where: { id: c.targetId }, data: { status } });
      if (res.count === 0) throw ApiException.notFound('That post no longer exists.');
    } else if (status && c.targetType === 'COMMENT') {
      const comment = await tx.comment.findUnique({
        where: { id: c.targetId },
        select: { postId: true },
      });
      if (!comment) throw ApiException.notFound('That comment no longer exists.');
      await tx.comment.update({ where: { id: c.targetId }, data: { status } });
      await recountReplies(tx, comment.postId);
    } else if (status && c.targetType === 'GROUP') {
      await tx.group.update({
        where: { id: c.targetId },
        data: { archivedAt: status === 'VISIBLE' ? null : new Date() },
      });
    }

    if (action === 'RESTRICT_ACCOUNT') {
      if (!c.targetAuthorId)
        throw ApiException.validation('There is no account to restrict.', { field: 'action' });
      await tx.communityRestriction.create({
        data: {
          userId: c.targetAuthorId,
          reason,
          restrictedById: actor.userId,
          expiresAt: restrictDays ? new Date(Date.now() + restrictDays * 86_400_000) : null,
        },
      });
    }
    if (action === 'RESTORE_CONTENT' && c.targetType === 'USER' && c.targetAuthorId) {
      await tx.communityRestriction.updateMany({
        where: { userId: c.targetAuthorId, liftedAt: null },
        data: { liftedAt: new Date() },
      });
    }
  }

  /** Suspending an account needs `user.suspend` (a moderator does not hold it) and a fresh authenticator check. */
  private async assertMaySuspend(actor: ModerationActor): Promise<void> {
    if (!(await this.access.hasPermission(actor.userId, 'ACTIVE', 'user.suspend'))) {
      throw ApiException.forbidden('You do not have permission to suspend accounts.', {
        missing: ['user.suspend'],
      });
    }
    if (!actor.reauthAt || Date.now() - actor.reauthAt.getTime() > REAUTH_MINUTES * 60_000) {
      throw new ApiException(
        ErrorCode.AUTHENTICATION_REQUIRED,
        'Confirm your authenticator code to continue.',
        401,
        { reason: 'REAUTH_REQUIRED', withinMinutes: REAUTH_MINUTES },
      );
    }
  }

  // ---- helpers -----------------------------------------------------------------------------------------------

  private async load(id: string): Promise<ModerationCase> {
    const c = await this.prisma.moderationCase.findUnique({ where: { id } });
    if (!c) throw ApiException.notFound('We could not find that case.');
    return c;
  }

  private async people(ids: string[]): Promise<Map<string, AdminPersonRefDto>> {
    const unique = [...new Set(ids)];
    const users = unique.length
      ? await this.prisma.user.findMany({
          where: { id: { in: unique } },
          select: {
            id: true,
            fullName: true,
            creativeProfile: { select: { handle: true, displayName: true } },
          },
        })
      : [];
    return new Map(
      users.map((u) => [
        u.id,
        {
          id: u.id,
          displayName: u.creativeProfile?.displayName ?? u.fullName,
          handle: u.creativeProfile?.handle ?? null,
        },
      ]),
    );
  }

  private async caseViews(rows: ModerationCase[]): Promise<AdminCaseDto[]> {
    const people = await this.people(
      rows.flatMap((c) => [c.assigneeId, c.targetAuthorId].filter((x): x is string => !!x)),
    );
    const postIds = rows.filter((c) => c.targetType === 'POST').map((c) => c.targetId);
    const commentIds = rows.filter((c) => c.targetType === 'COMMENT').map((c) => c.targetId);
    const userIds = rows.filter((c) => c.targetType === 'USER').map((c) => c.targetId);
    const groupIds = rows.filter((c) => c.targetType === 'GROUP').map((c) => c.targetId);
    const [posts, comments, groups] = await Promise.all([
      postIds.length
        ? this.prisma.post.findMany({
            where: { id: { in: postIds } },
            select: { id: true, body: true },
          })
        : [],
      commentIds.length
        ? this.prisma.comment.findMany({
            where: { id: { in: commentIds } },
            select: { id: true, body: true },
          })
        : [],
      groupIds.length
        ? this.prisma.group.findMany({
            where: { id: { in: groupIds } },
            select: { id: true, name: true },
          })
        : [],
    ]);
    const text = new Map<string, string>([
      ...posts.map((p) => [p.id, p.body] as [string, string]),
      ...comments.map((p) => [p.id, p.body] as [string, string]),
      ...groups.map((g) => [g.id, g.name] as [string, string]),
    ]);
    const userNames = await this.people(userIds);
    const now = Date.now();
    return rows.map((c) => ({
      id: c.id,
      targetType: c.targetType,
      targetId: c.targetId,
      status: c.status,
      priority: c.priority,
      reportCount: c.reportCount,
      topReason: c.topReason,
      assignee: c.assigneeId ? (people.get(c.assigneeId) ?? null) : null,
      author: c.targetAuthorId ? (people.get(c.targetAuthorId) ?? null) : null,
      preview: excerpt(
        c.targetType === 'USER' ? userNames.get(c.targetId)?.displayName : text.get(c.targetId),
      ),
      ageHours: Math.floor((now - c.createdAt.getTime()) / 3_600_000),
      createdAt: c.createdAt,
      resolvedAt: c.resolvedAt,
    }));
  }

  private async content(type: ReportTargetType, id: string) {
    const none = { exists: false, status: null, text: null, postId: null, createdAt: null };
    if (type === 'POST') {
      const p = await this.prisma.post.findUnique({ where: { id } });
      return p
        ? {
            exists: !p.deletedAt,
            status: p.status,
            text: p.body,
            postId: p.id,
            createdAt: p.createdAt,
          }
        : none;
    }
    if (type === 'COMMENT') {
      const c = await this.prisma.comment.findUnique({ where: { id } });
      return c
        ? {
            exists: !c.deletedAt,
            status: c.status,
            text: c.body,
            postId: c.postId,
            createdAt: c.createdAt,
          }
        : none;
    }
    if (type === 'GROUP') {
      const g = await this.prisma.group.findUnique({ where: { id } });
      return g
        ? {
            exists: true,
            status: g.archivedAt ? 'REMOVED' : 'VISIBLE',
            text: g.name,
            postId: null,
            createdAt: g.createdAt,
          }
        : none;
    }
    const u = await this.prisma.user.findUnique({
      where: { id },
      select: {
        fullName: true,
        createdAt: true,
        creativeProfile: { select: { displayName: true } },
      },
    });
    return u
      ? {
          exists: true,
          status: null,
          text: u.creativeProfile?.displayName ?? u.fullName,
          postId: null,
          createdAt: u.createdAt,
        }
      : none;
  }
}
