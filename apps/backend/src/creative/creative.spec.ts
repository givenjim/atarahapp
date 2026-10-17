import { COMPLETION_RULES, computeCompletion, type ProfileFacts } from './completion';
import { handleBase, handleCandidates, handleProblem, normaliseHandle } from './handle';
import { normalisePlace } from './taxonomy.service';

const empty: ProfileFacts = {
  hasAvatar: false,
  bio: null,
  headline: null,
  hasDiscipline: false,
  specialisationCount: 0,
  skillCount: 0,
  hasLocation: false,
  projectCount: 0,
  experienceCount: 0,
  contactVerified: false,
};
const full: ProfileFacts = {
  hasAvatar: true,
  bio: 'Illustrator and 2D animator in Nairobi.',
  headline: 'Character animator',
  hasDiscipline: true,
  specialisationCount: 2,
  skillCount: 5,
  hasLocation: true,
  projectCount: 3,
  experienceCount: 1,
  contactVerified: true,
};

describe('profile completion engine', () => {
  it('weights add up to exactly 100', () => {
    expect(COMPLETION_RULES.reduce((s, r) => s + r.weight, 0)).toBe(100);
  });

  it('is 0% for an empty profile and 100% for a complete one', () => {
    expect(computeCompletion(empty).percent).toBe(0);
    expect(computeCompletion(full).percent).toBe(100);
  });

  it('counts exactly what is done', () => {
    // avatar 15 + discipline 10 + location 10 + contact 5
    const r = computeCompletion({
      ...empty,
      hasAvatar: true,
      hasDiscipline: true,
      hasLocation: true,
      contactVerified: true,
    });
    expect(r.percent).toBe(40);
    expect(r.items.filter((i) => i.done).map((i) => i.key)).toEqual([
      'avatar',
      'discipline',
      'location',
      'contact',
    ]);
  });

  it('needs three skills, a real bio and ignores whitespace', () => {
    expect(
      computeCompletion({ ...empty, skillCount: 2 }).items.find((i) => i.key === 'skills')!.done,
    ).toBe(false);
    expect(
      computeCompletion({ ...empty, skillCount: 3 }).items.find((i) => i.key === 'skills')!.done,
    ).toBe(true);
    expect(
      computeCompletion({ ...empty, bio: 'Hi' }).items.find((i) => i.key === 'bio')!.done,
    ).toBe(false);
    expect(
      computeCompletion({ ...empty, bio: '   '.padEnd(40) }).items.find((i) => i.key === 'bio')!
        .done,
    ).toBe(false);
    expect(
      computeCompletion({ ...empty, headline: '  ' }).items.find((i) => i.key === 'headline')!.done,
    ).toBe(false);
  });

  it('lists the three heaviest missing items first', () => {
    const r = computeCompletion({
      ...full,
      hasAvatar: false,
      bio: null,
      projectCount: 0,
      headline: null,
    });
    expect(r.next.map((i) => i.key)).toEqual(['avatar', 'project', 'bio']);
    expect(r.next.map((i) => i.weight)).toEqual([15, 15, 10]);
  });

  it('keeps projects and experience open until P1-M4 supplies them', () => {
    const r = computeCompletion({ ...full, projectCount: 0, experienceCount: 0 });
    expect(r.percent).toBe(75);
  });
});

describe('handles', () => {
  it('normalises case and a leading @', () => {
    expect(normaliseHandle('  @Nia_Wairimu ')).toBe('nia_wairimu');
  });

  it('accepts 3-30 lower-case letters, digits and underscores', () => {
    expect(handleProblem('nia')).toBeNull();
    expect(handleProblem('a'.repeat(30))).toBeNull();
    expect(handleProblem('ab')).toBe('INVALID');
    expect(handleProblem('a'.repeat(31))).toBe('INVALID');
    expect(handleProblem('nia wairimu')).toBe('INVALID');
    expect(handleProblem('nia-wairimu')).toBe('INVALID');
    expect(handleProblem('Nia')).toBe('INVALID');
  });

  it('reserves routes and official-looking words', () => {
    for (const h of ['admin', 'atarah', 'support', 'passport'])
      expect(handleProblem(h)).toBe('RESERVED');
  });

  it('builds a base from a display name, with accents and short names handled', () => {
    expect(handleBase('Nia Wairimu')).toBe('niawairimu');
    expect(handleBase('Zoë Kamau')).toBe('zoekamau');
    expect(handleBase('Jo')).toBe('jocreative');
    expect(handleBase('!!')).toHaveLength(8);
  });

  it('proposes valid, unique candidates', () => {
    const c = handleCandidates('niawairimu', 5);
    expect(c).toEqual(['niawairimu2', 'niawairimu3', 'niawairimu4', 'niawairimu5', 'niawairimu6']);
    expect(c.every((h) => handleProblem(h) === null)).toBe(true);
  });
});

describe('place matching', () => {
  it('treats county, city and government words as noise', () => {
    expect(normalisePlace('Nairobi City County')).toBe('nairobi');
    expect(normalisePlace('Nairobi')).toBe('nairobi');
    expect(normalisePlace('County Government of Nakuru')).toBe('nakuru');
  });
  it('ignores accents, apostrophes and hyphens', () => {
    expect(normalisePlace("Murang'a")).toBe('muranga');
    expect(normalisePlace('Taita-Taveta County')).toBe('taitataveta');
    expect(normalisePlace('Tana River')).toBe('tanariver');
  });
});
