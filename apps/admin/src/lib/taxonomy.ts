/**
 * Pure helpers for the taxonomy screens: which lists exist, how an admin may reorder them, and the form
 * rules checked before anything is sent. The API repeats every rule; these only save a round trip.
 */
export const TAXONOMY_KINDS = [
  'disciplines',
  'specialisations',
  'skills',
  'interests',
  'development-areas',
] as const;
export type TaxonomyKind = (typeof TAXONOMY_KINDS)[number];

export const isTaxonomyKind = (v: string): v is TaxonomyKind =>
  (TAXONOMY_KINDS as readonly string[]).includes(v);

export interface KindInfo {
  kind: TaxonomyKind;
  /** Tab label. */
  label: string;
  /** Singular noun for dialogs. */
  noun: string;
  hasIcon: boolean;
  /** Entries belong to a discipline (specialisations always, skills optionally). */
  scoped: boolean;
  /** A discipline must be chosen to create one. */
  disciplineRequired: boolean;
}

export const KIND_INFO: Record<TaxonomyKind, KindInfo> = {
  disciplines: {
    kind: 'disciplines',
    label: 'Disciplines',
    noun: 'discipline',
    hasIcon: true,
    scoped: false,
    disciplineRequired: false,
  },
  specialisations: {
    kind: 'specialisations',
    label: 'Specialisations',
    noun: 'specialisation',
    hasIcon: false,
    scoped: true,
    disciplineRequired: true,
  },
  skills: {
    kind: 'skills',
    label: 'Skills',
    noun: 'skill',
    hasIcon: false,
    scoped: true,
    disciplineRequired: false,
  },
  interests: {
    kind: 'interests',
    label: 'Interests',
    noun: 'interest',
    hasIcon: false,
    scoped: false,
    disciplineRequired: false,
  },
  'development-areas': {
    kind: 'development-areas',
    label: 'Areas to develop',
    noun: 'area to develop',
    hasIcon: false,
    scoped: false,
    disciplineRequired: false,
  },
};

export const NAME_MIN = 2;
export const NAME_MAX = 60;

/** Trims and collapses inner whitespace, as the API does. */
export const normaliseName = (raw: string): string => raw.trim().replace(/\s+/g, ' ');

/** Returns an error message, or null when the name is acceptable. */
export function validateName(raw: string): string | null {
  const name = normaliseName(raw);
  if (name.length < NAME_MIN) return `Enter a name of at least ${NAME_MIN} characters.`;
  if (name.length > NAME_MAX) return `Keep the name to ${NAME_MAX} characters or fewer.`;
  return null;
}

/** Lucide icon names are lower-case words joined by hyphens, for example `paint-bucket`. */
const ICON_PATTERN = /^[a-z][a-z0-9]*(-[a-z0-9]+)*$/;

export function validateIcon(raw: string): string | null {
  const icon = raw.trim();
  if (!icon) return 'Enter a Lucide icon name, for example "palette".';
  if (icon.length > 40 || !ICON_PATTERN.test(icon)) {
    return 'Use a Lucide icon name: lower-case words joined by hyphens, for example "paint-bucket".';
  }
  return null;
}

export interface ItemFormInput {
  name: string;
  icon: string;
  disciplineId: string;
}

/** First problem with a create or edit form, or null. */
export function validateItemForm(
  info: KindInfo,
  input: ItemFormInput,
  mode: 'create' | 'edit',
): string | null {
  const nameError = validateName(input.name);
  if (nameError) return nameError;
  if (info.hasIcon) {
    const iconError = validateIcon(input.icon);
    if (iconError) return iconError;
  }
  if (mode === 'create' && info.disciplineRequired && !input.disciplineId) {
    return `Choose the discipline this ${info.noun} belongs to.`;
  }
  return null;
}

/**
 * Reordering rewrites the order of one list. For a list that belongs to a discipline the admin must have
 * filtered to that discipline first, otherwise the visible rows are a mix of several lists.
 */
export const canReorder = (info: KindInfo, disciplineId: string | undefined): boolean =>
  !info.scoped || Boolean(disciplineId);

/** New order after moving the entry at `index` one step. Returns null when it cannot move that way. */
export function moveId(
  ids: readonly string[],
  index: number,
  direction: 'up' | 'down',
): string[] | null {
  const to = direction === 'up' ? index - 1 : index + 1;
  if (index < 0 || index >= ids.length || to < 0 || to >= ids.length) return null;
  const next = [...ids];
  [next[index], next[to]] = [next[to]!, next[index]!];
  return next;
}

export const SUGGESTION_STATUSES = ['PENDING', 'APPROVED', 'MERGED', 'REJECTED'] as const;
export type SuggestionStatus = (typeof SUGGESTION_STATUSES)[number];

/** `ALL` shows every status; anything unknown falls back to the default queue (Pending). */
export function parseSuggestionFilter(raw: string | undefined): SuggestionStatus | 'ALL' {
  if (raw === 'ALL') return 'ALL';
  return (SUGGESTION_STATUSES as readonly string[]).includes(raw ?? '')
    ? (raw as SuggestionStatus)
    : 'PENDING';
}
