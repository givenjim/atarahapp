/** Pure helpers for the articles CMS and Home curation (no server imports, so client code and tests can use them). */

export type ArticleStatus = 'DRAFT' | 'IN_REVIEW' | 'PUBLISHED' | 'ARCHIVED';
export type ArticleSource = 'ATARAH' | 'PARTNER' | 'EXTERNAL';
export type BlockType = 'paragraph' | 'heading' | 'callout' | 'image' | 'quote';
export type LifecycleKind = 'submit' | 'return' | 'publish' | 'schedule' | 'archive' | 'restore';

export const STATUS_FILTERS: readonly { value: ArticleStatus | ''; label: string }[] = [
  { value: '', label: 'All' },
  { value: 'DRAFT', label: 'Draft' },
  { value: 'IN_REVIEW', label: 'In review' },
  { value: 'PUBLISHED', label: 'Published' },
  { value: 'ARCHIVED', label: 'Archived' },
];

const STATUS_VALUES = STATUS_FILTERS.map((s) => s.value).filter(Boolean) as ArticleStatus[];

/** Returns the status when it is a known one, otherwise undefined (so a bad query string is ignored). */
export const parseStatus = (value: string | undefined): ArticleStatus | undefined =>
  STATUS_VALUES.find((s) => s === value);

export const SOURCE_OPTIONS: readonly { value: ArticleSource; label: string }[] = [
  { value: 'ATARAH', label: 'Atarah' },
  { value: 'PARTNER', label: 'Partner' },
  { value: 'EXTERNAL', label: 'External' },
];

export const sourceNeedsLabel = (source: ArticleSource): boolean => source !== 'ATARAH';

export function statusPill(
  status: ArticleStatus,
  scheduled: boolean,
): { tone: '' | 'success' | 'warning' | 'muted'; label: string } {
  if (status === 'PUBLISHED') {
    return scheduled
      ? { tone: 'warning', label: 'Scheduled' }
      : { tone: 'success', label: 'Published' };
  }
  if (status === 'IN_REVIEW') return { tone: 'warning', label: 'In review' };
  if (status === 'ARCHIVED') return { tone: 'muted', label: 'Archived' };
  return { tone: '', label: 'Draft' };
}

/** Which lifecycle buttons apply to an article in this status. Archived articles are read-only. */
export function lifecycleOptions(status: ArticleStatus): LifecycleKind[] {
  switch (status) {
    case 'DRAFT':
      return ['submit'];
    case 'IN_REVIEW':
      return ['return', 'publish', 'schedule'];
    case 'PUBLISHED':
      return ['archive'];
    case 'ARCHIVED':
      return ['restore'];
  }
}

export const isEditable = (status: ArticleStatus): boolean => status !== 'ARCHIVED';

/** Friendly message for the API's answer to a lifecycle request. */
export function lifecycleMessage(status: number | undefined, fallback: string): string {
  if (status === 409) {
    return 'This article changed since you opened it. Refresh the page and try again.';
  }
  if (status === 404) return 'This article no longer exists.';
  return fallback;
}

/** Converts a `datetime-local` value to an ISO string; returns an error when it is not a future time. */
export function scheduleToIso(
  local: string,
  now: Date = new Date(),
): { ok: true; iso: string } | { ok: false; error: string } {
  if (!local) return { ok: false, error: 'Choose the date and time to publish.' };
  const d = new Date(local);
  if (Number.isNaN(d.getTime())) return { ok: false, error: 'That date and time is not valid.' };
  if (d.getTime() <= now.getTime()) {
    return { ok: false, error: 'Choose a time in the future, or use Publish now.' };
  }
  return { ok: true, iso: d.toISOString() };
}

export const TITLE_MAX = 200;
export const BYLINE_MAX = 120;

export function validateNewArticle(title: string, authorName: string): string | null {
  if (!title.trim()) return 'Give the article a title.';
  if (title.trim().length > TITLE_MAX) return `Keep the title to ${TITLE_MAX} characters or fewer.`;
  if (!authorName.trim()) return 'Give the article a byline.';
  if (authorName.trim().length > BYLINE_MAX) {
    return `Keep the byline to ${BYLINE_MAX} characters or fewer.`;
  }
  return null;
}

/** Splits comma or newline separated tags, trims, drops blanks and case-insensitive duplicates. */
export function parseTags(raw: string): string[] {
  const seen = new Set<string>();
  const out: string[] = [];
  for (const part of raw.split(/[,\n]/)) {
    const t = part.trim();
    if (t && !seen.has(t.toLowerCase())) {
      seen.add(t.toLowerCase());
      out.push(t);
    }
  }
  return out;
}

export const addTags = (tags: string[], raw: string): string[] =>
  parseTags([...tags, raw].join(','));

export const removeTag = (tags: string[], tag: string): string[] => tags.filter((t) => t !== tag);

// ---- block editor ----

export interface EditorBlock {
  /** Local identity for React keys; never sent to the API. */
  key: string;
  type: BlockType;
  text: string;
  title: string;
  mediaId: string;
  /** Preview URL (signed URL from the API, or a local object URL right after an upload). */
  imageUrl: string;
  caption: string;
  attribution: string;
}

export const BLOCK_LABELS: Record<BlockType, string> = {
  paragraph: 'Paragraph',
  heading: 'Heading',
  callout: 'Callout',
  quote: 'Quote',
  image: 'Image',
};

