import { describe, expect, it, vi } from 'vitest';
import {
  addTags,
  blocksFromApi,
  blocksReducer,
  blocksToInput,
  draftsEqual,
  emptyBlock,
  isEditable,
  lifecycleMessage,
  lifecycleOptions,
  parseStatus,
  parseTags,
  removeTag,
  scheduleToIso,
  statusPill,
  submitGaps,
  toUpdateBody,
  validateBlocks,
  validateDraft,
  validateImageFile,
  validateNewArticle,
  type ArticleDraft,
  type EditorBlock,
} from './articles';
import { uploadImage } from './image-upload';

const para = (key: string, text = 'Hello'): EditorBlock => ({
  ...emptyBlock(key, 'paragraph'),
  text,
});

const draft = (over: Partial<ArticleDraft> = {}): ArticleDraft => ({
  title: 'T',
  authorName: 'A',
  summary: 'S',
  source: 'ATARAH',
  sourceLabel: '',
  heroMediaId: '',
  tags: [],
  blocks: [para('a')],
  ...over,
});

describe('block reducer', () => {
  it('adds blocks of the chosen type at the end', () => {
    const s = blocksReducer([para('a')], { kind: 'add', key: 'b', type: 'quote' });
    expect(s.map((b) => [b.key, b.type])).toEqual([
      ['a', 'paragraph'],
      ['b', 'quote'],
    ]);
  });

  it('removes a block by key', () => {
    const s = blocksReducer([para('a'), para('b')], { kind: 'remove', key: 'a' });
    expect(s.map((b) => b.key)).toEqual(['b']);
  });

  it('moves up and down, and ignores moves past either end', () => {
    const base = [para('a'), para('b'), para('c')];
    expect(
      blocksReducer(base, { kind: 'move', key: 'c', direction: 'up' }).map((b) => b.key),
    ).toEqual(['a', 'c', 'b']);
    expect(
      blocksReducer(base, { kind: 'move', key: 'a', direction: 'down' }).map((b) => b.key),
    ).toEqual(['b', 'a', 'c']);
    expect(blocksReducer(base, { kind: 'move', key: 'a', direction: 'up' })).toBe(base);
    expect(blocksReducer(base, { kind: 'move', key: 'c', direction: 'down' })).toBe(base);
    expect(blocksReducer(base, { kind: 'move', key: 'zzz', direction: 'down' })).toBe(base);
  });

  it('updates only the matching block', () => {
    const s = blocksReducer([para('a'), para('b')], {
      kind: 'update',
      key: 'b',
      patch: { text: 'New' },
    });
    expect(s.map((b) => b.text)).toEqual(['Hello', 'New']);
  });
});

describe('block validation and API shape', () => {
  it('rejects empty text blocks and image blocks without an image', () => {
    expect(validateBlocks([para('a'), para('b', '  ')])).toMatch(/Block 2 \(paragraph\) is empty/);
    expect(validateBlocks([emptyBlock('i', 'image')])).toMatch(/Block 1 \(image\) needs an image/);
    expect(validateBlocks([para('a'), { ...emptyBlock('i', 'image'), mediaId: 'm1' }])).toBeNull();
    expect(validateBlocks([])).toBeNull();
  });

  it('sends only the fields that belong to each block type', () => {
    const out = blocksToInput([
      { ...emptyBlock('1', 'callout'), text: ' Tip ', title: 'Rule', attribution: 'ignored' },
      { ...emptyBlock('2', 'quote'), text: 'Q', attribution: 'Ama', title: 'ignored' },
      { ...emptyBlock('3', 'image'), mediaId: 'm1', caption: '', text: 'ignored' },
      { ...emptyBlock('4', 'heading'), text: 'H' },
    ]);
    expect(out).toEqual([
      { type: 'callout', text: 'Tip', title: 'Rule' },
      { type: 'quote', text: 'Q', attribution: 'Ama' },
      { type: 'image', mediaId: 'm1' },
      { type: 'heading', text: 'H' },
    ]);
  });

  it('maps API blocks into editor blocks with null-safe fields', () => {
    const b = blocksFromApi(
      [{ type: 'image', mediaId: 'm1', imageUrl: 'https://x/y.png', caption: null }],
      (i) => `k${i}`,
    );
    expect(b[0]).toMatchObject({
      key: 'k0',
      mediaId: 'm1',
      imageUrl: 'https://x/y.png',
      caption: '',
    });
  });
});

