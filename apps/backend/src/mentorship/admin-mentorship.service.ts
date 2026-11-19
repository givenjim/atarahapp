import { Injectable, Logger } from '@nestjs/common';
import { Prisma, type MentorApplication } from '@prisma/client';
import { AuditService } from '../audit/audit.service';
import { ApiException } from '../common/api.exception';
import { pageMeta, toSkipTake } from '../common/pagination';
import { NotificationsService } from '../notifications/notifications.service';
import { PrismaService } from '../prisma/prisma.service';
import {
  type AdminApplicationDto,
  type AdminApplicationsQueryDto,
  type AdminMentorDto,
  type AdminMentorsQueryDto,
  type AdminSessionTypeDto,
  type AdminSessionTypesQueryDto,
} from './mentorship.dto';
import { applicationDto, proposedTypesOf } from './mentor-application.service';
import { MentorViewsService, sessionTypeDto } from './mentor-views.service';

export interface MentorshipActor {
  userId: string;
  ip?: string | undefined;
  requestId?: string | undefined;
}

/** Staff operations (permission `mentor.manage`): applications queue, mentors, session type oversight, featuring. */
@Injectable()
export class AdminMentorshipService {
  private readonly log = new Logger(AdminMentorshipService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
    private readonly views: MentorViewsService,
    private readonly notifications: NotificationsService,
  ) {}

  private audited(
    actor: MentorshipActor,
    action: string,
    entityType: string,
    entityId: string,
    before: unknown,
    after: unknown,
  ) {
    return {
      actorType: 'ADMIN' as const,
      actorId: actor.userId,
      action,
      entityType,
      entityId,
      before,
      after,
      ip: actor.ip ?? null,
      requestId: actor.requestId ?? null,
    };
  }

  private async tell(
    userId: string,
    title: string,
    body: string,
    deepLink?: string,
  ): Promise<void> {
    try {
      await this.notifications.notify({
        userId,
        category: 'MENTORSHIP',
        type: 'mentorship.status',
        title,
        body,
        ...(deepLink ? { deepLink } : {}),
      });
    } catch (e) {
      this.log.warn(
        `Notification to ${userId} failed: ${e instanceof Error ? e.message : String(e)}`,
      );
    }
  }

  // ---- applications --------------------------------------------------------------------------------------------

  private async applicationDtos(rows: MentorApplication[]): Promise<AdminApplicationDto[]> {
    const people = await this.views.people([...new Set(rows.map((r) => r.userId))]);
    return rows.map((a) => {
      const p = people.get(a.userId);
      return {
        ...applicationDto(a),
        applicant: {
          userId: a.userId,
          displayName: p?.displayName ?? 'Unknown member',
          handle: p?.handle ?? null,
          email: p?.email ?? null,
        },
        passportSnapshot: (a.passportSnapshot ?? {}) as Record<string, unknown>,
        reviewedById: a.reviewedById,
      };
    });
  }

  async listApplications(q: AdminApplicationsQueryDto) {
    const where: Prisma.MentorApplicationWhereInput = { status: q.status ?? 'PENDING' };
    const [rows, total] = await Promise.all([
      this.prisma.mentorApplication.findMany({
        where,
        orderBy: { createdAt: 'asc' },
        ...toSkipTake(q),
      }),
      this.prisma.mentorApplication.count({ where }),
    ]);
    return { items: await this.applicationDtos(rows), meta: pageMeta(q, total) };
  }

  async getApplication(id: string): Promise<AdminApplicationDto> {
    const row = await this.prisma.mentorApplication.findUnique({ where: { id } });
    if (!row) throw ApiException.notFound('We could not find that application.');
    return (await this.applicationDtos([row]))[0]!;
  }

