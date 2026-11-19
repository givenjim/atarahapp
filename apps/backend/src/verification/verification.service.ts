import { Inject, Injectable, Logger } from '@nestjs/common';
import {
  type EntitlementKey,
  Prisma,
  type VerificationCase,
  type VerificationEvidence,
  type VerificationReference,
  type VerificationStatus,
  type VerificationSubjectType,
} from '@prisma/client';
import { AccessService } from '../access/access.service';
import { AuditService } from '../audit/audit.service';
import { ApiException } from '../common/api.exception';
import { ErrorCode } from '../common/error-codes';
import { AppConfigService } from '../config/app-config.service';
import { PlatformSettingsService } from '../feature-flags/platform-settings.service';
import { MediaService } from '../media/media.service';
import { EMAIL_PROVIDER, type EmailProvider } from '../messaging/messaging';
import { renderNotificationEmail } from '../notifications/notification-email';
import { PrismaService } from '../prisma/prisma.service';
import { VerificationBadgeService } from './verification-badge.service';
import {
  type AddEvidenceDto,
  type AddReferenceDto,
  type CaseViewDto,
  type EvidenceItemDto,
  type ReferenceItemDto,
  type TimelineStepDto,
  type UploadEvidenceFileDto,
  type VerificationOverviewDto,
} from './verification.dto';
import {
  addWorkingDays,
  canDo,
  evaluateRequirements,
  hashToken,
  isHttpsUrl,
  maskEmail,
  MEMBER_SUBJECTS,
  newReferenceToken,
  nextStatus,
  type RequirementRow,
} from './verification.rules';

const ENTITLEMENT: Partial<Record<VerificationSubjectType, EntitlementKey>> = {
  CREATIVE_IDENTITY: 'CREATIVE_VERIFICATION',
  SKILL: 'SKILL_VERIFICATION',
};
const TERMINAL: readonly VerificationStatus[] = ['REJECTED', 'EXPIRED', 'REVOKED'];
const MAX_EVIDENCE = 20;
const MAX_REFERENCES = 3;
const MAX_LINKS = 5;
const MAX_ID_IMAGES = 2;
const REFERENCE_TTL_DAYS = 14;
const RESEND_COOLDOWN_MS = 24 * 3600 * 1000;
const DEFAULT_SLA_DAYS = 5;

type CaseFull = VerificationCase & {
  evidence: VerificationEvidence[];
  references: VerificationReference[];
};

/**
 * Member side of verification (P2-M6): the case a member builds (ID, projects, reference, certificates, links), its
 * submission, and the referee's confirmation. Submitting needs the Pro entitlement for the case type (checked at the
 * route with `@RequiresEntitlement` and again here on every change, so a lapsed membership cannot keep editing).
 */
@Injectable()
export class VerificationService {
  private readonly log = new Logger(VerificationService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly access: AccessService,
    private readonly settings: PlatformSettingsService,
    private readonly media: MediaService,
    private readonly audit: AuditService,
    private readonly badges: VerificationBadgeService,
    private readonly config: AppConfigService,
    @Inject(EMAIL_PROVIDER) private readonly email: EmailProvider,
  ) {}

  // ---- reading ----------------------------------------------------------------------------------------------------

  slaDays(): Promise<number> {
    return this.settings.get<number>('verification.sla_working_days', DEFAULT_SLA_DAYS);
  }

  async overview(userId: string): Promise<VerificationOverviewDto> {
    const profile = await this.profileOf(userId);
    const [entitlements, slaWorkingDays] = await Promise.all([
      this.access.entitlements(userId),
      this.slaDays(),
    ]);
    const creative = await this.caseView(userId, 'CREATIVE_IDENTITY', profile?.id ?? null, entitlements);
    return {
      creative,
      creativeEntitled: entitlements.has('CREATIVE_VERIFICATION'),
      skillEntitled: entitlements.has('SKILL_VERIFICATION'),
      slaWorkingDays,
    };
  }

