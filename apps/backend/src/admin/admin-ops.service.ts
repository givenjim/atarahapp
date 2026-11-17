import { Injectable } from '@nestjs/common';
import { type AccountStatus, Prisma, type RoleKey } from '@prisma/client';
import { type AuthContext } from '../access/access.types';
import { AccessService } from '../access/access.service';
import { EVENT_NAMES, MAX_RANGE_DAYS } from '../analytics/analytics.events';
import { AnalyticsService, eatDate } from '../analytics/analytics.service';
import { AuditService } from '../audit/audit.service';
import { ApiException } from '../common/api.exception';
import { SessionService } from '../identity/session.service';
import { PrismaService } from '../prisma/prisma.service';
import { QueueAdminService } from '../queues/queue-admin.service';
import { QUEUE_NAMES } from '../queues/queues.constants';
import { AdminService } from './admin.service';
import {
  type AdminUserOverviewDto,
  type AnalyticsQueryDto,
  type AnalyticsSeriesDto,
  type AttentionQueueDto,
  type DashboardDto,
  type QueueCountsDto,
  type RoleDto,
} from './admin-ops.dto';

export interface OpsActor {
  userId: string;
  status: AccountStatus;
  ip?: string | undefined;
  requestId?: string | undefined;
}

const DAY_MS = 86_400_000;
const PRIORITY_ORDER = { URGENT: 0, HIGH: 1, NORMAL: 2, LOW: 3 } as const;
/** Roles an administrator with `role.assign` may hand out. Staff roles also need `admin.manage` (super admin). */
const PROTECTED_ROLES: RoleKey[] = ['SUPER_ADMIN', 'PLATFORM_ADMIN'];

const ago = (days: number, now = new Date()) => new Date(now.getTime() - days * DAY_MS);

/**
 * Operations for the admin console beyond user listing: the dashboard, analytics charts, the user overview, role
 * assignment and the queue (job) views. Every read is permission-filtered; every change is audited.
 */
