import { ApiException } from '../common/api.exception';
import { REPORT_OUTCOME_COPY } from './community-notifications.listener';
import {
  decodeFeedCursor,
  encodeFeedCursor,
  rankAt,
  rankBoostMinutes,
  RANK_BOOST_MINUTES,
} from './feed-cursor';
import { parseLinkPreview } from './jobs/link-preview';
import {
  assertFetchableUrl,
  isPrivateAddress,
  SafeFetcher,
  UnsafeUrlError,
} from './jobs/safe-fetch';
import {
  allowedActions,
  cleanText,
  higherPriority,
  parseSafeLink,
  priorityFor,
  publicReportStatus,
  reportOutcome,
  statusAfter,
} from './rules';

const ID = '3f2b8c1e-5a4d-4e6f-8a1b-0c9d7e6f5a4b';

describe('feed cursor', () => {
  it('round-trips the ranking time and id', () => {
    const t = new Date('2026-10-22T10:15:30.123Z');
    const c = decodeFeedCursor(encodeFeedCursor(t, ID));
    expect(c).toEqual({ t: '2026-10-22T10:15:30.123Z', id: ID });
  });

  it('is opaque base64url, not readable JSON', () => {
    const c = encodeFeedCursor(new Date(), ID);
    expect(c).toMatch(/^[A-Za-z0-9_-]+$/);
    expect(c).not.toContain('{');
  });

  it.each([
    ['not base64 json', '%%%'],
    ['a plain string', Buffer.from('"hello"').toString('base64url')],
    ['a bad date', Buffer.from(JSON.stringify({ t: 'yesterday', id: ID })).toString('base64url')],
    [
      'a bad id',
      Buffer.from(JSON.stringify({ t: '2026-10-22T10:00:00Z', id: 'x' })).toString('base64url'),
    ],
    ['no id', Buffer.from(JSON.stringify({ t: '2026-10-22T10:00:00Z' })).toString('base64url')],
  ])('rejects %s with VALIDATION_ERROR', (_name, cursor) => {
    expect(() => decodeFeedCursor(cursor)).toThrow(ApiException);
    try {
      decodeFeedCursor(cursor);
    } catch (e) {
      expect((e as ApiException).code).toBe('VALIDATION_ERROR');
    }
  });
});

describe('light relevance ranking', () => {
  const none = {
    inGroup: false,
    connected: false,
    sameDiscipline: false,
    sameCounty: false,
    announcement: false,
  };

  it('adds nothing when nothing is shared', () => {
    expect(rankBoostMinutes(none)).toBe(0);
  });

  it('adds the weights of every shared signal', () => {
    expect(rankBoostMinutes({ ...none, inGroup: true, sameCounty: true })).toBe(
      RANK_BOOST_MINUTES.group + RANK_BOOST_MINUTES.county,
    );
  });

  it('only nudges: the total stays under a day and a half', () => {
    const all = rankBoostMinutes({
      inGroup: true,
      connected: true,
      sameDiscipline: true,
      sameCounty: true,
      announcement: true,
    });
    expect(all).toBeLessThan(36 * 60);
  });

  it('a group post can overtake a newer post, but a very old one cannot', () => {
    const now = new Date('2026-10-22T12:00:00Z');
    const hoursAgo = (h: number) => new Date(now.getTime() - h * 3_600_000);
    const groupPost = rankAt(hoursAgo(5), { ...none, inGroup: true });
    const plainNewer = rankAt(hoursAgo(1), none);
    expect(groupPost.getTime()).toBeGreaterThan(plainNewer.getTime());
    const groupOld = rankAt(hoursAgo(30), { ...none, inGroup: true });
    expect(groupOld.getTime()).toBeLessThan(plainNewer.getTime());
  });

  it('never ranks a post earlier than it was created (the feed query relies on this)', () => {
    const created = new Date('2026-10-22T08:00:00Z');
    expect(rankAt(created, none).getTime()).toBeGreaterThanOrEqual(created.getTime());
  });
});