  async creativeCase(userId: string): Promise<CaseViewDto> {
    const profile = await this.profileOf(userId);
    return this.caseView(userId, 'CREATIVE_IDENTITY', profile?.id ?? null);
  }

  async skillCase(userId: string, skillId: string): Promise<CaseViewDto> {
    await this.ownedSkill(userId, skillId);
    return this.caseView(userId, 'SKILL', skillId);
  }

  async getCase(userId: string, caseId: string): Promise<CaseViewDto> {
    const c = await this.ownCase(userId, caseId);
    return this.viewOf(c);
  }

  private async caseView(
    userId: string,
    subjectType: VerificationSubjectType,
    subjectId: string | null,
    entitlements?: Set<EntitlementKey>,
  ): Promise<CaseViewDto> {
    const c = subjectId
      ? await this.prisma.verificationCase.findFirst({
          where: { applicantId: userId, subjectType, subjectId },
          orderBy: { createdAt: 'desc' },
          include: { evidence: { orderBy: { createdAt: 'asc' } }, references: { orderBy: { createdAt: 'asc' } } },
        })
      : null;
    if (c) return this.viewOf(c, entitlements);
    const [requirements, entitled, slaWorkingDays] = await Promise.all([
      this.requirementRows(subjectType),
      this.entitled(userId, subjectType, entitlements),
      this.slaDays(),
    ]);
    return {
      id: null,
      subjectType,
      subjectId: subjectId ?? '00000000-0000-0000-0000-000000000000',
      status: 'NOT_SUBMITTED',
      entitled,
      canStart: subjectId !== null && MEMBER_SUBJECTS.includes(subjectType),
      canEdit: false,
      canSubmit: false,
      needsInfo: false,
      moreInfoNote: null,
      feedback: null,
      submittedAt: null,
      decidedAt: null,
      expiresAt: null,
      slaWorkingDays,
      slaDueAt: null,
      requirements: evaluateRequirements(requirements, []),
      evidence: [],
      references: [],
      timeline: this.timeline('NOT_SUBMITTED', null, null),
    };
  }

  private async viewOf(c: CaseFull, entitlements?: Set<EntitlementKey>): Promise<CaseViewDto> {
    const [requirements, entitled, slaWorkingDays, evidence] = await Promise.all([
      this.requirementRows(c.subjectType),
      this.entitled(c.applicantId, c.subjectType, entitlements),
      this.slaDays(),
      this.evidenceItems(c),
    ]);
    const needsInfo = c.status === 'UNDER_REVIEW' && c.moreInfoRequestedAt !== null;
    const canEdit = c.status === 'NOT_SUBMITTED' || needsInfo;
    const states = evaluateRequirements(
      requirements,
      c.evidence.map((e) => e.type),
    );
    return {
      id: c.id,
      subjectType: c.subjectType,
      subjectId: c.subjectId,
      status: c.status,
      entitled,
      canStart: TERMINAL.includes(c.status),
      canEdit: canEdit && entitled,
      canSubmit: canEdit && entitled && states.every((r) => r.met),
      needsInfo,
      moreInfoNote: needsInfo ? c.moreInfoNote : null,
      feedback: TERMINAL.includes(c.status) ? c.feedback : null,
      submittedAt: c.submittedAt,
      decidedAt: c.decidedAt,
      expiresAt: c.status === 'VERIFIED' ? c.expiresAt : null,
      slaWorkingDays,
      slaDueAt: REVIEWABLE.includes(c.status) ? c.slaDueAt : null,
      requirements: states,
      evidence,
      references: c.references.map(
        (r): ReferenceItemDto => ({
          id: r.id,
          name: r.name,
          emailMasked: maskEmail(r.email),
          relationship: r.relationship,
          status: r.status,
          sentAt: r.sentAt,
        }),
      ),
      timeline: this.timeline(c.status, c.submittedAt, c.decidedAt),
    };
  }

