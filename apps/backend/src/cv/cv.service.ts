import { createHash, randomBytes } from 'node:crypto';
import { InjectQueue } from '@nestjs/bullmq';
import { Injectable, Logger } from '@nestjs/common';
import {
  type CreativeDocument,
  type CreativeDocumentFormat,
  type CreativeDocumentRender,
  type DocumentShareLink,
  type ProfileSection,
} from '@prisma/client';
import { type Queue } from 'bullmq';
import { AnalyticsService } from '../analytics/analytics.service';
import { ApiException } from '../common/api.exception';
import { AppConfigService } from '../config/app-config.service';
import { AuditService } from '../audit/audit.service';
import { PROFILE_SECTIONS } from '../creative/sections';
import { MediaService } from '../media/media.service';
import { PrismaService } from '../prisma/prisma.service';
import { StorageService } from '../storage/storage.service';
import { CvSourceService } from './cv-source.service';
import {
  type CvDocument,
  type CvConfig,
  type CvSource,
  FORMAT_SPECS,
  FORMATS,
  buildCvDocument,
} from './cv.model';
import {
  type CreateShareDto,
  type CvConfigDto,
  type CvDownloadDto,
  type CvFormatInfoDto,
  type CvPreviewDto,
  type CvRenderDto,
  type CvShareCreatedDto,
  type CvShareDto,
  type CvStateDto,
  type UpdateCvDto,
  MAX_CV_PROJECTS,
} from './cv.dto';
import { renderCvHtml, esc } from './cv.templates';
import { PdfRenderer, PdfRendererUnavailableError } from './pdf-renderer';

export const CV_RENDER_JOB = 'cv-pdf-render';
/** A download link works for five minutes: the app asks for a fresh one every time. */
export const DOWNLOAD_LINK_SECONDS = 300;
/** A build still queued or running this recently is reused instead of starting another. */
const IN_FLIGHT_MS = 10 * 60_000;
/** PDFs kept per document; older files are deleted. */
const KEEP_RENDERS = 3;

const hashToken = (token: string): string => createHash('sha256').update(token).digest('hex');
export const TOKEN_PATTERN = /^[A-Za-z0-9_-]{20,64}$/;

type DocRow = Pick<CreativeDocument, 'sections' | 'projectIds' | 'restricted'>;

/**
 * The Creative CV / EPK (P2-M7): one document per member and format. The member's choices are stored; the content is
 * always read live and passed through the visibility rule in `buildCvDocument`, so a PDF, a preview and a share link can
 * never show more than the member allows, and a change of audience applies to links that already exist.
 */
@Injectable()
export class CvService {
  private readonly log = new Logger(CvService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly source: CvSourceService,
    private readonly media: MediaService,
    private readonly storage: StorageService,
    private readonly renderer: PdfRenderer,
    private readonly audit: AuditService,
    private readonly analytics: AnalyticsService,
    private readonly config: AppConfigService,
    @InjectQueue('maintenance') private readonly queue: Queue,
  ) {}

  // ---- formats and the member's choices -----------------------------------------------------------------------

  formats(): CvFormatInfoDto[] {
    return FORMATS.map((f) => this.info(f));
  }

  private info(format: CreativeDocumentFormat): CvFormatInfoDto {
    const s = FORMAT_SPECS[format];
    return {
      format,
      label: s.label,
      allowedSections: [...s.allowed],
      defaultSections: [...s.defaults],
      maxProjects: s.maxProjects,
    };
  }

  private async profileOf(userId: string): Promise<{ id: string; handle: string | null }> {
    const p = await this.prisma.creativeProfile.findUnique({
      where: { userId },
      select: { id: true, handle: true },
    });
    if (!p) throw ApiException.notFound('Set up your creative profile first.');
    return p;
  }

  private async documentRow(profileId: string, format: CreativeDocumentFormat) {
    return this.prisma.creativeDocument.findUnique({
      where: { profileId_format: { profileId, format } },
    });
  }