  /**
   * Approves an application. The PENDING to APPROVED transition is claimed with a conditional update, so two
   * reviewers (or a double click) cannot both approve; the MENTOR role is granted only when the member has no live
   * grant, so the role is granted exactly once. Profile, session types, role and audit commit together.
   */
  async approve(actor: MentorshipActor, id: string, reason?: string): Promise<AdminApplicationDto> {
    const app = await this.prisma.mentorApplication.findUnique({ where: { id } });
    if (!app) throw ApiException.notFound('We could not find that application.');
    if (app.userId === actor.userId)
      throw ApiException.forbidden('You cannot review your own application.');
    await this.prisma.$transaction(async (tx) => {
      const claimed = await tx.mentorApplication.updateMany({
        where: { id, status: 'PENDING' },
        data: {
          status: 'APPROVED',
          reviewedById: actor.userId,
          reviewedAt: new Date(),
          reviewerNotes: reason?.trim() || null,
        },
      });
      if (claimed.count !== 1)
        throw ApiException.invalidState('That application was already decided.');

      const existing = await tx.mentorProfile.findUnique({ where: { userId: app.userId } });
      const fields = {
        headline: app.headline,
        yearsExperience: app.yearsExperience,
        bio: app.statement,
        expertiseTags: app.expertiseTags,
        disciplineIds: app.disciplineIds,
        credentials: app.credentials as Prisma.InputJsonValue,
        timeZone: app.timeZone,
        status: 'APPROVED' as const,
        statusReason: null,
        approvedAt: new Date(),
      };
      const profile = existing
        ? await tx.mentorProfile.update({ where: { id: existing.id }, data: fields })
        : await tx.mentorProfile.create({ data: { userId: app.userId, ...fields } });

      // Proposed session types become real ones the first time; a returning mentor keeps their own.
      const haveTypes = await tx.mentorSessionType.count({ where: { mentorId: profile.id } });
      if (haveTypes === 0) {
        const proposed = proposedTypesOf(app.proposedSessionTypes);
        if (proposed.length)
          await tx.mentorSessionType.createMany({
            data: proposed.map((t) => ({
              mentorId: profile.id,
              name: t.name,
              description: t.description ?? null,
              durationMinutes: t.durationMinutes,
              priceMinor: t.priceMinor,
              sessionCount: t.sessionCount ?? 1,
            })),
          });
      }

      const role = await tx.role.findUnique({ where: { key: 'MENTOR' } });
      if (!role) throw ApiException.invalidState('The Mentor role is not set up.');
      const live = await tx.userRole.count({
        where: { userId: app.userId, roleId: role.id, revokedAt: null },
      });
      if (live === 0)
        await tx.userRole.create({
          data: { userId: app.userId, roleId: role.id, grantedById: actor.userId },
        });

      await this.audit.record(
        this.audited(
          actor,
          'mentor.application.approve',
          'mentor_application',
          id,
          { status: 'PENDING' },
          {
            status: 'APPROVED',
            mentorId: profile.id,
            roleGranted: live === 0,
            ...(reason ? { reason } : {}),
          },
        ),
        tx,
      );
    });
    await this.tell(
      app.userId,
      'You are now an Atarah mentor',
      'Your application was approved. Set your availability to start appearing in the mentor directory.',
      '/mentorship/tools',
    );
    return this.getApplication(id);
  }

  async reject(actor: MentorshipActor, id: string, reason?: string): Promise<AdminApplicationDto> {
    const why = reason?.trim();
    if (!why)
      throw ApiException.validation('Say why, so the applicant knows what to change.', {
        field: 'reason',
      });
    const app = await this.prisma.mentorApplication.findUnique({ where: { id } });
    if (!app) throw ApiException.notFound('We could not find that application.');
    if (app.userId === actor.userId)
      throw ApiException.forbidden('You cannot review your own application.');
    await this.prisma.$transaction(async (tx) => {
      const claimed = await tx.mentorApplication.updateMany({
        where: { id, status: 'PENDING' },
        data: {
          status: 'REJECTED',
          reviewedById: actor.userId,
          reviewedAt: new Date(),
          reviewerNotes: why,
        },
      });
      if (claimed.count !== 1)
        throw ApiException.invalidState('That application was already decided.');
      await this.audit.record(
        this.audited(
          actor,
          'mentor.application.reject',
          'mentor_application',
          id,
          { status: 'PENDING' },
          { status: 'REJECTED', reason: why },
        ),
        tx,
      );
    });
    await this.tell(
      app.userId,
      'Your mentor application',
      `We could not approve it yet: ${why}`,
      '/mentorship/apply',
    );
    return this.getApplication(id);
  }

  // ---- mentors -------------------------------------------------------------------------------------------------

