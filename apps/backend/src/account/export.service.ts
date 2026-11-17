import { randomUUID } from 'node:crypto';
import { InjectQueue } from '@nestjs/bullmq';
import { Injectable, Logger } from '@nestjs/common';
import { type StorageBucket } from '@prisma/client';
import { type Queue } from 'bullmq';
import { ApiException } from '../common/api.exception';
import { ErrorCode } from '../common/error-codes';
import { NotificationsService } from '../notifications/notifications.service';
import { PrismaService } from '../prisma/prisma.service';
import { type BucketKind, StorageService } from '../storage/storage.service';
import { type ExportStateDto } from './account.dto';
import { zip, type ZipEntry } from './zip';

export const EXPORT_JOB = 'account-export-build';
/** One export per member per 24 hours. */
export const EXPORT_COOLDOWN_MS = 24 * 3_600_000;
/** The link works for 7 days. */
export const EXPORT_LINK_DAYS = 7;
/** The archive is built in memory, so it is bounded: files beyond these limits are listed but not included. */
const MAX_FILE_BYTES = 25 * 1024 * 1024;
const MAX_TOTAL_BYTES = 150 * 1024 * 1024;

const bucketKind = (b: StorageBucket): BucketKind =>
  b === 'PUBLIC' ? 'public' : b === 'PRIVATE' ? 'private' : 'evidence';

/** JSON with bigint and date support (Prisma returns both). */
const json = (v: unknown): Buffer =>
  Buffer.from(
    JSON.stringify(v, (_k, x) => (typeof x === 'bigint' ? x.toString() : x), 2),
    'utf8',
  );

const EXT: Record<string, string> = {
  'image/jpeg': 'jpg',
  'image/png': 'png',
  'image/webp': 'webp',
  'video/mp4': 'mp4',
  'video/quicktime': 'mov',
  'video/webm': 'webm',
  'audio/mpeg': 'mp3',
  'application/pdf': 'pdf',
};

/**
 * "Download my data" (P1-M11). A request is queued and a worker job builds one ZIP: a JSON file for every kind of
 * personal record the member owns, plus their uploaded pictures and files. The ZIP is stored privately (as a media asset
 * the member owns) and the member is told with a signed link that works for 7 days. One export per 24 hours.
 */
@Injectable()
export class ExportService {
  private readonly log = new Logger(ExportService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly storage: StorageService,
    private readonly notifications: NotificationsService,
    @InjectQueue('maintenance') private readonly queue: Queue,
  ) {}

  // ---- the member's side -----------------------------------------------------------------------------------

  async request(userId: string, now = new Date()): Promise<ExportStateDto> {
    const last = await this.prisma.dataExportRequest.findFirst({
      where: { userId },
      orderBy: { requestedAt: 'desc' },
    });
    if (
      last &&
      now.getTime() - last.requestedAt.getTime() < EXPORT_COOLDOWN_MS &&
      last.status !== 'FAILED'
    ) {
      throw new ApiException(
        ErrorCode.RATE_LIMITED,
        'You can ask for your data once a day. Your last request is below.',
        429,
        { nextAllowedAt: new Date(last.requestedAt.getTime() + EXPORT_COOLDOWN_MS) },
      );
    }
    const row = await this.prisma.dataExportRequest.create({ data: { userId } });
    await this.queue.add(EXPORT_JOB, { requestId: row.id }, { jobId: `export-${row.id}` });
    return this.state(userId, now);
  }

