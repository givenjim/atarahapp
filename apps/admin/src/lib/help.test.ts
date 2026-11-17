import { describe, expect, it } from 'vitest';
import { emptyBlock, type EditorBlock } from './articles';
import {
  canEditLegal,
  canManageHelp,
  canManageLegal,
  canViewPrivacy,
  dueLabel,
  effectiveAtToIso,
  emptyFaqForm,
  emptyHelpArticleForm,
  emptyLegalForm,
  faqPayload,
  groupLegal,
  helpArticlePayload,
  legalLabel,
  legalPayload,
  legalStatusMeta,
  nextSortOrder,
  parsePrivacyKind,
  privacyStatusMeta,
  slugFromTitle,
  swapOrders,
  validateFaq,
  validateHelpArticle,
  validateLegalForm,
  type HelpArticleForm,
} from './help';

const text = (key: string, value: string): EditorBlock => ({
  ...emptyBlock(key, 'paragraph'),
  text: value,
});
const article = (over: Partial<HelpArticleForm> = {}): HelpArticleForm => ({
  ...emptyHelpArticleForm(),
  slug: 'report-a-post',
  title: 'Report a post',
  blocks: [text('b1', 'Tap the three dots, then Report.')],
  ...over,
});

describe('help articles', () => {
  it('makes tidy addresses from titles', () => {
    expect(slugFromTitle('Report, block & mute: how it works!')).toBe(
      'report-block-mute-how-it-works',
    );
    expect(slugFromTitle('  Café Hélène  ')).toBe('cafe-helene');
    expect(slugFromTitle('***')).toBe('');
  });

  it('validates the title, address, order and text blocks', () => {
    expect(validateHelpArticle(article(), 'create')).toBeNull();
    expect(validateHelpArticle(article({ title: 'ab' }), 'create')).toMatch(/title/);
    expect(validateHelpArticle(article({ slug: 'Bad Slug' }), 'create')).toMatch(/lower-case/);
    expect(validateHelpArticle(article({ slug: 'ab' }), 'create')).toMatch(/address/);
    // The address is fixed after creation, so editing ignores it.
    expect(validateHelpArticle(article({ slug: '' }), 'edit')).toBeNull();
    expect(validateHelpArticle(article({ sortOrder: 'first' }), 'create')).toMatch(/order/);
    expect(validateHelpArticle(article({ sortOrder: '20000' }), 'create')).toMatch(/order/);
    expect(validateHelpArticle(article({ blocks: [text('b', '  ')] }), 'create')).toMatch(/empty/);
    expect(
      validateHelpArticle(article({ published: true, blocks: [], summary: '' }), 'create'),
    ).toMatch(/before publishing/);
    expect(
      validateHelpArticle(article({ published: false, blocks: [], summary: '' }), 'create'),
    ).toBeNull();
  });

  it('builds the payload: slug only on create, blanks left out of blocks, order as a number', () => {
    const create = helpArticlePayload(article({ sortOrder: '3', published: true }), 'create');
    expect(create).toMatchObject({
      slug: 'report-a-post',
      title: 'Report a post',
      published: true,
      sortOrder: 3,
      blocks: [{ type: 'paragraph', text: 'Tap the three dots, then Report.' }],
    });
    const edit = helpArticlePayload(article(), 'edit');
    expect(edit).not.toHaveProperty('slug');
    expect(edit).not.toHaveProperty('sortOrder');
  });
});

describe('FAQ', () => {
  it('validates and builds the payload', () => {
    expect(validateFaq(emptyFaqForm())).toMatch(/question/);
    expect(validateFaq({ question: 'How do I report?', answer: 'x', published: true })).toMatch(
      /answer/,
    );
    const ok = { question: ' How do I report? ', answer: ' Tap Report. ', published: true };
    expect(validateFaq(ok)).toBeNull();
    expect(faqPayload(ok, 4)).toEqual({
      question: 'How do I report?',
      answer: 'Tap Report.',
      published: true,
      sortOrder: 4,
    });
    expect(faqPayload(ok)).not.toHaveProperty('sortOrder');
  });

  it('adds new entries at the end', () => {
    expect(nextSortOrder([])).toBe(0);
    expect(nextSortOrder([{ sortOrder: 0 }, { sortOrder: 6 }, { sortOrder: 2 }])).toBe(7);
  });
});

describe('reordering', () => {
  const items = [
    { id: 'a', sortOrder: 0 },
    { id: 'b', sortOrder: 1 },
    { id: 'c', sortOrder: 2 },
  ];

  it('swaps the order with the neighbour', () => {
    expect(swapOrders(items, 'b', 'up')).toEqual([
      { id: 'b', sortOrder: 0 },
      { id: 'a', sortOrder: 1 },
    ]);
    expect(swapOrders(items, 'b', 'down')).toEqual([
      { id: 'b', sortOrder: 2 },
      { id: 'c', sortOrder: 1 },
    ]);
  });

  it('does nothing at either end or for an unknown entry', () => {
    expect(swapOrders(items, 'a', 'up')).toEqual([]);
    expect(swapOrders(items, 'c', 'down')).toEqual([]);
    expect(swapOrders(items, 'zzz', 'up')).toEqual([]);
  });

  it('still moves when entries share an order (a fresh seed can)', () => {
    const same = [
      { id: 'a', sortOrder: 0 },
      { id: 'b', sortOrder: 0 },
      { id: 'c', sortOrder: 0 },
    ];
    const updates = swapOrders(same, 'c', 'up');
    const after = same
      .map((i) => updates.find((u) => u.id === i.id) ?? i)
      .sort((x, y) => x.sortOrder - y.sortOrder);
    expect(after.map((i) => i.id)).toEqual(['a', 'c', 'b']);
  });
});

