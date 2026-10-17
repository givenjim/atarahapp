/**
 * Taxonomies exactly as in the design prototype (AtarahEntry `ob_disc`, `ob_spec`, `ob_skills`;
 * AtarahLearn category groups; AtarahMarket categories). Admins extend them afterwards.
 */

export const slugify = (s: string): string =>
  s
    .toLowerCase()
    .replace(/&/g, ' and ')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');

/** [name, Lucide icon] in prototype order (Master Prompt §6.8). */
export const DISCIPLINES: ReadonlyArray<readonly [string, string]> = [
  ['Music', 'music'],
  ['Acting', 'drama'],
  ['Dance', 'person-standing'],
  ['Writing', 'pen-line'],
  ['Fashion', 'shirt'],
  ['Visual Art', 'palette'],
  ['Photography', 'camera'],
  ['Film / Video', 'clapperboard'],
  ['Design', 'pen-tool'],
  ['Animation', 'aperture'],
  ['Production', 'sliders-vertical'],
  ['Entrepreneur', 'lightbulb'],
];

export const SPECIALISATIONS: Readonly<Record<string, readonly string[]>> = {
  Music: ['Singer', 'Producer', 'Instrumentalist', 'DJ', 'Songwriter'],
  Photography: ['Portrait', 'Documentary', 'Fashion', 'Commercial', 'Event'],
  'Film / Video': ['Director', 'Cinematographer', 'Editor', 'Producer', 'Screenwriter'],
  Design: ['Brand identity', 'UI / UX', 'Illustration', 'Motion', 'Packaging'],
  Animation: [
    '2D animation',
    '3D animation',
    'Motion graphics',
    'Character design',
    'Storyboarding',
  ],
  Fashion: ['Designer', 'Stylist', 'Pattern maker', 'Model'],
  Writing: ['Poet', 'Screenwriter', 'Journalist', 'Copywriter'],
  Acting: ['Stage', 'Screen', 'Voice', 'Improv'],
  Dance: ['Contemporary', 'Afro-fusion', 'Choreography', 'Hip hop'],
  'Visual Art': ['Painter', 'Illustrator', 'Muralist', 'Printmaker', 'Digital artist'],
  Production: ['Event production', 'Stage management', 'Lighting', 'Set design'],
  Entrepreneur: ['Agency founder', 'Label owner', 'Curator', 'Talent manager'],
};

/** General skills shown to every discipline until admins add discipline-specific ones. */
export const SKILLS = [
  'After Effects',
  'Toon Boom',
  'Procreate',
  'Storyboarding',
  'Character design',
  'Colour',
  'Blender',
  'Client management',
] as const;

export const INTERESTS = [
  'Music videos',
  'Kids content',
  'Brand campaigns',
  'Film festivals',
  'Comics',
  'Games',
] as const;

export const DEVELOPMENT_AREAS = [
  'Pricing my work',
  'Building a portfolio',
  'Grant writing',
  'Personal branding',
  'Legal awareness',
] as const;

export const LEARNING_CATEGORIES: ReadonlyArray<{
  group: 'CREATIVE' | 'BUSINESS' | 'PROFESSIONAL';
  names: readonly string[];
}> = [
  {
    group: 'CREATIVE',
    names: ['Animation', 'Music', 'Acting', 'Writing', 'Fashion', 'Visual Arts', 'Production'],
  },
  {
    group: 'BUSINESS',
    names: ['Financial Literacy', 'Entrepreneurship', 'Branding', 'Marketing'],
  },
  {
    group: 'PROFESSIONAL',
    names: ['Portfolio Building', 'Client Management', 'Legal Awareness', 'Career Development'],
  },
];

/** [name, Lucide icon, tone] from AtarahMarket `mcats`. */
export const MARKETPLACE_CATEGORIES: ReadonlyArray<readonly [string, string, string]> = [
  ['Photo', 'camera', 'violet'],
  ['Animation', 'aperture', 'pink'],
  ['Music', 'music', 'orange'],
  ['Design', 'pen-tool', 'green'],
  ['Film', 'clapperboard', 'blue'],
  ['Fashion', 'shirt', 'purple'],
  ['Writing', 'pen-line', 'amber'],
  ['Events', 'ticket', 'pink'],
];
