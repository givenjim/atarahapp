import { Type } from 'class-transformer';
import { IsInt, IsOptional, IsString, Max, MaxLength, Min } from 'class-validator';
import { ApiException } from './api.exception';

export const DEFAULT_LIMIT = 20;
export const MAX_LIMIT = 100;

/** Offset pagination for admin tables and bounded lists: `?page=1&limit=20`. */
export class PageQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page: number = 1;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(MAX_LIMIT)
  limit: number = DEFAULT_LIMIT;
}

/** Cursor pagination for feeds: `?cursor=...&limit=20`. */
export class CursorQueryDto {
  @IsOptional()
  @IsString()
  @MaxLength(512)
  cursor?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(MAX_LIMIT)
  limit: number = DEFAULT_LIMIT;
}

export function toSkipTake(q: { page: number; limit: number }): { skip: number; take: number } {
  return { skip: (q.page - 1) * q.limit, take: q.limit };
}

export function pageMeta(q: { page: number; limit: number }, total: number) {
  return { page: q.page, limit: q.limit, total };
}

/** Opaque cursors: base64url(JSON). Clients must not parse them. */
export function encodeCursor(payload: Record<string, string | number>): string {
  return Buffer.from(JSON.stringify(payload), 'utf8').toString('base64url');
}

export function decodeCursor<T extends Record<string, string | number>>(cursor: string): T {
  try {
    const parsed = JSON.parse(Buffer.from(cursor, 'base64url').toString('utf8')) as unknown;
    if (parsed && typeof parsed === 'object' && !Array.isArray(parsed)) return parsed as T;
  } catch {
    // fall through
  }
  throw ApiException.validation('That page cursor is not valid.', { field: 'cursor' });
}

/**
 * Cursor page helper. Fetch `limit + 1` rows, then call this: it trims the extra row and
 * builds `meta.nextCursor` from the last returned item (null when there is no next page).
 */
export function cursorPage<T>(
  rows: T[],
  limit: number,
  toCursor: (last: T) => Record<string, string | number>,
): { items: T[]; meta: { nextCursor: string | null; limit: number } } {
  const hasMore = rows.length > limit;
  const items = hasMore ? rows.slice(0, limit) : rows;
  const last = items[items.length - 1];
  return {
    items,
    meta: {
      nextCursor: hasMore && last !== undefined ? encodeCursor(toCursor(last)) : null,
      limit,
    },
  };
}
