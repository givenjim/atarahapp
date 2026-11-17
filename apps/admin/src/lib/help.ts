import { blocksToInput, validateBlocks, type BlockInput, type EditorBlock } from './articles';
import { deadlineToIso } from './opportunities';

/**
 * Pure helpers for Help & FAQ, legal documents and the privacy requests log (P1-M11). The API repeats every rule;
 * these only save a round trip and keep the screens consistent.
 */

type Tone = '' | 'success' | 'warning' | 'danger' | 'muted';

// ---- help articles ---------------------------------------------------------------------------------------------

export const SLUG_PATTERN = /^[a-z0-9]+(?:-[a-z0-9]+)*$/;
export const ARTICLE_TITLE_MAX = 140;
export const ARTICLE_SUMMARY_MAX = 300;
export const SLUG_MAX = 120;

/** Help blocks are text only: paragraph, heading, callout and quote (no images). */
export const HELP_BLOCK_TYPES = ['paragraph', 'heading', 'callout', 'quote'] as const;

/** A readable address from a title: "Report a post" becomes `report-a-post`. */
export function slugFromTitle(title: string): string {
  return title
    .toLowerCase()
    .normalize('NFKD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, SLUG_MAX)
    .replace(/-+$/g, '');
}

export interface HelpArticleForm {
  slug: string;
  title: string;
  summary: string;
  blocks: EditorBlock[];
  sortOrder: string;
  published: boolean;
}

export const emptyHelpArticleForm = (): HelpArticleForm => ({
  slug: '',
  title: '',
  summary: '',
  blocks: [],
  sortOrder: '',
  published: false,
});

export function validateHelpArticle(f: HelpArticleForm, mode: 'create' | 'edit'): string | null {
  const title = f.title.trim();
  if (title.length < 3) return 'Give the article a title of at least 3 characters.';
  if (title.length > ARTICLE_TITLE_MAX)
    return `The title can be up to ${ARTICLE_TITLE_MAX} characters.`;
  if (f.summary.trim().length > ARTICLE_SUMMARY_MAX) {
    return `The summary can be up to ${ARTICLE_SUMMARY_MAX} characters.`;
  }
  if (mode === 'create') {
    const slug = f.slug.trim();
    if (slug.length < 3 || slug.length > SLUG_MAX)
      return `The address must be 3 to ${SLUG_MAX} characters.`;
    if (!SLUG_PATTERN.test(slug))
      return 'The address can only use lower-case words separated by dashes.';
  }
  if (f.sortOrder.trim() && !/^\d{1,5}$/.test(f.sortOrder.trim())) {
    return 'The order must be a whole number from 0 to 10000.';
  }
  if (Number(f.sortOrder || 0) > 10_000) return 'The order must be a whole number from 0 to 10000.';
  const blocks = validateBlocks(f.blocks);
  if (blocks) return blocks;
  if (f.published && f.blocks.length === 0 && !f.summary.trim()) {
    return 'Add some text or a summary before publishing, or save it as a draft.';
  }
  return null;
}

/** The address (slug) is chosen when the article is created and never changed, so shared links keep working. */
export function helpArticlePayload(
  f: HelpArticleForm,
  mode: 'create' | 'edit',
): Record<string, unknown> {
  const body: Record<string, unknown> = {
    title: f.title.trim(),
    summary: f.summary.trim(),
    blocks: blocksToInput(f.blocks) satisfies BlockInput[],
    published: f.published,
  };
  if (f.sortOrder.trim()) body.sortOrder = Number.parseInt(f.sortOrder, 10);
  if (mode === 'create') body.slug = f.slug.trim();
  return body;
}

// ---- FAQ -------------------------------------------------------------------------------------------------------

export const QUESTION_MAX = 200;
export const ANSWER_MAX = 2000;

export interface FaqForm {
  question: string;
  answer: string;
  published: boolean;
}

export const emptyFaqForm = (): FaqForm => ({ question: '', answer: '', published: true });

export function validateFaq(f: FaqForm): string | null {
  const q = f.question.trim();
  const a = f.answer.trim();
  if (q.length < 5) return 'Write the question (at least 5 characters).';
  if (q.length > QUESTION_MAX) return `The question can be up to ${QUESTION_MAX} characters.`;
  if (a.length < 5) return 'Write the answer (at least 5 characters).';
  if (a.length > ANSWER_MAX) return `The answer can be up to ${ANSWER_MAX} characters.`;
  return null;
}

export const faqPayload = (f: FaqForm, sortOrder?: number): Record<string, unknown> => ({
  question: f.question.trim(),
  answer: f.answer.trim(),
  published: f.published,
  ...(sortOrder !== undefined ? { sortOrder } : {}),
});

/** The next free sort order for an entry added at the end of the list. */
export const nextSortOrder = (items: ReadonlyArray<{ sortOrder: number }>): number =>
  items.reduce((max, i) => Math.max(max, i.sortOrder), -1) + 1;

export interface Orderable {
  id: string;
  sortOrder: number;
}

/**
 * Moving an entry up or down swaps its order with its neighbour's. Returns the two updates to send (`id` and its new
 * `sortOrder`), or an empty list at either end. When both share an order (a fresh seed can), the entry that moves is
 * given the neighbour's position and the neighbour the next one, so the move still shows.
 */
export function swapOrders(
  items: readonly Orderable[],
  id: string,
  direction: 'up' | 'down',
): Array<{ id: string; sortOrder: number }> {
  const sorted = [...items].sort((a, b) => a.sortOrder - b.sortOrder);
  const i = sorted.findIndex((x) => x.id === id);
  const j = direction === 'up' ? i - 1 : i + 1;
  if (i < 0 || j < 0 || j >= sorted.length) return [];
  const a = sorted[i]!;
  const b = sorted[j]!;
  if (a.sortOrder === b.sortOrder) {
    // Re-number the whole run so that every entry has its own place, then swap the two.
    const orders = sorted.map((_, k) => k);
    [orders[i], orders[j]] = [orders[j]!, orders[i]!];
    return sorted
      .map((x, k) => ({ id: x.id, sortOrder: orders[k]! }))
      .filter((u, k) => u.sortOrder !== sorted[k]!.sortOrder);
  }
  return [
    { id: a.id, sortOrder: b.sortOrder },
    { id: b.id, sortOrder: a.sortOrder },
  ];
}

export const PUBLISHED_META = (published: boolean): { label: string; tone: Tone } =>
  published ? { label: 'Published', tone: 'success' } : { label: 'Draft', tone: 'muted' };

// ---- legal documents -------------------------------------------------------------------------------------------

export const LEGAL_TYPES = [
  'TERMS',
  'PRIVACY',
  'COMMUNITY_GUIDELINES',
  'PAYMENTS_REFUNDS',
  'SELLER_TERMS',
  'MENTOR_TERMS',
] as const;
export type LegalType = (typeof LEGAL_TYPES)[number];

export const LEGAL_LABELS: Record<LegalType, string> = {
  TERMS: 'Terms of Service',
  PRIVACY: 'Privacy Policy',
  COMMUNITY_GUIDELINES: 'Community Guidelines',
  PAYMENTS_REFUNDS: 'Payments & Refunds',
  SELLER_TERMS: 'Seller Terms',
  MENTOR_TERMS: 'Mentor Terms',
};

export const legalLabel = (t: string): string => LEGAL_LABELS[t as LegalType] ?? t;

export const LEGAL_STATUS_META: Record<string, { label: string; tone: Tone }> = {
  DRAFT: { label: 'Draft', tone: 'warning' },
  IN_REVIEW: { label: 'In review', tone: 'warning' },
  PUBLISHED: { label: 'Published', tone: 'success' },
  ARCHIVED: { label: 'Archived', tone: 'muted' },
};
export const legalStatusMeta = (s: string) =>
  LEGAL_STATUS_META[s] ?? { label: s.charAt(0) + s.slice(1).toLowerCase(), tone: '' as Tone };

/** A published or archived version is a record of what members agreed to: it is never edited, a new version is made. */
export const canEditLegal = (status: string): boolean =>
  status === 'DRAFT' || status === 'IN_REVIEW';
export const canPublishLegal = canEditLegal;

/** The label shown on a document that is still a draft ("DRAFT — pending legal review"). */
export const DRAFT_LABEL = 'DRAFT — pending legal review';

export const LEGAL_TITLE_MAX = 120;
export const LEGAL_BODY_MIN = 20;
export const LEGAL_BODY_MAX = 200_000;
export const VERSION_MAX = 20;

export interface LegalForm {
  type: string;
  version: string;
  title: string;
  body: string;
}

export const emptyLegalForm = (type: string = 'TERMS'): LegalForm => ({
  type,
  version: '',
  title: '',
  body: '',
});

export function validateLegalForm(f: LegalForm, mode: 'create' | 'edit'): string | null {
  const title = f.title.trim();
  if (title.length < 3) return 'Give the document a title of at least 3 characters.';
  if (title.length > LEGAL_TITLE_MAX)
    return `The title can be up to ${LEGAL_TITLE_MAX} characters.`;
  const body = f.body.trim();
  if (body.length < LEGAL_BODY_MIN) return `The text needs at least ${LEGAL_BODY_MIN} characters.`;
  if (body.length > LEGAL_BODY_MAX) return 'That text is too long.';
  if (mode === 'create') {
    if (!(LEGAL_TYPES as readonly string[]).includes(f.type))
      return 'Choose which document this is.';
    const v = f.version.trim();
    if (!v) return 'Give the version a name, like 2026.2.';
    if (v.length > VERSION_MAX) return `The version can be up to ${VERSION_MAX} characters.`;
  }
  return null;
}

export const legalPayload = (f: LegalForm, mode: 'create' | 'edit'): Record<string, unknown> =>
  mode === 'create'
    ? { type: f.type, version: f.version.trim(), title: f.title.trim(), body: f.body.trim() }
    : { title: f.title.trim(), body: f.body.trim() };

/**
 * When a published version takes effect. A blank value means now; otherwise a date and time entered in Nairobi time.
 * Returns undefined for blank, null when what was typed is not a date.
 */
export function effectiveAtToIso(local: string): string | undefined | null {
  const v = local.trim();
  if (!v) return undefined;
  return deadlineToIso(v);
}

export interface LegalRow {
  id: string;
  type: string;
  version: string;
  status: string;
  effectiveAt?: string | null;
  updatedAt: string;
}

/** Versions grouped by document type, in the order of {@link LEGAL_TYPES}, newest first inside each. */
export function groupLegal<T extends LegalRow>(
  rows: readonly T[],
): Array<{ type: LegalType; versions: T[] }> {
  return LEGAL_TYPES.map((type) => ({
    type,
    versions: rows
      .filter((r) => r.type === type)
      .sort((a, b) => b.updatedAt.localeCompare(a.updatedAt)),
  })).filter((g) => g.versions.length > 0);
}

// ---- privacy requests ------------------------------------------------------------------------------------------

export const PRIVACY_KINDS: ReadonlyArray<{ value: string; label: string }> = [
  { value: '', label: 'Exports and deletions' },
  { value: 'EXPORT', label: 'Data exports' },
  { value: 'DELETION', label: 'Account deletions' },
];

export const parsePrivacyKind = (v: string | undefined): 'EXPORT' | 'DELETION' | undefined =>
  v === 'EXPORT' || v === 'DELETION' ? v : undefined;

export const PRIVACY_KIND_LABEL: Record<string, string> = {
  EXPORT: 'Data export',
  DELETION: 'Account deletion',
};

export const PRIVACY_STATUS_META: Record<string, { label: string; tone: Tone }> = {
  PENDING: { label: 'In grace period', tone: 'warning' },
  QUEUED: { label: 'Queued', tone: 'warning' },
  PROCESSING: { label: 'Building', tone: 'warning' },
  READY: { label: 'Ready', tone: 'success' },
  EXPIRED: { label: 'Link expired', tone: 'muted' },
  FAILED: { label: 'Failed', tone: 'danger' },
  CANCELLED: { label: 'Cancelled', tone: 'muted' },
  PURGED: { label: 'Purged', tone: 'muted' },
};
export const privacyStatusMeta = (s: string) =>
  PRIVACY_STATUS_META[s] ?? { label: s.charAt(0) + s.slice(1).toLowerCase(), tone: '' as Tone };

/** What the due date means for each kind: an export link expires, a deletion is purged. */
export const dueLabel = (kind: string): string => (kind === 'EXPORT' ? 'Link expires' : 'Purge on');

/** Friendly wording for answers staff can see; anything else keeps the API's own message. */
export function helpMessage(status: number | undefined, message: string): string {
  if (status === 403) return 'You do not have permission to do that.';
  if (status === 404) return 'That item no longer exists.';
  if (status === 409) return message || 'That is not possible in the current state.';
  return message;
}

export const canManageHelp = (p: readonly string[]): boolean => p.includes('help.manage');
export const canManageLegal = (p: readonly string[]): boolean => p.includes('legal.manage');
export const canViewPrivacy = (p: readonly string[]): boolean => p.includes('user.view');
