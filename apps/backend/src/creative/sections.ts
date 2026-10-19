import { type ProfileSection, type Visibility } from '@prisma/client';

/** Display order on the Passport's "Sections & visibility" list. */
export const PROFILE_SECTIONS: readonly ProfileSection[] = [
  'BIO',
  'LOCATION',
  'PORTFOLIO',
  'SKILLS',
  'EXPERIENCE',
  'SERVICES',
  'LINKS',
  'CONTACT',
];

/** Master Prompt 6.2: identity, bio, portfolio, skills PUBLIC; experience and location MEMBERS; contact PRIVATE. */
export const DEFAULT_VISIBILITY: Readonly<Record<ProfileSection, Visibility>> = {
  BIO: 'PUBLIC',
  LOCATION: 'MEMBERS',
  PORTFOLIO: 'PUBLIC',
  SKILLS: 'PUBLIC',
  EXPERIENCE: 'MEMBERS',
  SERVICES: 'PUBLIC',
  LINKS: 'PUBLIC',
  CONTACT: 'PRIVATE',
};

/** How the person asking relates to the profile owner. */
export type ViewerRelation = 'OWNER' | 'CONNECTION' | 'MEMBER' | 'ANONYMOUS';

/**
 * Whether [relation] may see a section set to [visibility]. Connections are members, so they see what members
 * see. Contact details are the one place a connection sees more (see `canSeeContact`).
 */
export function relationCanSee(visibility: Visibility, relation: ViewerRelation): boolean {
  if (relation === 'OWNER') return true;
  switch (visibility) {
    case 'PUBLIC':
      return true;
    case 'MEMBERS':
      return relation === 'MEMBER' || relation === 'CONNECTION';
    case 'PRIVATE':
      return false;
  }
}

/** The audiences of a single item (a project) that [relation] may see: used to filter lists in the database. */
export function visibilitiesFor(relation: ViewerRelation): Visibility[] {
  if (relation === 'OWNER') return ['PUBLIC', 'MEMBERS', 'PRIVATE'];
  if (relation === 'ANONYMOUS') return ['PUBLIC'];
  return ['PUBLIC', 'MEMBERS'];
}

/** Contact details: by the section's audience, or to accepted connections when the member allows it. */
export function canSeeContact(
  visibility: Visibility,
  relation: ViewerRelation,
  forConnections: boolean,
): boolean {
  return (
    relationCanSee(visibility, relation) || (relation === 'CONNECTION' && forConnections === true)
  );
}

export const SECTION_LABELS: Readonly<Record<ProfileSection, string>> = {
  BIO: 'Bio',
  LOCATION: 'Location',
  PORTFOLIO: 'Portfolio',
  SKILLS: 'Skills',
  EXPERIENCE: 'Experience',
  SERVICES: 'Services',
  LINKS: 'Links',
  CONTACT: 'Contact details',
};
