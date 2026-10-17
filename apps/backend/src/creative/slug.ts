/** Same rule as the reference seed, so slugs created by admins and by the seed never disagree. */
export const slugify = (s: string): string =>
  s
    .toLowerCase()
    .replace(/&/g, ' and ')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