  /** The stored choice, or the defaults for a member who has not touched this format yet. */
  private resolveConfig(
    format: CreativeDocumentFormat,
    row: DocRow | null,
    src: CvSource,
  ): CvConfig {
    if (row) {
      return {
        format,
        sections: row.sections,
        projectIds: row.projectIds,
        restricted: row.restricted,
      };
    }
    const spec = FORMAT_SPECS[format];
    return {
      format,
      sections: [...spec.defaults],
      projectIds: src.projects
        .filter((p) => p.published && !p.hidden && !p.deleted && p.visibility === 'PUBLIC')
        .slice(0, spec.maxProjects)
        .map((p) => p.id),
      restricted: [],
    };
  }

  private async loadSource(profileId: string): Promise<CvSource> {
    const src = await this.source.load(profileId);
    if (!src) throw ApiException.notFound('Set up your creative profile first.');
    return src;
  }

  async state(userId: string, format: CreativeDocumentFormat): Promise<CvStateDto> {
    const profile = await this.profileOf(userId);
    const [src, row] = await Promise.all([
      this.loadSource(profile.id),
      this.documentRow(profile.id, format),
    ]);
    const cfg = this.resolveConfig(format, row, src);
    const spec = FORMAT_SPECS[format];
    const [preview, latest, shares] = await Promise.all([
      this.previewOf(src, cfg),
      row
        ? this.prisma.creativeDocumentRender.findFirst({
            where: { documentId: row.id },
            orderBy: { requestedAt: 'desc' },
          })
        : null,
      row
        ? this.prisma.documentShareLink.findMany({
            where: { documentId: row.id },
            orderBy: { createdAt: 'desc' },
            take: 20,
          })
        : [],
    ]);
    const now = new Date();
    return {
      info: this.info(format),
      config: this.configDto(cfg),
      sections: PROFILE_SECTIONS.map((section) => ({
        section,
        visibility: src.visibility[section],
        available: spec.allowed.includes(section),
      })),
      projects: src.projects
        .filter((p) => p.published && !p.hidden && !p.deleted)
        .map((p) => ({
          id: p.id,
          title: p.title,
          role: p.role,
          year: p.year,
          visibility: p.visibility,
        })),
      preview,
      latestRender: latest ? this.renderDto(latest) : null,
      shares: shares.map((s) => this.shareDto(s, now)),
    };
  }

  private configDto(c: CvConfig): CvConfigDto {
    return {
      sections: [...c.sections],
      projectIds: [...c.projectIds],
      restricted: [...c.restricted],
    };
  }

  async update(
    userId: string,
    format: CreativeDocumentFormat,
    dto: UpdateCvDto,
  ): Promise<CvStateDto> {
    const profile = await this.profileOf(userId);
    const spec = FORMAT_SPECS[format];
    const src = await this.loadSource(profile.id);
    const current = this.resolveConfig(format, await this.documentRow(profile.id, format), src);

    const uniq = <T>(a: readonly T[]): T[] => [...new Set(a)];
    const sections = dto.sections !== undefined ? uniq(dto.sections) : [...current.sections];
    const restricted =
      dto.restricted !== undefined ? uniq(dto.restricted) : [...current.restricted];
    const projectIds =
      dto.projectIds !== undefined ? uniq(dto.projectIds) : [...current.projectIds];

    for (const s of [...sections, ...restricted]) {
      if (!spec.allowed.includes(s)) {
        throw ApiException.validation(`${spec.label} cannot include that section.`, { section: s });
      }
    }
    if (spec.maxProjects === 0 && projectIds.length > 0) {
      throw ApiException.validation(`${spec.label} does not list projects.`, {});
    }
    if (projectIds.length > Math.min(MAX_CV_PROJECTS, Math.max(spec.maxProjects, 0))) {
      throw ApiException.validation(
        `Choose up to ${spec.maxProjects} projects for ${spec.label}.`,
        {},
      );
    }
    const mine = new Map(
      src.projects.filter((p) => p.published && !p.hidden && !p.deleted).map((p) => [p.id, p]),
    );
    for (const id of projectIds) {
      if (!mine.has(id)) {
        throw ApiException.validation('You can only list your own published projects.', {
          projectId: id,
        });
      }
    }
    // A non-public project needs the member's explicit yes, given on the portfolio section.
    const needsPortfolioOk = projectIds.some((id) => mine.get(id)?.visibility !== 'PUBLIC');
    if (needsPortfolioOk && !restricted.includes('PORTFOLIO')) {
      throw ApiException.validation(
        'Some chosen projects are not public. Allow non-public portfolio items for this document, or choose only public ones.',
        { section: 'PORTFOLIO' },
      );
    }

    await this.prisma.creativeDocument.upsert({
      where: { profileId_format: { profileId: profile.id, format } },
      create: { profileId: profile.id, format, sections, projectIds, restricted },
      update: { sections, projectIds, restricted },
    });
    return this.state(userId, format);
  }