  async listMentors(q: AdminMentorsQueryDto) {
    const where: Prisma.MentorProfileWhereInput = {
      ...(q.status ? { status: q.status } : {}),
      ...(q.featured !== undefined ? { featured: q.featured } : {}),
    };
    let rows = await this.prisma.mentorProfile.findMany({
      where,
      include: { _count: { select: { sessionTypes: true } } },
      orderBy: [{ featured: 'desc' }, { createdAt: 'desc' }],
      take: 500,
    });
    const people = await this.views.people(rows.map((r) => r.userId));
    const needle = q.q?.trim().toLowerCase();
    if (needle)
      rows = rows.filter((r) => {
        const p = people.get(r.userId);
        return (
          p?.displayName.toLowerCase().includes(needle) ||
          p?.email?.toLowerCase().includes(needle) ||
          r.headline.toLowerCase().includes(needle)
        );
      });
    const start = (q.page - 1) * q.limit;
    const items: AdminMentorDto[] = rows.slice(start, start + q.limit).map((r) => {
      const p = people.get(r.userId);
      return {
        id: r.id,
        mentor: {
          userId: r.userId,
          displayName: p?.displayName ?? 'Unknown member',
          handle: p?.handle ?? null,
          email: p?.email ?? null,
        },
        status: r.status,
        statusReason: r.statusReason,
        headline: r.headline,
        featured: r.featured,
        sessionTypeCount: r._count.sessionTypes,
        ratingAverage: r.ratingAverage,
        ratingCount: r.ratingCount,
        sessionsCount: r.sessionsCount,
        approvedAt: r.approvedAt ? r.approvedAt.toISOString() : null,
      };
    });
    return { items, meta: pageMeta(q, rows.length) };
  }

  private async mentor(id: string) {
    const m = await this.prisma.mentorProfile.findUnique({ where: { id } });
    if (!m) throw ApiException.notFound('We could not find that mentor.');
    return m;
  }

  private async mentorDto(id: string): Promise<AdminMentorDto> {
    const q = { page: 1, limit: 500 } as AdminMentorsQueryDto;
    const all = await this.listMentors(q);
    const hit = all.items.find((i) => i.id === id);
    if (!hit) throw ApiException.notFound('We could not find that mentor.');
    return hit;
  }

  /** Pause hides the mentor from the directory; only staff can lift a staff pause. */
  async pause(actor: MentorshipActor, id: string, reason: string): Promise<AdminMentorDto> {
    const m = await this.mentor(id);
    if (m.status !== 'APPROVED')
      throw ApiException.invalidState('Only an active mentor can be paused.');
    await this.prisma.$transaction(async (tx) => {
      const res = await tx.mentorProfile.updateMany({
        where: { id, status: 'APPROVED' },
        data: { status: 'PAUSED', statusReason: reason.trim() },
      });
      if (res.count !== 1) throw ApiException.invalidState('That mentor changed. Try again.');
      await this.audit.record(
        this.audited(
          actor,
          'mentor.pause',
          'mentor_profile',
          id,
          { status: m.status },
          { status: 'PAUSED', reason },
        ),
        tx,
      );
    });
    await this.tell(m.userId, 'Your mentor profile is paused', reason.trim());
    return this.mentorDto(id);
  }

  async resume(actor: MentorshipActor, id: string, reason: string): Promise<AdminMentorDto> {
    const m = await this.mentor(id);
    if (m.status !== 'PAUSED') throw ApiException.invalidState('That mentor is not paused.');
    await this.prisma.$transaction(async (tx) => {
      await tx.mentorProfile.update({
        where: { id },
        data: { status: 'APPROVED', statusReason: null },
      });
      await this.audit.record(
        this.audited(
          actor,
          'mentor.resume',
          'mentor_profile',
          id,
          { status: 'PAUSED' },
          { status: 'APPROVED', reason },
        ),
        tx,
      );
    });
    await this.tell(
      m.userId,
      'Your mentor profile is live again',
      'You are visible in the directory.',
      '/mentorship/tools',
    );
    return this.mentorDto(id);
  }