  /** The latest request, with a fresh signed link while it is ready and not expired. */
  async state(userId: string, now = new Date()): Promise<ExportStateDto> {
    const r = await this.prisma.dataExportRequest.findFirst({
      where: { userId },
      orderBy: { requestedAt: 'desc' },
      include: { fileMedia: true },
    });
    if (!r) {
      return {
        status: 'NONE',
        id: null,
        requestedAt: null,
        expiresAt: null,
        downloadUrl: null,
        nextAllowedAt: null,
      };
    }
    const expired = r.status === 'READY' && r.expiresAt !== null && r.expiresAt <= now;
    let downloadUrl: string | null = null;
    if (r.status === 'READY' && !expired && r.fileMedia && r.expiresAt) {
      const seconds = Math.max(60, Math.floor((r.expiresAt.getTime() - now.getTime()) / 1000));
      downloadUrl = await this.storage.signedDownloadUrl(
        bucketKind(r.fileMedia.bucket),
        r.fileMedia.objectKey,
        Math.min(seconds, EXPORT_LINK_DAYS * 86_400),
      );
    }
    return {
      status: expired ? 'EXPIRED' : r.status,
      id: r.id,
      requestedAt: r.requestedAt,
      expiresAt: r.expiresAt,
      downloadUrl,
      nextAllowedAt:
        r.status === 'FAILED' ? null : new Date(r.requestedAt.getTime() + EXPORT_COOLDOWN_MS),
    };
  }

  // ---- the worker's side -----------------------------------------------------------------------------------

  /** Builds the archive for one request. Safe to run again: a finished request is left alone. */
  async build(requestId: string, now = new Date()): Promise<{ status: string; files: number }> {
    const req = await this.prisma.dataExportRequest.findUnique({ where: { id: requestId } });
    if (!req || (req.status !== 'QUEUED' && req.status !== 'PROCESSING')) {
      return { status: req?.status ?? 'MISSING', files: 0 };
    }
    await this.prisma.dataExportRequest.update({
      where: { id: requestId },
      data: { status: 'PROCESSING' },
    });
    try {
      const { entries, files } = await this.collect(req.userId, now);
      const archive = zip(entries);
      const assetId = randomUUID();
      const key = `exports/${req.userId}/${requestId}.zip`;
      await this.storage.write('private', key, archive, 'application/zip');
      const expiresAt = new Date(now.getTime() + EXPORT_LINK_DAYS * 86_400_000);
      await this.prisma.$transaction(async (tx) => {
        await tx.mediaAsset.create({
          data: {
            id: assetId,
            ownerId: req.userId,
            kind: 'DOCUMENT',
            bucket: 'PRIVATE',
            objectKey: key,
            mimeType: 'application/zip',
            sizeBytes: BigInt(archive.length),
            status: 'READY',
          },
        });
        await tx.dataExportRequest.update({
          where: { id: requestId },
          data: { status: 'READY', fileMediaId: assetId, readyAt: now, expiresAt, error: null },
        });
      });
      const link = await this.storage.signedDownloadUrl('private', key, EXPORT_LINK_DAYS * 86_400);
      await this.notifications.notify({
        userId: req.userId,
        category: 'SYSTEM',
        type: 'account.export_ready',
        title: 'Your data export is ready',
        body: `Download your data within 7 days: ${link}`,
        deepLink: '/settings/privacy',
        critical: true,
      });
      return { status: 'READY', files };
    } catch (e) {
      const message = e instanceof Error ? e.message : String(e);
      this.log.error(`Export ${requestId} failed: ${message}`);
      await this.prisma.dataExportRequest.update({
        where: { id: requestId },
        data: { status: 'FAILED', error: message.slice(0, 300) },
      });
      throw e;
    }
  }

  /** Daily: links older than 7 days stop working. The file is deleted and the request becomes EXPIRED. */
  async expireOld(now = new Date()): Promise<number> {
    const old = await this.prisma.dataExportRequest.findMany({
      where: { status: 'READY', expiresAt: { lte: now } },
      include: { fileMedia: true },
    });
    for (const r of old) {
      if (r.fileMedia) {
        await this.storage
          .remove(bucketKind(r.fileMedia.bucket), r.fileMedia.objectKey)
          .catch(() => undefined);
        await this.prisma.mediaAsset
          .delete({ where: { id: r.fileMedia.id } })
          .catch(() => undefined);
      }
      await this.prisma.dataExportRequest.update({
        where: { id: r.id },
        data: { status: 'EXPIRED', fileMediaId: null },
      });
    }
    return old.length;
  }

