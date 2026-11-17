import { describe, expect, it } from 'vitest';
import { emptyBlock } from './articles';
import {
  actionsFor,
  canManageLearning,
  categoryPayload,
  deliveriesFor,
  deliveryLabel,
  embedPreview,
  emptyCategoryForm,
  emptyContentForm,
  emptyLessonForm,
  emptyOverride,
  formatRate,
  formFromDto,
  groupCategories,
  learningMessage,
  lessonFormFromDto,
  lessonPayload,
  moveItem,
  orderChanged,
  orderIds,
  overridePayload,
  sourceLabel,
  statusMeta,
  toContentPayload,
  validateCategory,
  validateContentForm,
  validateLessonForm,
  validateOverride,
  validateVideoFile,
  videoStatusMeta,
  withType,
  type ContentDtoLike,
  type ContentForm,
  type LessonForm,
} from './learning';

const HOSTS = ['www.youtube.com', 'www.youtube-nocookie.com', 'player.vimeo.com'];
const U1 = '3f2b8c1e-5a4d-4e6f-8a1b-0c9d7e6f5a4b';
const C1 = '5b4d0e3a-7c6f-4081-8c3d-2e1f9a8b7c6d';

const valid = (over: Partial<ContentForm> = {}): ContentForm => ({
  ...emptyContentForm(),
  title: 'Build a portfolio',
  summary: 'A short course on choosing and presenting your best work.',
  categoryId: C1,
  ...over,
});

describe('labels', () => {
  it('names status, source, delivery and video states for staff', () => {
    expect(statusMeta('PUBLISHED')).toEqual({ label: 'Published', tone: 'success' });
    expect(statusMeta('IN_REVIEW').label).toBe('In review');
    expect(sourceLabel('PARTNER')).toBe('Partner content');
    expect(deliveryLabel('EXTERNAL_LINK')).toBe('Opens outside Atarah');
    expect(videoStatusMeta('READY').tone).toBe('success');
    expect(videoStatusMeta('REJECTED').tone).toBe('danger');
    expect(videoStatusMeta(null).label).toBe('No video');
  });
});

describe('gating and lifecycle', () => {
  it('Learning needs learning.manage', () => {
    expect(canManageLearning(['admin.access', 'learning.manage'])).toBe(true);
    expect(canManageLearning(['admin.access', 'opportunity.manage'])).toBe(false);
  });

  it('offers the moves that make sense for a status', () => {
    expect(actionsFor('DRAFT', 0)).toEqual(['publish', 'archive']);
    expect(actionsFor('IN_REVIEW', 0)).toEqual(['publish', 'archive']);
    expect(actionsFor('PUBLISHED', 0)).toEqual(['unpublish', 'archive']);
    expect(actionsFor('ARCHIVED', 3)).toEqual(['publish']);
  });

  it('a published item with learners can only be archived, never taken back to draft', () => {
    expect(actionsFor('PUBLISHED', 1)).toEqual(['archive']);
  });

  it('a course is taught in the app; other types open a player or another site', () => {
    expect(deliveriesFor('COURSE')).toEqual(['NATIVE']);
    expect(deliveriesFor('WEBINAR')).toEqual(['EMBEDDED', 'EXTERNAL_LINK']);
  });
});

describe('embed allow-list', () => {
  it('converts watch links and shows the address members will see', () => {
    expect(embedPreview('https://www.youtube.com/watch?v=abcDEF12345', HOSTS)).toEqual({
      ok: true,
      url: 'https://www.youtube-nocookie.com/embed/abcDEF12345',
    });
    expect(embedPreview('https://youtu.be/abcDEF12345', HOSTS)).toMatchObject({ ok: true });
    expect(embedPreview('https://vimeo.com/123456789', HOSTS)).toEqual({
      ok: true,
      url: 'https://player.vimeo.com/video/123456789',
    });
  });

  it.each([
    ['a host that is not allowed', 'https://evil.example.com/embed/abc123456'],
    ['a look-alike host', 'https://www.youtube.com.evil.example.com/embed/abc123456'],
    ['plain http', 'http://player.vimeo.com/video/123456789'],
    ['credentials', 'https://u:p@player.vimeo.com/video/123456789'],
    ['a channel page', 'https://www.youtube.com/@someone'],
    ['not an address', 'hello'],
  ])('refuses %s', (_name, url) => {
    expect(embedPreview(url, HOSTS).ok).toBe(false);
  });

  it('follows the list the API returns', () => {
    expect(embedPreview('https://player.vimeo.com/video/123456789', ['www.youtube.com']).ok).toBe(
      false,
    );
  });
});

