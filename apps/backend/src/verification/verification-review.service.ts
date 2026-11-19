import { Injectable, Logger } from '@nestjs/common';
import { Prisma, type VerificationStatus, type VerificationSubjectType } from '@prisma/client';
import sharp from 'sharp';
import { AuditService } from '../audit/audit.service';
import { ApiException } from '../common/api.exception';
import { pageMeta, toSkipTake } from '../common/pagination';
import { PlatformSettingsService } from '../feature-flags/platform-settings.service';
import { NotificationsService } from '../notifications/notifications.service';
import { PrismaService } from '../prisma/prisma.service';
import { StorageService } from '../storage/storage.service';
import { VerificationBadgeService } from './verification-badge.service';
import {
  type AdminCaseDetailDto,
  type AdminCaseQueryDto,
  type AdminCaseRowDto,
  type AdminSummaryDto,
  type EvidenceAccessDto,
} from './verification.dto';
import {
  addMonths,
  canDo,
  type CaseAction,
  evaluateRequirements,
  maskEmail,
  nextStatus,
  REVIEW_STATUSES,
  watermarkText,
} from './verification.rules';

const HOUR_MS = 3_600_000;
const EVIDENCE_URL_TTL_SECONDS = 120;
const MAX_BADGE_MONTHS = 24;
const REMINDER_DAYS = 30;
const SUBJECT_ORDER: VerificationSubjectType[] = [
  'CREATIVE_IDENTITY',
  'SKILL',
  'SELLER',
  'OPPORTUNITY_PROVIDER',
  'MENTOR',
];

export interface Actor {
  userId: string;
  ip?: string;
  requestId?: string;
}

const CASE_INCLUDE = {
  applicant: {
    select: {
      id: true,
      fullName: true,
      createdAt: true,
      creativeProfile: { select: { id: true, displayName: true, handle: true, headline: true } },
    },
  },
  reviewer: { select: { id: true, fullName: true } },
  evidence: { orderBy: { createdAt: 'asc' } },
  references: { orderBy: { createdAt: 'asc' } },
} satisfies Prisma.VerificationCaseInclude;
type CaseRow = Prisma.VerificationCaseGetPayload<{ include: typeof CASE_INCLUDE }>;

/**
 * The reviewer workspace (P2-M6, DEC-153). The rules that matter, all enforced here and not in the app:
 *  - nobody reviews their own case (claim, evidence and decisions all refuse the applicant);
 *  - evidence is opened only by the reviewer the case is assigned to, while it is under review, through a signed address
 *    that lives two minutes, stamped with the reviewer's id (burned into images, returned as text for PDFs);
 *  - a decision needs the assigned reviewer; revoking needs only the decide permission;
 *  - every action is written to the audit log and the case timeline.
 */
@Injectable()
export class VerificationReviewService {
  private readonly log = new Logger(VerificationReviewService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
    private readonly badges: VerificationBadgeService,
    private readonly storage: StorageService,
    private readonly settings: PlatformSettingsService,
    private readonly notifications: NotificationsService,
  ) {}

  // ---- queue ------------------------------------------------------------------------------------------------------

  async list(actor: Actor, q: AdminCaseQueryDto) {
    const now = new Date();
    const where: Prisma.VerificationCaseWhereInput = {
      status: q.status ?? { in: [...REVIEW_STATUSES] },
      ...(q.type ? { subjectType: q.type } : {}),
      ...(q.assigned === 'mine' ? { reviewerId: actor.userId } : {}),
      ...(q.assigned === 'unassigned' ? { reviewerId: null } : {}),
      ...(q.overdue ? { slaDueAt: { lt: now }, status: { in: [...REVIEW_STATUSES] } } : {}),
    };
    const [rows, total] = await Promise.all([
      this.prisma.verificationCase.findMany({
        where,
        include: CASE_INCLUDE,
        // The oldest waiting case first; undecided drafts (no submit date) last.
        orderBy: [{ submittedAt: { sort: 'asc', nulls: 'last' } }, { id: 'asc' }],
        ...toSkipTake(q),
      }),
      this.prisma.verificationCase.count({ where }),
    ]);
    const labels = await this.subjectLabels(rows);
    return { items: rows.map((r) => this.row(r, actor, labels, now)), meta: pageMeta(q, total) };
  }

