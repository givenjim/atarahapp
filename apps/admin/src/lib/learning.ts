/** Pure helpers for the Skill Labs (Learning) screens (no server imports): labels, form ↔ payload, lessons, gating. */
import { blocksToInput, emptyBlock, type BlockInput, type EditorBlock } from './articles';
import { isUuid, linkMeta, titleCase } from './opportunities';

export { isUuid, linkMeta, titleCase };

export const CONTENT_TYPES = [
  'COURSE',
  'TUTORIAL',
  'TOOLKIT',
  'WEBINAR',
  'MASTERCLASS',
  'ARTICLE',
] as const;
export const STATUSES = ['DRAFT', 'IN_REVIEW', 'PUBLISHED', 'ARCHIVED'] as const;
export const SOURCES = ['ATARAH', 'PARTNER', 'EXTERNAL'] as const;
export const DELIVERIES = ['NATIVE', 'EMBEDDED', 'EXTERNAL_LINK'] as const;
export const LEVELS = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT'] as const;
export const ACCESS = ['FREE', 'PREMIUM_CONTENT'] as const;
export const GROUPS = ['CREATIVE', 'BUSINESS', 'PROFESSIONAL'] as const;
export const OVERRIDE_ACTIONS = ['COMPLETE_LESSON', 'RESET_LESSON', 'RESET_COURSE'] as const;
export type OverrideAction = (typeof OVERRIDE_ACTIONS)[number];

type Tone = '' | 'success' | 'warning' | 'danger' | 'muted';

export const TYPE_LABELS: Record<string, string> = {
  COURSE: 'Course',
  TUTORIAL: 'Tutorial',
  TOOLKIT: 'Toolkit',
  WEBINAR: 'Webinar',
  MASTERCLASS: 'Masterclass',
  ARTICLE: 'Article',
};
export const typeLabel = (t: string): string => TYPE_LABELS[t] ?? titleCase(t);

export const STATUS_META: Record<string, { label: string; tone: Tone }> = {
  DRAFT: { label: 'Draft', tone: 'muted' },
  IN_REVIEW: { label: 'In review', tone: 'warning' },
  PUBLISHED: { label: 'Published', tone: 'success' },
  ARCHIVED: { label: 'Archived', tone: 'muted' },
};
export const statusMeta = (s: string) =>
  STATUS_META[s] ?? { label: titleCase(s), tone: '' as Tone };

/** The labels members see ("Atarah Course", "Partner content", "External resource"). */
export const SOURCE_LABELS: Record<string, string> = {
  ATARAH: 'Atarah',
  PARTNER: 'Partner content',
  EXTERNAL: 'External resource',
};
export const sourceLabel = (s: string): string => SOURCE_LABELS[s] ?? titleCase(s);

export const DELIVERY_LABELS: Record<string, string> = {
  NATIVE: 'In-app lessons',
  EMBEDDED: 'Embedded',
  EXTERNAL_LINK: 'Opens outside Atarah',
};
export const deliveryLabel = (d: string): string => DELIVERY_LABELS[d] ?? titleCase(d);

export const ACCESS_LABELS: Record<string, string> = {
  FREE: 'Free',
  PREMIUM_CONTENT: 'Premium content',
};
export const accessLabel = (a: string): string => ACCESS_LABELS[a] ?? titleCase(a);

export const GROUP_LABELS: Record<string, string> = {
  CREATIVE: 'Creative',
  BUSINESS: 'Business',
  PROFESSIONAL: 'Professional',
};
export const groupLabel = (g: string): string => GROUP_LABELS[g] ?? titleCase(g);

export const VIDEO_STATUS_META: Record<string, { label: string; tone: Tone }> = {
  UPLOADED: { label: 'Uploaded, waiting to be checked', tone: 'warning' },
  PROCESSING: { label: 'Being checked', tone: 'warning' },
  READY: { label: 'Ready to play', tone: 'success' },
  REJECTED: { label: 'Refused', tone: 'danger' },
  PENDING_UPLOAD: { label: 'Upload not finished', tone: 'warning' },
  MISSING: { label: 'File missing', tone: 'danger' },
};
export const videoStatusMeta = (s: string | null | undefined) =>
  VIDEO_STATUS_META[s ?? ''] ?? { label: s ? titleCase(s) : 'No video', tone: 'muted' as Tone };