  async preview(userId: string, format: CreativeDocumentFormat): Promise<CvPreviewDto> {
    const profile = await this.profileOf(userId);
    const [src, row] = await Promise.all([
      this.loadSource(profile.id),
      this.documentRow(profile.id, format),
    ]);
    return this.previewOf(src, this.resolveConfig(format, row, src));
  }

  private async previewOf(src: CvSource, cfg: CvConfig): Promise<CvPreviewDto> {
    const marks = await this.source.verifiedMarks(src.profileId);
    const doc = buildCvDocument(src, cfg, marks);
    const profile = await this.prisma.creativeProfile.findUnique({
      where: { id: src.profileId },
      select: { avatarMediaId: true },
    });
    return {
      displayName: doc.displayName,
      subtitle: doc.formatLabel,
      avatarUrl: await this.media.imageUrl(profile?.avatarMediaId ?? null, 200),
      identityVerified: doc.identityVerified,
      summary: doc.bio,
      work: (doc.projects ?? []).map((p) => ({ title: p.title, role: p.role, year: p.year })),
      skills: (doc.skills ?? []).map((s) => ({ name: s.name, verified: s.verified })),
      included: doc.included,
      withheld: doc.withheld,
    };
  }

  // ---- PDF -----------------------------------------------------------------------------------------------------

  async generate(userId: string, format: CreativeDocumentFormat): Promise<CvRenderDto> {
    const profile = await this.profileOf(userId);
    const doc = await this.ensureDocument(profile.id, format);
    const recent = await this.prisma.creativeDocumentRender.findFirst({
      where: {
        documentId: doc.id,
        status: { in: ['QUEUED', 'PROCESSING'] },
        requestedAt: { gt: new Date(Date.now() - IN_FLIGHT_MS) },
      },
      orderBy: { requestedAt: 'desc' },
    });
    if (recent) return this.renderDto(recent);

    const render = await this.prisma.creativeDocumentRender.create({
      data: { documentId: doc.id },
    });
    await this.queue.add(
      CV_RENDER_JOB,
      { renderId: render.id },
      { jobId: `cv-${render.id}`, attempts: 1 },
    );
    this.analytics.track('cv_generated', { format }, userId);
    await this.audit.record({
      actorType: 'USER',
      actorId: userId,
      action: 'cv.generate',
      entityType: 'creative_document',
      entityId: doc.id,
      after: { format, renderId: render.id },
    });
    return this.renderDto(render);
  }

  private async ensureDocument(profileId: string, format: CreativeDocumentFormat) {
    const existing = await this.documentRow(profileId, format);
    if (existing) return existing;
    const src = await this.loadSource(profileId);
    const cfg = this.resolveConfig(format, null, src);
    return this.prisma.creativeDocument.upsert({
      where: { profileId_format: { profileId, format } },
      create: {
        profileId,
        format,
        sections: [...cfg.sections],
        projectIds: [...cfg.projectIds],
        restricted: [],
      },
      update: {},
    });
  }

  async renderStatus(userId: string, renderId: string): Promise<CvRenderDto> {
    return this.renderDto(await this.ownedRender(userId, renderId));
  }

  async download(userId: string, renderId: string): Promise<CvDownloadDto> {
    const render = await this.ownedRender(userId, renderId);
    if (render.status !== 'READY' || !render.objectKey) {
      throw ApiException.invalidState('Your PDF is not ready yet.');
    }
    let url: string;
    try {
      url = await this.storage.signedDownloadUrl(
        'private',
        render.objectKey,
        DOWNLOAD_LINK_SECONDS,
      );
    } catch {
      throw ApiException.notFound('That PDF is no longer available. Create it again.');
    }
    const doc = await this.prisma.creativeDocument.findUniqueOrThrow({
      where: { id: render.documentId },
      select: { format: true },
    });
    this.analytics.track('cv_downloaded', { format: doc.format }, userId);
    return { url, expiresAt: new Date(Date.now() + DOWNLOAD_LINK_SECONDS * 1000) };
  }

