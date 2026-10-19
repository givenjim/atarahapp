import { ApiException } from '../common/api.exception';
import { type ArticleBlockInputDto, MAX_BLOCKS } from './content.dto';

/** What is stored in `articles.body`. Plain data, no HTML. */
export type StoredBlock =
  | { type: 'paragraph'; text: string }
  | { type: 'heading'; text: string }
  | { type: 'callout'; title: string | null; text: string }
  | { type: 'image'; mediaId: string; caption: string | null }
  | { type: 'quote'; text: string; attribution: string | null };

const clean = (s: string | undefined): string => (s ?? '').trim();
const orNull = (s: string | undefined): string | null => clean(s) || null;

/** Checks each block has what its type needs and drops the rest. Throws a VALIDATION_ERROR on the first bad block. */
export function normaliseBlocks(input: ArticleBlockInputDto[]): StoredBlock[] {
  if (input.length > MAX_BLOCKS) {
    throw ApiException.validation(`An article can have up to ${MAX_BLOCKS} blocks.`, {
      field: 'blocks',
    });
  }
  return input.map((b, i) => {
    const where = { field: 'blocks', index: i };
    switch (b.type) {
      case 'paragraph':
      case 'heading': {
        const text = clean(b.text);
        if (!text) throw ApiException.validation(`Block ${i + 1} needs some text.`, where);
        if (b.type === 'heading' && text.length > 200) {
          throw ApiException.validation('A heading can be up to 200 characters.', where);
        }
        return { type: b.type, text };
      }
      case 'callout': {
        const text = clean(b.text);
        if (!text) throw ApiException.validation(`Block ${i + 1} needs some text.`, where);
        return { type: 'callout', title: orNull(b.title), text };
      }
      case 'quote': {
        const text = clean(b.text);
        if (!text) throw ApiException.validation(`Block ${i + 1} needs some text.`, where);
        return { type: 'quote', text, attribution: orNull(b.attribution) };
      }
      case 'image': {
        if (!b.mediaId) throw ApiException.validation(`Block ${i + 1} needs an image.`, where);
        return { type: 'image', mediaId: b.mediaId, caption: orNull(b.caption) };
      }
    }
  });
}

/** Reads the stored JSON defensively: rows written by anything else are skipped, never thrown on. */
export function readBlocks(body: unknown): StoredBlock[] {
  if (!Array.isArray(body)) return [];
  const out: StoredBlock[] = [];
  for (const raw of body as Array<Record<string, unknown>>) {
    const str = (k: string) => (typeof raw?.[k] === 'string' ? (raw[k] as string) : null);
    switch (raw?.type) {
      case 'paragraph':
      case 'heading':
        if (str('text')) out.push({ type: raw.type, text: str('text')! });
        break;
      case 'callout':
        if (str('text')) out.push({ type: 'callout', title: str('title'), text: str('text')! });
        break;
      case 'quote':
        if (str('text')) {
          out.push({ type: 'quote', text: str('text')!, attribution: str('attribution') });
        }
        break;
      case 'image':
        if (str('mediaId')) {
          out.push({ type: 'image', mediaId: str('mediaId')!, caption: str('caption') });
        }
        break;
    }
  }
  return out;
}

/** Whole minutes at 200 words a minute, at least one. */
export function readMinutes(blocks: StoredBlock[], title = '', summary = ''): number {
  const words = [title, summary, ...blocks.map((b) => ('text' in b ? b.text : ''))]
    .join(' ')
    .split(/\s+/)
    .filter(Boolean).length;
  return Math.max(1, Math.ceil(words / 200));
}