// ---- permissions and lifecycle -------------------------------------------------------------------------------

export const canManageLearning = (permissions: readonly string[]): boolean =>
  permissions.includes('learning.manage');

export type LifecycleAction = 'publish' | 'unpublish' | 'archive';

/**
 * The moves that make sense for a status. A published item with learners cannot be sent back to draft (members
 * already on it keep it), so it is archived instead. The API checks every move again.
 */
export function actionsFor(status: string, learners: number): LifecycleAction[] {
  const out: LifecycleAction[] = [];
  if (status !== 'PUBLISHED') out.push('publish');
  if (status === 'PUBLISHED' && learners === 0) out.push('unpublish');
  if (status !== 'ARCHIVED') out.push('archive');
  return out;
}

/** Courses are taught in the app; every other type opens an embedded player or another site. */
export const deliveriesFor = (type: string): readonly string[] =>
  type === 'COURSE' ? ['NATIVE'] : ['EMBEDDED', 'EXTERNAL_LINK'];

// ---- embedded players ----------------------------------------------------------------------------------------

const YOUTUBE = new Set(['youtube.com', 'www.youtube.com', 'm.youtube.com', 'youtu.be']);

/**
 * The address a pasted video link becomes (YouTube and Vimeo watch links are converted to their player addresses) and
 * whether its host is allowed. This mirrors the API so most mistakes never leave the browser; the API is still the
 * authority and its answer is what the page shows afterwards.
 */
export function embedPreview(
  raw: string,
  allowedHosts: readonly string[],
): { ok: true; url: string } | { ok: false; error: string } {
  const text = raw.trim();
  let url: URL;
  try {
    url = new URL(text);
  } catch {
    return { ok: false, error: 'That is not a valid web address.' };
  }
  if (url.protocol !== 'https:' || url.username || url.password)
    return { ok: false, error: 'Embedded players must use https:// and contain no password.' };
  const host = url.hostname.toLowerCase();
  let out = url;
  if (YOUTUBE.has(host)) {
    const id =
      host === 'youtu.be'
        ? url.pathname.split('/')[1]
        : url.pathname.startsWith('/embed/')
          ? url.pathname.split('/')[2]
          : url.pathname === '/watch'
            ? url.searchParams.get('v')
            : null;
    if (!id || !/^[A-Za-z0-9_-]{6,20}$/.test(id))
      return { ok: false, error: 'That YouTube link does not point at a video.' };
    out = new URL(`https://www.youtube-nocookie.com/embed/${id}`);
  } else if (host === 'vimeo.com' || host === 'www.vimeo.com') {
    const id = url.pathname.split('/').filter(Boolean)[0];
    if (!id || !/^\d{5,12}$/.test(id))
      return { ok: false, error: 'That Vimeo link does not point at a video.' };
    out = new URL(`https://player.vimeo.com/video/${id}`);
  }
  if (!allowedHosts.map((h) => h.toLowerCase()).includes(out.hostname.toLowerCase()))
    return {
      ok: false,
      error: `Videos from ${out.hostname} cannot be embedded. Allowed: ${allowedHosts.join(', ')}.`,
    };
  out.hash = '';
  return { ok: true, url: out.href };
}

const isHttps = (v: string): boolean => /^https:\/\/[^\s/]+\.[^\s/]+/i.test(v.trim());

// ---- the content form ----------------------------------------------------------------------------------------

export interface ContentForm {
  title: string;
  type: string;
  summary: string;
  categoryId: string;
  level: string;
  durationMinutes: string;
  source: string;
  delivery: string;
  providerName: string;
  instructorUserId: string;
  externalUrl: string;
  embedUrl: string;
  coverMediaId: string;
  /** A preview address for the cover (signed address from the API, or a local one after an upload). */
  coverUrl: string;
  access: string;
  featured: boolean;
  whatYouLearn: string[];
  whoItsFor: string;
  disciplineIds: string[];
  skillIds: string[];
  sequential: boolean;
}