describe('draft', () => {
  it('validates title, byline and blocks, and builds the PATCH body', () => {
    expect(validateDraft(draft({ title: ' ' }))).toMatch(/title/);
    expect(validateDraft(draft({ authorName: '' }))).toMatch(/byline/);
    expect(validateDraft(draft({ blocks: [para('a', '')] }))).toMatch(/empty/);
    expect(validateDraft(draft())).toBeNull();
    expect(toUpdateBody(draft({ title: ' T ', heroMediaId: '' }))).toEqual({
      title: 'T',
      authorName: 'A',
      summary: 'S',
      source: 'ATARAH',
      sourceLabel: '',
      heroMediaId: '',
      tags: [],
      blocks: [{ type: 'paragraph', text: 'Hello' }],
    });
  });

  it('detects unsaved changes and ignores block keys and whitespace', () => {
    expect(draftsEqual(draft(), draft({ blocks: [para('zzz')] }))).toBe(true);
    expect(draftsEqual(draft(), draft({ title: ' T ' }))).toBe(true);
    expect(draftsEqual(draft(), draft({ summary: 'other' }))).toBe(false);
  });

  it('lists what is missing before submitting', () => {
    expect(submitGaps(draft())).toEqual([]);
    expect(submitGaps(draft({ summary: '', blocks: [], source: 'PARTNER' }))).toEqual([
      'a summary',
      'at least one block of content',
      'a source label',
    ]);
    expect(submitGaps(draft({ source: 'EXTERNAL', sourceLabel: 'BBC' }))).toEqual([]);
  });

  it('validates the new-article form', () => {
    expect(validateNewArticle('', 'A')).toMatch(/title/);
    expect(validateNewArticle('T', ' ')).toMatch(/byline/);
    expect(validateNewArticle('T', 'A')).toBeNull();
  });
});

describe('tags', () => {
  it('splits on commas and new lines, trims and drops duplicates', () => {
    expect(parseTags(' Film, music ,,FILM\nDesign')).toEqual(['Film', 'music', 'Design']);
    expect(addTags(['film'], 'Film, art')).toEqual(['film', 'art']);
    expect(removeTag(['a', 'b'], 'a')).toEqual(['b']);
  });
});