  private async evidenceItems(c: CaseFull): Promise<EvidenceItemDto[]> {
    const assetIds = c.evidence.flatMap((e) => (e.mediaAssetId ? [e.mediaAssetId] : []));
    const projectIds = c.evidence.flatMap((e) => (e.projectId ? [e.projectId] : []));
    const [assets, projects] = await Promise.all([
      assetIds.length
        ? this.prisma.mediaAsset.findMany({ where: { id: { in: assetIds } }, select: { id: true, status: true } })
        : [],
      projectIds.length
        ? this.prisma.project.findMany({ where: { id: { in: projectIds } }, select: { id: true, title: true } })
        : [],
    ]);
    const status = new Map(assets.map((a) => [a.id, a.status as string]));
    const title = new Map(projects.map((p) => [p.id, p.title]));
    return c.evidence.map((e) => ({
      id: e.id,
      type: e.type,
      label: e.label,
      projectId: e.projectId,
      projectTitle: e.projectId ? (title.get(e.projectId) ?? null) : null,
      url: e.url,
      referenceId: e.referenceId,
      fileStatus: e.mediaAssetId ? (e.purgedAt ? 'DELETED' : (status.get(e.mediaAssetId) ?? 'DELETED')) : null,
      purged: e.purgedAt !== null,
      createdAt: e.createdAt,
    }));
  }

  timeline(status: VerificationStatus, submittedAt: Date | null, decidedAt: Date | null): TimelineStepDto[] {
    const submitted = status !== 'NOT_SUBMITTED';
    const decided = ['VERIFIED', 'REJECTED', 'EXPIRED', 'REVOKED'].includes(status);
    const label =
      status === 'VERIFIED' || status === 'EXPIRED'
        ? 'Verified'
        : status === 'REJECTED'
          ? 'Not approved'
          : status === 'REVOKED'
            ? 'Revoked'
            : 'Decision';
    return [
      { key: 'SUBMITTED', label: 'Application submitted', state: submitted ? 'done' : 'upcoming', at: submittedAt },
      {
        key: 'UNDER_REVIEW',
        label: 'Under review',
        state: decided ? 'done' : submitted ? 'current' : 'upcoming',
        at: null,
      },
      { key: 'DECISION', label, state: decided ? 'done' : 'upcoming', at: decidedAt },
    ];
  }

  // ---- starting, evidence, references -----------------------------------------------------------------------------

  /** Start (or return) the member's draft for Verified Creative. */
  async startCreative(userId: string): Promise<CaseViewDto> {
    const profile = await this.profileOf(userId);
    if (!profile) throw ApiException.invalidState('Create your creative profile first.');
    return this.start(userId, 'CREATIVE_IDENTITY', profile.id);
  }

  async startSkill(userId: string, skillId: string): Promise<CaseViewDto> {
    await this.ownedSkill(userId, skillId);
    return this.start(userId, 'SKILL', skillId);
  }

  private async start(userId: string, subjectType: VerificationSubjectType, subjectId: string): Promise<CaseViewDto> {
    await this.requireEntitlement(userId, subjectType);
    const latest = await this.prisma.verificationCase.findFirst({
      where: { applicantId: userId, subjectType, subjectId },
      orderBy: { createdAt: 'desc' },
      include: { evidence: { orderBy: { createdAt: 'asc' } }, references: { orderBy: { createdAt: 'asc' } } },
    });
    if (latest && !TERMINAL.includes(latest.status)) {
      if (latest.status === 'VERIFIED') {
        throw ApiException.invalidState('This is already verified.');
      }
      return this.viewOf(latest);
    }
    try {
      const created = await this.prisma.verificationCase.create({
        data: { applicantId: userId, subjectType, subjectId },
        include: { evidence: true, references: true },
      });
      return this.viewOf(created);
    } catch (err) {
      // A second tap racing the first: the partial unique index allows only one open case.
      if (err instanceof Prisma.PrismaClientKnownRequestError && err.code === 'P2002') {
        const open = await this.prisma.verificationCase.findFirstOrThrow({
          where: { applicantId: userId, subjectType, subjectId, status: { in: ['NOT_SUBMITTED', 'SUBMITTED', 'UNDER_REVIEW'] } },
          include: { evidence: { orderBy: { createdAt: 'asc' } }, references: { orderBy: { createdAt: 'asc' } } },
        });
        return this.viewOf(open);
      }
      throw err;
    }
  }