export const emptyContentForm = (): ContentForm => ({
  title: '',
  type: 'COURSE',
  summary: '',
  categoryId: '',
  level: 'BEGINNER',
  durationMinutes: '',
  source: 'ATARAH',
  delivery: 'NATIVE',
  providerName: '',
  instructorUserId: '',
  externalUrl: '',
  embedUrl: '',
  coverMediaId: '',
  coverUrl: '',
  access: 'FREE',
  featured: false,
  whatYouLearn: [''],
  whoItsFor: '',
  disciplineIds: [],
  skillIds: [],
  sequential: true,
});

export interface ContentDtoLike {
  title: string;
  type: string;
  summary: string;
  category: { id: string };
  level: string;
  durationMinutes: number;
  source: string;
  delivery: string;
  providerName?: string | null;
  instructorUserId?: string | null;
  externalUrl?: string | null;
  embedUrl?: string | null;
  coverMediaId?: string | null;
  coverUrl?: string | null;
  access: string;
  featured: boolean;
  whatYouLearn: string[];
  whoItsFor?: string | null;
  disciplineIds: string[];
  skillIds: string[];
  sequential?: boolean | null;
}

export function formFromDto(c: ContentDtoLike): ContentForm {
  return {
    title: c.title,
    type: c.type,
    summary: c.summary,
    categoryId: c.category.id,
    level: c.level,
    durationMinutes: c.type === 'COURSE' ? '' : String(c.durationMinutes),
    source: c.source,
    delivery: c.delivery,
    providerName: c.providerName ?? '',
    instructorUserId: c.instructorUserId ?? '',
    externalUrl: c.externalUrl ?? '',
    embedUrl: c.embedUrl ?? '',
    coverMediaId: c.coverMediaId ?? '',
    coverUrl: c.coverUrl ?? '',
    access: c.access,
    featured: c.featured,
    whatYouLearn: c.whatYouLearn.length > 0 ? [...c.whatYouLearn] : [''],
    whoItsFor: c.whoItsFor ?? '',
    disciplineIds: [...c.disciplineIds],
    skillIds: [...c.skillIds],
    sequential: c.sequential ?? true,
  };
}

/** Changing the type moves the delivery to one that suits it (a course is taught in the app). */
export function withType(f: ContentForm, type: string): ContentForm {
  const allowed = deliveriesFor(type);
  return {
    ...f,
    type,
    delivery: allowed.includes(f.delivery) ? f.delivery : (allowed[0] ?? 'EXTERNAL_LINK'),
  };
}

const cleanList = (items: string[]): string[] => items.map((s) => s.trim()).filter(Boolean);

/** First problem with the form, or null. The API repeats every rule, and checks the rest when publishing. */
export function validateContentForm(
  f: ContentForm,
  _mode: 'create' | 'edit',
  hosts: readonly string[],
): string | null {
  const title = f.title.trim();
  if (title.length < 3 || title.length > 140) return 'The title must be 3 to 140 characters.';
  const summary = f.summary.trim();
  if (summary.length < 10 || summary.length > 300)
    return 'The summary must be 10 to 300 characters.';
  if (!f.categoryId) return 'Choose a category.';
  if (f.type !== 'COURSE' && f.durationMinutes.trim()) {
    const n = Number(f.durationMinutes);
    if (!Number.isInteger(n) || n < 0 || n > 6000)
      return 'The duration is a whole number of minutes, up to 6,000.';
  }
  if (f.type === 'COURSE' && f.delivery !== 'NATIVE')
    return 'A course is taught in the app. Use another type for an external resource.';
  if (f.delivery === 'EXTERNAL_LINK' && f.externalUrl.trim() && !isHttps(f.externalUrl))
    return 'The link must start with https://.';
  if (f.delivery === 'EMBEDDED' && f.type !== 'COURSE' && f.embedUrl.trim()) {
    const p = embedPreview(f.embedUrl, hosts);
    if (!p.ok) return p.error;
  }
  if (f.instructorUserId.trim() && !isUuid(f.instructorUserId))
    return 'The instructor is a user id (a UUID) copied from the member’s page.';
  if (cleanList(f.whatYouLearn).length > 10) return 'List up to 10 things members will learn.';
  if (cleanList(f.whatYouLearn).some((s) => s.length > 160))
    return 'Each “what you’ll learn” line is 160 characters at most.';
  if (f.whoItsFor.length > 300) return 'The “who it’s for” note is 300 characters at most.';
  return null;
}

