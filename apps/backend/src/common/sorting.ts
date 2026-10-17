import { ApiException } from './api.exception';

/** The only sort keys any list endpoint may expose (Master Prompt §7.2). */
export const SORT_KEYS = [
  'recent',
  'deadline',
  'relevance',
  'popularity',
  'rating',
  'price',
] as const;
export type SortKey = (typeof SORT_KEYS)[number];

/**
 * Resolve a client-supplied sort key against a per-resource whitelist. Unknown keys are a
 * VALIDATION_ERROR rather than silently ignored, and a key never reaches the database unvetted.
 */
export function resolveSort<TOrder>(
  requested: string | undefined,
  whitelist: Partial<Record<SortKey, TOrder>>,
  fallback: SortKey,
): { key: SortKey; order: TOrder } {
  const key = (requested ?? fallback) as SortKey;
  const order = Object.hasOwn(whitelist, key) ? whitelist[key] : undefined;
  if (order === undefined) {
    throw ApiException.validation('That sort option is not supported here.', {
      field: 'sort',
      allowed: Object.keys(whitelist),
    });
  }
  return { key, order };
}
