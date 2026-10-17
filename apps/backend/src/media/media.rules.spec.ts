import { ALLOWED_MIME, MAX_BYTES, kindOfMime, normaliseMime, sniffMime } from './media.rules';

const bytes = (...b: number[]) => Buffer.from(b);
const ascii = (s: string, pad = 0) => Buffer.concat([Buffer.from(s, 'latin1'), Buffer.alloc(pad)]);

describe('sniffMime (identifies files by content, never by name or declared type)', () => {
  it.each([
    ['JPEG', bytes(0xff, 0xd8, 0xff, 0xe0, 0, 0), 'image/jpeg'],
    ['PNG', bytes(0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0), 'image/png'],
    ['WebP', Buffer.concat([ascii('RIFF'), bytes(0, 0, 0, 0), ascii('WEBPVP8 ')]), 'image/webp'],
    ['WAV', Buffer.concat([ascii('RIFF'), bytes(0, 0, 0, 0), ascii('WAVEfmt ')]), 'audio/wav'],
    ['PDF', ascii('%PDF-1.7\n'), 'application/pdf'],
    ['MP4', Buffer.concat([bytes(0, 0, 0, 0x18), ascii('ftypisom')]), 'video/mp4'],
    ['QuickTime', Buffer.concat([bytes(0, 0, 0, 0x14), ascii('ftypqt  ')]), 'video/quicktime'],
    ['M4A', Buffer.concat([bytes(0, 0, 0, 0x14), ascii('ftypM4A ')]), 'audio/mp4'],
    ['WebM', bytes(0x1a, 0x45, 0xdf, 0xa3, 0x9f), 'video/webm'],
    ['Ogg', ascii('OggS', 8), 'audio/ogg'],
    ['MP3 with ID3 tag', ascii('ID3', 8), 'audio/mpeg'],
    ['MP3 frame', bytes(0xff, 0xfb, 0x90, 0x00), 'audio/mpeg'],
  ])('%s', (_name, buf, expected) => {
    expect(sniffMime(buf)).toBe(expected);
  });

  it.each([
    ['a PHP script', ascii('<?php echo 1; ?>')],
    ['HTML', ascii('<!doctype html><script>alert(1)</script>')],
    ['SVG', ascii('<svg xmlns="http://www.w3.org/2000/svg"></svg>')],
    ['a Windows executable', ascii('MZ', 64)],
    ['an empty file', Buffer.alloc(0)],
    [
      'a RIFF container of an unknown type',
      Buffer.concat([ascii('RIFF'), bytes(0, 0, 0, 0), ascii('AVI LIST')]),
    ],
  ])('does not recognise %s', (_name, buf) => {
    expect(sniffMime(buf)).toBeNull();
  });
});

describe('media rules', () => {
  it('maps every allowed type to exactly one kind', () => {
    for (const [kind, mimes] of Object.entries(ALLOWED_MIME)) {
      for (const m of mimes) expect(kindOfMime(m)).toBe(kind);
    }
    expect(kindOfMime('image/svg+xml')).toBeNull();
    expect(kindOfMime('text/html')).toBeNull();
  });

  it('normalises casing, parameters and common aliases', () => {
    expect(normaliseMime('Image/JPEG; charset=binary')).toBe('image/jpeg');
    expect(normaliseMime('audio/x-wav')).toBe('audio/wav');
    expect(normaliseMime('image/jpg')).toBe('image/jpeg');
  });

  it('uses the documented size limits', () => {
    expect(MAX_BYTES).toEqual({
      IMAGE: 10 * 1024 * 1024,
      VIDEO: 200 * 1024 * 1024,
      AUDIO: 50 * 1024 * 1024,
      DOCUMENT: 10 * 1024 * 1024,
    });
  });
});