describe('lifecycle', () => {
  it('offers the right actions for each status', () => {
    expect(lifecycleOptions('DRAFT')).toEqual(['submit']);
    expect(lifecycleOptions('IN_REVIEW')).toEqual(['return', 'publish', 'schedule']);
    expect(lifecycleOptions('PUBLISHED')).toEqual(['archive']);
    expect(lifecycleOptions('ARCHIVED')).toEqual(['restore']);
  });

  it('treats archived articles as read-only', () => {
    expect(isEditable('ARCHIVED')).toBe(false);
    expect(isEditable('DRAFT')).toBe(true);
    expect(isEditable('PUBLISHED')).toBe(true);
  });

  it('labels scheduled articles as Scheduled', () => {
    expect(statusPill('PUBLISHED', true).label).toBe('Scheduled');
    expect(statusPill('PUBLISHED', false).label).toBe('Published');
    expect(statusPill('IN_REVIEW', false).label).toBe('In review');
    expect(statusPill('ARCHIVED', false).label).toBe('Archived');
    expect(statusPill('DRAFT', false).label).toBe('Draft');
  });

  it('requires a future time to schedule', () => {
    const now = new Date('2026-10-19T10:00:00');
    expect(scheduleToIso('', now)).toMatchObject({ ok: false });
    expect(scheduleToIso('nonsense', now)).toMatchObject({ ok: false });
    expect(scheduleToIso('2026-10-19T09:00', now)).toMatchObject({
      ok: false,
      error: expect.stringMatching(/future/),
    });
    const ok = scheduleToIso('2026-10-20T09:00', now);
    expect(ok).toEqual({ ok: true, iso: new Date('2026-10-20T09:00').toISOString() });
  });

  it('maps API errors to plain language and keeps the server message otherwise', () => {
    expect(lifecycleMessage(409, 'x')).toMatch(/changed/);
    expect(lifecycleMessage(404, 'x')).toMatch(/no longer exists/);
    expect(lifecycleMessage(400, 'Add a summary first.')).toBe('Add a summary first.');
  });

  it('parses the status filter and ignores unknown values', () => {
    expect(parseStatus('IN_REVIEW')).toBe('IN_REVIEW');
    expect(parseStatus('bogus')).toBeUndefined();
    expect(parseStatus(undefined)).toBeUndefined();
  });
});

describe('image upload', () => {
  it('checks the file type and size', () => {
    expect(validateImageFile({ type: 'image/png', size: 10 })).toBeNull();
    expect(validateImageFile({ type: 'application/pdf', size: 10 })).toMatch(/JPEG/);
    expect(validateImageFile({ type: 'image/png', size: 0 })).toMatch(/empty/);
  });

  const file = new File(['abc'], 'a.png', { type: 'image/png' });
  const ticket = {
    id: 'm1',
    uploadUrl: 'https://s3/put',
    headers: { 'content-type': 'image/png' },
  };

  it('requests a ticket, PUTs the bytes with its headers, then completes', async () => {
    const put = vi.fn().mockResolvedValue({ ok: true, status: 200 });
    const request = vi.fn().mockResolvedValue({ ok: true, ticket });
    const complete = vi.fn().mockResolvedValue({ ok: true });
    const r = await uploadImage(file, { request, complete, put: put as unknown as typeof fetch });
    expect(r).toEqual({ ok: true, mediaId: 'm1' });
    expect(request).toHaveBeenCalledWith('image/png', 3);
    expect(put).toHaveBeenCalledWith('https://s3/put', {
      method: 'PUT',
      headers: ticket.headers,
      body: file,
    });
    expect(complete).toHaveBeenCalledWith('m1');
  });

  it('stops without completing when storage refuses the bytes', async () => {
    const put = vi.fn().mockResolvedValue({ ok: false, status: 403 });
    const complete = vi.fn();
    const r = await uploadImage(file, {
      request: vi.fn().mockResolvedValue({ ok: true, ticket }),
      complete,
      put: put as unknown as typeof fetch,
    });
    expect(r).toMatchObject({ ok: false, error: expect.stringMatching(/403/) });
    expect(complete).not.toHaveBeenCalled();
  });

  it('reports a network failure and an API refusal', async () => {
    const down = await uploadImage(file, {
      request: vi.fn().mockResolvedValue({ ok: true, ticket }),
      complete: vi.fn(),
      put: vi.fn().mockRejectedValue(new Error('offline')) as unknown as typeof fetch,
    });
    expect(down).toMatchObject({ ok: false, error: expect.stringMatching(/connection/) });
    const refused = await uploadImage(file, {
      request: vi.fn().mockResolvedValue({ ok: false, error: 'No permission' }),
      complete: vi.fn(),
    });
    expect(refused).toEqual({ ok: false, error: 'No permission' });
    const bad = await uploadImage(new File(['x'], 'a.pdf', { type: 'application/pdf' }), {
      request: vi.fn(),
      complete: vi.fn(),
    });
    expect(bad).toMatchObject({ ok: false });
  });
});
