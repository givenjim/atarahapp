/** Public handles (atarah.app/{handle}): lower-case letters, digits and underscores, 3 to 30 characters. */

export const HANDLE_PATTERN = /^[a-z0-9_]{3,30}$/;

/** Words that would collide with routes or look official. Compared after normalising. */
export const RESERVED_HANDLES: ReadonlySet<string> = new Set([
  'admin',
  'administrator',
  'api',
  'app',
  'atarah',
  'help',
  'support',
  'security',
  'staff',
  'team',
  'moderator',
  'mod',
  'root',
  'system',
  'official',
  'luxaion',
  'about',
  'terms',
  'privacy',
  'legal',
  'login',
  'signin',
  'signup',
  'register',
  'settings',
  'profile',
  'passport',
  'explore',
  'community',
  'opportunities',
  'learn',
  'mentors',
  'marketplace',
  'home',
  'me',
  'null',
  'undefined',
]);

export type HandleProblem = 'INVALID' | 'RESERVED';

/** Lower-case, trim and drop a leading `@`. */
export const normaliseHandle = (raw: string): string => raw.trim().replace(/^@/, '').toLowerCase();

export function handleProblem(handle: string): HandleProblem | null {
  if (!HANDLE_PATTERN.test(handle)) return 'INVALID';
  if (RESERVED_HANDLES.has(handle)) return 'RESERVED';
  return null;
}

/** A starting point from a display name: "Nia Wairimu" becomes "niawairimu". */
export function handleBase(name: string): string {
  const base = name
    .normalize('NFKD')
    .replace(/[̀-ͯ]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '')
    .slice(0, 24);
  return base.length >= 3 ? base : `${base}creative`.slice(0, 24);
}

/** Candidates to try, in order, when the first choice is taken. */
export function handleCandidates(base: string, count = 12): string[] {
  const b = handleBase(base);
  const out: string[] = [];
  for (let i = 2; out.length < count; i++) {
    const c = `${b}${i}`.slice(0, 30);
    if (!out.includes(c)) out.push(c);
    if (i > 5000) break;
  }
  return out.filter((c) => handleProblem(c) === null);
}