describe('content form', () => {
  it('accepts a valid course and a draft external item without its address yet', () => {
    expect(validateContentForm(valid(), 'create', HOSTS)).toBeNull();
    expect(
      validateContentForm(
        valid({ type: 'TOOLKIT', delivery: 'EXTERNAL_LINK', externalUrl: '' }),
        'create',
        HOSTS,
      ),
    ).toBeNull();
  });

  it.each([
    ['a short title', { title: 'ab' }, /title/],
    ['a short summary', { summary: 'too short' }, /summary/],
    ['no category', { categoryId: '' }, /category/i],
    [
      'a bad duration',
      { type: 'TUTORIAL', delivery: 'EXTERNAL_LINK', durationMinutes: '12.5' },
      /duration/i,
    ],
    [
      'an insecure link',
      { type: 'TOOLKIT', delivery: 'EXTERNAL_LINK', externalUrl: 'http://x.example.org' },
      /https/,
    ],
    ['a course that is not in-app', { delivery: 'EXTERNAL_LINK' }, /taught in the app/],
    ['a bad instructor id', { instructorUserId: 'someone' }, /instructor/i],
    [
      'an embed on a host that is not allowed',
      { type: 'MASTERCLASS', delivery: 'EMBEDDED', embedUrl: 'https://evil.example.com/v/1' },
      /cannot be embedded/,
    ],
  ] as const)('refuses %s', (_name, over, message) => {
    expect(validateContentForm(valid(over as Partial<ContentForm>), 'create', HOSTS)).toMatch(
      message,
    );
  });

  it('changing the type moves the delivery to one that suits it', () => {
    expect(withType(valid(), 'WEBINAR').delivery).toBe('EMBEDDED');
    expect(
      withType(valid({ type: 'WEBINAR', delivery: 'EXTERNAL_LINK' }), 'TOOLKIT').delivery,
    ).toBe('EXTERNAL_LINK');
    expect(withType(valid({ type: 'WEBINAR', delivery: 'EMBEDDED' }), 'COURSE').delivery).toBe(
      'NATIVE',
    );
  });

  it('builds a create payload without empty optional fields', () => {
    const body = toContentPayload(
      valid({ whatYouLearn: ['One', '  ', 'Two'], skillIds: [U1], sequential: false }),
      'create',
    );
    expect(body).toMatchObject({
      title: 'Build a portfolio',
      type: 'COURSE',
      categoryId: C1,
      delivery: 'NATIVE',
      access: 'FREE',
      whatYouLearn: ['One', 'Two'],
      skillIds: [U1],
      sequential: false,
    });
    for (const k of [
      'providerName',
      'whoItsFor',
      'instructorUserId',
      'externalUrl',
      'embedUrl',
      'coverMediaId',
      'durationMinutes',
    ]) {
      expect(body).not.toHaveProperty(k);
    }
  });

  it('single items send their duration and the address that belongs to the delivery', () => {
    const external = toContentPayload(
      valid({
        type: 'TOOLKIT',
        delivery: 'EXTERNAL_LINK',
        externalUrl: ' https://toolkit.example.org/a ',
        durationMinutes: '30',
      }),
      'create',
    );
    expect(external).toMatchObject({
      durationMinutes: 30,
      externalUrl: 'https://toolkit.example.org/a',
    });
    expect(external).not.toHaveProperty('sequential');
    expect(external).not.toHaveProperty('embedUrl');
    const embedded = toContentPayload(
      valid({
        type: 'MASTERCLASS',
        delivery: 'EMBEDDED',
        embedUrl: 'https://www.youtube.com/watch?v=abcDEF12345',
      }),
      'create',
    );
    expect(embedded).toMatchObject({ embedUrl: 'https://www.youtube.com/watch?v=abcDEF12345' });
  });

  it('an edit clears emptied fields with null, sends the type only when it changed and clears the other address', () => {
    const body = toContentPayload(
      valid({ type: 'TOOLKIT', delivery: 'EXTERNAL_LINK', externalUrl: '', providerName: '' }),
      'edit',
      'TOOLKIT',
    );
    expect(body).toMatchObject({
      providerName: null,
      whoItsFor: null,
      instructorUserId: null,
      externalUrl: null,
      embedUrl: null,
      coverMediaId: null,
    });
    expect(body).not.toHaveProperty('type');
    expect(toContentPayload(valid(), 'edit', 'COURSE')).not.toHaveProperty('type');
    expect(
      toContentPayload(valid({ type: 'TUTORIAL', delivery: 'EMBEDDED' }), 'edit', 'ARTICLE'),
    ).toHaveProperty('type', 'TUTORIAL');
    const course = toContentPayload(valid(), 'edit', 'COURSE');
    expect(course).toMatchObject({ externalUrl: null, embedUrl: null });
  });

  it('turns an API item back into a form', () => {
    const dto: ContentDtoLike = {
      title: 'T',
      type: 'COURSE',
      summary: 'Summary of the course.',
      category: { id: C1 },
      level: 'ADVANCED',
      durationMinutes: 42,
      source: 'PARTNER',
      delivery: 'NATIVE',
      providerName: 'P',
      instructorUserId: null,
      externalUrl: null,
      embedUrl: null,
      coverMediaId: 'm1',
      coverUrl: 'https://img',
      access: 'PREMIUM_CONTENT',
      featured: true,
      whatYouLearn: [],
      whoItsFor: null,
      disciplineIds: ['d1'],
      skillIds: ['s1'],
      sequential: false,
    };
    const f = formFromDto(dto);
    expect(f).toMatchObject({
      categoryId: C1,
      level: 'ADVANCED',
      durationMinutes: '',
      source: 'PARTNER',
      access: 'PREMIUM_CONTENT',
      featured: true,
      whatYouLearn: [''],
      whoItsFor: '',
      coverMediaId: 'm1',
      sequential: false,
      disciplineIds: ['d1'],
      skillIds: ['s1'],
    });
    expect(formFromDto({ ...dto, type: 'WEBINAR', durationMinutes: 55 }).durationMinutes).toBe(
      '55',
    );
  });
});