  private async ownedRender(userId: string, renderId: string) {
    const render = await this.prisma.creativeDocumentRender.findFirst({
      where: { id: renderId, document: { profile: { userId } } },
    });
    // Someone else's render looks exactly like one that does not exist.
    if (!render) throw ApiException.notFound('We could not find that PDF.');
    return render;
  }

  private renderDto(r: CreativeDocumentRender): CvRenderDto {
    return {
      id: r.id,
      status: r.status,
      requestedAt: r.requestedAt,
      readyAt: r.readyAt,
      error: r.error,
    };
  }

  /** Worker: builds one PDF. A failure is recorded on the render and shown to the member; it is not retried blindly. */
  async build(renderId: string): Promise<{ status: string }> {
    const render = await this.prisma.creativeDocumentRender.findUnique({
      where: { id: renderId },
      include: { document: true },
    });
    if (!render || (render.status !== 'QUEUED' && render.status !== 'PROCESSING')) {
      return { status: render?.status ?? 'MISSING' };
    }
    await this.prisma.creativeDocumentRender.update({
      where: { id: renderId },
      data: { status: 'PROCESSING' },
    });
    try {
      const doc = await this.compose(render.document);
      if (!doc) throw new Error('The profile is no longer available.');
      const pdf = await this.renderer.render(renderCvHtml(doc, new Date()));
      const key = `cv/${render.document.profileId}/${renderId}.pdf`;
      await this.storage.write('private', key, pdf, 'application/pdf');
      await this.prisma.creativeDocumentRender.update({
        where: { id: renderId },
        data: {
          status: 'READY',
          objectKey: key,
          sizeBytes: pdf.length,
          readyAt: new Date(),
          error: null,
        },
      });
      await this.pruneOld(render.documentId);
      return { status: 'READY' };
    } catch (e) {
      const unavailable = e instanceof PdfRendererUnavailableError;
      const message = unavailable
        ? 'PDF creation is not available right now. Please try again later.'
        : 'We could not create your PDF. Please try again.';
      this.log.error(`CV render ${renderId} failed: ${e instanceof Error ? e.message : String(e)}`);
      await this.prisma.creativeDocumentRender.update({
        where: { id: renderId },
        data: { status: 'FAILED', error: message },
      });
      return { status: 'FAILED' };
    }
  }

  private async pruneOld(documentId: string): Promise<void> {
    const old = await this.prisma.creativeDocumentRender.findMany({
      where: { documentId, status: 'READY' },
      orderBy: { requestedAt: 'desc' },
      skip: KEEP_RENDERS,
      select: { id: true, objectKey: true },
    });
    for (const r of old) {
      if (r.objectKey) await this.storage.remove('private', r.objectKey).catch(() => undefined);
      await this.prisma.creativeDocumentRender
        .delete({ where: { id: r.id } })
        .catch(() => undefined);
    }
  }

  /** The filtered, render-ready document for a stored configuration. */
  private async compose(row: CreativeDocument): Promise<CvDocument | null> {
    const src = await this.source.load(row.profileId);
    if (!src) return null;
    const marks = await this.source.verifiedMarks(row.profileId);
    return buildCvDocument(
      src,
      {
        format: row.format,
        sections: row.sections,
        projectIds: row.projectIds,
        restricted: row.restricted,
      },
      marks,
    );
  }

  // ---- share links ---------------------------------------------------------------------------------------------

