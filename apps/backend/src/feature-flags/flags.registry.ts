/**
 * Every capability that ships after Phase 0 has a flag here (Master Prompt P0-M3). The registry is
 * the source of truth for which flags exist; `FeatureFlagService.syncRegistry()` creates missing
 * rows on startup and never overwrites an operator's choice.
 */
export interface FlagDefinition {
  key: string;
  description: string;
  /** Phase that delivers the capability. */
  phase: 0 | 1 | 2 | 3;
  defaultEnabled: boolean;
}

export const FLAG_REGISTRY: readonly FlagDefinition[] = [
  {
    key: 'google-sign-in',
    description: 'Continue with Google (needs OAuth client credentials).',
    phase: 0,
    defaultEnabled: false,
  },

  {
    key: 'community',
    description: 'Community feed, groups and connections.',
    phase: 1,
    defaultEnabled: false,
  },
  {
    key: 'opportunities',
    description: 'Opportunities discovery and tracking.',
    phase: 1,
    defaultEnabled: false,
  },
  {
    key: 'skill-labs',
    description: 'Learning: courses, lessons, certificates.',
    phase: 1,
    defaultEnabled: false,
  },
  {
    key: 'two-step-verification',
    description: 'Code on sign-in from a new device.',
    phase: 1,
    defaultEnabled: false,
  },
  {
    key: 'push-notifications',
    description: 'Push delivery through FCM.',
    phase: 1,
    defaultEnabled: false,
  },

  {
    key: 'payments-mpesa',
    description: 'M-Pesa (Daraja STK Push) payments.',
    phase: 2,
    defaultEnabled: false,
  },
  {
    key: 'card-payments',
    description: 'Card payments (needs the owner-selected provider).',
    phase: 2,
    defaultEnabled: false,
  },
  {
    key: 'atarah-pro',
    description: 'Atarah Pro membership and entitlements.',
    phase: 2,
    defaultEnabled: false,
  },
  {
    key: 'marketplace',
    description: 'Marketplace foundation: listings and enquiries.',
    phase: 2,
    defaultEnabled: false,
  },
  {
    key: 'mentorship',
    description: 'Mentor discovery and paid booking.',
    phase: 2,
    defaultEnabled: false,
  },
  {
    key: 'verified-creative',
    description: 'Verified Creative identity verification.',
    phase: 2,
    defaultEnabled: false,
  },
  {
    key: 'skill-verification',
    description: 'Skill verification cases.',
    phase: 2,
    defaultEnabled: false,
  },
  {
    key: 'creative-cv-epk',
    description: 'Creative CV / EPK generation and sharing.',
    phase: 2,
    defaultEnabled: false,
  },

  {
    key: 'ai-assist',
    description: 'Master switch for contextual AI.',
    phase: 3,
    defaultEnabled: false,
  },
  {
    key: 'ai-bio',
    description: 'AI bio help (onboarding and profile).',
    phase: 3,
    defaultEnabled: false,
  },
  {
    key: 'ai-project-description',
    description: 'AI help describing a project.',
    phase: 3,
    defaultEnabled: false,
  },
  {
    key: 'ai-opportunity-summary',
    description: 'Plain-language opportunity summary.',
    phase: 3,
    defaultEnabled: false,
  },
  {
    key: 'ai-learning-recommendations',
    description: 'What should I learn next?',
    phase: 3,
    defaultEnabled: false,
  },
  {
    key: 'creative-economy',
    description: 'Kenya creative economy map and county pages.',
    phase: 3,
    defaultEnabled: false,
  },
  {
    key: 'public-web',
    description: 'Public web acquisition pages.',
    phase: 3,
    defaultEnabled: false,
  },
  {
    key: 'app-store-links',
    description: 'Show app-store download links on the public web.',
    phase: 3,
    defaultEnabled: false,
  },
];

export type FlagKey = (typeof FLAG_REGISTRY)[number]['key'];