/**
 * The request body. Creating omits empty optional fields; editing sends null so a cleared field is cleared.
 * The type is sent only when it changed (the API refuses to turn a course into another type).
 */
export function toContentPayload(
  f: ContentForm,
  mode: 'create' | 'edit',
  originalType?: string,
): Record<string, unknown> {
  const edit = mode === 'edit';
  const course = f.type === 'COURSE';
  const body: Record<string, unknown> = {
    title: f.title.trim(),
    summary: f.summary.trim(),
    categoryId: f.categoryId,
    level: f.level,
    source: f.source,
    delivery: f.delivery,
    access: f.access,
    featured: f.featured,
    whatYouLearn: cleanList(f.whatYouLearn),
    disciplineIds: f.disciplineIds,
    skillIds: f.skillIds,
  };
  if (!edit || f.type !== originalType) body.type = f.type;
  if (course) body.sequential = f.sequential;
  else if (f.durationMinutes.trim()) body.durationMinutes = Number(f.durationMinutes);
  const optional = (key: string, value: string) => {
    const v = value.trim();
    if (v) body[key] = v;
    else if (edit) body[key] = null;
  };
  optional('providerName', f.providerName);
  optional('whoItsFor', f.whoItsFor);
  optional('instructorUserId', f.instructorUserId);
  if (f.delivery === 'EXTERNAL_LINK') {
    optional('externalUrl', f.externalUrl);
    if (edit) body.embedUrl = null;
  } else if (f.delivery === 'EMBEDDED' && !course) {
    optional('embedUrl', f.embedUrl);
    if (edit) body.externalUrl = null;
  } else if (edit) {
    body.externalUrl = null;
    body.embedUrl = null;
  }
  if (f.coverMediaId) body.coverMediaId = f.coverMediaId;
  else if (edit) body.coverMediaId = null;
  return body;
}

// ---- categories ----------------------------------------------------------------------------------------------

export interface CategoryForm {
  name: string;
  group: string;
  sortOrder: string;
  isActive: boolean;
}

export const emptyCategoryForm = (): CategoryForm => ({
  name: '',
  group: 'CREATIVE',
  sortOrder: '',
  isActive: true,
});

export function validateCategory(f: CategoryForm): string | null {
  const name = f.name.trim();
  if (name.length < 2 || name.length > 60) return 'The name must be 2 to 60 characters.';
  if (f.sortOrder.trim()) {
    const n = Number(f.sortOrder);
    if (!Number.isInteger(n) || n < 0 || n > 1000)
      return 'The order is a whole number from 0 to 1,000.';
  }
  return null;
}

export function categoryPayload(f: CategoryForm): Record<string, unknown> {
  return {
    name: f.name.trim(),
    group: f.group,
    isActive: f.isActive,
    ...(f.sortOrder.trim() ? { sortOrder: Number(f.sortOrder) } : {}),
  };
}

interface CategoryLike {
  id: string;
  group: string;
  sortOrder: number;
  name: string;
}

/** Categories under their three groups in the order members see them (Creative, Business, Professional). */
export function groupCategories<T extends CategoryLike>(
  items: readonly T[],
): Array<{ group: string; items: T[] }> {
  return GROUPS.map((group) => ({
    group,
    items: items
      .filter((c) => c.group === group)
      .sort((a, b) => a.sortOrder - b.sortOrder || a.name.localeCompare(b.name)),
  }));
}

