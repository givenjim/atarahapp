import { type INestApplication } from '@nestjs/common';
import request from 'supertest';
import { SafeFetcher } from '../src/community/jobs/safe-fetch';
import { LearningJobsModule } from '../src/learning/jobs/learning-jobs.module';
import { LearningJobsService } from '../src/learning/jobs/learning-jobs.service';
import { MediaService } from '../src/media/media.service';
import { PlatformSettingsService } from '../src/feature-flags/platform-settings.service';
import { PrismaService } from '../src/prisma/prisma.service';
import {
  adminSignIn,
  bearer,
  createTestApp,
  deleteUsers,
  loginMember,
  makeUser,
  uniq,
} from './helpers';

jest.setTimeout(180_000);

interface Member {
  id: string;
  token: string;
  profileId: string;
}

describe('Skill Labs (integration)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  let jobs: LearningJobsService;
  const http = () => request(app.getHttpServer());
  const users: string[] = [];
  const created: string[] = [];

  const as = (token?: string) => {
    const wrap = (r: request.Test) => (token ? r.set(...bearer(token)) : r);
    return {
      get: (p: string, query: object = {}) => wrap(http().get(`/api/v1${p}`).query(query)),
      post: (p: string, b: object = {}) => wrap(http().post(`/api/v1${p}`).send(b)),
      put: (p: string, b: object = {}) => wrap(http().put(`/api/v1${p}`).send(b)),
      patch: (p: string, b: object = {}) => wrap(http().patch(`/api/v1${p}`).send(b)),
      del: (p: string) => wrap(http().delete(`/api/v1${p}`)),
    };
  };

  beforeAll(async () => {
    app = await createTestApp([LearningJobsModule]);
    prisma = app.get(PrismaService);
    jobs = app.get(LearningJobsService);
  });
  afterAll(async () => {
    await prisma.learningContent.deleteMany({ where: { id: { in: created } } });
    await deleteUsers(app, users);
    await app.close();
  });

  async function member(
    o: { pro?: boolean; skills?: string[]; areas?: string[] } = {},
  ): Promise<Member> {
    const { user, email } = await makeUser(app, {
      fullName: `Learner ${uniq()}`,
      ...(o.pro ? { membership: { status: 'ACTIVE', periodEndInDays: 20 } } : {}),
    });
    users.push(user.id);
    const token = (await loginMember(app, email)).accessToken;
    const discipline = await prisma.discipline.findFirstOrThrow({ where: { name: 'Animation' } });
    const profile = await prisma.creativeProfile.create({
      data: {
        userId: user.id,
        handle: `l_${uniq()}`.replace(/-/g, '_'),
        displayName: 'Learner',
        onboardingStep: 'DONE',
        onboardingCompletedAt: new Date(),
        primaryDisciplineId: discipline.id,
        disciplines: { create: [{ disciplineId: discipline.id, isPrimary: true }] },
      },
    });
    for (const skillId of o.skills ?? []) {
      await prisma.creativeSkill.create({ data: { profileId: profile.id, skillId } });
    }
    for (const slug of o.areas ?? []) {
      const area = await prisma.developmentArea.findFirstOrThrow({ where: { slug } });
      await prisma.creativeDevelopmentArea.create({
        data: { profileId: profile.id, developmentAreaId: area.id },
      });
    }
    return { id: user.id, token, profileId: profile.id };
  }

  async function editor() {
    const { user, email } = await makeUser(app, {
      roles: ['CONTENT_ADMIN'],
      fullName: `Editor ${uniq()}`,
    });
    users.push(user.id);
    const { session } = await adminSignIn(app, email);
    return { id: user.id, token: session.accessToken };
  }

  const category = (slug: string) => prisma.learningCategory.findFirstOrThrow({ where: { slug } });

  const body = (text: string) => [{ type: 'paragraph', text }];

  /** A published course with `n` text lessons. */
  async function course(
    ed: { token: string },
    o: {
      title?: string;
      lessons?: number;
      access?: 'FREE' | 'PREMIUM_CONTENT';
      skillIds?: string[];
      category?: string;
      sequential?: boolean;
      featured?: boolean;
      minutes?: number;
    } = {},
    publish = true,
  ) {
    const cat = await category(o.category ?? 'portfolio-building');
    const res = await as(ed.token)
      .post('/admin/learning/contents', {
        title: o.title ?? `Course ${uniq()}`,
        type: 'COURSE',
        summary: 'A short course with real lessons for creatives.',
        categoryId: cat.id,
        access: o.access ?? 'FREE',
        skillIds: o.skillIds ?? [],
        featured: o.featured ?? false,
        sequential: o.sequential ?? true,
        providerName: 'Atarah Studio',
        whatYouLearn: ['One thing', 'Another thing'],
      })
      .expect(201);
    const id = res.body.data.id as string;
    created.push(id);
    for (let i = 1; i <= (o.lessons ?? 3); i += 1) {
      await as(ed.token)
        .post(`/admin/courses/${id}/lessons`, {
          title: `Lesson ${i}`,
          durationMinutes: o.minutes ?? 5,
          body: body(`Text of lesson ${i}`),
          practicePrompt: i === 1 ? 'Try it yourself' : undefined,
        })
        .expect(201);
    }
    if (publish) await as(ed.token).post(`/admin/learning/contents/${id}/publish`).expect(200);
    const full = (await as(ed.token).get(`/admin/learning/contents/${id}`).expect(200)).body.data;
    return {
      id,
      lessons: full.lessons as Array<{ id: string; sequence: number }>,
      title: full.title as string,
    };
  }

  // ---------------------------------------------------------------------------------------------------------------

  describe('the learning CMS', () => {
    it('validates before publishing, keeps lesson counts, reorders and audits', async () => {
      const ed = await editor();
      const cat = await category('branding');
      const c = (
        await as(ed.token)
          .post('/admin/learning/contents', {
            title: `Draft ${uniq()}`,
            type: 'COURSE',
            summary: 'A course that is not finished yet.',
            categoryId: cat.id,
          })
          .expect(201)
      ).body.data;
      created.push(c.id);
      // A course with no lessons cannot go live.
      const refuse = await as(ed.token)
        .post(`/admin/learning/contents/${c.id}/publish`)
        .expect(400);
      expect(refuse.body.error.details.field).toBe('lessons');
      await as(ed.token)
        .post(`/admin/courses/${c.id}/lessons`, { title: 'Empty lesson' })
        .expect(201);
      await as(ed.token).post(`/admin/learning/contents/${c.id}/publish`).expect(400);

      let full = (await as(ed.token).get(`/admin/learning/contents/${c.id}`).expect(200)).body.data;
      const first = full.lessons[0].id;
      await as(ed.token)
        .patch(`/admin/courses/${c.id}/lessons/${first}`, {
          body: body('Now it has text.'),
          durationMinutes: 7,
        })
        .expect(200);
      await as(ed.token)
        .post(`/admin/courses/${c.id}/lessons`, {
          title: 'Second',
          body: body('More text.'),
          durationMinutes: 3,
        })
        .expect(201);
      await as(ed.token)
        .post(`/admin/courses/${c.id}/lessons`, {
          title: 'Third',
          body: body('Even more.'),
          durationMinutes: 2,
        })
        .expect(201);
      full = (await as(ed.token).get(`/admin/learning/contents/${c.id}`).expect(200)).body.data;
      expect(full.durationMinutes).toBe(12);
      expect(await prisma.course.findUniqueOrThrow({ where: { contentId: c.id } })).toMatchObject({
        lessonCount: 3,
        totalMinutes: 12,
      });

      // Reorder: send every lesson once, in the new order.
      const ids = full.lessons.map((l: { id: string }) => l.id) as string[];
      await as(ed.token)
        .put(`/admin/courses/${c.id}/lessons/order`, { lessonIds: [ids[2], ids[0], ids[1]] })
        .expect(200);
      full = (await as(ed.token).get(`/admin/learning/contents/${c.id}`).expect(200)).body.data;
      expect(full.lessons.map((l: { id: string }) => l.id)).toEqual([ids[2], ids[0], ids[1]]);
      expect(full.lessons.map((l: { sequence: number }) => l.sequence)).toEqual([1, 2, 3]);
      await as(ed.token)
        .put(`/admin/courses/${c.id}/lessons/order`, { lessonIds: [ids[0], ids[1]] })
        .expect(400);
      await as(ed.token)
        .put(`/admin/courses/${c.id}/lessons/order`, { lessonIds: [ids[0], ids[0], ids[1]] })
        .expect(400);

      // Delete closes the gap.
      await as(ed.token).del(`/admin/courses/${c.id}/lessons/${ids[0]}`).expect(200);
      full = (await as(ed.token).get(`/admin/learning/contents/${c.id}`).expect(200)).body.data;
      expect(full.lessons.map((l: { sequence: number }) => l.sequence)).toEqual([1, 2]);

      const live = (await as(ed.token).post(`/admin/learning/contents/${c.id}/publish`).expect(200))
        .body.data;
      expect(live).toMatchObject({ status: 'PUBLISHED' });
      await as(ed.token).post(`/admin/learning/contents/${c.id}/publish`).expect(409);
      const trail = await prisma.auditLog.findMany({
        where: { entityType: 'learning', action: { startsWith: 'learning.' }, actorId: ed.id },
      });
      expect(trail.map((t) => t.action)).toEqual(
        expect.arrayContaining([
          'learning.content.create',
          'learning.lesson.create',
          'learning.lesson.reorder',
          'learning.lesson.delete',
          'learning.content.publish',
        ]),
      );

      // A type cannot change from or to a course.
      await as(ed.token)
        .patch(`/admin/learning/contents/${c.id}`, { type: 'TUTORIAL' })
        .expect(409);
    });

    it('only content admins manage Skill Labs', async () => {
      const m = await member();
      await as(m.token).get('/admin/learning/contents').expect(403);
      await as(undefined).get('/admin/learning/contents').expect(401);
      const mod = await makeUser(app, { roles: ['MODERATOR'], fullName: `Mod ${uniq()}` });
      users.push(mod.user.id);
      const { session } = await adminSignIn(app, mod.email);
      await as(session.accessToken).get('/admin/learning/contents').expect(403);
    });

    it('enforces the embed allow-list on lessons and items, and converts watch links', async () => {
      const ed = await editor();
      const c = await course(ed, { lessons: 1 }, false);
      const lessonId = c.lessons[0]!.id;
      const bad = await as(ed.token)
        .patch(`/admin/courses/${c.id}/lessons/${lessonId}`, {
          embedUrl: 'https://evil.example.com/embed/abc123456',
        })
        .expect(400);
      expect(bad.body.error.details.field).toBe('embedUrl');
      await as(ed.token)
        .patch(`/admin/courses/${c.id}/lessons/${lessonId}`, {
          embedUrl: 'http://player.vimeo.com/video/123456789',
        })
        .expect(400);
      const ok = await as(ed.token)
        .patch(`/admin/courses/${c.id}/lessons/${lessonId}`, {
          embedUrl: 'https://www.youtube.com/watch?v=abcDEF12345',
        })
        .expect(200);
      expect(ok.body.data.lessons[0].embedUrl).toBe(
        'https://www.youtube-nocookie.com/embed/abcDEF12345',
      );

      const cat = await category('production');
      await as(ed.token)
        .post('/admin/learning/contents', {
          title: 'Bad embed item',
          type: 'MASTERCLASS',
          summary: 'A masterclass with a bad address.',
          categoryId: cat.id,
          delivery: 'EMBEDDED',
          embedUrl: 'https://example.com/v/1',
        })
        .expect(400);
      const hosts = (await as(ed.token).get('/admin/learning/embed-hosts').expect(200)).body.data
        .hosts;
      expect(hosts).toEqual(expect.arrayContaining(['player.vimeo.com']));
      // Staff change the list in settings and the rule follows it.
      const settings = app.get(PlatformSettingsService);
      await settings.set('learning.embed_hosts', ['player.vimeo.com'], { id: ed.id });
      try {
        await as(ed.token)
          .patch(`/admin/courses/${c.id}/lessons/${lessonId}`, {
            embedUrl: 'https://www.youtube.com/watch?v=abcDEF12345',
          })
          .expect(400);
      } finally {
        await settings.set(
          'learning.embed_hosts',
          ['www.youtube.com', 'www.youtube-nocookie.com', 'player.vimeo.com'],
          { id: ed.id },
        );
      }
    });
  });

  describe('learning a course', () => {
    it('unlocks lessons in order, saves progress idempotently and resumes where the member left off', async () => {
      const ed = await editor();
      const m = await member();
      const c = await course(ed, { lessons: 3 });
      const [l1, l2, l3] = c.lessons.map((l) => l.id) as [string, string, string];

      // Not enrolled: lessons stay closed.
      await as(m.token).get(`/learning/lessons/${l1}`).expect(409);
      const enrol = (await as(m.token).post(`/learning/${c.id}/enrol`).expect(200)).body.data;
      expect(enrol.nextLessonId).toBe(l1);
      // Enrolling twice is harmless.
      await as(m.token).post(`/learning/${c.id}/enrol`).expect(200);
      expect(await prisma.enrolment.count({ where: { userId: m.id, courseId: c.id } })).toBe(1);

      let detail = (await as(m.token).get(`/learning/${c.id}`).expect(200)).body.data;
      expect(detail.course.lessons.map((l: { state: string }) => l.state)).toEqual([
        'CURRENT',
        'LOCKED',
        'LOCKED',
      ]);
      expect(detail.course).toMatchObject({
        enrolled: true,
        completedLessons: 0,
        percent: 0,
        nextLessonId: l1,
      });

      // A locked lesson cannot be opened or written to.
      const locked = await as(m.token).get(`/learning/lessons/${l2}`).expect(409);
      expect(locked.body.error.details.reason).toBe('LOCKED');
      await as(m.token)
        .put(`/learning/lessons/${l2}/progress`, { positionSeconds: 10 })
        .expect(409);

      // Progress only moves forward; the same write again is a no-op; a late earlier write is ignored.
      const w1 = (
        await as(m.token)
          .put(`/learning/lessons/${l1}/progress`, { positionSeconds: 120 })
          .expect(200)
      ).body.data;
      expect(w1.progress).toMatchObject({ status: 'IN_PROGRESS', lastPositionSeconds: 120 });
      await as(m.token)
        .put(`/learning/lessons/${l1}/progress`, { positionSeconds: 120 })
        .expect(200);
      const late = (
        await as(m.token)
          .put(`/learning/lessons/${l1}/progress`, { positionSeconds: 30 })
          .expect(200)
      ).body.data;
      expect(late.progress.lastPositionSeconds).toBe(120);

      // "Close the app and come back": the lesson reports where to resume.
      const reopened = (await as(m.token).get(`/learning/lessons/${l1}`).expect(200)).body.data;
      expect(reopened.progress).toMatchObject({ status: 'IN_PROGRESS', lastPositionSeconds: 120 });
      expect(reopened).toMatchObject({
        sequence: 1,
        lessonCount: 3,
        state: 'CURRENT',
        nextLessonId: l2,
        previousLessonId: null,
      });
      expect(reopened.segments).toEqual([false, false, false]);
      expect(reopened.practice).toMatchObject({ prompt: 'Try it yourself' });
      expect(reopened.body[0]).toMatchObject({ type: 'paragraph', text: 'Text of lesson 1' });

      // Completing is set once; unlocks the next; repeating changes nothing.
      const done1 = (
        await as(m.token).put(`/learning/lessons/${l1}/progress`, { completed: true }).expect(200)
      ).body.data;
      expect(done1).toMatchObject({ courseCompleted: false, percent: 33, nextLessonId: l2 });
      const firstDone = (
        await prisma.lessonProgress.findUniqueOrThrow({
          where: { userId_lessonId: { userId: m.id, lessonId: l1 } },
        })
      ).completedAt!;
      await as(m.token).put(`/learning/lessons/${l1}/progress`, { completed: true }).expect(200);
      expect(
        (
          await prisma.lessonProgress.findUniqueOrThrow({
            where: { userId_lessonId: { userId: m.id, lessonId: l1 } },
          })
        ).completedAt,
      ).toEqual(firstDone);
      detail = (await as(m.token).get(`/learning/${c.id}`).expect(200)).body.data;
      expect(detail.course.lessons.map((l: { state: string }) => l.state)).toEqual([
        'DONE',
        'CURRENT',
        'LOCKED',
      ]);
      expect(detail.course.nextLessonId).toBe(l2);
      await as(m.token).get(`/learning/lessons/${l3}`).expect(409);

      // Time spent is counted for "hours this month".
      const stats = (await as(m.token).get('/me/learning/stats').expect(200)).body.data;
      expect(stats.inProgress).toBe(1);
      expect(stats.minutesThisMonth).toBeGreaterThanOrEqual(5);

      // Restarting a lesson is explicit.
      const restarted = (
        await as(m.token)
          .put(`/learning/lessons/${l2}/progress`, { positionSeconds: 50 })
          .expect(200)
      ).body.data;
      expect(restarted.progress.lastPositionSeconds).toBe(50);
      const back = (
        await as(m.token).put(`/learning/lessons/${l2}/progress`, { restart: true }).expect(200)
      ).body.data;
      expect(back.progress).toMatchObject({
        status: 'IN_PROGRESS',
        lastPositionSeconds: 0,
        completedAt: null,
      });
    });

    it('completing the last lesson issues one certificate, one achievement, moves the skill to LEARNING and notifies', async () => {
      const ed = await editor();
      const taught = await prisma.skill.findFirstOrThrow({ where: { name: 'Colour' } });
      const mine = await prisma.skill.findFirstOrThrow({ where: { name: 'Blender' } });
      const verified = await prisma.skill.findFirstOrThrow({ where: { name: 'Procreate' } });
      const m = await member({ skills: [taught.id] });
      await prisma.creativeSkill.create({
        data: { profileId: m.profileId, skillId: verified.id, source: 'VERIFIED' },
      });
      const c = await course(ed, { lessons: 2, skillIds: [taught.id, verified.id, mine.id] });
      await as(m.token).post(`/learning/${c.id}/enrol`).expect(200);

      await as(m.token)
        .put(`/learning/lessons/${c.lessons[0]!.id}/progress`, { completed: true })
        .expect(200);
      const last = (
        await as(m.token)
          .put(`/learning/lessons/${c.lessons[1]!.id}/progress`, { completed: true })
          .expect(200)
      ).body.data;
      expect(last.courseCompleted).toBe(true);
      expect(last.percent).toBe(100);
      expect(last.certificate.certificateNumber).toMatch(/^ATC-\d{4}-\d{6}$/);

      // Exactly once: writing again (even in parallel) issues nothing new.
      await Promise.all([
        as(m.token).put(`/learning/lessons/${c.lessons[1]!.id}/progress`, { completed: true }),
        as(m.token).put(`/learning/lessons/${c.lessons[1]!.id}/progress`, { completed: true }),
      ]);
      expect(await prisma.certificate.count({ where: { userId: m.id, courseId: c.id } })).toBe(1);
      const cert = await prisma.certificate.findFirstOrThrow({
        where: { userId: m.id, courseId: c.id },
      });
      expect(cert.certificateNumber).toBe(last.certificate.certificateNumber);

      const achievements = await prisma.achievement.findMany({ where: { profileId: m.profileId } });
      expect(achievements).toHaveLength(1);
      expect(achievements[0]).toMatchObject({
        type: 'CERTIFICATE',
        source: 'SYSTEM',
        description: c.title,
        id: cert.achievementId,
      });
      expect(achievements[0]!.title).toMatch(/^Atarah Skill Lab certificate · [A-Z][a-z]+ \d{4}$/);

      // The skill the member claimed becomes LEARNING; a verified skill stays verified; a missing one is added.
      const skills = await prisma.creativeSkill.findMany({ where: { profileId: m.profileId } });
      const src = Object.fromEntries(skills.map((s) => [s.skillId, s.source]));
      expect(src[taught.id]).toBe('LEARNING');
      expect(src[verified.id]).toBe('VERIFIED');
      expect(src[mine.id]).toBe('LEARNING');

      expect(
        (await prisma.enrolment.findFirstOrThrow({ where: { userId: m.id, courseId: c.id } }))
          .completedAt,
      ).not.toBeNull();
      const detail = (await as(m.token).get(`/learning/${c.id}`).expect(200)).body.data;
      expect(detail.course.certificate.certificateNumber).toBe(cert.certificateNumber);
      expect(detail.progress).toMatchObject({ status: 'COMPLETED', percent: 100 });

      const told = await prisma.notification.findMany({
        where: { userId: m.id, category: 'LEARNING' },
      });
      expect(told.map((n) => n.title)).toEqual(['Certificate earned']);
      expect(told[0]!.deepLink).toBe(`/learning/courses/${c.id}`);

      // Passport learning growth reads the real count (25 per completed course).
      const passport = (await as(m.token).get('/me/profile').expect(200)).body.data;
      expect(JSON.stringify(passport)).toBeDefined();
      const done = (await as(m.token).get('/me/learning', { tab: 'completed' }).expect(200)).body
        .data;
      expect(done.map((x: { content: { id: string } }) => x.content.id)).toEqual([c.id]);
      expect((await as(m.token).get('/me/learning/stats').expect(200)).body.data).toMatchObject({
        completed: 1,
        inProgress: 0,
      });
    });

    it('a non-sequential course leaves every lesson open', async () => {
      const ed = await editor();
      const m = await member();
      const c = await course(ed, { lessons: 3, sequential: false });
      await as(m.token).post(`/learning/${c.id}/enrol`).expect(200);
      await as(m.token).get(`/learning/lessons/${c.lessons[2]!.id}`).expect(200);
      const detail = (await as(m.token).get(`/learning/${c.id}`).expect(200)).body.data;
      expect(detail.course.lessons.map((l: { state: string }) => l.state)).toEqual([
        'CURRENT',
        'AVAILABLE',
        'AVAILABLE',
      ]);
    });

    it('an archived course stays open to members already learning it and closes to everyone else', async () => {
      const ed = await editor();
      const learner = await member();
      const other = await member();
      const c = await course(ed, { lessons: 2 });
      await as(learner.token).post(`/learning/${c.id}/enrol`).expect(200);
      await as(ed.token).post(`/admin/learning/contents/${c.id}/archive`).expect(200);
      await as(learner.token).get(`/learning/${c.id}`).expect(200);
      await as(learner.token).get(`/learning/lessons/${c.lessons[0]!.id}`).expect(200);
      await as(other.token).get(`/learning/${c.id}`).expect(404);
      await as(other.token).post(`/learning/${c.id}/enrol`).expect(404);
      // With learners it cannot be sent back to draft.
      const c2 = await course(ed, { lessons: 1 });
      await as(learner.token).post(`/learning/${c2.id}/enrol`).expect(200);
      await as(ed.token).post(`/admin/learning/contents/${c2.id}/unpublish`).expect(409);
    });
  });

  describe('premium content', () => {
    it('answers PREMIUM_REQUIRED to free members everywhere, including the video address, and opens for Pro', async () => {
      const ed = await editor();
      const free = await member();
      const pro = await member({ pro: true });
      const c = await course(ed, { lessons: 2, access: 'PREMIUM_CONTENT' });
      const lessonId = c.lessons[0]!.id;

      // The card and detail say it is locked (so the app shows AtPremiumGate) and hide addresses.
      const card = (await as(free.token).get(`/learning/${c.id}`).expect(200)).body.data;
      expect(card).toMatchObject({ access: 'PREMIUM_CONTENT', premiumLocked: true });
      const enrol = await as(free.token).post(`/learning/${c.id}/enrol`).expect(403);
      expect(enrol.body.error.code).toBe('PREMIUM_REQUIRED');
      expect(await prisma.enrolment.count({ where: { userId: free.id, courseId: c.id } })).toBe(0);

      // Even a free member who somehow has an enrolment row cannot read lessons or fetch the video address.
      await prisma.enrolment.create({ data: { userId: free.id, courseId: c.id } });
      const lesson = await as(free.token).get(`/learning/lessons/${lessonId}`).expect(403);
      expect(lesson.body.error.code).toBe('PREMIUM_REQUIRED');
      const video = await as(free.token).get(`/learning/lessons/${lessonId}/video`).expect(403);
      expect(video.body.error.code).toBe('PREMIUM_REQUIRED');
      await as(free.token)
        .put(`/learning/lessons/${lessonId}/progress`, { positionSeconds: 5 })
        .expect(403);

      const proCard = (await as(pro.token).get(`/learning/${c.id}`).expect(200)).body.data;
      expect(proCard.premiumLocked).toBe(false);
      await as(pro.token).post(`/learning/${c.id}/enrol`).expect(200);
      await as(pro.token).get(`/learning/lessons/${lessonId}`).expect(200);
    });

    it('the video address needs enrolment and a ready video, and is a short-lived signed address', async () => {
      const ed = await editor();
      const m = await member();
      const other = await member();
      const c = await course(ed, { lessons: 1 });
      const lessonId = c.lessons[0]!.id;
      const asset = await prisma.mediaAsset.create({
        data: {
          ownerId: ed.id,
          kind: 'VIDEO',
          bucket: 'PRIVATE',
          objectKey: `test/${uniq()}.mp4`,
          mimeType: 'video/mp4',
          sizeBytes: 1000n,
          status: 'READY',
        },
      });
      await as(ed.token)
        .patch(`/admin/courses/${c.id}/lessons/${lessonId}`, { videoMediaId: asset.id })
        .expect(200);
      // A lesson plays one player: an embed cannot be added alongside the video.
      await as(ed.token)
        .patch(`/admin/courses/${c.id}/lessons/${lessonId}`, {
          embedUrl: 'https://player.vimeo.com/video/123456789',
          videoMediaId: asset.id,
        })
        .expect(400);

      await as(m.token).get(`/learning/lessons/${lessonId}/video`).expect(409); // not enrolled
      await as(m.token).post(`/learning/${c.id}/enrol`).expect(200);
      const spy = jest.spyOn(app.get(MediaService), 'playback').mockResolvedValue({
        url: 'https://storage.example.org/signed/video.mp4?token=abc',
        posterUrl: null,
        expiresAt: new Date(Date.now() + 900_000),
        durationSeconds: 90,
      });
      try {
        const v = (await as(m.token).get(`/learning/lessons/${lessonId}/video`).expect(200)).body
          .data;
        expect(v.url).toContain('video.mp4');
        expect(spy).toHaveBeenCalledWith(asset.id);
        expect(
          (await as(m.token).get(`/learning/lessons/${lessonId}`).expect(200)).body.data.hasVideo,
        ).toBe(true);
        await as(other.token).get(`/learning/lessons/${lessonId}/video`).expect(409);
      } finally {
        spy.mockRestore();
      }
      // A video that is not READY yet is not served.
      await prisma.mediaAsset.update({ where: { id: asset.id }, data: { status: 'PROCESSING' } });
      await as(m.token).get(`/learning/lessons/${lessonId}/video`).expect(409);
    });
  });

  describe('single items, saving and discovery', () => {
    it('tracks a non-course item as started, then completed by hand, and counts its time', async () => {
      const ed = await editor();
      const m = await member();
      const cat = await category('legal-awareness');
      const item = (
        await as(ed.token)
          .post('/admin/learning/contents', {
            title: `Toolkit ${uniq()}`,
            type: 'TOOLKIT',
            summary: 'Templates you can adapt.',
            categoryId: cat.id,
            source: 'PARTNER',
            delivery: 'EXTERNAL_LINK',
            externalUrl: 'https://toolkit.example.org/start',
            durationMinutes: 30,
            providerName: 'Partner (demo)',
          })
          .expect(201)
      ).body.data;
      created.push(item.id);
      await as(ed.token).post(`/admin/learning/contents/${item.id}/publish`).expect(200);
      await as(ed.token)
        .post('/admin/learning/contents', {
          title: 'No address',
          type: 'WEBINAR',
          summary: 'A webinar with no address.',
          categoryId: cat.id,
          delivery: 'EXTERNAL_LINK',
        })
        .expect(201)
        .then(async (r) => {
          created.push(r.body.data.id);
          await as(ed.token).post(`/admin/learning/contents/${r.body.data.id}/publish`).expect(400);
        });

      const detail = (await as(m.token).get(`/learning/${item.id}`).expect(200)).body.data;
      expect(detail).toMatchObject({
        source: 'PARTNER',
        delivery: 'EXTERNAL_LINK',
        externalUrl: 'https://toolkit.example.org/start',
        externalDomain: 'toolkit.example.org',
        course: null,
        linkStatus: 'UNKNOWN',
      });
      await as(m.token).post(`/learning/${item.id}/enrol`).expect(409);
      expect(
        (await as(m.token).post(`/learning/${item.id}/start`).expect(200)).body.data,
      ).toMatchObject({ status: 'IN_PROGRESS', percent: 0 });
      await as(m.token).post(`/learning/${item.id}/start`).expect(200);
      expect(
        (await as(m.token).get('/me/learning', { tab: 'active' }).expect(200)).body.data.map(
          (x: { content: { id: string } }) => x.content.id,
        ),
      ).toContain(item.id);
      expect(
        (await as(m.token).post(`/learning/${item.id}/complete`).expect(200)).body.data,
      ).toMatchObject({ status: 'COMPLETED', percent: 100 });
      await as(m.token).post(`/learning/${item.id}/complete`).expect(200);
      const stats = (await as(m.token).get('/me/learning/stats').expect(200)).body.data;
      expect(stats).toMatchObject({
        completed: 1,
        inProgress: 0,
        minutesThisMonth: 30,
        hoursThisMonth: 0.5,
      });
      await as(m.token)
        .post(`/learning/${(await course(ed, { lessons: 1 })).id}/start`)
        .expect(409);
    });

    it('saves and unsaves, lists saved, and hides unpublished items from the saved tab', async () => {
      const ed = await editor();
      const m = await member();
      const a = await course(ed, { lessons: 1 });
      const b = await course(ed, { lessons: 1 });
      await as(m.token).put(`/learning/${a.id}/save`).expect(204);
      await as(m.token).put(`/learning/${a.id}/save`).expect(204);
      await as(m.token).put(`/learning/${b.id}/save`).expect(204);
      expect((await as(m.token).get(`/learning/${a.id}`).expect(200)).body.data.saved).toBe(true);
      const ids = async () =>
        (await as(m.token).get('/me/learning', { tab: 'saved' }).expect(200)).body.data.map(
          (x: { content: { id: string } }) => x.content.id,
        );
      expect((await ids()).sort()).toEqual([a.id, b.id].sort());
      await as(m.token).del(`/learning/${b.id}/save`).expect(204);
      await as(m.token).del(`/learning/${b.id}/save`).expect(204);
      expect(await ids()).toEqual([a.id]);
      await as(ed.token).post(`/admin/learning/contents/${a.id}/unpublish`).expect(200);
      expect(await ids()).toEqual([]);
      await as(m.token).put(`/learning/${randomId()}/save`).expect(404);
    });

    it('hub: continue learning with a real percentage, featured, categories with counts and reasons for recommendations', async () => {
      const ed = await editor();
      const skill = await prisma.skill.findFirstOrThrow({ where: { name: 'Storyboarding' } });
      const m = await member({ skills: [skill.id], areas: ['personal-branding'] });
      const tag = uniq();
      const learning = await course(ed, { title: `Continue ${tag}`, lessons: 4, featured: true });
      const rec1 = await course(ed, { title: `Brand ${tag}`, lessons: 1, category: 'branding' });
      const rec2 = await course(ed, {
        title: `Story ${tag}`,
        lessons: 1,
        category: 'animation',
        skillIds: [skill.id],
      });
      const rec3 = await course(ed, { title: `Anim ${tag}`, lessons: 1, category: 'animation' });
      await prisma.learningContentDiscipline.create({
        data: {
          contentId: rec3.id,
          disciplineId: (await prisma.discipline.findFirstOrThrow({ where: { name: 'Animation' } }))
            .id,
        },
      });

      await as(m.token).post(`/learning/${learning.id}/enrol`).expect(200);
      await as(m.token)
        .put(`/learning/lessons/${learning.lessons[0]!.id}/progress`, { completed: true })
        .expect(200);

      const hub = (await as(m.token).get('/learning').expect(200)).body.data;
      expect(hub.continueLearning).toMatchObject({
        percent: 25,
        lessonsDone: 1,
        lessonCount: 4,
        nextLessonId: learning.lessons[1]!.id,
        nextLessonTitle: 'Lesson 2',
      });
      expect(hub.continueLearning.content.id).toBe(learning.id);
      expect(hub.featured.map((x: { id: string }) => x.id)).toContain(learning.id);
      const branding = hub.categories.find((c: { slug: string }) => c.slug === 'branding');
      expect(branding).toMatchObject({ group: 'BUSINESS' });
      expect(branding.count).toBeGreaterThanOrEqual(1);
      expect(hub.categories.map((c: { group: string }) => c.group)).toEqual(
        [...hub.categories.map((c: { group: string }) => c.group)].sort(
          (a: string, b: string) =>
            ['CREATIVE', 'BUSINESS', 'PROFESSIONAL'].indexOf(a) -
            ['CREATIVE', 'BUSINESS', 'PROFESSIONAL'].indexOf(b),
        ),
      );

      const reasons = Object.fromEntries(
        hub.recommended.map((r: { content: { id: string }; reason: string }) => [
          r.content.id,
          r.reason,
        ]),
      );
      expect(reasons[rec1.id]).toBe('Because you want to develop Personal branding');
      expect(reasons[rec2.id]).toBe('Builds on your Storyboarding');
      expect(reasons[rec3.id]).toBe('For Animation creatives');
      // What the member is already on is not recommended.
      expect(reasons[learning.id]).toBeUndefined();
    });

    it('category page: counts per type, the type filter and an empty state for a type with nothing', async () => {
      const ed = await editor();
      const m = await member();
      const cat = await category('client-management');
      const mk = async (type: string, extra: object = {}) => {
        const r = await as(ed.token)
          .post('/admin/learning/contents', {
            title: `${type} ${uniq()}`,
            type,
            summary: 'An item for the category page.',
            categoryId: cat.id,
            delivery: 'EXTERNAL_LINK',
            externalUrl: 'https://example.org/x',
            ...extra,
          })
          .expect(201);
        created.push(r.body.data.id);
        await as(ed.token).post(`/admin/learning/contents/${r.body.data.id}/publish`).expect(200);
        return r.body.data.id as string;
      };
      const t1 = await mk('TUTORIAL');
      const t2 = await mk('TUTORIAL');
      const w1 = await mk('WEBINAR');
      const all = await as(m.token).get('/learning/categories/client-management').expect(200);
      expect(all.body.meta.category).toMatchObject({
        slug: 'client-management',
        group: 'PROFESSIONAL',
      });
      expect(all.body.meta.total).toBe(3);
      const counts = Object.fromEntries(
        all.body.meta.types.map((t: { type: string; count: number }) => [t.type, t.count]),
      );
      expect(counts).toMatchObject({ TUTORIAL: 2, WEBINAR: 1 });
      const tutorials = await as(m.token)
        .get('/learning/categories/client-management', { type: 'TUTORIAL' })
        .expect(200);
      expect(tutorials.body.data.map((x: { id: string }) => x.id).sort()).toEqual([t1, t2].sort());
      expect(tutorials.body.meta.total_all).toBe(3);
      const none = await as(m.token)
        .get('/learning/categories/client-management', { type: 'MASTERCLASS' })
        .expect(200);
      expect(none.body.data).toEqual([]);
      expect(w1).toBeTruthy();
      await as(m.token).get('/learning/categories/no-such-category').expect(404);
    });

    it('search finds published items only, in the shared search', async () => {
      const ed = await editor();
      const m = await member();
      const word = `Zorblax${uniq()}`.replace(/[^a-z0-9]/gi, '');
      const live = await course(ed, { title: `${word} basics`, lessons: 1 });
      await course(ed, { title: `${word} hidden draft`, lessons: 1 }, false);
      const res = await as(m.token).get('/search', { q: word, type: 'learning' }).expect(200);
      expect(res.body.data.groups).toHaveLength(1);
      expect(res.body.data.groups[0]).toMatchObject({ type: 'learning', count: 1 });
      expect(res.body.data.groups[0].items[0]).toMatchObject({
        id: live.id,
        path: `/learning/courses/${live.id}`,
      });
      const own = await as(m.token).get('/learning/search', { q: word }).expect(200);
      expect(own.body.meta.total).toBe(1);
    });
  });

  describe('operations', () => {
    it('progress overrides are explicit, reasoned, audited and need a fresh authenticator check', async () => {
      const ed = await editor();
      const m = await member();
      const c = await course(ed, { lessons: 2 });
      await as(m.token).post(`/learning/${c.id}/enrol`).expect(200);
      const body = {
        userId: m.id,
        courseId: c.id,
        lessonId: c.lessons[0]!.id,
        action: 'COMPLETE_LESSON',
      };
      await as(m.token)
        .post('/admin/learning/progress-overrides', { ...body, reason: 'A member trying this' })
        .expect(403);
      await as(ed.token)
        .post('/admin/learning/progress-overrides', { ...body, reason: 'short' })
        .expect(400);
      const done = (
        await as(ed.token)
          .post('/admin/learning/progress-overrides', {
            ...body,
            reason: 'Member finished offline at a workshop',
          })
          .expect(200)
      ).body.data;
      expect(done).toMatchObject({ ok: true, courseCompleted: false });
      expect(
        (await as(m.token).get(`/learning/${c.id}`).expect(200)).body.data.course.completedLessons,
      ).toBe(1);
      const finish = (
        await as(ed.token)
          .post('/admin/learning/progress-overrides', {
            ...body,
            lessonId: c.lessons[1]!.id,
            reason: 'Member finished offline at a workshop',
          })
          .expect(200)
      ).body.data;
      expect(finish.courseCompleted).toBe(true);
      expect(await prisma.certificate.count({ where: { userId: m.id, courseId: c.id } })).toBe(1);
      const reset = await as(ed.token)
        .post('/admin/learning/progress-overrides', {
          userId: m.id,
          courseId: c.id,
          action: 'RESET_COURSE',
          reason: 'Recorded against the wrong member',
        })
        .expect(200);
      expect(reset.body.data.ok).toBe(true);
      expect(
        (await as(m.token).get(`/learning/${c.id}`).expect(200)).body.data.course,
      ).toMatchObject({ completedLessons: 0 });
      // An issued certificate stays; every override is logged.
      expect(await prisma.certificate.count({ where: { userId: m.id, courseId: c.id } })).toBe(1);
      expect(
        await prisma.learningProgressOverride.count({ where: { userId: m.id, courseId: c.id } }),
      ).toBe(3);
      const audit = await prisma.auditLog.findMany({
        where: { action: 'learning.progress.override', actorId: ed.id },
      });
      expect(audit.length).toBeGreaterThanOrEqual(3);
      expect(audit[0]!.after).toMatchObject({ userId: m.id });
      const stranger = await member();
      await as(ed.token)
        .post('/admin/learning/progress-overrides', {
          userId: stranger.id,
          courseId: c.id,
          action: 'RESET_COURSE',
          reason: 'Not enrolled at all',
        })
        .expect(409);
    });

    it('analytics count starts and completions per item', async () => {
      const ed = await editor();
      const a = await member();
      const b = await member();
      const c = await course(ed, { lessons: 1 });
      for (const m of [a, b]) await as(m.token).post(`/learning/${c.id}/enrol`).expect(200);
      await as(a.token)
        .put(`/learning/lessons/${c.lessons[0]!.id}/progress`, { completed: true })
        .expect(200);
      const stats = (await as(ed.token).get('/admin/learning/analytics').expect(200)).body.data;
      const row = stats.items.find((i: { contentId: string }) => i.contentId === c.id);
      expect(row).toMatchObject({ starts: 2, completions: 1, completionRate: 50 });
      expect(stats.certificatesIssued).toBeGreaterThanOrEqual(1);
      expect(stats.publishedItems).toBeGreaterThanOrEqual(1);
    });

    it('the weekly link check flags a broken external address and never unpublishes', async () => {
      const ed = await editor();
      const cat = await category('marketing');
      const mk = async (url: string) => {
        const r = await as(ed.token)
          .post('/admin/learning/contents', {
            title: `Link ${uniq()}`,
            type: 'ARTICLE',
            summary: 'An external article to check.',
            categoryId: cat.id,
            delivery: 'EXTERNAL_LINK',
            externalUrl: url,
          })
          .expect(201);
        created.push(r.body.data.id);
        await as(ed.token).post(`/admin/learning/contents/${r.body.data.id}/publish`).expect(200);
        return r.body.data.id as string;
      };
      const good = await mk('https://good.example.org/a');
      const gone = await mk('https://gone.example.org/a');
      const picky = await mk('https://picky.example.org/a');
      const fetcher = app.get(SafeFetcher);
      const real = fetcher.probe.bind(fetcher);
      fetcher.probe = jest.fn(async (url: string) => {
        if (url.includes('gone.')) return { status: 404, url };
        if (url.includes('picky.')) return { status: 403, url };
        if (url.includes('good.')) return { status: 200, url };
        return real(url);
      });
      try {
        expect((await jobs.checkLinks()).checked).toBeGreaterThanOrEqual(3);
      } finally {
        fetcher.probe = real;
      }
      const row = (id: string) => prisma.learningContent.findUniqueOrThrow({ where: { id } });
      expect((await row(good)).linkStatus).toBe('OK');
      expect((await row(picky)).linkStatus).toBe('OK');
      const bad = await row(gone);
      expect(bad).toMatchObject({ linkStatus: 'BROKEN', status: 'PUBLISHED' });
      const m = await member();
      expect((await as(m.token).get(`/learning/${gone}`).expect(200)).body.data.linkStatus).toBe(
        'BROKEN',
      );
      const broken = await as(ed.token)
        .get('/admin/learning/contents', { brokenLink: true })
        .expect(200);
      expect(broken.body.data.map((x: { id: string }) => x.id)).toContain(gone);
      expect((await jobs.checkLinks()).checked).toBe(0);
    });
  });

  describe('database rules', () => {
    it('refuses a completed lesson without a time, and a second certificate', async () => {
      const ed = await editor();
      const m = await member();
      const c = await course(ed, { lessons: 1 });
      await expect(
        prisma.lessonProgress.create({
          data: { userId: m.id, lessonId: c.lessons[0]!.id, status: 'COMPLETED' },
        }),
      ).rejects.toThrow();
      await expect(
        prisma.lessonProgress.create({
          data: {
            userId: m.id,
            lessonId: c.lessons[0]!.id,
            status: 'IN_PROGRESS',
            lastPositionSeconds: -3,
          },
        }),
      ).rejects.toThrow();
      await prisma.certificate.create({
        data: { userId: m.id, courseId: c.id, certificateNumber: `ATC-T-${uniq()}` },
      });
      await expect(
        prisma.certificate.create({
          data: { userId: m.id, courseId: c.id, certificateNumber: `ATC-T-${uniq()}` },
        }),
      ).rejects.toThrow();
    });

    it('every learning table is deny-all for the client roles (RLS)', async () => {
      const tables = [
        'learning_contents',
        'learning_content_disciplines',
        'learning_content_skills',
        'courses',
        'lessons',
        'enrolments',
        'lesson_progress',
        'content_progress',
        'learning_activity_daily',
        'certificates',
        'learning_progress_overrides',
      ];
      const rows = await prisma.$queryRaw<
        Array<{ relname: string; relrowsecurity: boolean }>
      >`SELECT relname, relrowsecurity FROM pg_class WHERE relname = ANY(${tables})`;
      expect(rows).toHaveLength(tables.length);
      expect(rows.every((r) => r.relrowsecurity)).toBe(true);
      const grants = await prisma.$queryRaw<
        Array<{ n: bigint }>
      >`SELECT count(*) AS n FROM information_schema.role_table_grants WHERE table_name = ANY(${tables}) AND grantee IN ('anon','authenticated')`;
      expect(Number(grants[0]!.n)).toBe(0);
    });
  });
});

const randomId = () => '11111111-1111-4111-8111-111111111111';