  /** Queued requests nobody picked up (a lost job): put them back on the queue. */
  async requeueStuck(now = new Date()): Promise<number> {
    const stuck = await this.prisma.dataExportRequest.findMany({
      where: {
        OR: [
          { status: 'QUEUED', requestedAt: { lt: new Date(now.getTime() - 10 * 60_000) } },
          { status: 'PROCESSING', requestedAt: { lt: new Date(now.getTime() - 60 * 60_000) } },
        ],
      },
      select: { id: true },
      take: 20,
    });
    for (const s of stuck) {
      await this.prisma.dataExportRequest.update({
        where: { id: s.id },
        data: { status: 'QUEUED' },
      });
      await this.queue.add(
        EXPORT_JOB,
        { requestId: s.id },
        { jobId: `export-${s.id}-${now.getTime()}` },
      );
    }
    return stuck.length;
  }

  // ---- what goes in the archive ----------------------------------------------------------------------------

  private async collect(
    userId: string,
    now: Date,
  ): Promise<{ entries: ZipEntry[]; files: number }> {
    const p = this.prisma;
    const profile = await p.creativeProfile.findUnique({ where: { userId } });
    const pid = profile?.id ?? '00000000-0000-0000-0000-000000000000';

    const [
      user,
      prefs,
      notifPrefs,
      consents,
      devices,
      links,
      disciplines,
      specialisations,
      skills,
      interests,
      development,
      sectionVis,
      passport,
      fieldVis,
      projects,
      experience,
      achievements,
      services,
      connections,
      posts,
      comments,
      reactions,
      saved,
      mutes,
      blocks,
      reports,
      trackings,
      enrolments,
      lessonProgress,
      contentProgress,
      certificates,
      learningActivity,
      notifications,
      exports,
      mediaAssets,
    ] = await Promise.all([
      p.user.findUnique({
        where: { id: userId },
        select: {
          id: true,
          fullName: true,
          email: true,
          phone: true,
          status: true,
          createdAt: true,
          emailVerifiedAt: true,
          phoneVerifiedAt: true,
        },
      }),
      p.memberPreference.findUnique({ where: { userId } }),
      p.notificationPreference.findMany({ where: { userId } }),
      p.consentRecord.findMany({ where: { userId } }),
      p.userDevice.findMany({
        where: { userId },
        select: { name: true, platform: true, createdAt: true, lastSeenAt: true },
      }),
      p.profileLink.findMany({ where: { profileId: pid } }),
      p.creativeDiscipline.findMany({
        where: { profileId: pid },
        include: { discipline: { select: { name: true } } },
      }),
      p.creativeSpecialisation.findMany({
        where: { profileId: pid },
        include: { specialisation: { select: { name: true } } },
      }),
      p.creativeSkill.findMany({
        where: { profileId: pid },
        include: { skill: { select: { name: true } } },
      }),
      p.creativeInterest.findMany({
        where: { profileId: pid },
        include: { interest: { select: { name: true } } },
      }),
      p.creativeDevelopmentArea.findMany({
        where: { profileId: pid },
        include: { developmentArea: { select: { name: true } } },
      }),
      p.profileSectionVisibility.findMany({ where: { profileId: pid } }),
      p.creativePassport.findUnique({ where: { profileId: pid } }),
      p.profileFieldVisibility.findMany({ where: { userId } }),
      p.project.findMany({
        where: { profileId: pid, deletedAt: null },
        include: { media: true, skills: true, links: true, collaborators: true },
      }),
      p.experience.findMany({ where: { profileId: pid } }),
      p.achievement.findMany({ where: { profileId: pid } }),
      p.profileService.findMany({ where: { profileId: pid } }),
      p.connection.findMany({
        where: { OR: [{ requesterId: userId }, { addresseeId: userId }] },
        select: {
          status: true,
          createdAt: true,
          requester: {
            select: { creativeProfile: { select: { handle: true, displayName: true } } },
          },
          addressee: {
            select: { creativeProfile: { select: { handle: true, displayName: true } } },
          },
        },
      }),
      p.post.findMany({ where: { authorId: userId, deletedAt: null }, include: { link: true } }),
      p.comment.findMany({ where: { authorId: userId, deletedAt: null } }),
      p.reaction.findMany({ where: { userId }, select: { postId: true, createdAt: true } }),
      p.savedItem.findMany({ where: { userId } }),
      p.mute.findMany({ where: { userId } }),
      p.block.findMany({
        where: { blockerId: userId },
        select: { blockedId: true, createdAt: true },
      }),
      p.report.findMany({
        where: { reporterId: userId },
        select: { targetType: true, reason: true, status: true, createdAt: true },
      }),
      p.opportunityTracking.findMany({
        where: { userId },
        include: { opportunity: { select: { title: true } } },
      }),
      p.enrolment.findMany({ where: { userId } }),
      p.lessonProgress.findMany({ where: { userId } }),
      p.contentProgress.findMany({ where: { userId } }),
      p.certificate.findMany({ where: { userId } }),
      p.learningActivityDaily.findMany({ where: { userId } }),
      p.notification.findMany({ where: { userId }, orderBy: { createdAt: 'desc' }, take: 1000 }),
      p.dataExportRequest.findMany({
        where: { userId },
        select: { requestedAt: true, status: true },
      }),
      p.mediaAsset.findMany({
        where: {
          ownerId: userId,
          status: 'READY',
          deletedAt: null,
          bucket: { in: ['PUBLIC', 'PRIVATE'] },
          NOT: { objectKey: { startsWith: 'exports/' } },
        },
      }),
    ]);

    const when = now;
    const entry = (name: string, data: unknown): ZipEntry => ({
      name,
      data: json(data),
      modified: when,
    });
    const entries: ZipEntry[] = [
      entry('account.json', {
        user,
        preferences: prefs,
        notificationPreferences: notifPrefs,
        consents,
        devices,
      }),
      entry('profile.json', {
        profile,
        links,
        disciplines,
        specialisations,
        skills,
        interests,
        developmentAreas: development,
        sectionVisibility: sectionVis,
        fieldVisibility: fieldVis,
        passport,
      }),
      entry('portfolio.json', { projects, experience, achievements, services }),
      entry('community.json', {
        connections,
        posts,
        comments,
        reactions,
        mutes,
        blocksMade: blocks,
        reportsMade: reports,
      }),
      entry('saved.json', { saved, opportunityTrackings: trackings }),
      entry('learning.json', {
        enrolments,
        lessonProgress,
        contentProgress,
        certificates,
        activity: learningActivity,
      }),
      entry('notifications.json', notifications),
      entry('exports.json', exports),
    ];

    // The member's own pictures and files, within the size limits; anything left out is listed in the manifest.
    const skipped: Array<{ id: string; reason: string }> = [];
    let total = 0;
    let files = 0;
    for (const m of mediaAssets) {
      const size = Number(m.sizeBytes);
      if (size > MAX_FILE_BYTES || total + size > MAX_TOTAL_BYTES) {
        skipped.push({ id: m.id, reason: 'too large to include' });
        continue;
      }
      try {
        const data = await this.storage.read(bucketKind(m.bucket), m.objectKey);
        total += data.length;
        files += 1;
        entries.push({
          name: `media/${m.id}.${EXT[m.mimeType] ?? 'bin'}`,
          data,
          modified: m.createdAt,
        });
      } catch {
        skipped.push({ id: m.id, reason: 'could not be read' });
      }
    }
    entries.push(
      entry('README.json', {
        generatedAt: now.toISOString(),
        about:
          'Your personal data from Atarah. Each JSON file lists one kind of record; pictures and files are in media/.',
        mediaIncluded: files,
        mediaSkipped: skipped,
      }),
    );
    return { entries, files };
  }
}