describe('post text and links', () => {
  it('normalises line breaks and strips control characters', () => {
    expect(cleanText('  hello\r\nworld\u0000\u0007 \n')).toBe('hello\nworld');
  });

  it('accepts ordinary web links', () => {
    expect(parseSafeLink('https://example.com/a?b=1').hostname).toBe('example.com');
    expect(parseSafeLink(' http://news.example.co.ke/story ').protocol).toBe('http:');
  });

  it.each([
    'javascript:alert(1)',
    'file:///etc/passwd',
    'ftp://example.com/a',
    'https://user:pass@example.com/',
    'https://localhost/admin',
    'https://intranet/',
    'https://printer.local/',
    'not a url',
    `https://example.com/${'a'.repeat(2100)}`,
  ])('refuses %s', (bad) => {
    expect(() => parseSafeLink(bad)).toThrow(ApiException);
  });
});

describe('moderation rules', () => {
  it('prioritises serious reasons and repeated reports', () => {
    expect(priorityFor('INAPPROPRIATE', 1)).toBe('NORMAL');
    expect(priorityFor('HARASSMENT', 1)).toBe('HIGH');
    expect(priorityFor('SCAM', 1)).toBe('HIGH');
    expect(priorityFor('OTHER', 1)).toBe('LOW');
    expect(priorityFor('MISLEADING', 3)).toBe('HIGH');
    expect(priorityFor('OTHER', 10)).toBe('URGENT');
  });

  it('never lowers a priority', () => {
    expect(higherPriority('HIGH', 'NORMAL')).toBe('HIGH');
    expect(higherPriority('LOW', 'URGENT')).toBe('URGENT');
  });

  it('maps decisions to case statuses', () => {
    expect(statusAfter('NO_ACTION')).toBe('DISMISSED');
    expect(statusAfter('ESCALATE')).toBe('ESCALATED');
    for (const a of [
      'WARN_USER',
      'HIDE_CONTENT',
      'REMOVE_CONTENT',
      'RESTORE_CONTENT',
      'RESTRICT_ACCOUNT',
      'SUSPEND_ACCOUNT',
    ] as const) {
      expect(statusAfter(a)).toBe('RESOLVED');
    }
  });

  it('tells reporters only whether a decision was made, never how', () => {
    expect(publicReportStatus('SUBMITTED')).toBe('SUBMITTED');
    expect(publicReportStatus('IN_REVIEW')).toBe('UNDER_REVIEW');
    expect(publicReportStatus('ESCALATED')).toBe('UNDER_REVIEW'); // escalation is internal
    expect(publicReportStatus('RESOLVED')).toBe('REVIEWED');
    expect(publicReportStatus('DISMISSED')).toBe('REVIEWED');
    expect(reportOutcome('ESCALATED')).toBeNull();
    expect(reportOutcome('RESOLVED')).toBe('ACTION_TAKEN');
    expect(reportOutcome('DISMISSED')).toBe('NO_ACTION');
  });

  it('keeps internal details out of the reporter notification copy', () => {
    const text = JSON.stringify(REPORT_OUTCOME_COPY).toLowerCase();
    for (const internal of [
      'moderator',
      'suspend',
      'hidden',
      'removed',
      'escalat',
      'restrict',
      'warn',
      'reason',
    ]) {
      expect(text).not.toContain(internal);
    }
  });

  it('offers only the decisions that make sense for the target', () => {
    expect(allowedActions('POST')).toContain('HIDE_CONTENT');
    expect(allowedActions('USER')).not.toContain('HIDE_CONTENT');
    expect(allowedActions('GROUP')).not.toContain('SUSPEND_ACCOUNT');
    for (const t of ['POST', 'COMMENT', 'USER', 'GROUP'] as const) {
      expect(allowedActions(t)).toContain('NO_ACTION');
      expect(allowedActions(t)).toContain('ESCALATE');
    }
  });
});