  async summary(): Promise<AdminSummaryDto> {
    const now = new Date();
    const open = await this.prisma.verificationCase.findMany({
      where: { status: { in: [...REVIEW_STATUSES] } },
      select: { subjectType: true, status: true, submittedAt: true, slaDueAt: true },
    });
    const byType = SUBJECT_ORDER.map((subjectType) => {
      const mine = open.filter((c) => c.subjectType === subjectType);
      const waiting = mine.filter((c) => c.status === 'SUBMITTED');
      const oldest = waiting.reduce<Date | null>(
        (m, c) => (c.submittedAt && (!m || c.submittedAt < m) ? c.submittedAt : m),
        null,
      );
      return {
        subjectType,
        waiting: waiting.length,
        underReview: mine.length - waiting.length,
        overdue: mine.filter((c) => c.slaDueAt && c.slaDueAt < now).length,
        oldestHours: oldest ? Math.floor((now.getTime() - oldest.getTime()) / HOUR_MS) : null,
      };
    });
    const expiringSoon = await this.prisma.verificationBadge.count({
      where: {
        endedAt: null,
        expiresAt: { gt: now, lt: new Date(now.getTime() + REMINDER_DAYS * 86_400_000) },
      },
    });
    return { slaWorkingDays: await this.sla(), byType, expiringSoon };
  }

  async detail(actor: Actor, caseId: string): Promise<AdminCaseDetailDto> {
    const c = await this.load(caseId);
    const now = new Date();
    const [labels, requirements, events, prior, projects, assets] = await Promise.all([
      this.subjectLabels([c]),
      this.prisma.verificationRequirement.findMany({
        where: { subjectType: c.subjectType, isActive: true },
        orderBy: { sortOrder: 'asc' },
      }),
      this.prisma.verificationCaseEvent.findMany({ where: { caseId }, orderBy: { createdAt: 'asc' } }),
      this.prisma.verificationCase.findMany({
        where: {
          applicantId: c.applicantId,
          id: { not: c.id },
          decidedAt: { not: null },
        },
        orderBy: { decidedAt: 'desc' },
        take: 10,
        select: { id: true, subjectType: true, status: true, decidedAt: true, feedback: true },
      }),
      this.prisma.project.findMany({
        where: { id: { in: c.evidence.flatMap((e) => (e.projectId ? [e.projectId] : [])) } },
        select: { id: true, title: true, role: true },
      }),
      this.prisma.mediaAsset.findMany({
        where: { id: { in: c.evidence.flatMap((e) => (e.mediaAssetId ? [e.mediaAssetId] : [])) } },
        select: { id: true, mimeType: true },
      }),
    ]);
    const actorIds = [...new Set(events.flatMap((e) => (e.actorId ? [e.actorId] : [])))];
    const actors = actorIds.length
      ? await this.prisma.user.findMany({ where: { id: { in: actorIds } }, select: { id: true, fullName: true } })
      : [];
    const name = new Map(actors.map((a) => [a.id, a.fullName]));
    const project = new Map(projects.map((p) => [p.id, p]));
    const mime = new Map(assets.map((a) => [a.id, a.mimeType]));
    const states = evaluateRequirements(requirements, c.evidence.map((e) => e.type));
    const own = c.applicantId === actor.userId;
    const assigned = c.reviewerId === actor.userId;
    const hasConfirmed = c.references.some((r) => r.status === 'CONFIRMED');
    const needsInfo = c.moreInfoRequestedAt !== null;
    return {
      ...this.row(c, actor, labels, now),
      requirements: states,
      evidence: c.evidence.map((e) => ({
        id: e.id,
        type: e.type,
        label: e.label,
        url: e.url,
        projectId: e.projectId,
        projectTitle: e.projectId ? (project.get(e.projectId)?.title ?? null) : null,
        projectRole: e.projectId ? (project.get(e.projectId)?.role ?? null) : null,
        isFile: e.mediaAssetId !== null,
        mimeType: e.mediaAssetId ? (mime.get(e.mediaAssetId) ?? null) : null,
        purged: e.purgedAt !== null,
        purgeAfter: e.purgeAfter,
      })),
      references: c.references.map((r) => ({
        id: r.id,
        name: r.name,
        emailMasked: maskEmail(r.email),
        relationship: r.relationship,
        status: r.status,
        comment: r.comment,
        respondedAt: r.respondedAt,
      })),
      events: events.map((e) => ({
        action: e.action,
        actorName: e.actorId ? (name.get(e.actorId) ?? null) : null,
        note: e.note,
        createdAt: e.createdAt,
      })),
      previousDecisions: prior,
      decisionNotes: c.decisionNotes,
      feedback: c.feedback,
      moreInfoNote: c.moreInfoNote,
      canViewEvidence: !own && assigned && c.status === 'UNDER_REVIEW',
      canDecide: !own && assigned && c.status === 'UNDER_REVIEW' && !needsInfo,
      applicantMemberSince: c.applicant.createdAt.toISOString().slice(0, 10),
      applicantHeadline: c.applicant.creativeProfile?.headline ?? null,
      hasConfirmedReference: hasConfirmed,
    };
  }