  /** Signed upload of one evidence file into the private evidence bucket. */
  async requestEvidenceUpload(userId: string, caseId: string, dto: UploadEvidenceFileDto) {
    const c = await this.editableCase(userId, caseId);
    const count = c.evidence.filter((e) => e.mediaAssetId).length;
    if (count >= MAX_EVIDENCE) throw ApiException.invalidState('That is enough files for one application.');
    return this.media.requestUpload(
      userId,
      { kind: dto.kind, mimeType: dto.mimeType, sizeBytes: dto.sizeBytes, visibility: 'PRIVATE' },
      { evidence: true },
    );
  }

  async addEvidence(userId: string, caseId: string, dto: AddEvidenceDto): Promise<CaseViewDto> {
    const c = await this.editableCase(userId, caseId);
    if (c.evidence.length >= MAX_EVIDENCE) {
      throw ApiException.invalidState('That is enough evidence for one application.');
    }
    const label = dto.label?.trim() || null;
    const data: Prisma.VerificationEvidenceUncheckedCreateInput = { caseId, type: dto.type, label };

    switch (dto.type) {
      case 'GOVERNMENT_ID': {
        if (c.subjectType !== 'CREATIVE_IDENTITY' && c.subjectType !== 'SELLER') {
          throw ApiException.validation('A government ID is not part of this application.');
        }
        if (c.evidence.filter((e) => e.type === 'GOVERNMENT_ID').length >= MAX_ID_IMAGES) {
          throw ApiException.invalidState('You can add the front and the back of your ID.');
        }
        data.mediaAssetId = await this.ownedEvidenceAsset(userId, dto.mediaAssetId, c);
        break;
      }
      case 'DOCUMENT': {
        data.mediaAssetId = await this.ownedEvidenceAsset(userId, dto.mediaAssetId, c);
        break;
      }
      case 'PORTFOLIO_PROJECT': {
        if (!dto.projectId) throw ApiException.validation('Choose a project.', { field: 'projectId' });
        const profile = await this.profileOf(userId);
        const project = profile
          ? await this.prisma.project.findFirst({
              where: { id: dto.projectId, profileId: profile.id, deletedAt: null },
              select: { id: true, role: true, skills: { select: { skillId: true } } },
            })
          : null;
        if (!project) throw ApiException.notFound('We could not find that project.');
        if (c.subjectType === 'CREATIVE_IDENTITY' && !project.role?.trim()) {
          throw ApiException.validation('Add your role to this project first, so the reviewer can see what you did.', {
            field: 'projectId',
            code: 'ROLE_MISSING',
          });
        }
        if (c.subjectType === 'SKILL' && !project.skills.some((s) => s.skillId === c.subjectId)) {
          throw ApiException.validation('That project does not list this skill. Add the skill to the project first.', {
            field: 'projectId',
          });
        }
        if (c.evidence.some((e) => e.projectId === project.id)) {
          throw ApiException.conflict('You already added that project.');
        }
        data.projectId = project.id;
        break;
      }
      case 'LINK': {
        const url = dto.url?.trim();
        if (!url || !isHttpsUrl(url)) {
          throw ApiException.validation('Add a link that starts with https://.', { field: 'url' });
        }
        if (c.evidence.filter((e) => e.type === 'LINK').length >= MAX_LINKS) {
          throw ApiException.invalidState(`You can add up to ${MAX_LINKS} links.`);
        }
        data.url = url;
        break;
      }
    }
    await this.prisma.verificationEvidence.create({ data });
    return this.getCase(userId, caseId);
  }