describe('categories', () => {
  it('validates and builds the body', () => {
    expect(validateCategory({ ...emptyCategoryForm(), name: 'A' })).toMatch(/2 to 60/);
    expect(validateCategory({ ...emptyCategoryForm(), name: 'Branding', sortOrder: '-2' })).toMatch(
      /whole number/,
    );
    expect(
      validateCategory({ ...emptyCategoryForm(), name: 'Branding', sortOrder: '3' }),
    ).toBeNull();
    expect(
      categoryPayload({ name: ' Branding ', group: 'BUSINESS', sortOrder: '3', isActive: false }),
    ).toEqual({ name: 'Branding', group: 'BUSINESS', sortOrder: 3, isActive: false });
    expect(
      categoryPayload({ name: 'Music', group: 'CREATIVE', sortOrder: '', isActive: true }),
    ).not.toHaveProperty('sortOrder');
  });

  it('groups under Creative, Business, Professional in member order', () => {
    const g = groupCategories([
      { id: '1', name: 'Marketing', group: 'BUSINESS', sortOrder: 2 },
      { id: '2', name: 'Animation', group: 'CREATIVE', sortOrder: 1 },
      { id: '3', name: 'Branding', group: 'BUSINESS', sortOrder: 1 },
    ]);
    expect(g.map((x) => x.group)).toEqual(['CREATIVE', 'BUSINESS', 'PROFESSIONAL']);
    expect(g[1]!.items.map((c) => c.name)).toEqual(['Branding', 'Marketing']);
    expect(g[2]!.items).toEqual([]);
  });
});

