import { type MediaKind } from '@prisma/client';

const MB = 1024 * 1024;

/** Size limits per kind (Master Prompt §7.4). */
export const MAX_BYTES: Record<MediaKind, number> = {
  IMAGE: 10 * MB,
  VIDEO: 200 * MB,
  AUDIO: 50 * MB,
  DOCUMENT: 10 * MB,
};

/** The only types accepted per kind. Everything else is refused before and after upload. */
export const ALLOWED_MIME: Record<MediaKind, readonly string[]> = {
  IMAGE: ['image/jpeg', 'image/png', 'image/webp'],
  VIDEO: ['video/mp4', 'video/quicktime', 'video/webm'],
  AUDIO: ['audio/mpeg', 'audio/mp4', 'audio/wav', 'audio/ogg'],
  DOCUMENT: ['application/pdf'],
};

export const IMAGE_VARIANT_WIDTHS = [200, 600, 1200] as const;
/** Guards against decompression bombs: refuse images that decode to more than this many pixels. */
export const MAX_IMAGE_PIXELS = 50_000_000;
export const SNIFF_BYTES = 4096;

const ALIASES: Record<string, string> = {
  'audio/x-wav': 'audio/wav',
  'audio/wave': 'audio/wav',
  'audio/mp3': 'audio/mpeg',
  'audio/x-m4a': 'audio/mp4',
  'image/jpg': 'image/jpeg',
};

export const normaliseMime = (mime: string): string => {
  const m = mime.trim().toLowerCase().split(';')[0]!.trim();
  return ALIASES[m] ?? m;
};

export const kindOfMime = (mime: string): MediaKind | null => {
  const m = normaliseMime(mime);
  for (const kind of Object.keys(ALLOWED_MIME) as MediaKind[]) {
    if (ALLOWED_MIME[kind].includes(m)) return kind;
  }
  return null;
};

export const EXTENSION: Record<string, string> = {
  'image/jpeg': 'jpg',
  'image/png': 'png',
  'image/webp': 'webp',
  'video/mp4': 'mp4',
  'video/quicktime': 'mov',
  'video/webm': 'webm',
  'audio/mpeg': 'mp3',
  'audio/mp4': 'm4a',
  'audio/wav': 'wav',
  'audio/ogg': 'ogg',
  'application/pdf': 'pdf',
};

/**
 * Identify a file from its first bytes. Never trusts the declared type, the file name or the extension:
 * a script renamed to `.jpg` has no JPEG signature and is rejected.
 */
export function sniffMime(head: Buffer): string | null {
  const b = head;
  const ascii = (from: number, to: number) => b.subarray(from, to).toString('latin1');
  if (b.length >= 3 && b[0] === 0xff && b[1] === 0xd8 && b[2] === 0xff) return 'image/jpeg';
  if (
    b.length >= 8 &&
    b.subarray(0, 8).equals(Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]))
  ) {
    return 'image/png';
  }
  if (b.length >= 12 && ascii(0, 4) === 'RIFF') {
    if (ascii(8, 12) === 'WEBP') return 'image/webp';
    if (ascii(8, 12) === 'WAVE') return 'audio/wav';
  }
  if (b.length >= 5 && ascii(0, 5) === '%PDF-') return 'application/pdf';
  if (b.length >= 12 && ascii(4, 8) === 'ftyp') {
    const brand = ascii(8, 12);
    if (brand === 'qt  ') return 'video/quicktime';
    if (brand === 'M4A ' || brand === 'M4B ') return 'audio/mp4';
    return 'video/mp4';
  }
  if (b.length >= 4 && b[0] === 0x1a && b[1] === 0x45 && b[2] === 0xdf && b[3] === 0xa3)
    return 'video/webm';
  if (b.length >= 4 && ascii(0, 4) === 'OggS') return 'audio/ogg';
  if (b.length >= 3 && ascii(0, 3) === 'ID3') return 'audio/mpeg';
  if (b.length >= 2 && b[0] === 0xff && (b[1]! & 0xe0) === 0xe0) return 'audio/mpeg';
  return null;
}
