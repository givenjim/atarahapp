import { ApiException } from '../common/api.exception';
import { transcodeArgs } from '../media/video-transcode';
import {
  applyProgress,
  certificateNumber,
  certificateTitle,
  DEFAULT_EMBED_HOSTS,
  lessonStates,
  minutesFor,
  nairobiDate,
  nairobiMonthStart,
  normaliseEmbedUrl,
  parseExternalUrl,
  percentComplete,
} from './learning.rules';

const code = (fn: () => unknown): string | undefined => {
  try {
    fn();
  } catch (e) {
    return (e as ApiException).code;
  }
  return undefined;
};

const NOW = new Date('2026-11-02T09:00:00Z');
const L = (n: number) =>
  Array.from({ length: n }, (_, i) => ({ id: `l${i + 1}`, sequence: i + 1 }));

describe('embed allow-list', () => {
  it('turns YouTube and Vimeo watch links into player addresses on allowed hosts', () => {
    const hosts = DEFAULT_EMBED_HOSTS;
    expect(normaliseEmbedUrl('https://www.youtube.com/watch?v=abcDEF12345', hosts)).toBe(
      'https://www.youtube-nocookie.com/embed/abcDEF12345',
    );
    expect(normaliseEmbedUrl('https://youtu.be/abcDEF12345?t=5', hosts)).toBe(
      'https://www.youtube-nocookie.com/embed/abcDEF12345',
    );
    expect(normaliseEmbedUrl('https://www.youtube.com/embed/abcDEF12345', hosts)).toBe(
      'https://www.youtube-nocookie.com/embed/abcDEF12345',
    );
    expect(normaliseEmbedUrl('https://vimeo.com/123456789', hosts)).toBe(
      'https://player.vimeo.com/video/123456789',
    );
    expect(normaliseEmbedUrl('https://player.vimeo.com/video/123456789#t=3', hosts)).toBe(
      'https://player.vimeo.com/video/123456789',
    );
  });

  it.each([
    ['a host that is not allowed', 'https://evil.example.com/embed/abc123456'],
    ['a look-alike host', 'https://www.youtube.com.evil.example.com/embed/abc123456'],
    ['plain http', 'http://player.vimeo.com/video/123456789'],
    ['credentials in the address', 'https://user:pw@player.vimeo.com/video/123456789'],
    ['a YouTube channel page', 'https://www.youtube.com/@someone'],
    ['a Vimeo page without a video', 'https://vimeo.com/channels/staffpicks'],
    ['not a web address', 'not a url'],
    ['a javascript address', 'javascript:alert(1)'],
  ])('refuses %s', (_name, url) => {
    expect(code(() => normaliseEmbedUrl(url, DEFAULT_EMBED_HOSTS))).toBe('VALIDATION_ERROR');
  });

  it('follows the list staff set, not the built-in one', () => {
    expect(() =>
      normaliseEmbedUrl('https://player.vimeo.com/video/123456789', ['www.youtube.com']),
    ).toThrow(ApiException);
    expect(normaliseEmbedUrl('https://media.example.org/embed/9', ['media.example.org'])).toBe(
      'https://media.example.org/embed/9',
    );
  });

  it('external resources must be https without credentials', () => {
    expect(parseExternalUrl(' https://example.org/a ')).toBe('https://example.org/a');
    for (const bad of [
      'http://example.org',
      'https://a:b@example.org',
      'ftp://example.org',
      'https://intranet',
    ]) {
      expect(code(() => parseExternalUrl(bad))).toBe('VALIDATION_ERROR');
    }
  });
});

describe('lesson states', () => {
  it('sequential: done, then one current, the rest locked', () => {
    const s = lessonStates(L(4), new Set(['l1']), true);
    expect([...s.values()]).toEqual(['DONE', 'CURRENT', 'LOCKED', 'LOCKED']);
  });

  it('completing in order moves the current lesson on, and finishing leaves everything done', () => {
    expect([...lessonStates(L(3), new Set(['l1', 'l2']), true).values()]).toEqual([
      'DONE',
      'DONE',
      'CURRENT',
    ]);
    expect([...lessonStates(L(3), new Set(['l1', 'l2', 'l3']), true).values()]).toEqual([
      'DONE',
      'DONE',
      'DONE',
    ]);
  });

  it('a lesson done out of order (a staff override) does not re-lock earlier ones', () => {
    const s = lessonStates(L(3), new Set(['l2']), true);
    expect([...s.values()]).toEqual(['CURRENT', 'DONE', 'LOCKED']);
  });

  it('non-sequential: nothing is locked', () => {
    const s = lessonStates(L(3), new Set(), false);
    expect([...s.values()]).toEqual(['CURRENT', 'AVAILABLE', 'AVAILABLE']);
  });

  it('not enrolled: the first lesson is only available and nothing is current', () => {
    expect([...lessonStates(L(3), new Set(), true, false).values()]).toEqual([
      'AVAILABLE',
      'LOCKED',
      'LOCKED',
    ]);
  });

  it('computes percentages safely', () => {
    expect(percentComplete(0, 0)).toBe(0);
    expect(percentComplete(1, 3)).toBe(33);
    expect(percentComplete(3, 3)).toBe(100);
    expect(percentComplete(9, 3)).toBe(100);
  });
});