  async createShare(
    userId: string,
    format: CreativeDocumentFormat,
    dto: CreateShareDto,
  ): Promise<CvShareCreatedDto> {
    const profile = await this.profileOf(userId);
    if (!profile.handle) {
      throw ApiException.invalidState('Choose your Atarah username before you share a link.');
    }
    const doc = await this.ensureDocument(profile.id, format);
    const active = await this.prisma.documentShareLink.count({
      where: {
        documentId: doc.id,
        revokedAt: null,
        OR: [{ expiresAt: null }, { expiresAt: { gt: new Date() } }],
      },
    });
    if (active >= 10) {
      throw ApiException.invalidState(
        'You have 10 active links for this document. Revoke one first.',
      );
    }
    const token = randomBytes(32).toString('base64url');
    const expiresAt = dto.expiresInDays
      ? new Date(Date.now() + dto.expiresInDays * 86_400_000)
      : null;
    const row = await this.prisma.documentShareLink.create({
      data: {
        documentId: doc.id,
        tokenHash: hashToken(token),
        tokenHint: token.slice(-4),
        expiresAt,
      },
    });
    this.analytics.track('cv_shared', { format }, userId);
    await this.audit.record({
      actorType: 'USER',
      actorId: userId,
      action: 'cv.share.create',
      entityType: 'document_share_link',
      entityId: row.id,
      after: { format, expiresAt },
    });
    return {
      ...this.shareDto(row, new Date()),
      url: `${this.config.appLinkBaseUrl}/${profile.handle}/cv/${token}`,
    };
  }

  async listShares(userId: string, format: CreativeDocumentFormat): Promise<CvShareDto[]> {
    const profile = await this.profileOf(userId);
    const doc = await this.documentRow(profile.id, format);
    if (!doc) return [];
    const rows = await this.prisma.documentShareLink.findMany({
      where: { documentId: doc.id },
      orderBy: { createdAt: 'desc' },
      take: 20,
    });
    const now = new Date();
    return rows.map((r) => this.shareDto(r, now));
  }

  async revokeShare(userId: string, shareId: string): Promise<CvShareDto> {
    const row = await this.prisma.documentShareLink.findFirst({
      where: { id: shareId, document: { profile: { userId } } },
      include: { document: { select: { format: true } } },
    });
    if (!row) throw ApiException.notFound('We could not find that link.');
    const updated = row.revokedAt
      ? row
      : await this.prisma.documentShareLink.update({
          where: { id: row.id },
          data: { revokedAt: new Date() },
        });
    if (!row.revokedAt) {
      await this.audit.record({
        actorType: 'USER',
        actorId: userId,
        action: 'cv.share.revoke',
        entityType: 'document_share_link',
        entityId: row.id,
        after: { format: row.document.format },
      });
    }
    return this.shareDto(updated, new Date());
  }

  private shareDto(s: DocumentShareLink, now: Date): CvShareDto {
    return {
      id: s.id,
      hint: s.tokenHint,
      createdAt: s.createdAt,
      expiresAt: s.expiresAt,
      revokedAt: s.revokedAt,
      status: s.revokedAt ? 'REVOKED' : s.expiresAt && s.expiresAt <= now ? 'EXPIRED' : 'ACTIVE',
    };
  }

  // ---- the public page -----------------------------------------------------------------------------------------

  /**
   * The HTML a share link opens, or null (the caller answers 404) when the token is unknown, revoked or expired, when
   * the handle does not belong to the document, or when the account is not active. The same answer for every reason,
   * so a visitor learns nothing about which links exist.
   */
  async publicPage(handle: string, token: string, now = new Date()): Promise<string | null> {
    if (!TOKEN_PATTERN.test(token)) return null;
    const link = await this.prisma.documentShareLink.findUnique({
      where: { tokenHash: hashToken(token) },
      include: { document: { include: { profile: { select: { handle: true } } } } },
    });
    if (!link || link.revokedAt) return null;
    if (link.expiresAt && link.expiresAt <= now) return null;
    if (link.document.profile.handle?.toLowerCase() !== handle.toLowerCase()) return null;
    const doc = await this.compose(link.document);
    if (!doc) return null;
    this.analytics.track('cv_viewed', { format: link.document.format }, null);
    return renderCvHtml(doc, now);
  }

  /** The page shown for every refused link. */
  static notFoundHtml(): string {
    return `<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><meta name="robots" content="noindex"><title>${esc('Link not found')}</title><style>body{font-family:Helvetica,Arial,sans-serif;color:#1c1a3a;display:grid;place-items:center;min-height:100vh;margin:0;text-align:center;padding:24px}h1{font-size:20px}p{color:#6a6888}</style></head><body><div><h1>This link is not available</h1><p>It may have expired or been turned off by its owner.</p></div></body></html>`;
  }
}

export type { ProfileSection };
