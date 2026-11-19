/**
 * Sidebar sections of the Admin Platform spec (Master Prompt P0-M8). A section is shown only when the
 * signed-in administrator holds `permission`; the backend enforces the same permission on every call, so
 * hiding a link is a convenience and never the control.
 */
export interface NavSection {
  slug: string;
  label: string;
  href: string;
  /** Permission needed to see the section. */
  permission: string;
  /** `live` sections are built; others open a "Soon" panel naming the phase that ships them. */
  phase: 'live' | 'P1' | 'P2' | 'P3';
  summary: string;
}

export const NAV: readonly NavSection[] = [
  {
    slug: 'dashboard',
    label: 'Dashboard',
    href: '/',
    permission: 'admin.access',
    phase: 'live',
    summary: 'Attention queues and key counts for running the platform.',
  },
  {
    slug: 'users',
    label: 'Users',
    href: '/users',
    permission: 'user.view',
    phase: 'live',
    summary: 'Search members, view accounts, suspend and reactivate.',
  },
  {
    slug: 'privacy-requests',
    label: 'Privacy requests',
    href: '/privacy-requests',
    permission: 'user.view',
    phase: 'live',
    summary: 'Data exports and account deletions members asked for.',
  },
  {
    slug: 'memberships',
    label: 'Memberships',
    href: '/memberships',
    permission: 'membership.manage',
    phase: 'P2',
    summary: 'Membership history, grants, scholarships and extensions.',
  },
  {
    slug: 'roles',
    label: 'Roles & Permissions',
    href: '/roles',
    permission: 'role.manage',
    phase: 'live',
    summary: 'Assign roles and review what each role can do.',
  },
  {
    slug: 'verification',
    label: 'Verification',
    href: '/verification',
    permission: 'verification.review',
    phase: 'P2',
    summary: 'Review verification cases and evidence.',
  },
  {
    slug: 'content',
    label: 'Content',
    href: '/content',
    permission: 'help.manage',
    phase: 'live',
    summary: 'Help articles, the FAQ and versioned legal documents.',
  },
  {
    slug: 'articles',
    label: 'Articles',
    href: '/articles',
    permission: 'article.manage',
    phase: 'live',
    summary: 'Write, review, schedule and publish articles.',
  },
  {
    slug: 'home-curation',
    label: 'Home curation',
    href: '/home-curation',
    permission: 'article.manage',
    phase: 'live',
    summary: 'Choose the article pinned on the Home screen.',
  },
  {
    slug: 'taxonomy',
    label: 'Taxonomy',
    href: '/taxonomy',
    permission: 'taxonomy.manage',
    phase: 'live',
    summary: 'Disciplines, specialisations, skills, interests and the suggestion queue.',
  },
  {
    slug: 'learning',
    label: 'Learning',
    href: '/learning',
    permission: 'learning.manage',
    phase: 'live',
    summary:
      'Skill Labs: categories, courses and lessons, publishing, progress overrides and analytics.',
  },
  {
    slug: 'opportunities',
    label: 'Opportunities',
    href: '/opportunities',
    permission: 'opportunity.manage',
    phase: 'live',
    summary: 'Listings, review queue, providers, trust badges, link health and CSV import.',
  },
  {
    slug: 'mentorship',
    label: 'Mentorship',
    href: '/mentorship',
    permission: 'mentor.manage',
    phase: 'live',
    summary: 'Mentor applications, mentors, session types and featured mentors.',
  },
  {
    slug: 'marketplace',
    label: 'Marketplace',
    href: '/marketplace',
    permission: 'marketplace.manage',
    phase: 'live',
    summary: 'Listing review queue, sellers, reported listings, categories and review moderation.',
  },
  {
    slug: 'community',
    label: 'Community & Reports',
    href: '/community',
    permission: 'report.view',
    phase: 'live',
    summary: 'Reports queue, case review and moderation decisions.',
  },
  {
    slug: 'groups',
    label: 'Groups',
    href: '/groups',
    permission: 'community.group.manage',
    phase: 'live',
    summary: 'Official groups, moderators and pinned posts.',
  },
  {
    slug: 'announcements',
    label: 'Announcements',
    href: '/announcements',
    permission: 'community.announce',
    phase: 'live',
    summary: 'Staff announcements to every member or one group.',
  },
  {
    slug: 'portfolio',
    label: 'Portfolio',
    href: '/portfolio',
    permission: 'moderation.act',
    phase: 'live',
    summary: 'Review published portfolio projects, hide and restore them.',
  },
  {
    slug: 'creative-economy',
    label: 'Creative Economy',
    href: '/creative-economy',
    permission: 'creative-economy.manage',
    phase: 'P3',
    summary: 'Organisations, county ecosystem data and rising talent.',
  },
  {
    slug: 'payments',
    label: 'Payments',
    href: '/payments',
    permission: 'payment.view',
    phase: 'live',
    summary: 'Payment records, event history, re-checks and refunds.',
  },
  {
    slug: 'notifications',
    label: 'Notifications',
    href: '/notifications',
    permission: 'notification.broadcast',
    phase: 'live',
    summary: 'Broadcast announcements to members: audience, schedule and history.',
  },
  {
    slug: 'ai',
    label: 'AI',
    href: '/ai',
    permission: 'ai.configure',
    phase: 'P3',
    summary: 'AI capabilities, limits and usage.',
  },
  {
    slug: 'analytics',
    label: 'Analytics',
    href: '/analytics',
    permission: 'analytics.view',
    phase: 'live',
    summary:
      'Daily event counts for registrations, onboarding, opportunities, learning and search.',
  },
  {
    slug: 'audit-logs',
    label: 'Audit Logs',
    href: '/audit-logs',
    permission: 'audit.view',
    phase: 'live',
    summary: 'Every sensitive action, who did it and when.',
  },
  {
    slug: 'settings',
    label: 'Settings',
    href: '/settings',
    permission: 'settings.manage',
    phase: 'live',
    summary: 'Feature flags, tunable values and failed background jobs.',
  },
];

export const visibleNav = (permissions: readonly string[]): NavSection[] =>
  NAV.filter((s) => permissions.includes(s.permission));

export const sectionBySlug = (slug: string): NavSection | undefined =>
  NAV.find((s) => s.slug === slug);

export const phaseLabel = (phase: NavSection['phase']): string =>
  phase === 'live' ? '' : `Soon · ${phase}`;