// ---- lessons -------------------------------------------------------------------------------------------------

export type Player = 'NONE' | 'VIDEO' | 'EMBED';

export interface LessonForm {
  title: string;
  durationMinutes: string;
  blocks: EditorBlock[];
  player: Player;
  videoMediaId: string;
  embedUrl: string;
  practicePrompt: string;
  practiceSkillId: string;
}

export const emptyLessonForm = (): LessonForm => ({
  title: '',
  durationMinutes: '',
  blocks: [],
  player: 'NONE',
  videoMediaId: '',
  embedUrl: '',
  practicePrompt: '',
  practiceSkillId: '',
});

export interface LessonDtoLike {
  title: string;
  durationMinutes: number;
  body: Array<{
    type: string;
    text?: string | null;
    title?: string | null;
    mediaId?: string | null;
    imageUrl?: string | null;
    caption?: string | null;
    attribution?: string | null;
  }>;
  videoMediaId?: string | null;
  embedUrl?: string | null;
  practicePrompt?: string | null;
  practiceSkillId?: string | null;
}

export function lessonFormFromDto(l: LessonDtoLike, keyFor: (i: number) => string): LessonForm {
  return {
    title: l.title,
    durationMinutes: l.durationMinutes > 0 ? String(l.durationMinutes) : '',
    blocks: l.body.map((b, i) => ({
      ...emptyBlock(keyFor(i), b.type as EditorBlock['type']),
      text: b.text ?? '',
      title: b.title ?? '',
      mediaId: b.mediaId ?? '',
      imageUrl: b.imageUrl ?? '',
      caption: b.caption ?? '',
      attribution: b.attribution ?? '',
    })),
    player: l.videoMediaId ? 'VIDEO' : l.embedUrl ? 'EMBED' : 'NONE',
    videoMediaId: l.videoMediaId ?? '',
    embedUrl: l.embedUrl ?? '',
    practicePrompt: l.practicePrompt ?? '',
    practiceSkillId: l.practiceSkillId ?? '',
  };
}

export function validateLessonForm(f: LessonForm, hosts: readonly string[]): string | null {
  const title = f.title.trim();
  if (title.length < 2 || title.length > 140)
    return 'The lesson title must be 2 to 140 characters.';
  if (f.durationMinutes.trim()) {
    const n = Number(f.durationMinutes);
    if (!Number.isInteger(n) || n < 0 || n > 600)
      return 'The length is a whole number of minutes, up to 600.';
  }
  for (const [i, b] of f.blocks.entries()) {
    if (b.type === 'image') {
      if (!b.mediaId)
        return `Block ${i + 1} (image) needs an image. Upload one or remove the block.`;
    } else if (!b.text.trim()) {
      return `Block ${i + 1} (${b.type}) is empty. Write something or remove the block.`;
    }
  }
  if (f.player === 'VIDEO' && !f.videoMediaId) return 'Upload the video, or choose “No video”.';
  if (f.player === 'EMBED') {
    if (!f.embedUrl.trim()) return 'Paste the embedded player address, or choose “No video”.';
    const p = embedPreview(f.embedUrl, hosts);
    if (!p.ok) return p.error;
  }
  if (f.practicePrompt.length > 400) return 'The practice prompt is 400 characters at most.';
  if (f.practiceSkillId && !f.practicePrompt.trim())
    return 'A practice skill needs a practice prompt as well.';
  return null;
}

/**
 * The lesson request body. A lesson plays an uploaded video or an embedded player, never both, so the one not chosen is
 * sent as null when editing (and left out when creating).
 */