  async removeEvidence(userId: string, caseId: string, evidenceId: string): Promise<CaseViewDto> {
    const c = await this.ownCase(userId, caseId);
    if (c.status !== 'NOT_SUBMITTED') {
      throw ApiException.invalidState('Evidence cannot be removed after you submit.');
    }
    const e = c.evidence.find((x) => x.id === evidenceId);
    if (!e) throw ApiException.notFound('We could not find that item.');
    if (e.type === 'REFERENCE') {
      if (e.referenceId) await this.prisma.verificationReference.delete({ where: { id: e.referenceId } });
    } else {
      await this.prisma.verificationEvidence.delete({ where: { id: e.id } });
    }
    if (e.mediaAssetId) await this.media.remove(userId, e.mediaAssetId).catch(() => undefined);
    return this.getCase(userId, caseId);
  }

  async addReference(userId: string, caseId: string, dto: AddReferenceDto): Promise<CaseViewDto> {
    const c = await this.editableCase(userId, caseId);
    if (c.references.length >= MAX_REFERENCES) {
      throw ApiException.invalidState(`You can add up to ${MAX_REFERENCES} references.`);
    }
    const email = dto.email.trim().toLowerCase();
    const me = await this.prisma.user.findUnique({ where: { id: userId }, select: { email: true } });
    if (me?.email && me.email.toLowerCase() === email) {
      throw ApiException.validation('A reference has to be someone else.', { field: 'email' });
    }
    if (c.references.some((r) => r.email === email)) {
      throw ApiException.conflict('You already added that person.');
    }
    const { token, hash } = newReferenceToken();
    const ref = await this.prisma.verificationReference.create({
      data: {
        caseId,
        name: dto.name.trim(),
        email,
        relationship: dto.relationship.trim(),
        tokenHash: hash,
        tokenExpiresAt: new Date(Date.now() + REFERENCE_TTL_DAYS * 86_400_000),
      },
    });
    await this.prisma.verificationEvidence.create({
      data: { caseId, type: 'REFERENCE', label: ref.name, referenceId: ref.id },
    });
    // A draft sends nothing yet: referees are emailed when the application is submitted.
    if (c.status !== 'NOT_SUBMITTED') await this.sendReferenceEmail(ref, token, userId, c.subjectType);
    return this.getCase(userId, caseId);
  }

  async resendReference(userId: string, caseId: string, referenceId: string): Promise<CaseViewDto> {
    const c = await this.ownCase(userId, caseId);
    const ref = c.references.find((r) => r.id === referenceId);
    if (!ref) throw ApiException.notFound('We could not find that reference.');
    if (c.status === 'NOT_SUBMITTED') {
      throw ApiException.invalidState('Referees are emailed when you submit your application.');
    }
    if (!['SUBMITTED', 'UNDER_REVIEW'].includes(c.status) || ref.status === 'CONFIRMED' || ref.status === 'DECLINED') {
      throw ApiException.invalidState('This reference cannot be sent again.');
    }
    if (ref.sentAt && Date.now() - ref.sentAt.getTime() < RESEND_COOLDOWN_MS) {
      throw new ApiException(ErrorCode.RATE_LIMITED, 'You can send the reminder once a day.', 429);
    }
    const { token, hash } = newReferenceToken();
    const updated = await this.prisma.verificationReference.update({
      where: { id: ref.id },
      data: {
        tokenHash: hash,
        tokenExpiresAt: new Date(Date.now() + REFERENCE_TTL_DAYS * 86_400_000),
        status: 'PENDING',
      },
    });
    await this.sendReferenceEmail(updated, token, userId, c.subjectType);
    return this.getCase(userId, caseId);
  }

  // ---- submitting -------------------------------------------------------------------------------------------------

