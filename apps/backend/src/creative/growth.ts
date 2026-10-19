/**
 * Creative growth: six bars computed from real data, shown on the Creative Passport. Pure, so the formulas are
 * unit-tested and documented in docs/DOMAIN.md. Inputs that belong to later milestones (projects, experience,
 * achievements, services, learning) are 0 until those features exist, and the bars say so by being low, not by
 * being hidden.
 */

export interface GrowthFacts {
  /** Identity items done, weights from the completion engine (0-100). */
  identityPercent: number;
  publishedProjects: number;
  skills: number;
  verifiedSkills: number;
  completedCourses: number;
  enrolledCourses: number;
  acceptedConnections: number;
  services: number;
  experiences: number;
  achievements: number;
  verifiedIdentity: boolean;
}

export type GrowthKey =
  'identity' | 'portfolio' | 'skills' | 'learning' | 'connections' | 'professionalisation';

export interface GrowthBar {
  key: GrowthKey;
  label: string;
  percent: number;
}

export type GrowthStrength = 'EARLY' | 'GROWING' | 'ACTIVE' | 'STRONG';

export interface GrowthResult {
  score: number;
  strength: GrowthStrength;
  bars: GrowthBar[];
}

const cap = (n: number) => Math.max(0, Math.min(100, Math.round(n)));

/** Four published projects is a full portfolio. */
export const PROJECTS_FOR_FULL = 4;
/** Eight skills is a full skills bar. */
export const SKILLS_FOR_FULL = 8;
/** Ten accepted connections is a full network bar. */
export const CONNECTIONS_FOR_FULL = 10;

export function computeGrowth(f: GrowthFacts): GrowthResult {
  const bars: GrowthBar[] = [
    // Identity: the completion engine's identity items (photo, bio, headline, discipline, specialisation,
    // location, contact), rescaled to 100.
    { key: 'identity', label: 'Identity', percent: cap(f.identityPercent) },
    // Portfolio: 25 points per published project, 4 projects for a full bar.
    {
      key: 'portfolio',
      label: 'Portfolio',
      percent: cap((f.publishedProjects * 100) / PROJECTS_FOR_FULL),
    },
    // Skills: 12.5 points per skill (8 for a full bar), plus 5 per verified skill, capped.
    {
      key: 'skills',
      label: 'Skills',
      percent: cap((f.skills * 100) / SKILLS_FOR_FULL + f.verifiedSkills * 5),
    },
    // Learning: 25 per completed course, 10 per course started.
    {
      key: 'learning',
      label: 'Learning',
      percent: cap(
        f.completedCourses * 25 + Math.max(0, f.enrolledCourses - f.completedCourses) * 10,
      ),
    },
    // Connections: 10 points per accepted connection, 10 for a full bar.
    {
      key: 'connections',
      label: 'Connections',
      percent: cap((f.acceptedConnections * 100) / CONNECTIONS_FOR_FULL),
    },
    // Professionalisation: 25 per service, 20 per experience, 10 per achievement, 20 for a verified identity.
    {
      key: 'professionalisation',
      label: 'Professionalisation',
      percent: cap(
        f.services * 25 + f.experiences * 20 + f.achievements * 10 + (f.verifiedIdentity ? 20 : 0),
      ),
    },
  ];
  const score = Math.round(bars.reduce((s, b) => s + b.percent, 0) / bars.length);
  const strength: GrowthStrength =
    score >= 75 ? 'STRONG' : score >= 50 ? 'ACTIVE' : score >= 25 ? 'GROWING' : 'EARLY';
  return { score, strength, bars };
}