  // ---- assignment -------------------------------------------------------------------------------------------------

  async claim(actor: Actor, caseId: string): Promise<AdminCaseDetailDto> {
    const c = await this.load(caseId);
    this.refuseOwn(actor, c);
    if (!canDo('CLAIM', c.status)) {
      throw ApiException.invalidState('This case is not waiting for a reviewer.');
    }
    const now = new Date();
    await this.prisma.transaction(async (tx) => {
      const won = await tx.verificationCase.updateMany({
        where: { id: caseId, status: 'SUBMITTED', reviewerId: null },
        data: {
          status: nextStatus('CLAIM'),
          reviewerId: actor.userId,
          assignedAt: now,
          version: { increment: 1 },
        },
      });
      // Two reviewers pressing Claim at once: only one wins.
      if (won.count !== 1) throw ApiException.conflict('Another reviewer just took this case.');
      await tx.verificationCaseEvent.create({ data: { caseId, action: 'CLAIMED', actorId: actor.userId } });
      await this.badges.mirrorStatus(tx, c, 'UNDER_REVIEW');
      await this.auditAction(actor, 'verification.claim', c, { status: 'UNDER_REVIEW' }, tx);
    });
    return this.detail(actor, caseId);
  }

  async release(actor: Actor, caseId: string): Promise<AdminCaseDetailDto> {
    const c = await this.load(caseId);
    if (c.reviewerId !== actor.userId) {
      throw ApiException.forbidden('This case is assigned to someone else.');
    }
    if (!canDo('RELEASE', c.status)) throw ApiException.invalidState('This case cannot be released now.');
    await this.prisma.transaction(async (tx) => {
      await tx.verificationCase.update({
        where: { id: caseId },
        data: {
          status: nextStatus('RELEASE'),
          reviewerId: null,
          assignedAt: null,
          moreInfoNote: null,
          moreInfoRequestedAt: null,
          version: { increment: 1 },
        },
      });
      await tx.verificationCaseEvent.create({ data: { caseId, action: 'RELEASED', actorId: actor.userId } });
      await this.badges.mirrorStatus(tx, c, 'SUBMITTED');
      await this.auditAction(actor, 'verification.release', c, { status: 'SUBMITTED' }, tx);
    });
    await this.removeViewCopies(c, actor.userId);
    return this.detail(actor, caseId);
  }

  // ---- evidence ---------------------------------------------------------------------------------------------------

  /**
   * A short-lived address for one stored file. Refused unless the caller is the assigned reviewer and not the applicant,
   * and the case is still under review. Images are re-encoded with the reviewer's watermark burned in.
   */
  async evidenceAccess(actor: Actor, caseId: string, evidenceId: string): Promise<EvidenceAccessDto> {
    const c = await this.load(caseId);
    this.refuseOwn(actor, c);
    if (c.reviewerId !== actor.userId || c.status !== 'UNDER_REVIEW') {
      throw ApiException.forbidden('Claim this case to open its evidence.');
    }
    const e = c.evidence.find((x) => x.id === evidenceId);
    if (!e || !e.mediaAssetId) throw ApiException.notFound('We could not find that file.');
    if (e.purgedAt) throw ApiException.invalidState('This file was deleted under the retention rule.');
    const asset = await this.prisma.mediaAsset.findFirst({
      where: { id: e.mediaAssetId, bucket: 'EVIDENCE', deletedAt: null, status: 'READY' },
    });
    if (!asset) throw ApiException.notFound('We could not find that file.');

    const now = new Date();
    const watermark = watermarkText(actor.userId, c.id, now);
    let key = asset.objectKey;
    let mimeType = asset.mimeType;
    if (asset.kind === 'IMAGE') {
      key = this.viewKey(c.id, actor.userId, e.id);
      await this.storage.write('evidence', key, await this.stamp(await this.storage.read('evidence', asset.objectKey), watermark), 'image/jpeg');
      mimeType = 'image/jpeg';
    }
    const url = await this.storage.signedDownloadUrl('evidence', key, EVIDENCE_URL_TTL_SECONDS);
    await this.auditAction(actor, 'verification.evidence.view', c, { evidenceId, type: e.type });
    return {
      url,
      expiresAt: new Date(now.getTime() + EVIDENCE_URL_TTL_SECONDS * 1000),
      watermark,
      mimeType,
    };
  }