  async submit(userId: string, caseId: string): Promise<CaseViewDto> {
    const c = await this.ownCase(userId, caseId);
    await this.requireEntitlement(userId, c.subjectType);
    const needsInfo = c.status === 'UNDER_REVIEW' && c.moreInfoRequestedAt !== null;
    const action = c.status === 'NOT_SUBMITTED' ? 'SUBMIT' : needsInfo ? 'RESUBMIT' : null;
    if (!action || !canDo(action, c.status)) {
      throw ApiException.invalidState('This application cannot be submitted now.');
    }

    const requirements = await this.requirementRows(c.subjectType);
    const states = evaluateRequirements(requirements, c.evidence.map((e) => e.type));
    const unmet = states.filter((r) => !r.met);
    if (unmet.length > 0) {
      throw ApiException.validation('Add everything that is required, then submit.', {
        unmet: unmet.map((r) => r.key),
      });
    }
    await this.assertEvidenceUsable(userId, c);

    const now = new Date();
    const sla = await this.slaDays();
    const to = nextStatus(action);
    await this.prisma.transaction(async (tx) => {
      const claimed = await tx.verificationCase.updateMany({
        where: { id: c.id, status: c.status, version: c.version },
        data:
          action === 'SUBMIT'
            ? { status: to, submittedAt: now, slaDueAt: addWorkingDays(now, sla), version: { increment: 1 } }
            : { moreInfoNote: null, moreInfoRequestedAt: null, version: { increment: 1 } },
      });
      if (claimed.count !== 1) throw ApiException.conflict('This application just changed. Refresh and try again.');
      await tx.verificationCaseEvent.create({
        data: { caseId: c.id, action: action === 'SUBMIT' ? 'SUBMITTED' : 'RESUBMITTED', actorId: userId },
      });
      if (action === 'SUBMIT') await this.badges.mirrorStatus(tx, c, to);
      await this.audit.record(
        {
          actorType: 'USER',
          actorId: userId,
          action: action === 'SUBMIT' ? 'verification.submit' : 'verification.resubmit',
          entityType: 'verification_case',
          entityId: c.id,
          after: { subjectType: c.subjectType, status: to },
        },
        tx,
      );
    });

    // Referees named before submitting are emailed now; unsent ones from an earlier failure are retried.
    await this.sendPendingReferences(c.id, userId, c.subjectType);
    return this.getCase(userId, caseId);
  }

  private async assertEvidenceUsable(userId: string, c: CaseFull): Promise<void> {
    const assetIds = c.evidence.flatMap((e) => (e.mediaAssetId ? [e.mediaAssetId] : []));
    if (assetIds.length > 0) {
      const assets = await this.prisma.mediaAsset.findMany({
        where: { id: { in: assetIds }, ownerId: userId, bucket: 'EVIDENCE', deletedAt: null },
        select: { id: true, status: true },
      });
      const byId = new Map(assets.map((a) => [a.id, a.status]));
      for (const id of assetIds) {
        const s = byId.get(id);
        if (s === 'REJECTED' || !s) {
          throw ApiException.validation('One of your files could not be used. Remove it and add it again.');
        }
        if (s !== 'READY') {
          throw ApiException.invalidState('Your files are still being checked. Try again in a moment.');
        }
      }
    }
    const projectIds = c.evidence.flatMap((e) => (e.projectId ? [e.projectId] : []));
    if (projectIds.length > 0) {
      const profile = await this.profileOf(userId);
      const live = await this.prisma.project.findMany({
        where: { id: { in: projectIds }, profileId: profile?.id ?? '', deletedAt: null },
        select: { id: true, role: true },
      });
      const ok = live.filter((p) => c.subjectType !== 'CREATIVE_IDENTITY' || p.role?.trim());
      if (ok.length !== projectIds.length) {
        throw ApiException.validation('One of your projects was removed or has no role. Check your projects and try again.');
      }
    }
  }

  // ---- references (the referee's side) ----------------------------------------------------------------------------

  async referenceRequest(token: string) {
    const ref = await this.referenceByToken(token);
    const { case: c } = ref;
    const [applicantName, skill] = await Promise.all([
      this.applicantName(c.applicantId),
      c.subjectType === 'SKILL'
        ? this.prisma.skill.findUnique({ where: { id: c.subjectId }, select: { name: true } })
        : null,
    ]);
    return {
      refereeName: ref.name,
      applicantName,
      relationship: ref.relationship,
      about: c.subjectType === 'SKILL' ? 'SKILL' : 'VERIFIED_CREATIVE',
      skillName: skill?.name ?? null,
      status: ref.status,
    };
  }