  /** Removes the mentor: hidden everywhere, MENTOR role revoked. They may apply again. */
  async remove(actor: MentorshipActor, id: string, reason: string): Promise<AdminMentorDto> {
    const m = await this.mentor(id);
    if (m.status === 'REMOVED') throw ApiException.invalidState('That mentor was already removed.');
    await this.prisma.$transaction(async (tx) => {
      await tx.mentorProfile.update({
        where: { id },
        data: { status: 'REMOVED', statusReason: reason.trim(), featured: false },
      });
      const role = await tx.role.findUnique({ where: { key: 'MENTOR' } });
      if (role)
        await tx.userRole.updateMany({
          where: { userId: m.userId, roleId: role.id, revokedAt: null },
          data: { revokedAt: new Date() },
        });
      await this.audit.record(
        this.audited(
          actor,
          'mentor.remove',
          'mentor_profile',
          id,
          { status: m.status },
          { status: 'REMOVED', reason },
        ),
        tx,
      );
    });
    await this.tell(m.userId, 'Your mentor profile was removed', reason.trim());
    return this.mentorDto(id);
  }

  async feature(actor: MentorshipActor, id: string, featured: boolean): Promise<AdminMentorDto> {
    const m = await this.mentor(id);
    if (featured && m.status !== 'APPROVED')
      throw ApiException.invalidState('Only an active mentor can be featured.');
    await this.prisma.$transaction(async (tx) => {
      await tx.mentorProfile.update({ where: { id }, data: { featured } });
      await this.audit.record(
        this.audited(
          actor,
          featured ? 'mentor.feature' : 'mentor.unfeature',
          'mentor_profile',
          id,
          { featured: m.featured },
          { featured },
        ),
        tx,
      );
    });
    return this.mentorDto(id);
  }

  // ---- session type oversight ----------------------------------------------------------------------------------

  async listSessionTypes(q: AdminSessionTypesQueryDto) {
    const where: Prisma.MentorSessionTypeWhereInput = {
      ...(q.mentorId ? { mentorId: q.mentorId } : {}),
      ...(q.disabledByStaff !== undefined ? { disabledByStaff: q.disabledByStaff } : {}),
    };
    const [rows, total] = await Promise.all([
      this.prisma.mentorSessionType.findMany({
        where,
        include: { mentor: { select: { userId: true } } },
        orderBy: [{ createdAt: 'desc' }],
        ...toSkipTake(q),
      }),
      this.prisma.mentorSessionType.count({ where }),
    ]);
    const people = await this.views.people([...new Set(rows.map((r) => r.mentor.userId))]);
    const items: AdminSessionTypeDto[] = rows.map((r) => ({
      ...sessionTypeDto(r),
      mentorId: r.mentorId,
      mentorName: people.get(r.mentor.userId)?.displayName ?? 'Unknown member',
      staffNote: r.staffNote,
    }));
    return { items, meta: pageMeta(q, total) };
  }

  async setSessionTypeDisabled(
    actor: MentorshipActor,
    id: string,
    disabled: boolean,
    note?: string,
  ): Promise<AdminSessionTypeDto> {
    const t = await this.prisma.mentorSessionType.findUnique({
      where: { id },
      include: { mentor: { select: { userId: true } } },
    });
    if (!t) throw ApiException.notFound('We could not find that session type.');
    const updated = await this.prisma.$transaction(async (tx) => {
      const row = await tx.mentorSessionType.update({
        where: { id },
        data: disabled
          ? { disabledByStaff: true, active: false, staffNote: note?.trim() || null }
          : { disabledByStaff: false, staffNote: note?.trim() || null },
      });
      await this.audit.record(
        this.audited(
          actor,
          disabled ? 'mentor.session_type.disable' : 'mentor.session_type.enable',
          'mentor_session_type',
          id,
          { active: t.active, disabledByStaff: t.disabledByStaff },
          { active: row.active, disabledByStaff: row.disabledByStaff, ...(note ? { note } : {}) },
        ),
        tx,
      );
      return row;
    });
    if (disabled)
      await this.tell(
        t.mentor.userId,
        'A session type was switched off',
        `${t.name}${note ? `: ${note}` : ''}`,
        '/mentorship/tools',
      );
    const people = await this.views.people([t.mentor.userId]);
    return {
      ...sessionTypeDto(updated),
      mentorId: updated.mentorId,
      mentorName: people.get(t.mentor.userId)?.displayName ?? 'Unknown member',
      staffNote: updated.staffNote,
    };
  }
}