@Injectable()
export class AdminOpsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
    private readonly access: AccessService,
    private readonly analytics: AnalyticsService,
    private readonly queues: QueueAdminService,
    private readonly sessions: SessionService,
    private readonly admin: AdminService,
  ) {}

  // ---- dashboard ------------------------------------------------------------------------------------------------

  async dashboard(
    auth: Pick<AuthContext, 'userId' | 'status'>,
    now = new Date(),
  ): Promise<DashboardDto> {
    const can = async (perm: string) => this.access.hasPermission(auth.userId, auth.status, perm);
    const [canReports, canOpps, canTaxonomy, canJobs] = await Promise.all([
      can('report.view'),
      can('opportunity.manage'),
      can('taxonomy.manage'),
      can('settings.manage'),
    ]);

    const queues: AttentionQueueDto[] = [];
    if (canReports) {
      const [open, urgent, oldest] = await Promise.all([
        this.prisma.moderationCase.count({
          where: { status: { in: ['SUBMITTED', 'IN_REVIEW', 'ESCALATED'] } },
        }),
        this.prisma.moderationCase.count({
          where: {
            status: { in: ['SUBMITTED', 'IN_REVIEW', 'ESCALATED'] },
            priority: { in: ['HIGH', 'URGENT'] },
          },
        }),
        this.prisma.moderationCase.findFirst({
          where: { status: { in: ['SUBMITTED', 'IN_REVIEW', 'ESCALATED'] } },
          orderBy: { createdAt: 'asc' },
          select: { createdAt: true },
        }),
      ]);
      const stale = oldest ? now.getTime() - oldest.createdAt.getTime() > 2 * DAY_MS : false;
      queues.push({
        key: 'reports',
        label: 'Reports waiting',
        count: open,
        priority: urgent > 0 ? 'URGENT' : stale ? 'HIGH' : 'NORMAL',
        oldestAt: oldest?.createdAt ?? null,
        path: '/community',
      });
    }
    if (canOpps) {
      const [review, review0, broken] = await Promise.all([
        this.prisma.opportunity.count({ where: { status: 'PENDING_REVIEW' } }),
        this.prisma.opportunity.findFirst({
          where: { status: 'PENDING_REVIEW' },
          orderBy: { updatedAt: 'asc' },
          select: { updatedAt: true },
        }),
        this.prisma.opportunity.count({ where: { status: 'PUBLISHED', linkStatus: 'BROKEN' } }),
      ]);
      queues.push({
        key: 'opportunity-review',
        label: 'Opportunities awaiting review',
        count: review,
        priority:
          review0 && now.getTime() - review0.updatedAt.getTime() > 2 * DAY_MS ? 'HIGH' : 'NORMAL',
        oldestAt: review0?.updatedAt ?? null,
        path: '/opportunities?status=PENDING_REVIEW',
      });
      queues.push({
        key: 'broken-links',
        label: 'Opportunity links that no longer work',
        count: broken,
        priority: broken > 0 ? 'NORMAL' : 'LOW',
        oldestAt: null,
        path: '/opportunities/link-health',
      });
    }
    if (canTaxonomy) {
      const [n, oldest] = await Promise.all([
        this.prisma.specialisationSuggestion.count({ where: { status: 'PENDING' } }),
        this.prisma.specialisationSuggestion.findFirst({
          where: { status: 'PENDING' },
          orderBy: { createdAt: 'asc' },
          select: { createdAt: true },
        }),
      ]);
      queues.push({
        key: 'specialisation-suggestions',
        label: 'Specialisation suggestions',
        count: n,
        priority: 'LOW',
        oldestAt: oldest?.createdAt ?? null,
        path: '/taxonomy',
      });
    }
    if (canJobs) {
      const failed = (await this.queueCounts()).reduce((n, q) => n + q.failed, 0);
      queues.push({
        key: 'failed-jobs',
        label: 'Failed background jobs',
        count: failed,
        priority: failed > 0 ? 'HIGH' : 'LOW',
        oldestAt: null,
        path: '/jobs',
      });
    }
    queues.sort(
      (a, b) => PRIORITY_ORDER[a.priority] - PRIORITY_ORDER[b.priority] || b.count - a.count,
    );

    return { generatedAt: now, queues, counts: await this.counts(now) };
  }

  private async counts(now: Date): Promise<DashboardDto['counts']> {
    const d7 = ago(7, now);
    const d30 = ago(30, now);
    const [new7, new30, completed30, active7, active30, posts7, saved7, applied7, courses] =
      await Promise.all([
        this.prisma.user.count({ where: { createdAt: { gte: d7 }, deletedAt: null } }),
        this.prisma.user.count({ where: { createdAt: { gte: d30 }, deletedAt: null } }),
        this.prisma.creativeProfile.count({
          where: {
            onboardingCompletedAt: { not: null },
            user: { createdAt: { gte: d30 }, deletedAt: null },
          },
        }),
        this.prisma.user.count({
          where: { lastLoginAt: { gte: d7 }, deletedAt: null, status: 'ACTIVE' },
        }),
        this.prisma.user.count({
          where: { lastLoginAt: { gte: d30 }, deletedAt: null, status: 'ACTIVE' },
        }),
        this.prisma.post.count({ where: { createdAt: { gte: d7 }, deletedAt: null } }),
        this.prisma.opportunityTracking.count({ where: { savedAt: { gte: d7 } } }),
        this.prisma.opportunityTracking.count({ where: { appliedAt: { gte: d7 } } }),
        this.courseCompletions(d30),
      ]);
    return {
      newMembers7d: new7,
      newMembers30d: new30,
      onboardingCompletionRate30d: new30 === 0 ? 0 : Math.round((completed30 / new30) * 100),
      activeMembers7d: active7,
      activeMembers30d: active30,
      posts7d: posts7,
      opportunitiesSaved7d: saved7,
      opportunitiesApplied7d: applied7,
      courseCompletions30d: courses,
    };
  }

  /** Course completions since a date; 0 while Skill Labs' tables are not installed. */
  private async courseCompletions(since: Date): Promise<number> {
    const [t] = await this.prisma.$queryRaw<Array<{ ok: boolean }>>(
      Prisma.sql`SELECT to_regclass('public.enrolments') IS NOT NULL AS ok`,
    );
    if (!t?.ok) return 0;
    const [r] = await this.prisma.$queryRaw<Array<{ n: number }>>(
      Prisma.sql`SELECT count(*)::int AS n FROM enrolments WHERE "completedAt" >= ${since}`,
    );
    return r?.n ?? 0;
  }

  // ---- analytics ------------------------------------------------------------------------------------------------

  async analyticsSeries(q: AnalyticsQueryDto, now = new Date()): Promise<AnalyticsSeriesDto> {
    const to = q.to ?? eatDate(now);
    const from = q.from ?? eatDate(new Date(new Date(`${to}T00:00:00Z`).getTime() - 29 * DAY_MS));
    const span =
      (new Date(`${to}T00:00:00Z`).getTime() - new Date(`${from}T00:00:00Z`).getTime()) / DAY_MS;
    if (Number.isNaN(span) || span < 0) {
      throw ApiException.validation('The end date is before the start date.', { field: 'to' });
    }
    if (span + 1 > MAX_RANGE_DAYS) {
      throw ApiException.validation(`Choose at most ${MAX_RANGE_DAYS} days.`, { field: 'from' });
    }
    const names = q.names?.length ? q.names : [...EVENT_NAMES];
    const unknown = names.filter((n) => !(EVENT_NAMES as string[]).includes(n));
    if (unknown.length > 0) {
      throw ApiException.validation(`Unknown event: ${unknown[0]}.`, { field: 'names' });
    }
    const [series, totals] = await Promise.all([
      this.analytics.series(from, to, names),
      this.analytics.totals(from, to),
    ]);
    return { from, to, series, totals: totals.filter((t) => names.includes(t.name)) };
  }

  // ---- jobs -----------------------------------------------------------------------------------------------------

  async queueCounts(): Promise<QueueCountsDto[]> {
    return Promise.all(
      QUEUE_NAMES.map(async (queue) => ({ queue, ...(await this.queues.counts(queue)) })),
    );
  }

  failedJobs(queue: string) {
    return this.queues.failed(queue, 0, 49);
  }

  async retryJob(actor: OpsActor, queue: string, jobId: string): Promise<void> {
    await this.queues.retry(queue, jobId);
    await this.audit.record({
      actorType: 'ADMIN',
      actorId: actor.userId,
      action: 'job.retry',
      entityType: 'job',
      entityId: `${queue}:${jobId}`,
      ip: actor.ip ?? null,
      requestId: actor.requestId ?? null,
    });
  }

  // ---- roles ----------------------------------------------------------------------------------------------------

  async listRoles(): Promise<RoleDto[]> {
    const roles = await this.prisma.role.findMany({
      orderBy: { key: 'asc' },
      include: { permissions: { include: { permission: { select: { key: true } } } } },
    });
    return roles.map((r) => ({
      key: r.key,
      name: r.name,
      description: r.description,
      isStaff: r.isStaff,
      permissions: r.permissions.map((p) => p.permission.key).sort(),
    }));
  }

  /**
   * Gives a member a role. Member-level roles need `role.assign`; staff roles need `admin.manage` as well, so in
   * practice only a super admin hands them out. Nobody changes their own roles, and only a super admin changes an
   * account that already holds an administrator role.
   */
  async assignRole(actor: OpsActor, targetId: string, role: RoleKey, reason?: string) {
    const { roleRow, targetRoles } = await this.guardRoleChange(actor, targetId, role);
    if (targetRoles.includes(role)) throw ApiException.conflict('They already have that role.');
    await this.prisma.$transaction(async (tx) => {
      await tx.userRole.create({
        data: { userId: targetId, roleId: roleRow.id, grantedById: actor.userId },
      });
      await this.audit.record(
        {
          actorType: 'ADMIN',
          actorId: actor.userId,
          action: 'user.role.assign',
          entityType: 'user',
          entityId: targetId,
          before: { roles: targetRoles },
          after: { roles: [...targetRoles, role], ...(reason ? { reason } : {}) },
          ip: actor.ip ?? null,
          requestId: actor.requestId ?? null,
        },
        tx,
      );
    });
    return this.admin.getUser(targetId);
  }

  async revokeRole(actor: OpsActor, targetId: string, role: RoleKey, reason?: string) {
    const { roleRow, targetRoles } = await this.guardRoleChange(actor, targetId, role);
    if (!targetRoles.includes(role)) throw ApiException.notFound('They do not have that role.');
    if (role === 'SUPER_ADMIN') {
      const supers = await this.prisma.userRole.count({
        where: {
          revokedAt: null,
          role: { key: 'SUPER_ADMIN' },
          user: { status: 'ACTIVE', deletedAt: null },
        },
      });
      if (supers <= 1) throw ApiException.invalidState('The last super admin cannot be removed.');
    }
    await this.prisma.$transaction(async (tx) => {
      await tx.userRole.updateMany({
        where: { userId: targetId, roleId: roleRow.id, revokedAt: null },
        data: { revokedAt: new Date() },
      });
      await this.audit.record(
        {
          actorType: 'ADMIN',
          actorId: actor.userId,
          action: 'user.role.revoke',
          entityType: 'user',
          entityId: targetId,
          before: { roles: targetRoles },
          after: { roles: targetRoles.filter((r) => r !== role), ...(reason ? { reason } : {}) },
          ip: actor.ip ?? null,
          requestId: actor.requestId ?? null,
        },
        tx,
      );
    });
    return this.admin.getUser(targetId);
  }

  private async guardRoleChange(actor: OpsActor, targetId: string, role: RoleKey) {
    if (targetId === actor.userId)
      throw ApiException.forbidden('You cannot change your own roles.');
    const [roleRow, target, actorRoles] = await Promise.all([
      this.prisma.role.findUnique({ where: { key: role } }),
      this.prisma.user.findFirst({
        where: { id: targetId, deletedAt: null },
        select: {
          id: true,
          roles: { where: { revokedAt: null }, select: { role: { select: { key: true } } } },
        },
      }),
      this.prisma.userRole.findMany({
        where: { userId: actor.userId, revokedAt: null },
        select: { role: { select: { key: true } } },
      }),
    ]);
    if (!roleRow) throw ApiException.notFound('That role does not exist.');
    if (!target) throw ApiException.notFound('That user does not exist.');
    const targetRoles = target.roles.map((r) => r.role.key);
    const actorIsSuper = actorRoles.some((r) => r.role.key === 'SUPER_ADMIN');
    if (
      roleRow.isStaff &&
      !(await this.access.hasPermission(actor.userId, actor.status, 'admin.manage'))
    ) {
      throw ApiException.forbidden('Only a super admin can assign administrator roles.');
    }
    if (
      !actorIsSuper &&
      (targetRoles.some((r) => PROTECTED_ROLES.includes(r)) || PROTECTED_ROLES.includes(role))
    ) {
      throw ApiException.forbidden('Only a super admin can change an administrator account.');
    }
    return { roleRow, targetRoles };
  }

  // ---- user overview --------------------------------------------------------------------------------------------

  async userOverview(targetId: string): Promise<AdminUserOverviewDto> {
    const user = await this.admin.getUser(targetId);
    const row = await this.prisma.user.findUniqueOrThrow({
      where: { id: targetId },
      select: {
        suspendedUntil: true,
        creativeProfile: {
          select: {
            handle: true,
            displayName: true,
            headline: true,
            completionPercent: true,
            onboardingCompletedAt: true,
            county: { select: { name: true } },
            primaryDiscipline: { select: { name: true } },
            _count: { select: { projects: { where: { status: 'PUBLISHED', deletedAt: null } } } },
          },
        },
        roles: {
          where: { revokedAt: null },
          orderBy: { grantedAt: 'desc' },
          select: {
            grantedAt: true,
            role: { select: { key: true, name: true, isStaff: true } },
            grantedBy: { select: { fullName: true } },
          },
        },
        memberships: {
          where: { status: { in: ['ACTIVE', 'PAST_DUE', 'CANCELLED'] } },
          orderBy: { startsAt: 'desc' },
          take: 1,
          select: {
            status: true,
            source: true,
            startsAt: true,
            currentPeriodEnd: true,
            plan: { select: { key: true } },
          },
        },
      },
    });

    const [history, reportsAbout, reportsMade, cases, sessions] = await Promise.all([
      this.prisma.auditLog.findMany({
        where: {
          entityType: 'user',
          entityId: targetId,
          action: {
            in: ['user.suspend', 'user.reactivate', 'user.role.assign', 'user.role.revoke'],
          },
        },
        orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
        take: 50,
      }),
      this.prisma.moderationCase.count({
        where: { OR: [{ targetAuthorId: targetId }, { targetType: 'USER', targetId }] },
      }),
      this.prisma.report.count({ where: { reporterId: targetId } }),
      this.prisma.moderationCase.findMany({
        where: { OR: [{ targetAuthorId: targetId }, { targetType: 'USER', targetId }] },
        orderBy: { createdAt: 'desc' },
        take: 10,
        select: {
          id: true,
          targetType: true,
          topReason: true,
          status: true,
          priority: true,
          reportCount: true,
          createdAt: true,
        },
      }),
      this.sessions.list(targetId, '').catch(() => []),
    ]);
    const actorIds = [...new Set(history.map((h) => h.actorId).filter((v): v is string => !!v))];
    const actors = actorIds.length
      ? await this.prisma.user.findMany({
          where: { id: { in: actorIds } },
          select: { id: true, fullName: true },
        })
      : [];
    const names = new Map(actors.map((a) => [a.id, a.fullName]));
    const pick = (v: unknown, key: string): string | null => {
      if (v && typeof v === 'object' && key in (v as Record<string, unknown>)) {
        const x = (v as Record<string, unknown>)[key];
        return typeof x === 'string' ? x : null;
      }
      return null;
    };

    const p = row.creativeProfile;
    const m = row.memberships[0];
    return {
      user,
      suspendedUntil: row.suspendedUntil,
      profile: p
        ? {
            handle: p.handle,
            displayName: p.displayName,
            headline: p.headline,
            completionPercent: p.completionPercent,
            onboardingCompleted: p.onboardingCompletedAt !== null,
            county: p.county?.name ?? null,
            discipline: p.primaryDiscipline?.name ?? null,
            publishedProjects: p._count.projects,
          }
        : null,
      roleGrants: row.roles.map((r) => ({
        key: r.role.key,
        name: r.role.name,
        isStaff: r.role.isStaff,
        grantedAt: r.grantedAt,
        grantedBy: r.grantedBy?.fullName ?? null,
      })),
      membership: m
        ? {
            plan: m.plan.key,
            status: m.status,
            source: m.source,
            startsAt: m.startsAt,
            currentPeriodEnd: m.currentPeriodEnd,
          }
        : null,
      statusHistory: history.map((h) => ({
        action: h.action,
        at: h.createdAt,
        actorName: h.actorId ? (names.get(h.actorId) ?? null) : 'System',
        reason: pick(h.after, 'reason'),
        from: pick(h.before, 'status'),
        to: pick(h.after, 'status'),
      })),
      sessions: sessions.map((s) => ({
        id: s.id,
        client: s.client,
        deviceName: s.deviceName,
        lastActiveAt: s.lastActiveAt,
      })),
      reports: {
        about: reportsAbout,
        made: reportsMade,
        recent: cases.map(({ id, ...c }) => ({ caseId: id, ...c })),
      },
    };
  }
}