  async respondToReference(token: string, confirm: boolean, comment?: string) {
    const ref = await this.referenceByToken(token);
    if (ref.status !== 'PENDING') throw ApiException.invalidState('You already responded. Thank you.');
    const now = new Date();
    const done = await this.prisma.verificationReference.updateMany({
      where: { id: ref.id, status: 'PENDING', tokenExpiresAt: { gt: now } },
      data: { status: confirm ? 'CONFIRMED' : 'DECLINED', respondedAt: now, comment: comment?.trim() || null },
    });
    if (done.count !== 1) throw ApiException.invalidState('This link has expired.');
    await this.prisma.verificationCaseEvent.create({
      data: { caseId: ref.caseId, action: confirm ? 'REFERENCE_CONFIRMED' : 'REFERENCE_DECLINED' },
    });
    await this.audit.record({
      actorType: 'SYSTEM',
      action: confirm ? 'verification.reference.confirm' : 'verification.reference.decline',
      entityType: 'verification_case',
      entityId: ref.caseId,
      after: { referenceId: ref.id },
    });
    return { status: confirm ? ('CONFIRMED' as const) : ('DECLINED' as const) };
  }

  private async referenceByToken(token: string) {
    const ref = await this.prisma.verificationReference.findUnique({
      where: { tokenHash: hashToken(token) },
      include: { case: true },
    });
    // One answer for an unknown token and a case that is over: nothing is confirmed to a stranger.
    if (!ref || !['SUBMITTED', 'UNDER_REVIEW'].includes(ref.case.status)) {
      throw ApiException.notFound('This link is not valid any more.');
    }
    if (ref.status === 'PENDING' && ref.tokenExpiresAt <= new Date()) {
      await this.prisma.verificationReference.updateMany({
        where: { id: ref.id, status: 'PENDING' },
        data: { status: 'EXPIRED' },
      });
      throw ApiException.notFound('This link has expired.');
    }
    return ref;
  }

  // ---- emails ----------------------------------------------------------------------------------------------------

  private async sendPendingReferences(caseId: string, userId: string, subjectType: VerificationSubjectType) {
    const refs = await this.prisma.verificationReference.findMany({
      where: { caseId, status: 'PENDING', sentAt: null },
    });
    for (const r of refs) {
      // The stored token is only a hash, so each unsent reference gets a fresh link.
      const { token, hash } = newReferenceToken();
      const updated = await this.prisma.verificationReference.update({
        where: { id: r.id },
        data: { tokenHash: hash, tokenExpiresAt: new Date(Date.now() + REFERENCE_TTL_DAYS * 86_400_000) },
      });
      await this.sendReferenceEmail(updated, token, userId, subjectType);
    }
  }

  private async sendReferenceEmail(
    ref: VerificationReference,
    token: string,
    userId: string,
    subjectType: VerificationSubjectType,
  ): Promise<void> {
    const applicant = await this.applicantName(userId);
    const link = `${this.config.appLinkBaseUrl}/api/v1/verification/references/${token}/page`;
    const about = subjectType === 'SKILL' ? 'skill verification' : 'Verified Creative application';
    const mail = renderNotificationEmail({
      title: `${applicant} named you as a reference`,
      body:
        `Hello ${ref.name}, ${applicant} listed you as a ${ref.relationship.toLowerCase()} reference for their ${about} on Atarah. ` +
        'It takes one minute: tell us whether you know them and their work. We share nothing about you with them, ' +
        'and if you do not know this person you can ignore this email.',
      link,
    });
    try {
      await this.email.send({ to: ref.email, ...mail });
      await this.prisma.verificationReference.update({ where: { id: ref.id }, data: { sentAt: new Date() } });
    } catch (err) {
      // The reference stays PENDING and unsent; the applicant can resend, and the next submit retries it.
      this.log.warn(`Reference email for ${ref.id} failed: ${(err as Error).message}`);
    }
  }