describe('lessons', () => {
  const lesson = (over: Partial<LessonForm> = {}): LessonForm => ({
    ...emptyLessonForm(),
    title: 'What a portfolio is for',
    blocks: [{ ...emptyBlock('b1', 'paragraph'), text: 'Some text.' }],
    ...over,
  });

  it('accepts text-only and refuses empty blocks, bad lengths and a missing player', () => {
    expect(validateLessonForm(lesson(), HOSTS)).toBeNull();
    expect(validateLessonForm(lesson({ title: 'x' }), HOSTS)).toMatch(/title/);
    expect(validateLessonForm(lesson({ durationMinutes: '700' }), HOSTS)).toMatch(/minutes/);
    expect(validateLessonForm(lesson({ blocks: [emptyBlock('b', 'paragraph')] }), HOSTS)).toMatch(
      /Block 1/,
    );
    expect(validateLessonForm(lesson({ blocks: [emptyBlock('b', 'image')] }), HOSTS)).toMatch(
      /needs an image/,
    );
    expect(validateLessonForm(lesson({ player: 'VIDEO' }), HOSTS)).toMatch(/Upload the video/);
    expect(validateLessonForm(lesson({ player: 'EMBED' }), HOSTS)).toMatch(/Paste/);
    expect(validateLessonForm(lesson({ practiceSkillId: U1 }), HOSTS)).toMatch(/practice prompt/);
  });

  it('enforces the embed allow-list on a lesson', () => {
    expect(
      validateLessonForm(
        lesson({ player: 'EMBED', embedUrl: 'https://evil.example.com/e/1' }),
        HOSTS,
      ),
    ).toMatch(/cannot be embedded/);
    expect(
      validateLessonForm(
        lesson({ player: 'EMBED', embedUrl: 'https://vimeo.com/123456789' }),
        HOSTS,
      ),
    ).toBeNull();
  });

  it('plays a video or an embed, never both: the other is cleared on edit and left out on create', () => {
    const video = lesson({
      player: 'VIDEO',
      videoMediaId: 'm1',
      embedUrl: 'https://vimeo.com/123456789',
    });
    expect(lessonPayload(video, 'create')).toMatchObject({ videoMediaId: 'm1' });
    expect(lessonPayload(video, 'create')).not.toHaveProperty('embedUrl');
    expect(lessonPayload(video, 'edit')).toMatchObject({ videoMediaId: 'm1', embedUrl: null });
    const embed = lesson({
      player: 'EMBED',
      embedUrl: ' https://vimeo.com/123456789 ',
      videoMediaId: 'm1',
    });
    expect(lessonPayload(embed, 'edit')).toMatchObject({
      embedUrl: 'https://vimeo.com/123456789',
      videoMediaId: null,
    });
    expect(lessonPayload(embed, 'create')).not.toHaveProperty('videoMediaId');
    expect(lessonPayload(lesson(), 'edit')).toMatchObject({
      videoMediaId: null,
      embedUrl: null,
      practicePrompt: null,
      practiceSkillId: null,
      durationMinutes: 0,
    });
  });

  it('sends only the block fields that belong to each type, and the practice skill only with a prompt', () => {
    const body = lessonPayload(
      lesson({
        durationMinutes: '7',
        blocks: [
          { ...emptyBlock('a', 'callout'), title: 'Rule', text: 'Three beat twelve.' },
          { ...emptyBlock('b', 'quote'), text: 'Show it.', attribution: ' A director ' },
        ],
        practicePrompt: ' Add three projects ',
        practiceSkillId: U1,
      }),
      'create',
    );
    expect(body).toMatchObject({
      durationMinutes: 7,
      body: [
        { type: 'callout', title: 'Rule', text: 'Three beat twelve.' },
        { type: 'quote', text: 'Show it.', attribution: 'A director' },
      ],
      practicePrompt: 'Add three projects',
      practiceSkillId: U1,
    });
  });

  it('turns an API lesson back into a form', () => {
    const f = lessonFormFromDto(
      {
        title: 'L',
        durationMinutes: 6,
        body: [
          { type: 'image', mediaId: 'm9', imageUrl: 'https://i', caption: 'Cap' },
          { type: 'paragraph', text: 'Hi' },
        ],
        videoMediaId: null,
        embedUrl: 'https://player.vimeo.com/video/123456789',
        practicePrompt: 'Try',
        practiceSkillId: U1,
      },
      (i) => `k${i}`,
    );
    expect(f).toMatchObject({
      durationMinutes: '6',
      player: 'EMBED',
      practicePrompt: 'Try',
      practiceSkillId: U1,
    });
    expect(f.blocks.map((b) => [b.key, b.type, b.mediaId, b.caption])).toEqual([
      ['k0', 'image', 'm9', 'Cap'],
      ['k1', 'paragraph', '', ''],
    ]);
    expect(
      lessonFormFromDto(
        { title: 'V', durationMinutes: 0, body: [], videoMediaId: 'v1' },
        (i) => `k${i}`,
      ).player,
    ).toBe('VIDEO');
    expect(
      lessonFormFromDto({ title: 'N', durationMinutes: 0, body: [] }, (i) => `k${i}`).player,
    ).toBe('NONE');
  });
});

