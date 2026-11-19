import { type CreativeDocumentFormat, type ProfileSection, type Visibility } from '@prisma/client';
import { DEFAULT_VISIBILITY, PROFILE_SECTIONS } from '../creative/sections';

/** What the member can choose for each format, and what is switched on by default. */
export interface FormatSpec {
  format: CreativeDocumentFormat;
  label: string;
  /** Sections this format can show. Achievements belong to EXPERIENCE (there is no section of their own). */
  allowed: readonly ProfileSection[];
  defaults: readonly ProfileSection[];
  /** The most projects the layout lists. */
  maxProjects: number;
}

export const FORMAT_SPECS: Readonly<Record<CreativeDocumentFormat, FormatSpec>> = {
  CV: {
    format: 'CV',
    label: 'Creative CV',
    allowed: [
      'BIO',
      'LOCATION',
      'PORTFOLIO',
      'SKILLS',
      'EXPERIENCE',
      'SERVICES',
      'LINKS',
      'CONTACT',
    ],
    defaults: ['BIO', 'PORTFOLIO', 'SKILLS', 'EXPERIENCE', 'LINKS'],
    maxProjects: 8,
  },
  BIO: {
    format: 'BIO',
    label: 'Artist biography',
    allowed: ['BIO', 'LOCATION', 'EXPERIENCE', 'SKILLS', 'LINKS', 'CONTACT'],
    defaults: ['BIO', 'EXPERIENCE', 'LINKS'],
    maxProjects: 0,
  },
  EPK: {
    format: 'EPK',
    label: 'Electronic press kit',
    allowed: [
      'BIO',
      'LOCATION',
      'PORTFOLIO',
      'SKILLS',
      'EXPERIENCE',
      'SERVICES',
      'LINKS',
      'CONTACT',
    ],
    defaults: ['BIO', 'PORTFOLIO', 'EXPERIENCE', 'SERVICES', 'LINKS'],
    maxProjects: 6,
  },
  DECK: {
    format: 'DECK',
    label: 'Portfolio presentation',
    allowed: ['BIO', 'LOCATION', 'PORTFOLIO', 'SKILLS', 'SERVICES', 'LINKS', 'CONTACT'],
    defaults: ['BIO', 'PORTFOLIO', 'SKILLS', 'LINKS'],
    maxProjects: 10,
  },
};

export const FORMATS = Object.keys(FORMAT_SPECS) as CreativeDocumentFormat[];

/** The member's choices for one document. */
export interface CvConfig {
  format: CreativeDocumentFormat;
  sections: readonly ProfileSection[];
  projectIds: readonly string[];
  /** Sections whose audience is not PUBLIC that the member explicitly allows into the output. */
  restricted: readonly ProfileSection[];
}

// ---- the raw material, loaded from the database ---------------------------------------------------------------

export interface CvSource {
  profileId: string;
  handle: string | null;
  displayName: string;
  headline: string | null;
  bio: string | null;
  discipline: string | null;
  county: string | null;
  town: string | null;
  openToCommissions: boolean;
  avatarDataUri: string | null;
  contact: {
    email: string | null;
    phone: string | null;
    showEmail: boolean;
    showPhone: boolean;
  };
  /** Every section's audience as the member set it. */
  visibility: Readonly<Record<ProfileSection, Visibility>>;
  skills: Array<{ id: string; name: string; level: string | null }>;
  projects: Array<{
    id: string;
    title: string;
    role: string | null;
    client: string | null;
    year: number | null;
    category: string;
    description: string | null;
    outcome: string | null;
    visibility: Visibility;
    published: boolean;
    hidden: boolean;
    deleted: boolean;
    skills: string[];
    links: Array<{ label: string; url: string }>;
  }>;
  experience: Array<{
    title: string;
    organisation: string;
    location: string | null;
    start: string;
    end: string | null;
    current: boolean;
    description: string | null;
  }>;
  achievements: Array<{
    type: string;
    title: string;
    issuer: string | null;
    year: number | null;
    description: string | null;
  }>;
  services: Array<{ title: string; description: string | null; price: string | null }>;
  links: Array<{ label: string; url: string }>;
}

/** What the verified marks reader answers: real data only, never inferred. */
export interface VerifiedMarks {
  identity: boolean;
  skillIds: ReadonlySet<string>;
}

// ---- the filtered, render-ready document -----------------------------------------------------------------------