  // ---- helpers ---------------------------------------------------------------------------------------------------

  private async requirementRows(subjectType: VerificationSubjectType): Promise<RequirementRow[]> {
    return this.prisma.verificationRequirement.findMany({
      where: { subjectType, isActive: true },
      orderBy: { sortOrder: 'asc' },
      select: { key: true, label: true, description: true, evidenceTypes: true, minCount: true },
    });
  }

  private async entitled(userId: string, subjectType: VerificationSubjectType, known?: Set<EntitlementKey>) {
    const key = ENTITLEMENT[subjectType];
    if (!key) return false;
    return (known ?? (await this.access.entitlements(userId))).has(key);
  }

  private async requireEntitlement(userId: string, subjectType: VerificationSubjectType): Promise<void> {
    const key = ENTITLEMENT[subjectType];
    if (!key || !MEMBER_SUBJECTS.includes(subjectType)) {
      throw ApiException.invalidState('This type of verification is not open to applications yet.');
    }
    if (!(await this.access.hasEntitlement(userId, key))) {
      throw new ApiException(ErrorCode.PREMIUM_REQUIRED, 'This is part of Atarah Pro.', 403, { entitlement: key });
    }
  }

  private profileOf(userId: string) {
    return this.prisma.creativeProfile.findUnique({ where: { userId }, select: { id: true } });
  }

  private async ownedSkill(userId: string, skillId: string): Promise<void> {
    const profile = await this.profileOf(userId);
    const row = profile
      ? await this.prisma.creativeSkill.findUnique({
          where: { profileId_skillId: { profileId: profile.id, skillId } },
          select: { skillId: true },
        })
      : null;
    if (!row) throw ApiException.notFound('Add this skill to your profile first.');
  }

  private async applicantName(userId: string): Promise<string> {
    const u = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { fullName: true, creativeProfile: { select: { displayName: true } } },
    });
    return u?.creativeProfile?.displayName ?? u?.fullName ?? 'A member';
  }

  private async ownCase(userId: string, caseId: string): Promise<CaseFull> {
    const c = await this.prisma.verificationCase.findFirst({
      where: { id: caseId, applicantId: userId },
      include: { evidence: { orderBy: { createdAt: 'asc' } }, references: { orderBy: { createdAt: 'asc' } } },
    });
    // The same answer for another member's case and for one that does not exist.
    if (!c) throw ApiException.notFound('We could not find that application.');
    return c;
  }

  /** A case the member may still add to (a draft, or one where a reviewer asked for more), with the entitlement held. */
  private async editableCase(userId: string, caseId: string): Promise<CaseFull> {
    const c = await this.ownCase(userId, caseId);
    await this.requireEntitlement(userId, c.subjectType);
    const needsInfo = c.status === 'UNDER_REVIEW' && c.moreInfoRequestedAt !== null;
    if (c.status !== 'NOT_SUBMITTED' && !needsInfo) {
      throw ApiException.invalidState('This application can no longer be changed.');
    }
    return c;
  }

  private async ownedEvidenceAsset(userId: string, assetId: string | undefined, c: CaseFull): Promise<string> {
    if (!assetId) throw ApiException.validation('Upload the file first.', { field: 'mediaAssetId' });
    const asset = await this.prisma.mediaAsset.findFirst({
      where: { id: assetId, ownerId: userId, bucket: 'EVIDENCE', deletedAt: null },
      select: { id: true, status: true },
    });
    if (!asset || asset.status === 'PENDING_UPLOAD' || asset.status === 'REJECTED' || asset.status === 'DELETED') {
      throw ApiException.validation('We have not received that file. Upload it again.', { field: 'mediaAssetId' });
    }
    if (c.evidence.some((e) => e.mediaAssetId === asset.id)) {
      throw ApiException.conflict('That file is already attached.');
    }
    return asset.id;
  }

}

const REVIEWABLE: readonly VerificationStatus[] = ['SUBMITTED', 'UNDER_REVIEW'];