describe('lesson order', () => {
  const L = [{ id: 'a' }, { id: 'b' }, { id: 'c' }];

  it('moves one place and stays put at the ends', () => {
    expect(moveItem(L, 1, -1).map((l) => l.id)).toEqual(['b', 'a', 'c']);
    expect(moveItem(L, 1, 1).map((l) => l.id)).toEqual(['a', 'c', 'b']);
    expect(moveItem(L, 0, -1).map((l) => l.id)).toEqual(['a', 'b', 'c']);
    expect(moveItem(L, 2, 1).map((l) => l.id)).toEqual(['a', 'b', 'c']);
    expect(L.map((l) => l.id)).toEqual(['a', 'b', 'c']);
  });

  it('knows whether the order changed and sends every id once', () => {
    expect(orderChanged(L, moveItem(L, 0, 1))).toBe(true);
    expect(orderChanged(L, moveItem(L, 0, -1))).toBe(false);
    expect(orderIds(moveItem(L, 2, -1))).toEqual(['a', 'c', 'b']);
  });
});

describe('video upload', () => {
  it('accepts MP4, MOV and WebM up to 200 MB only', () => {
    expect(validateVideoFile({ type: 'video/mp4', size: 5_000_000 })).toBeNull();
    expect(validateVideoFile({ type: 'video/quicktime', size: 1 })).toBeNull();
    expect(validateVideoFile({ type: 'video/webm', size: 200 * 1024 * 1024 })).toBeNull();
    expect(validateVideoFile({ type: 'video/x-matroska', size: 10 })).toMatch(/MP4/);
    expect(validateVideoFile({ type: 'video/mp4', size: 200 * 1024 * 1024 + 1 })).toMatch(
      /too large/,
    );
    expect(validateVideoFile({ type: 'video/mp4', size: 0 })).toMatch(/empty/);
  });
});

describe('progress override', () => {
  it('needs a member id, a lesson (for lesson actions) and a reason of at least 10 characters', () => {
    expect(validateOverride({ ...emptyOverride(), userId: 'nope' })).toMatch(/user id/);
    expect(validateOverride({ ...emptyOverride(), userId: U1 })).toMatch(/Choose the lesson/);
    expect(
      validateOverride({ ...emptyOverride(), userId: U1, lessonId: C1, reason: 'short' }),
    ).toMatch(/10 characters/);
    expect(
      validateOverride({
        userId: U1,
        action: 'COMPLETE_LESSON',
        lessonId: C1,
        reason: 'Finished offline at a workshop',
      }),
    ).toBeNull();
    expect(
      validateOverride({
        userId: U1,
        action: 'RESET_COURSE',
        lessonId: '',
        reason: 'Recorded against the wrong member',
      }),
    ).toBeNull();
  });

  it('sends the lesson only for lesson actions', () => {
    expect(
      overridePayload('course1', {
        userId: ` ${U1} `,
        action: 'RESET_LESSON',
        lessonId: C1,
        reason: ' Wrong member ',
      }),
    ).toEqual({
      userId: U1,
      courseId: 'course1',
      action: 'RESET_LESSON',
      lessonId: C1,
      reason: 'Wrong member',
    });
    expect(
      overridePayload('course1', {
        userId: U1,
        action: 'RESET_COURSE',
        lessonId: C1,
        reason: 'Recorded against the wrong member',
      }),
    ).not.toHaveProperty('lessonId');
  });
});

describe('analytics and messages', () => {
  it('formats a rate and friendly errors', () => {
    expect(formatRate(33.3)).toBe('33%');
    expect(formatRate(0)).toBe('0%');
    expect(learningMessage(403, 'x')).toBe('You do not have permission to do that.');
    expect(learningMessage(404, 'x')).toBe('That item no longer exists.');
    expect(learningMessage(409, 'Members have started this.')).toBe('Members have started this.');
    expect(learningMessage(400, 'Add at least one lesson before publishing.')).toBe(
      'Add at least one lesson before publishing.',
    );
  });
});