export interface CvProject {
  title: string;
  role: string | null;
  client: string | null;
  year: number | null;
  category: string;
  description: string | null;
  outcome: string | null;
  skills: string[];
  links: Array<{ label: string; url: string }>;
}

export interface CvDocument {
  format: CreativeDocumentFormat;
  formatLabel: string;
  handle: string | null;
  displayName: string;
  headline: string | null;
  discipline: string | null;
  identityVerified: boolean;
  avatarDataUri: string | null;
  openToCommissions: boolean;
  bio: string | null;
  location: string | null;
  skills: Array<{ name: string; level: string | null; verified: boolean }> | null;
  projects: CvProject[] | null;
  experience: CvSource['experience'] | null;
  achievements: CvSource['achievements'] | null;
  services: CvSource['services'] | null;
  links: CvSource['links'] | null;
  contact: { email: string | null; phone: string | null } | null;
  /** Which sections ended up in the output (after visibility filtering). */
  included: ProfileSection[];
  /** The sections the member picked that were left out because their audience is not public. */
  withheld: ProfileSection[];
}

/**
 * The visibility rule of the CV (P2-M7): a section reaches the output only when the member picked it AND it is
 * PUBLIC, or the member explicitly allowed that non-public section for this document. Pure: no database, no clock.
 */
export function sectionIncluded(
  section: ProfileSection,
  config: Pick<CvConfig, 'sections' | 'restricted'>,
  visibility: Readonly<Record<ProfileSection, Visibility>>,
): boolean {
  if (!config.sections.includes(section)) return false;
  return (visibility[section] ?? DEFAULT_VISIBILITY[section]) === 'PUBLIC'
    ? true
    : config.restricted.includes(section);
}

export function buildCvDocument(
  source: CvSource,
  config: CvConfig,
  marks: VerifiedMarks,
): CvDocument {
  const spec = FORMAT_SPECS[config.format];
  const picked = config.sections.filter((s) => spec.allowed.includes(s));
  const cfg = { sections: picked, restricted: config.restricted };
  const on = (s: ProfileSection) => sectionIncluded(s, cfg, source.visibility);

  const included = PROFILE_SECTIONS.filter(on);
  const withheld = PROFILE_SECTIONS.filter((s) => picked.includes(s) && !on(s));

  const place = [source.town, source.county].filter(Boolean).join(', ');
  const emailOk = on('CONTACT') && source.contact.showEmail && !!source.contact.email;
  const phoneOk = on('CONTACT') && source.contact.showPhone && !!source.contact.phone;

  let projects: CvProject[] | null = null;
  if (on('PORTFOLIO') && spec.maxProjects > 0) {
    const byId = new Map(source.projects.map((p) => [p.id, p]));
    projects = config.projectIds
      .map((id) => byId.get(id))
      .filter((p): p is CvSource['projects'][number] => !!p)
      .filter(
        (p) =>
          p.published &&
          !p.hidden &&
          !p.deleted &&
          (p.visibility === 'PUBLIC' || config.restricted.includes('PORTFOLIO')),
      )
      .slice(0, spec.maxProjects)
      .map((p) => ({
        title: p.title,
        role: p.role,
        client: p.client,
        year: p.year,
        category: p.category,
        description: p.description,
        outcome: p.outcome,
        skills: p.skills,
        links: p.links,
      }));
  }

  return {
    format: config.format,
    formatLabel: spec.label,
    handle: source.handle,
    displayName: source.displayName,
    headline: source.headline,
    discipline: source.discipline,
    identityVerified: marks.identity,
    avatarDataUri: source.avatarDataUri,
    openToCommissions: source.openToCommissions,
    bio: on('BIO') ? source.bio : null,
    location: on('LOCATION') && place ? place : null,
    skills: on('SKILLS')
      ? source.skills.map((s) => ({
          name: s.name,
          level: s.level,
          verified: marks.skillIds.has(s.id),
        }))
      : null,
    projects,
    experience: on('EXPERIENCE') ? source.experience : null,
    achievements: on('EXPERIENCE') ? source.achievements : null,
    services: on('SERVICES') ? source.services : null,
    links: on('LINKS') ? source.links : null,
    contact:
      emailOk || phoneOk
        ? {
            email: emailOk ? source.contact.email : null,
            phone: phoneOk ? source.contact.phone : null,
          }
        : null,
    included,
    withheld,
  };
}