describe('progress writes', () => {
  const MAX = 3600;

  it('moves the position forward, never back, and ignores a late earlier write', () => {
    const a = applyProgress(null, { positionSeconds: 90 }, NOW, MAX);
    expect(a).toMatchObject({
      status: 'IN_PROGRESS',
      lastPositionSeconds: 90,
      advancedSeconds: 90,
    });
    const late = applyProgress(a, { positionSeconds: 30 }, NOW, MAX);
    expect(late.lastPositionSeconds).toBe(90);
    expect(late.advancedSeconds).toBe(0);
    const on = applyProgress(late, { positionSeconds: 150 }, NOW, MAX);
    expect(on).toMatchObject({ lastPositionSeconds: 150, advancedSeconds: 60 });
  });

  it('is idempotent: the same write twice changes nothing the second time', () => {
    const once = applyProgress(null, { positionSeconds: 120 }, NOW, MAX);
    const twice = applyProgress(once, { positionSeconds: 120 }, NOW, MAX);
    expect(twice).toMatchObject({
      lastPositionSeconds: 120,
      advancedSeconds: 0,
      newlyCompleted: false,
      status: 'IN_PROGRESS',
    });
  });

  it('completes once: the first time is new, a repeat keeps the original time', () => {
    const first = applyProgress(null, { completed: true }, NOW, MAX);
    expect(first).toMatchObject({ status: 'COMPLETED', newlyCompleted: true, completedAt: NOW });
    const later = new Date(NOW.getTime() + 86_400_000);
    const again = applyProgress(first, { completed: true }, later, MAX);
    expect(again).toMatchObject({ status: 'COMPLETED', newlyCompleted: false });
    expect(again.completedAt).toEqual(NOW);
    // Writing a position after completion does not undo it.
    const after = applyProgress(first, { positionSeconds: 5 }, later, MAX);
    expect(after.status).toBe('COMPLETED');
    expect(after.completedAt).toEqual(NOW);
  });

  it('a restart goes back to zero and clears completion; only a restart can rewind', () => {
    const done = applyProgress(
      applyProgress(null, { positionSeconds: 300 }, NOW, MAX),
      { completed: true },
      NOW,
      MAX,
    );
    const restarted = applyProgress(done, { restart: true }, NOW, MAX);
    expect(restarted).toMatchObject({
      status: 'IN_PROGRESS',
      lastPositionSeconds: 0,
      completedAt: null,
    });
  });

  it('clamps nonsense positions to the lesson maximum and to zero', () => {
    expect(applyProgress(null, { positionSeconds: 999_999 }, NOW, MAX).lastPositionSeconds).toBe(
      MAX,
    );
    expect(applyProgress(null, { positionSeconds: -5 }, NOW, MAX).lastPositionSeconds).toBe(0);
  });

  it('counts whole minutes of forward movement, at most 15 per write', () => {
    expect(minutesFor(59)).toBe(0);
    expect(minutesFor(60)).toBe(1);
    expect(minutesFor(125)).toBe(2);
    expect(minutesFor(100_000)).toBe(15);
    expect(minutesFor(-4)).toBe(0);
  });
});

describe('certificates and Nairobi dates', () => {
  it('names the certificate after the month and year in Nairobi', () => {
    expect(certificateTitle(new Date('2026-10-15T10:00:00Z'))).toBe(
      'Atarah Skill Lab certificate · October 2026',
    );
    // 22:00 UTC on 31 Oct is already 1 Nov in Nairobi.
    expect(certificateTitle(new Date('2026-10-31T22:00:00Z'))).toBe(
      'Atarah Skill Lab certificate · November 2026',
    );
  });

  it('numbers certificates ATC-year-sequence', () => {
    expect(certificateNumber(2026, 7)).toBe('ATC-2026-000007');
    expect(certificateNumber(2027, 123456)).toBe('ATC-2027-123456');
  });

  it('finds the Nairobi date and month start', () => {
    expect(nairobiDate(new Date('2026-10-31T22:00:00Z')).toISOString()).toBe(
      '2026-11-01T00:00:00.000Z',
    );
    expect(nairobiMonthStart(new Date('2026-11-18T05:00:00Z')).toISOString()).toBe(
      '2026-11-01T00:00:00.000Z',
    );
  });
});

describe('video transcode command', () => {
  it('caps the height at 720p, never enlarges, encodes H.264 and AAC with the moov atom first', () => {
    const a = transcodeArgs('in', 'out.mp4', 'poster.jpg');
    expect(a.mp4).toEqual(expect.arrayContaining(['-c:v', 'libx264', '-c:a', 'aac', '+faststart']));
    expect(a.mp4.join(' ')).toContain("scale=-2:'min(720,ih)'");
    expect(a.mp4.at(-1)).toBe('out.mp4');
    expect(a.poster).toEqual(expect.arrayContaining(['-ss', '1', '-frames:v', '1']));
    expect(a.posterFromStart).not.toContain('-ss');
    expect(a.probe).toContain('format=duration');
  });
});
