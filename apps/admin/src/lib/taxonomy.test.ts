import { describe, expect, it } from 'vitest';
import {
  canReorder,
  KIND_INFO,
  moveId,
  normaliseName,
  parseSuggestionFilter,
  validateIcon,
  validateItemForm,
  validateName,
} from './taxonomy';

describe('names', () => {
  it('trims and collapses whitespace like the API', () => {
    expect(normaliseName('  Stage   design ')).toBe('Stage design');
  });

  it('accepts 2 to 60 characters and explains the rest', () => {
    expect(validateName('Ab')).toBeNull();
    expect(validateName(' a ')).toMatch(/at least 2/);
    expect(validateName('')).toMatch(/at least 2/);
    expect(validateName('x'.repeat(60))).toBeNull();
    expect(validateName('x'.repeat(61))).toMatch(/60 characters/);
  });
});

describe('icons', () => {
  it('accepts kebab-case Lucide names', () => {
    expect(validateIcon('palette')).toBeNull();
    expect(validateIcon('paint-bucket')).toBeNull();
    expect(validateIcon('code-2')).toBeNull();
  });

  it('refuses empty, upper-case, spaced and over-long names', () => {
    expect(validateIcon('')).toMatch(/Lucide/);
    expect(validateIcon('Palette')).toMatch(/lower-case/);
    expect(validateIcon('paint bucket')).toMatch(/lower-case/);
    expect(validateIcon('-x')).toMatch(/lower-case/);
    expect(validateIcon('a'.repeat(41))).toMatch(/lower-case/);
  });
});

describe('validateItemForm', () => {
  const blank = { name: 'Puppetry', icon: '', disciplineId: '' };

  it('needs an icon for a discipline, not for other lists', () => {
    expect(validateItemForm(KIND_INFO.disciplines, blank, 'create')).toMatch(/icon/i);
    expect(
      validateItemForm(KIND_INFO.disciplines, { ...blank, icon: 'drama' }, 'create'),
    ).toBeNull();
    expect(validateItemForm(KIND_INFO.interests, blank, 'create')).toBeNull();
  });

  it('needs a discipline for a new specialisation but not for a new skill or an edit', () => {
    expect(validateItemForm(KIND_INFO.specialisations, blank, 'create')).toMatch(/discipline/);
    expect(validateItemForm(KIND_INFO.specialisations, blank, 'edit')).toBeNull();
    expect(validateItemForm(KIND_INFO.skills, blank, 'create')).toBeNull();
    expect(
      validateItemForm(KIND_INFO.specialisations, { ...blank, disciplineId: 'abc' }, 'create'),
    ).toBeNull();
  });

  it('checks the name first', () => {
    expect(validateItemForm(KIND_INFO.interests, { ...blank, name: ' ' }, 'create')).toMatch(
      /name/i,
    );
  });
});

describe('reordering', () => {
  it('moves an entry one step and leaves the input untouched', () => {
    const ids = ['a', 'b', 'c'];
    expect(moveId(ids, 1, 'up')).toEqual(['b', 'a', 'c']);
    expect(moveId(ids, 1, 'down')).toEqual(['a', 'c', 'b']);
    expect(ids).toEqual(['a', 'b', 'c']);
  });

  it('refuses to move past either end or from a missing index', () => {
    expect(moveId(['a', 'b'], 0, 'up')).toBeNull();
    expect(moveId(['a', 'b'], 1, 'down')).toBeNull();
    expect(moveId(['a'], 5, 'up')).toBeNull();
    expect(moveId([], 0, 'down')).toBeNull();
  });

  it('allows reordering a discipline-scoped list only inside one discipline', () => {
    expect(canReorder(KIND_INFO.specialisations, undefined)).toBe(false);
    expect(canReorder(KIND_INFO.skills, undefined)).toBe(false);
    expect(canReorder(KIND_INFO.specialisations, 'd1')).toBe(true);
    expect(canReorder(KIND_INFO.disciplines, undefined)).toBe(true);
    expect(canReorder(KIND_INFO.interests, undefined)).toBe(true);
  });
});

describe('suggestion filter', () => {
  it('defaults to Pending and accepts every status or ALL', () => {
    expect(parseSuggestionFilter(undefined)).toBe('PENDING');
    expect(parseSuggestionFilter('nonsense')).toBe('PENDING');
    expect(parseSuggestionFilter('MERGED')).toBe('MERGED');
    expect(parseSuggestionFilter('ALL')).toBe('ALL');
  });
});
