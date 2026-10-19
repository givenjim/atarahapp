import { computeGrowth, type GrowthFacts } from './growth';
import { canSeeContact, DEFAULT_VISIBILITY, relationCanSee, type ViewerRelation } from './sections';
import { identityPercent, type ProfileFacts } from './completion';

const none: GrowthFacts = {
  identityPercent: 0,
  publishedProjects: 0,
  skills: 0,
  verifiedSkills: 0,
  completedCourses: 0,
  enrolledCourses: 0,
  acceptedConnections: 0,
  services: 0,
  experiences: 0,
  achievements: 0,
  verifiedIdentity: false,
};
const bar = (f: Partial<GrowthFacts>, key: string) =>
  computeGrowth({ ...none, ...f }).bars.find((b) => b.key === key)!.percent;

describe('growth formulas', () => {
  it('has the six bars in order and is 0 for an empty profile', () => {
    const g = computeGrowth(none);
    expect(g.bars.map((b) => b.key)).toEqual([
      'identity',
      'portfolio',
      'skills',
      'learning',
      'connections',
      'professionalisation',
    ]);
    expect(g.score).toBe(0);
    expect(g.strength).toBe('EARLY');
  });

  it('portfolio: 25 points per published project, full at four', () => {
    expect(bar({ publishedProjects: 1 }, 'portfolio')).toBe(25);
    expect(bar({ publishedProjects: 3 }, 'portfolio')).toBe(75);
    expect(bar({ publishedProjects: 9 }, 'portfolio')).toBe(100);
  });

  it('skills: 12.5 per skill (8 for full) plus 5 per verified skill, capped', () => {
    expect(bar({ skills: 4 }, 'skills')).toBe(50);
    expect(bar({ skills: 3 }, 'skills')).toBe(38); // 37.5 rounds up
    expect(bar({ skills: 4, verifiedSkills: 2 }, 'skills')).toBe(60);
    expect(bar({ skills: 20, verifiedSkills: 20 }, 'skills')).toBe(100);
  });

  it('learning: 25 per completed course, 10 per course only started', () => {
    expect(bar({ completedCourses: 2 }, 'learning')).toBe(50);
    expect(bar({ completedCourses: 1, enrolledCourses: 3 }, 'learning')).toBe(45);
    expect(bar({ completedCourses: 5 }, 'learning')).toBe(100);
  });

  it('connections: 10 points each, full at ten', () => {
    expect(bar({ acceptedConnections: 3 }, 'connections')).toBe(30);
    expect(bar({ acceptedConnections: 25 }, 'connections')).toBe(100);
  });

  it('professionalisation: services, experience, achievements and a verified identity', () => {
    expect(bar({ services: 1, experiences: 1, achievements: 1 }, 'professionalisation')).toBe(55);
    expect(bar({ verifiedIdentity: true }, 'professionalisation')).toBe(20);
    expect(bar({ services: 4, experiences: 4 }, 'professionalisation')).toBe(100);
  });

  it('identity passes the completion engine value through, clamped', () => {
    expect(bar({ identityPercent: 62 }, 'identity')).toBe(62);
    expect(bar({ identityPercent: 140 }, 'identity')).toBe(100);
    expect(bar({ identityPercent: -5 }, 'identity')).toBe(0);
  });

  it('overall strength thresholds: 25, 50, 75', () => {
    const all = (n: number): GrowthFacts => ({ ...none, identityPercent: n });
    // Only identity set: the score is n / 6.
    expect(computeGrowth(all(100)).score).toBe(17);
    const full: GrowthFacts = {
      identityPercent: 100,
      publishedProjects: 4,
      skills: 8,
      verifiedSkills: 0,
      completedCourses: 4,
      enrolledCourses: 4,
      acceptedConnections: 10,
      services: 4,
      experiences: 5,
      achievements: 0,
      verifiedIdentity: false,
    };
    expect(computeGrowth(full)).toMatchObject({ score: 100, strength: 'STRONG' });
    expect(
      computeGrowth({ ...full, publishedProjects: 0, completedCourses: 0, enrolledCourses: 0 })
        .strength,
    ).toBe('ACTIVE');
    // identity + skills full = 200 / 6 = 33, which is GROWING; adding a full network makes 50, which is ACTIVE.
    expect(computeGrowth({ ...none, identityPercent: 100, skills: 8 }).strength).toBe('GROWING');
    expect(
      computeGrowth({ ...none, identityPercent: 100, skills: 8, acceptedConnections: 10 }).strength,
    ).toBe('ACTIVE');
  });

  it('identity percent counts only identity items, rescaled', () => {
    const empty: ProfileFacts = {
      hasAvatar: false,
      bio: null,
      headline: null,
      hasDiscipline: false,
      specialisationCount: 0,
      skillCount: 9,
      hasLocation: false,
      projectCount: 9,
      experienceCount: 9,
      contactVerified: false,
    };
    // Skills, projects and experience do not count towards identity.
    expect(identityPercent(empty)).toBe(0);
    expect(identityPercent({ ...empty, hasAvatar: true })).toBe(23); // 15 of 65
    expect(
      identityPercent({
        ...empty,
        hasAvatar: true,
        bio: 'A long enough biography here.',
        headline: 'Animator',
        hasDiscipline: true,
        specialisationCount: 1,
        hasLocation: true,
        contactVerified: true,
      }),
    ).toBe(100);
  });
});

describe('who can see a section', () => {
  const relations: ViewerRelation[] = ['OWNER', 'CONNECTION', 'MEMBER', 'ANONYMOUS'];

  it('the visibility matrix (relation x level)', () => {
    const expected = {
      PUBLIC: { OWNER: true, CONNECTION: true, MEMBER: true, ANONYMOUS: true },
      MEMBERS: { OWNER: true, CONNECTION: true, MEMBER: true, ANONYMOUS: false },
      PRIVATE: { OWNER: true, CONNECTION: false, MEMBER: false, ANONYMOUS: false },
    } as const;
    for (const level of ['PUBLIC', 'MEMBERS', 'PRIVATE'] as const) {
      for (const r of relations) {
        expect(relationCanSee(level, r)).toBe(expected[level][r]);
      }
    }
  });

  it('contact: connections see it when the member allows it, nobody else does', () => {
    expect(canSeeContact('PRIVATE', 'CONNECTION', true)).toBe(true);
    expect(canSeeContact('PRIVATE', 'CONNECTION', false)).toBe(false);
    expect(canSeeContact('PRIVATE', 'MEMBER', true)).toBe(false);
    expect(canSeeContact('PRIVATE', 'ANONYMOUS', true)).toBe(false);
    expect(canSeeContact('PRIVATE', 'OWNER', false)).toBe(true);
    expect(canSeeContact('MEMBERS', 'MEMBER', false)).toBe(true);
    expect(canSeeContact('PUBLIC', 'ANONYMOUS', false)).toBe(true);
  });

  it('defaults follow Master Prompt 6.2', () => {
    expect(DEFAULT_VISIBILITY).toEqual({
      BIO: 'PUBLIC',
      LOCATION: 'MEMBERS',
      PORTFOLIO: 'PUBLIC',
      SKILLS: 'PUBLIC',
      EXPERIENCE: 'MEMBERS',
      SERVICES: 'PUBLIC',
      LINKS: 'PUBLIC',
      CONTACT: 'PRIVATE',
    });
  });
});