describe('legal documents', () => {
  it('only drafts are editable or publishable; published and archived versions are records', () => {
    expect(canEditLegal('DRAFT')).toBe(true);
    expect(canEditLegal('IN_REVIEW')).toBe(true);
    expect(canEditLegal('PUBLISHED')).toBe(false);
    expect(canEditLegal('ARCHIVED')).toBe(false);
  });

  it('validates a new version and a draft edit', () => {
    const ok = {
      ...emptyLegalForm('PRIVACY'),
      version: '2026.2',
      title: 'Privacy Policy',
      body: 'x'.repeat(40),
    };
    expect(validateLegalForm(ok, 'create')).toBeNull();
    expect(validateLegalForm({ ...ok, version: ' ' }, 'create')).toMatch(/version/);
    expect(validateLegalForm({ ...ok, version: 'v'.repeat(21) }, 'create')).toMatch(/version/);
    expect(validateLegalForm({ ...ok, type: 'NOPE' }, 'create')).toMatch(/Choose which/);
    expect(validateLegalForm({ ...ok, body: 'short' }, 'create')).toMatch(/text/);
    expect(validateLegalForm({ ...ok, title: '' }, 'create')).toMatch(/title/);
    // Editing a draft ignores the type and version, which never change.
    expect(validateLegalForm({ ...ok, version: '', type: '' }, 'edit')).toBeNull();
  });

  it('sends type and version only when creating', () => {
    const f = {
      type: 'TERMS',
      version: ' 2026.3 ',
      title: ' Terms ',
      body: ' ' + 'y'.repeat(30) + ' ',
    };
    expect(legalPayload(f, 'create')).toEqual({
      type: 'TERMS',
      version: '2026.3',
      title: 'Terms',
      body: 'y'.repeat(30),
    });
    expect(legalPayload(f, 'edit')).toEqual({ title: 'Terms', body: 'y'.repeat(30) });
  });

  it('reads the effective time in Nairobi time; blank means now', () => {
    expect(effectiveAtToIso('')).toBeUndefined();
    expect(effectiveAtToIso('2026-12-01T09:00')).toBe('2026-12-01T06:00:00.000Z');
    expect(effectiveAtToIso('not a date')).toBeNull();
  });

  it('groups versions by document in the usual order, newest first', () => {
    const rows = [
      {
        id: '1',
        type: 'PRIVACY',
        version: '1',
        status: 'ARCHIVED',
        updatedAt: '2026-01-01T00:00:00Z',
      },
      {
        id: '2',
        type: 'TERMS',
        version: '1',
        status: 'PUBLISHED',
        updatedAt: '2026-02-01T00:00:00Z',
      },
      {
        id: '3',
        type: 'PRIVACY',
        version: '2',
        status: 'DRAFT',
        updatedAt: '2026-03-01T00:00:00Z',
      },
    ];
    const g = groupLegal(rows);
    expect(g.map((x) => x.type)).toEqual(['TERMS', 'PRIVACY']);
    expect(g[1]!.versions.map((v) => v.id)).toEqual(['3', '1']);
    expect(legalLabel('COMMUNITY_GUIDELINES')).toBe('Community Guidelines');
    expect(legalStatusMeta('DRAFT')).toEqual({ label: 'Draft', tone: 'warning' });
    expect(legalStatusMeta('PUBLISHED').tone).toBe('success');
  });
});

describe('privacy requests and permissions', () => {
  it('names kinds, statuses and due dates', () => {
    expect(parsePrivacyKind('EXPORT')).toBe('EXPORT');
    expect(parsePrivacyKind('DELETION')).toBe('DELETION');
    expect(parsePrivacyKind('x')).toBeUndefined();
    expect(privacyStatusMeta('READY').tone).toBe('success');
    expect(privacyStatusMeta('PURGED').label).toBe('Purged');
    expect(privacyStatusMeta('PENDING').label).toBe('In grace period');
    expect(privacyStatusMeta('FAILED').tone).toBe('danger');
    expect(dueLabel('EXPORT')).toBe('Link expires');
    expect(dueLabel('DELETION')).toBe('Purge on');
  });

  it('gates each screen on its own permission', () => {
    expect(canManageHelp(['help.manage'])).toBe(true);
    expect(canManageHelp(['legal.manage'])).toBe(false);
    expect(canManageLegal(['legal.manage'])).toBe(true);
    expect(canManageLegal(['help.manage'])).toBe(false);
    expect(canViewPrivacy(['user.view'])).toBe(true);
    expect(canViewPrivacy(['admin.access'])).toBe(false);
  });
});