export const BLOCK_TYPES = Object.keys(BLOCK_LABELS) as BlockType[];

export const emptyBlock = (key: string, type: BlockType): EditorBlock => ({
  key,
  type,
  text: '',
  title: '',
  mediaId: '',
  imageUrl: '',
  caption: '',
  attribution: '',
});

export type BlockAction =
  | { kind: 'add'; key: string; type: BlockType }
  | { kind: 'remove'; key: string }
  | { kind: 'move'; key: string; direction: 'up' | 'down' }
  | { kind: 'update'; key: string; patch: Partial<Omit<EditorBlock, 'key' | 'type'>> };

export function blocksReducer(state: EditorBlock[], action: BlockAction): EditorBlock[] {
  switch (action.kind) {
    case 'add':
      return [...state, emptyBlock(action.key, action.type)];
    case 'remove':
      return state.filter((b) => b.key !== action.key);
    case 'move': {
      const i = state.findIndex((b) => b.key === action.key);
      const j = action.direction === 'up' ? i - 1 : i + 1;
      if (i < 0 || j < 0 || j >= state.length) return state;
      const next = [...state];
      [next[i], next[j]] = [next[j]!, next[i]!];
      return next;
    }
    case 'update':
      return state.map((b) => (b.key === action.key ? { ...b, ...action.patch } : b));
  }
}

interface ApiBlock {
  type: BlockType;
  text?: string | null;
  title?: string | null;
  mediaId?: string | null;
  imageUrl?: string | null;
  caption?: string | null;
  attribution?: string | null;
}

export function blocksFromApi(
  blocks: ApiBlock[],
  keyFor: (index: number) => string,
): EditorBlock[] {
  return blocks.map((b, i) => ({
    key: keyFor(i),
    type: b.type,
    text: b.text ?? '',
    title: b.title ?? '',
    mediaId: b.mediaId ?? '',
    imageUrl: b.imageUrl ?? '',
    caption: b.caption ?? '',
    attribution: b.attribution ?? '',
  }));
}

export interface BlockInput {
  type: BlockType;
  text?: string;
  title?: string;
  mediaId?: string;
  caption?: string;
  attribution?: string;
}

/** The body the API wants: only the fields that belong to each block type, blanks left out. */
export function blocksToInput(blocks: EditorBlock[]): BlockInput[] {
  return blocks.map((b) => {
    const out: BlockInput = { type: b.type };
    const put = (k: Exclude<keyof BlockInput, 'type'>, v: string) => {
      const t = v.trim();
      if (t) out[k] = t;
    };
    if (b.type === 'image') {
      put('mediaId', b.mediaId);
      put('caption', b.caption);
    } else {
      put('text', b.text);
      if (b.type === 'callout') put('title', b.title);
      if (b.type === 'quote') put('attribution', b.attribution);
    }
    return out;
  });
}

/** Plain-language problem with the blocks, or null when they can be saved. */
export function validateBlocks(blocks: EditorBlock[]): string | null {
  for (const [i, b] of blocks.entries()) {
    const n = `Block ${i + 1} (${BLOCK_LABELS[b.type].toLowerCase()})`;
    if (b.type === 'image') {
      if (!b.mediaId) return `${n} needs an image. Upload one or remove the block.`;
    } else if (!b.text.trim()) {
      return `${n} is empty. Write something or remove the block.`;
    }
  }
  return null;
}

export interface ArticleDraft {
  title: string;
  authorName: string;
  summary: string;
  source: ArticleSource;
  sourceLabel: string;
  heroMediaId: string;
  tags: string[];
  blocks: EditorBlock[];
}

export function validateDraft(d: ArticleDraft): string | null {
  if (!d.title.trim()) return 'The title cannot be empty.';
  if (d.title.trim().length > TITLE_MAX) {
    return `Keep the title to ${TITLE_MAX} characters or fewer.`;
  }
  if (!d.authorName.trim()) return 'The byline cannot be empty.';
  return validateBlocks(d.blocks);
}

/** What is still missing before the article can be submitted for review. */
export function submitGaps(d: ArticleDraft): string[] {
  const gaps: string[] = [];
  if (!d.summary.trim()) gaps.push('a summary');
  if (d.blocks.length === 0) gaps.push('at least one block of content');
  if (sourceNeedsLabel(d.source) && !d.sourceLabel.trim()) gaps.push('a source label');
  return gaps;
}

export function toUpdateBody(d: ArticleDraft) {
  return {
    title: d.title.trim(),
    authorName: d.authorName.trim(),
    summary: d.summary.trim(),
    source: d.source,
    sourceLabel: d.sourceLabel.trim(),
    heroMediaId: d.heroMediaId,
    tags: d.tags,
    blocks: blocksToInput(d.blocks),
  };
}

export const draftsEqual = (a: ArticleDraft, b: ArticleDraft): boolean =>
  JSON.stringify(toUpdateBody(a)) === JSON.stringify(toUpdateBody(b));

// ---- image upload ----

export const IMAGE_TYPES = ['image/jpeg', 'image/png', 'image/webp'] as const;

export function validateImageFile(file: { type: string; size: number }): string | null {
  if (!(IMAGE_TYPES as readonly string[]).includes(file.type)) {
    return 'Use a JPEG, PNG or WebP image.';
  }
  if (file.size <= 0) return 'That file is empty.';
  return null;
}