describe('SSRF-safe fetching', () => {
  it.each([
    '127.0.0.1',
    '10.1.2.3',
    '172.16.0.1',
    '172.31.255.255',
    '192.168.1.1',
    '169.254.169.254', // cloud metadata
    '100.64.0.1',
    '0.0.0.0',
    '224.0.0.1',
    '::1',
    '::',
    'fe80::1',
    'fc00::1',
    'fd12:3456::1',
    '::ffff:127.0.0.1',
    '::ffff:7f00:1',
    '[::1]',
  ])('treats %s as private', (ip) => {
    expect(isPrivateAddress(ip)).toBe(true);
  });

  it.each(['8.8.8.8', '41.90.0.1', '172.32.0.1', '2606:4700:4700::1111', '1.1.1.1'])(
    'treats %s as public',
    (ip) => {
      expect(isPrivateAddress(ip)).toBe(false);
    },
  );

  it.each([
    'http://127.0.0.1/',
    'http://localhost:3000/',
    'http://[::1]/',
    'http://169.254.169.254/latest/meta-data/',
    'http://user:pw@example.com/',
    'gopher://example.com/',
    'file:///etc/passwd',
    'http://metadata.internal/',
  ])('refuses %s before connecting', (url) => {
    expect(() => assertFetchableUrl(url)).toThrow(UnsafeUrlError);
  });

  it('refuses a host name that resolves to a private address (DNS pointing inside)', async () => {
    const fetcher = new SafeFetcher();
    fetcher.resolve = async () => ['10.0.0.5'];
    await expect(fetcher.fetchHtml('https://innocent.example.com/')).rejects.toBeInstanceOf(
      UnsafeUrlError,
    );
  });

  it('refuses when any one of several resolved addresses is private', async () => {
    const fetcher = new SafeFetcher();
    fetcher.resolve = async () => ['93.184.216.34', '192.168.0.10'];
    await expect(fetcher.fetchHtml('https://mixed.example.com/')).rejects.toBeInstanceOf(
      UnsafeUrlError,
    );
  });

  it('refuses a name that does not resolve at all', async () => {
    const fetcher = new SafeFetcher();
    fetcher.resolve = async () => [];
    await expect(fetcher.fetchHtml('https://nowhere.example.com/')).rejects.toBeInstanceOf(
      UnsafeUrlError,
    );
  });
});

describe('link preview parsing', () => {
  const page = 'https://news.example.com/story/1';

  it('prefers Open Graph tags and decodes entities', () => {
    const html = `<html><head>
      <title>Fallback title</title>
      <meta property="og:title" content="Kenya&#39;s creative economy &amp; you">
      <meta content="A short summary." property="og:description">
      <meta property="og:image" content="/img/cover.jpg">
      <meta property="og:site_name" content="Example News">
    </head><body>ignored</body></html>`;
    expect(parseLinkPreview(html, page)).toEqual({
      title: "Kenya's creative economy & you",
      description: 'A short summary.',
      image: 'https://news.example.com/img/cover.jpg',
      siteName: 'Example News',
    });
  });

  it('falls back to the page title and host name', () => {
    const p = parseLinkPreview(
      '<head><title> Plain  page </title></head>',
      'https://www.example.org/x',
    );
    expect(p).toEqual({
      title: 'Plain page',
      description: null,
      image: null,
      siteName: 'example.org',
    });
  });

  it('keeps only absolute https images and never executes anything', () => {
    const http = parseLinkPreview(
      '<head><meta property="og:image" content="http://cdn.example.com/a.png"></head>',
      page,
    );
    expect(http.image).toBeNull();
    const js = parseLinkPreview(
      '<head><meta property="og:image" content="javascript:alert(1)"></head>',
      page,
    );
    expect(js.image).toBeNull();
  });

  it('clips very long text', () => {
    const long = 'x'.repeat(1000);
    const p = parseLinkPreview(`<head><meta property="og:title" content="${long}"></head>`, page);
    expect(p.title!.length).toBeLessThanOrEqual(200);
  });
});
