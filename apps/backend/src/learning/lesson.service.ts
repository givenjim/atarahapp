import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { ApiException } from '../common/api.exception';
import { DomainEventBus } from '../community-core/domain-events';
import { readBlocks } from '../content/blocks';
import { MediaService } from '../media/media.service';
import { PrismaService, type TxClient } from '../prisma/prisma.service';
import {
  type CertificateDto,
  type LessonDto,
  type LessonProgressBodyDto,
  type LessonVideoDto,
  type ProgressResultDto,
} from './learning.dto';
import {
  applyProgress,
  certificateNumber,
  certificateTitle,
  lessonStates,
  MAX_LESSON_SECONDS,
  minutesFor,
  nairobiDate,
  percentComplete,
} from './learning.rules';
import { LearningService } from './learning.service';
import { LearningViewsService } from './learning-views.service';

const MAX_SKILLS = 20;

/**
 * Lessons: reading one, playing its video, and writing progress. A member must be enrolled; in a sequential course a
 * lesson that is still locked cannot be opened or written to. Finishing the last lesson completes the course in one
 * transaction (certificate, achievement, skill source), then raises `CourseCompleted`.
 */
@Injectable()
export class LessonService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly learning: LearningService,
    private readonly views: LearningViewsService,
    private readonly media: MediaService,
    private readonly bus: DomainEventBus,
  ) {}

  /** Loads a lesson with its course and the viewer's progress, and enforces access, enrolment and locking. */
  private async open(userId: string, lessonId: string, opts: { allowLocked?: boolean } = {}) {
    const lesson = await this.prisma.lesson.findUnique({
      where: { id: lessonId },
      include: {
        practiceSkill: { select: { id: true, name: true } },
        course: { include: { content: true, lessons: { orderBy: { sequence: 'asc' } } } },
      },
    });
    // The course must be visible to this member (published, or one they are already on).
    if (!lesson) throw ApiException.notFound('That lesson does not exist.');
    await this.learning.findVisible(userId, lesson.courseId);
    await this.learning.assertAccess(userId, lesson.course.content.access);
    const enrolment = await this.prisma.enrolment.findUnique({
      where: { userId_courseId: { userId, courseId: lesson.courseId } },
    });
    if (!enrolment) throw ApiException.invalidState('Enrol in this course to open its lessons.');
    const progress = await this.prisma.lessonProgress.findMany({
      where: { userId, lessonId: { in: lesson.course.lessons.map((l) => l.id) } },
    });
    const done = new Set(progress.filter((p) => p.status === 'COMPLETED').map((p) => p.lessonId));
    const states = lessonStates(lesson.course.lessons, done, lesson.course.sequential);
    if (!opts.allowLocked && states.get(lesson.id) === 'LOCKED') {
      throw ApiException.invalidState('Finish the earlier lessons to unlock this one.', {
        reason: 'LOCKED',
      });
    }
    return { lesson, enrolment, progress, done, states };
  }

  async get(userId: string, lessonId: string): Promise<LessonDto> {
    const { lesson, progress, done, states } = await this.open(userId, lessonId);
    const lessons = lesson.course.lessons;
    const idx = lessons.findIndex((l) => l.id === lesson.id);
    const mine = progress.find((p) => p.lessonId === lesson.id);
    const body = await Promise.all(
      readBlocks(lesson.body).map(async (b) => ({
        type: b.type,
        text: 'text' in b ? b.text : null,
        title: b.type === 'callout' ? b.title : null,
        imageUrl: b.type === 'image' ? await this.media.imageUrl(b.mediaId, 1200) : null,
        caption: b.type === 'image' ? b.caption : null,
        attribution: b.type === 'quote' ? b.attribution : null,
      })),
    );
    return {
      id: lesson.id,
      courseId: lesson.courseId,
      courseTitle: lesson.course.content.title,
      sequence: lesson.sequence,
      lessonCount: lessons.length,
      title: lesson.title,
      durationMinutes: lesson.durationMinutes,
      body,
      practice: lesson.practicePrompt
        ? { prompt: lesson.practicePrompt, skill: lesson.practiceSkill }
        : null,
      hasVideo: lesson.videoMediaId !== null,
      embedUrl: lesson.embedUrl,
      progress: {
        status: mine?.status ?? 'NOT_STARTED',
        lastPositionSeconds: mine?.lastPositionSeconds ?? 0,
        completedAt: mine?.completedAt ?? null,
      },
      state: states.get(lesson.id)!,
      previousLessonId: lessons[idx - 1]?.id ?? null,
      nextLessonId: lessons[idx + 1]?.id ?? null,
      segments: lessons.map((l) => done.has(l.id)),
    };
  }

  /** The signed address of the lesson's video. Same checks as reading the lesson, premium included. */
  async video(userId: string, lessonId: string): Promise<LessonVideoDto> {
    const { lesson } = await this.open(userId, lessonId);
    if (!lesson.videoMediaId) throw ApiException.notFound('This lesson has no video.');
    const play = await this.media.playback(lesson.videoMediaId);
    if (!play)
      throw ApiException.invalidState('The video is still being prepared. Try again in a moment.');
    return play;
  }

  // ---- progress -----------------------------------------------------------------------------------------------

  async progress(
    userId: string,
    lessonId: string,
    dto: LessonProgressBodyDto,
    now = new Date(),
  ): Promise<ProgressResultDto> {
    const { lesson } = await this.open(userId, lessonId);
    const courseId = lesson.courseId;
    const lessonCount = lesson.course.lessons.length;
    const maxSeconds = Math.max(lesson.durationMinutes * 60 * 2, MAX_LESSON_SECONDS);

    const outcome = await this.prisma.$transaction(async (tx) => {
      // Make sure the row exists, then lock it so two writes cannot interleave.
      await tx.lessonProgress.upsert({
        where: { userId_lessonId: { userId, lessonId } },
        create: { userId, lessonId },
        update: {},
      });
      await tx.$queryRaw`SELECT id FROM lesson_progress WHERE "userId" = ${userId}::uuid AND "lessonId" = ${lessonId}::uuid FOR UPDATE`;
      const prev = await tx.lessonProgress.findUniqueOrThrow({
        where: { userId_lessonId: { userId, lessonId } },
      });
      const next = applyProgress(prev, dto, now, maxSeconds);
      const row = await tx.lessonProgress.update({
        where: { userId_lessonId: { userId, lessonId } },
        data: {
          status: next.status,
          lastPositionSeconds: next.lastPositionSeconds,
          completedAt: next.completedAt,
        },
      });
      let minutes = minutesFor(next.advancedSeconds);
      // Finishing a lesson counts its length once (the member may have skipped ahead in the player).
      if (next.newlyCompleted) minutes = Math.max(minutes, lesson.durationMinutes);
      await this.learning.addMinutes(tx, userId, minutes, now);

      const done = await tx.lessonProgress.count({
        where: { userId, status: 'COMPLETED', lesson: { courseId } },
      });
      let certificate: CertificateDto | null = null;
      let certificateId: string | null = null;
      const finished = next.status === 'COMPLETED' && done >= lessonCount && lessonCount > 0;
      if (finished) {
        const issued = await this.completeCourse(tx, userId, courseId, now);
        certificate = issued.dto;
        certificateId = issued.newlyIssued ? issued.id : null;
      }
      return { row, next, done, certificate, certificateId };
    });

    if (outcome.next.newlyCompleted) {
      await this.bus.emit({ type: 'LessonCompleted', userId, courseId, lessonId });
    }
    if (outcome.certificateId) {
      await this.bus.emit({
        type: 'CourseCompleted',
        userId,
        courseId,
        certificateId: outcome.certificateId,
      });
    }
    const lessons = lesson.course.lessons;
    const idx = lessons.findIndex((l) => l.id === lessonId);
    return {
      progress: {
        status: outcome.row.status,
        lastPositionSeconds: outcome.row.lastPositionSeconds,
        completedAt: outcome.row.completedAt,
      },
      courseCompleted: outcome.certificate !== null,
      percent: percentComplete(outcome.done, lessonCount),
      nextLessonId: lessons[idx + 1]?.id ?? null,
      certificate: outcome.certificate,
    };
  }

  /**
   * One transaction: certificate (once), the Achievement "Atarah Skill Lab certificate · {month year}", the skills the
   * course teaches moved to source LEARNING, and the enrolment closed. Running it again returns the same certificate and
   * writes nothing more.
   */
  async completeCourse(
    tx: TxClient,
    userId: string,
    courseId: string,
    now: Date,
  ): Promise<{ id: string; dto: CertificateDto; newlyIssued: boolean }> {
    const existing = await tx.certificate.findUnique({
      where: { userId_courseId: { userId, courseId } },
    });
    if (existing) {
      return {
        id: existing.id,
        newlyIssued: false,
        dto: {
          certificateNumber: existing.certificateNumber,
          issuedAt: existing.issuedAt,
          achievementId: existing.achievementId,
        },
      };
    }
    const content = await tx.learningContent.findUniqueOrThrow({
      where: { id: courseId },
      include: { skills: { select: { skillId: true } } },
    });
    const [seq] = await tx.$queryRaw<Array<{ n: bigint }>>(
      Prisma.sql`SELECT nextval('certificate_number_seq') AS n`,
    );
    const number = certificateNumber(nairobiDate(now).getUTCFullYear(), Number(seq!.n));

    const profile = await tx.creativeProfile.findUnique({
      where: { userId },
      select: { id: true },
    });
    let achievementId: string | null = null;
    if (profile) {
      const achievement = await tx.achievement.create({
        data: {
          profileId: profile.id,
          type: 'CERTIFICATE',
          title: certificateTitle(now),
          issuer: content.providerName ?? 'Atarah',
          achievedOn: nairobiDate(now),
          description: content.title,
          source: 'SYSTEM',
        },
      });
      achievementId = achievement.id;

      const have = await tx.creativeSkill.findMany({
        where: { profileId: profile.id },
        select: { skillId: true, source: true },
      });
      const haveIds = new Map(have.map((h) => [h.skillId, h.source]));
      let count = have.length;
      for (const { skillId } of content.skills) {
        const source = haveIds.get(skillId);
        if (source === 'SELF_DECLARED') {
          await tx.creativeSkill.update({
            where: { profileId_skillId: { profileId: profile.id, skillId } },
            data: { source: 'LEARNING' },
          });
        } else if (source === undefined && count < MAX_SKILLS) {
          await tx.creativeSkill.create({
            data: { profileId: profile.id, skillId, source: 'LEARNING' },
          });
          count += 1;
        }
        // A VERIFIED skill stays verified.
      }
    }
    const cert = await tx.certificate.create({
      data: { userId, courseId, certificateNumber: number, issuedAt: now, achievementId },
    });
    await tx.enrolment.updateMany({
      where: { userId, courseId, completedAt: null },
      data: { completedAt: now },
    });
    return {
      id: cert.id,
      newlyIssued: true,
      dto: { certificateNumber: cert.certificateNumber, issuedAt: cert.issuedAt, achievementId },
    };
  }
}