export function lessonPayload(f: LessonForm, mode: 'create' | 'edit'): Record<string, unknown> {
  const edit = mode === 'edit';
  const body: Record<string, unknown> = {
    title: f.title.trim(),
    body: blocksToInput(f.blocks) satisfies BlockInput[],
  };
  if (f.durationMinutes.trim()) body.durationMinutes = Number(f.durationMinutes);
  else if (edit) body.durationMinutes = 0;
  if (f.player === 'VIDEO') {
    body.videoMediaId = f.videoMediaId;
    if (edit) body.embedUrl = null;
  } else if (f.player === 'EMBED') {
    body.embedUrl = f.embedUrl.trim();
    if (edit) body.videoMediaId = null;
  } else if (edit) {
    body.videoMediaId = null;
    body.embedUrl = null;
  }
  const prompt = f.practicePrompt.trim();
  if (prompt) body.practicePrompt = prompt;
  else if (edit) body.practicePrompt = null;
  if (f.practiceSkillId && prompt) body.practiceSkillId = f.practiceSkillId;
  else if (edit) body.practiceSkillId = null;
  return body;
}

/** Moves one item one place; the same list back when it cannot move. Used for the lesson order. */
export function moveItem<T>(items: readonly T[], index: number, direction: -1 | 1): T[] {
  const to = index + direction;
  if (to < 0 || to >= items.length) return [...items];
  const out = [...items];
  [out[index], out[to]] = [out[to]!, out[index]!];
  return out;
}

/** The body of the reorder request: every lesson id, once, in the new order. */
export const orderIds = (lessons: ReadonlyArray<{ id: string }>): string[] =>
  lessons.map((l) => l.id);

export const orderChanged = (
  before: ReadonlyArray<{ id: string }>,
  after: ReadonlyArray<{ id: string }>,
): boolean => before.length !== after.length || before.some((l, i) => l.id !== after[i]?.id);

// ---- video upload --------------------------------------------------------------------------------------------

export const VIDEO_TYPES = ['video/mp4', 'video/quicktime', 'video/webm'] as const;
export const VIDEO_MAX_BYTES = 200 * 1024 * 1024;

export function validateVideoFile(file: { type: string; size: number }): string | null {
  if (!(VIDEO_TYPES as readonly string[]).includes(file.type))
    return 'Choose an MP4, MOV or WebM video.';
  if (file.size <= 0) return 'That file is empty.';
  if (file.size > VIDEO_MAX_BYTES) return 'That video is too large (200 MB at most).';
  return null;
}

// ---- progress overrides --------------------------------------------------------------------------------------

export interface OverrideForm {
  userId: string;
  action: OverrideAction;
  lessonId: string;
  reason: string;
}

export const emptyOverride = (): OverrideForm => ({
  userId: '',
  action: 'COMPLETE_LESSON',
  lessonId: '',
  reason: '',
});

export const OVERRIDE_LABELS: Record<OverrideAction, string> = {
  COMPLETE_LESSON: 'Mark a lesson complete',
  RESET_LESSON: 'Reset a lesson',
  RESET_COURSE: 'Reset the whole course',
};

export function validateOverride(f: OverrideForm): string | null {
  if (!isUuid(f.userId)) return 'The member is a user id (a UUID) copied from their page.';
  if (f.action !== 'RESET_COURSE' && !f.lessonId) return 'Choose the lesson.';
  const reason = f.reason.trim();
  if (reason.length < 10)
    return 'Give a reason of at least 10 characters. It is kept with the audit entry.';
  if (reason.length > 400) return 'The reason is 400 characters at most.';
  return null;
}

export function overridePayload(courseId: string, f: OverrideForm): Record<string, unknown> {
  return {
    userId: f.userId.trim(),
    courseId,
    action: f.action,
    reason: f.reason.trim(),
    ...(f.action !== 'RESET_COURSE' ? { lessonId: f.lessonId } : {}),
  };
}

// ---- analytics and messages ----------------------------------------------------------------------------------

export const formatRate = (n: number): string => `${Math.round(n)}%`;

/** Friendly wording for the answers staff can see; anything else keeps the API's own message. */
export function learningMessage(status: number | undefined, message: string): string {
  if (status === 403) return 'You do not have permission to do that.';
  if (status === 404) return 'That item no longer exists.';
  if (status === 409) return message || 'That is not possible in the current state.';
  return message;
}