  private viewKey(caseId: string, reviewerId: string, evidenceId: string): string {
    return `verification/${caseId}/view/${reviewerId.slice(0, 8)}-${evidenceId}.jpg`;
  }

  /** Burn the text diagonally across the picture so a screenshot still carries the reviewer's id. */
  private async stamp(original: Buffer, text: string): Promise<Buffer> {
    const base = sharp(original).rotate().resize({ width: 1600, withoutEnlargement: true });
    const { data, info } = await base.jpeg({ quality: 82 }).toBuffer({ resolveWithObject: true });
    const esc = text.replace(/&/g, '&amp;').replace(/</g, '&lt;');
    const step = 220;
    const lines: string[] = [];
    for (let y = 0; y < info.height + info.width; y += step) {
      lines.push(`<text x="0" y="${y}" transform="rotate(-30 0 ${y})">${esc}</text>`);
    }
    const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${info.width}" height="${info.height}">
      <g font-family="Arial, sans-serif" font-size="${Math.max(16, Math.round(info.width / 40))}" font-weight="700"
         fill="rgba(255,255,255,0.55)" stroke="rgba(0,0,0,0.45)" stroke-width="0.8">${lines.join('')}</g></svg>`;
    return sharp(data)
      .composite([{ input: Buffer.from(svg), top: 0, left: 0 }])
      .jpeg({ quality: 82 })
      .toBuffer();
  }

  private async removeViewCopies(c: CaseRow, reviewerId: string | null): Promise<void> {
    if (!reviewerId) return;
    for (const e of c.evidence) {
      if (!e.mediaAssetId) continue;
      await this.storage.remove('evidence', this.viewKey(c.id, reviewerId, e.id)).catch(() => undefined);
    }
  }

  // ---- decisions --------------------------------------------------------------------------------------------------

  async approve(actor: Actor, caseId: string, notes?: string, expiresAt?: string): Promise<AdminCaseDetailDto> {
    const c = await this.decidable(actor, caseId, 'APPROVE');
    const requirements = await this.prisma.verificationRequirement.findMany({
      where: { subjectType: c.subjectType, isActive: true },
    });
    const states = evaluateRequirements(requirements, c.evidence.map((e) => e.type));
    if (states.some((s) => !s.met)) {
      throw ApiException.invalidState('Not everything required is attached yet.');
    }
    if (c.subjectType === 'CREATIVE_IDENTITY' && !c.references.some((r) => r.status === 'CONFIRMED')) {
      throw ApiException.invalidState('No reference has confirmed yet. Approve once a referee has responded.');
    }
    const now = new Date();
    const months = await this.settings.get<number>('verification.badge_valid_months', 12);
    let expiry = addMonths(now, months);
    if (expiresAt) {
      const asked = new Date(expiresAt);
      if (Number.isNaN(asked.getTime()) || asked <= now || asked > addMonths(now, MAX_BADGE_MONTHS)) {
        throw ApiException.validation(`Choose an expiry date within the next ${MAX_BADGE_MONTHS} months.`, {
          field: 'expiresAt',
        });
      }
      expiry = asked;
    }
    const retention = await this.settings.get<number>('verification.id_retention_days', 90);

    await this.prisma.transaction(async (tx) => {
      await this.finish(tx, c, 'APPROVE', actor, { decisionNotes: notes?.trim() || null, expiresAt: expiry }, now, retention);
      await this.badges.grant(tx, c, expiry, now);
      await this.auditAction(actor, 'verification.approve', c, { status: 'VERIFIED', expiresAt: expiry }, tx);
    });
    await this.removeViewCopies(c, c.reviewerId);
    await this.tell(c, 'verification.approved', this.approvedText(c.subjectType));
    return this.detail(actor, caseId);
  }

  async reject(actor: Actor, caseId: string, feedback: string, notes?: string): Promise<AdminCaseDetailDto> {
    const c = await this.decidable(actor, caseId, 'REJECT');
    const now = new Date();
    const retention = await this.settings.get<number>('verification.id_retention_days', 90);
    await this.prisma.transaction(async (tx) => {
      await this.finish(tx, c, 'REJECT', actor, { feedback: feedback.trim(), decisionNotes: notes?.trim() || null }, now, retention);
      await this.badges.mirrorStatus(tx, c, 'REJECTED');
      await this.auditAction(actor, 'verification.reject', c, { status: 'REJECTED' }, tx);
    });
    await this.removeViewCopies(c, c.reviewerId);
    await this.tell(c, 'verification.rejected', `We could not verify you this time. ${feedback.trim()}`);
    return this.detail(actor, caseId);
  }

  async requestInfo(actor: Actor, caseId: string, message: string): Promise<AdminCaseDetailDto> {
    const c = await this.decidable(actor, caseId, 'REQUEST_INFO');
    const now = new Date();
    await this.prisma.transaction(async (tx) => {
      await tx.verificationCase.update({
        where: { id: caseId },
        data: { moreInfoNote: message.trim(), moreInfoRequestedAt: now, version: { increment: 1 } },
      });
      await tx.verificationCaseEvent.create({
        data: { caseId, action: 'MORE_INFO_REQUESTED', actorId: actor.userId, note: message.trim() },
      });
      await this.auditAction(actor, 'verification.request_info', c, { status: 'UNDER_REVIEW' }, tx);
    });
    await this.removeViewCopies(c, c.reviewerId);
    await this.tell(c, 'verification.more_info', `A reviewer needs a little more from you: ${message.trim()}`);
    return this.detail(actor, caseId);
  }

  /** Revoke a verified case. Any holder of `verification.decide` may, except on their own case. */
  async revoke(actor: Actor, caseId: string, reason: string): Promise<AdminCaseDetailDto> {
    const c = await this.load(caseId);
    this.refuseOwn(actor, c);
    if (!canDo('REVOKE', c.status)) throw ApiException.invalidState('Only a verified case can be revoked.');
    const now = new Date();
    await this.prisma.transaction(async (tx) => {
      const won = await tx.verificationCase.updateMany({
        where: { id: caseId, status: 'VERIFIED' },
        data: { status: nextStatus('REVOKE'), feedback: reason.trim(), version: { increment: 1 } },
      });
      if (won.count !== 1) throw ApiException.conflict('This case just changed. Refresh and try again.');
      await tx.verificationCaseEvent.create({
        data: { caseId, action: 'REVOKED', actorId: actor.userId, note: reason.trim() },
      });
      await this.badges.end(tx, c, 'REVOKED', now);
      await this.auditAction(actor, 'verification.revoke', c, { status: 'REVOKED' }, tx);
    });
    await this.tell(c, 'verification.revoked', `Your verification was removed. ${reason.trim()}`);
    return this.detail(actor, caseId);
  }

  // ---- internals --------------------------------------------------------------------------------------------------

  private async finish(
    tx: Prisma.TransactionClient,
    c: CaseRow,
    action: Extract<CaseAction, 'APPROVE' | 'REJECT'>,
    actor: Actor,
    data: Prisma.VerificationCaseUpdateManyMutationInput,
    now: Date,
    retentionDays: number,
  ): Promise<void> {
    const won = await tx.verificationCase.updateMany({
      where: { id: c.id, status: 'UNDER_REVIEW', reviewerId: actor.userId, moreInfoRequestedAt: null },
      data: { ...data, status: nextStatus(action), decidedAt: now, version: { increment: 1 } },
    });
    if (won.count !== 1) throw ApiException.conflict('This case just changed. Refresh and try again.');
    await tx.verificationCaseEvent.create({
      data: {
        caseId: c.id,
        action: action === 'APPROVE' ? 'APPROVED' : 'REJECTED',
        actorId: actor.userId,
        note: action === 'REJECT' ? (data.feedback as string | undefined) : undefined,
      },
    });
    // Retention: government ID images are deleted `retentionDays` after the decision; the decision record stays.
    await tx.verificationEvidence.updateMany({
      where: { caseId: c.id, type: 'GOVERNMENT_ID', purgedAt: null },
      data: { purgeAfter: new Date(now.getTime() + retentionDays * 86_400_000) },
    });
  }

  /** A case in front of the caller as its assigned reviewer, in a state the action allows. */
  private async decidable(actor: Actor, caseId: string, action: CaseAction): Promise<CaseRow> {
    const c = await this.load(caseId);
    this.refuseOwn(actor, c);
    if (c.reviewerId !== actor.userId) {
      throw ApiException.forbidden('Claim this case before deciding on it.');
    }
    if (!canDo(action, c.status)) throw ApiException.invalidState('This case is not under review.');
    if (c.moreInfoRequestedAt !== null && action !== 'REQUEST_INFO') {
      throw ApiException.invalidState('Waiting for the applicant to add what you asked for.');
    }
    if (c.moreInfoRequestedAt !== null && action === 'REQUEST_INFO') {
      throw ApiException.invalidState('You already asked for more. Wait for the applicant.');
    }
    return c;
  }

  private refuseOwn(actor: Actor, c: CaseRow): void {
    if (c.applicantId === actor.userId) {
      throw ApiException.forbidden('You cannot review your own verification.');
    }
  }

  private async load(caseId: string): Promise<CaseRow> {
    const c = await this.prisma.verificationCase.findUnique({ where: { id: caseId }, include: CASE_INCLUDE });
    if (!c) throw ApiException.notFound('We could not find that case.');
    return c;
  }

  private sla(): Promise<number> {
    return this.settings.get<number>('verification.sla_working_days', 5);
  }

  private async subjectLabels(rows: Array<{ subjectType: VerificationSubjectType; subjectId: string }>) {
    const skillIds = rows.filter((r) => r.subjectType === 'SKILL').map((r) => r.subjectId);
    const skills = skillIds.length
      ? await this.prisma.skill.findMany({ where: { id: { in: skillIds } }, select: { id: true, name: true } })
      : [];
    return new Map(skills.map((s) => [s.id, s.name]));
  }

  private row(c: CaseRow, actor: Actor, labels: Map<string, string>, now: Date): AdminCaseRowDto {
    const profile = c.applicant.creativeProfile;
    const open = REVIEW_STATUSES.includes(c.status);
    return {
      id: c.id,
      subjectType: c.subjectType,
      status: c.status,
      applicantName: profile?.displayName ?? c.applicant.fullName ?? 'Member',
      applicantHandle: profile?.handle ?? null,
      subjectLabel: c.subjectType === 'SKILL' ? (labels.get(c.subjectId) ?? null) : null,
      submittedAt: c.submittedAt,
      ageHours: c.submittedAt ? Math.max(0, Math.floor((now.getTime() - c.submittedAt.getTime()) / HOUR_MS)) : 0,
      slaDueAt: c.slaDueAt,
      overdue: open && c.slaDueAt !== null && c.slaDueAt < now,
      reviewerId: c.reviewerId,
      reviewerName: c.reviewer?.fullName ?? null,
      isOwnCase: c.applicantId === actor.userId,
      assignedToMe: c.reviewerId === actor.userId,
      expiresAt: c.expiresAt,
    };
  }

  private auditAction(
    actor: Actor,
    action: string,
    c: { id: string; subjectType: VerificationSubjectType; status: VerificationStatus },
    after: Record<string, unknown>,
    tx?: Prisma.TransactionClient,
  ) {
    return this.audit.record(
      {
        actorType: 'ADMIN',
        actorId: actor.userId,
        action,
        entityType: 'verification_case',
        entityId: c.id,
        before: { status: c.status },
        after: { subjectType: c.subjectType, ...after },
        ip: actor.ip,
        requestId: actor.requestId,
      },
      tx,
    );
  }

  private approvedText(subjectType: VerificationSubjectType): string {
    return subjectType === 'SKILL'
      ? 'Your skill is verified. The badge now shows on your profile.'
      : 'You are a Verified Creative. The tick now shows next to your name.';
  }

  private async tell(c: CaseRow, type: string, body: string): Promise<void> {
    try {
      await this.notifications.notify({
        userId: c.applicantId,
        category: 'PROFILE',
        type,
        title: c.subjectType === 'SKILL' ? 'Skill verification update' : 'Verified Creative update',
        body,
        deepLink: c.subjectType === 'SKILL' ? '/skills' : '/verification',
      });
    } catch (err) {
      // The decision stands even if the notice cannot be queued.
      this.log.warn(`Could not notify about case ${c.id}: ${(err as Error).message}`);
    }
  }
}
