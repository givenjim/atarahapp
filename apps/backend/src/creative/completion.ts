/**
 * Profile completion engine. Pure: it scores a snapshot of facts about a profile, so every screen that shows
 * "Profile completion" (onboarding, Passport, Home, Profile) gets the same number from one place.
 * Weights are documented in docs/DOMAIN.md and add up to 100.
 */

export interface ProfileFacts {
  hasAvatar: boolean;
  bio: string | null;
  headline: string | null;
  hasDiscipline: boolean;
  specialisationCount: number;
  skillCount: number;
  hasLocation: boolean;
  /** Projects and experience arrive in P1-M4. Until then the counts are 0 and those items stay open. */
  projectCount: number;
  experienceCount: number;
  contactVerified: boolean;
}

export type CompletionKey =
  | 'avatar'
  | 'bio'
  | 'headline'
  | 'discipline'
  | 'specialisation'
  | 'skills'
  | 'location'
  | 'project'
  | 'experience'
  | 'contact';

export interface CompletionItem {
  key: CompletionKey;
  label: string;
  weight: number;
  done: boolean;
}

export interface CompletionResult {
  percent: number;
  items: CompletionItem[];
  /** The three most valuable things still missing, heaviest first. */
  next: CompletionItem[];
}

export const MIN_BIO_LENGTH = 20;
export const MIN_SKILLS = 3;

interface Rule {
  key: CompletionKey;
  label: string;
  weight: number;
  done: (f: ProfileFacts) => boolean;
}

export const COMPLETION_RULES: readonly Rule[] = [
  { key: 'avatar', label: 'Add a profile photo', weight: 15, done: (f) => f.hasAvatar },
  {
    key: 'bio',
    label: 'Write a short bio',
    weight: 10,
    done: (f) => (f.bio?.trim().length ?? 0) >= MIN_BIO_LENGTH,
  },
  {
    key: 'headline',
    label: 'Add a headline',
    weight: 5,
    done: (f) => (f.headline?.trim().length ?? 0) > 0,
  },
  { key: 'discipline', label: 'Choose your discipline', weight: 10, done: (f) => f.hasDiscipline },
  {
    key: 'specialisation',
    label: 'Pick a specialisation',
    weight: 10,
    done: (f) => f.specialisationCount >= 1,
  },
  {
    key: 'skills',
    label: `Add at least ${MIN_SKILLS} skills`,
    weight: 10,
    done: (f) => f.skillCount >= MIN_SKILLS,
  },
  { key: 'location', label: 'Set your location', weight: 10, done: (f) => f.hasLocation },
  { key: 'project', label: 'Add your first project', weight: 15, done: (f) => f.projectCount >= 1 },
  {
    key: 'experience',
    label: 'Add an experience',
    weight: 10,
    done: (f) => f.experienceCount >= 1,
  },
  {
    key: 'contact',
    label: 'Verify your contact details',
    weight: 5,
    done: (f) => f.contactVerified,
  },
];

export function computeCompletion(facts: ProfileFacts): CompletionResult {
  const items = COMPLETION_RULES.map((r) => ({
    key: r.key,
    label: r.label,
    weight: r.weight,
    done: r.done(facts),
  }));
  const percent = items.reduce((sum, i) => sum + (i.done ? i.weight : 0), 0);
  const next = items
    .filter((i) => !i.done)
    .sort((a, b) => b.weight - a.weight)
    .slice(0, 3);
  return { percent, items, next };
}
