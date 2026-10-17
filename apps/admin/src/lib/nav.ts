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
    phase: 'P1',
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
    phase: 'P1',
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
    permission: 'article.manage',
    phase: 'P1',
    summary: 'Articles, help articles and legal documents.',
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
    phase: 'P1',
    summary: 'Skill Labs courses, lessons and enrolments.',
  },
  {
    slug: 'opportunities',
    label: 'Opportunities',
    href: '/opportunities',
    permission: 'opportunity.manage',
    phase: 'P1',
    summary: 'Opportunity moderation, providers and trust badges.',
  },
  {
    slug: 'mentorship',
    label: 'Mentorship',
    href: '/mentorship',
    permission: 'mentor.manage',
    phase: 'P2',
    summary: 'Mentor approvals, bookings and feedback.',
  },
  {
    slug: 'marketplace',
    label: 'Marketplace',
    href: '/marketplace',
    permission: 'marketplace.manage',
    phase: 'P2',
    summary: 'Listing review and seller management.',
  },
  {
    slug: 'community',
    label: 'Community & Reports',
    href: '/community',
    permission: 'report.view',
    phase: 'P1',
    summary: 'Reports queue, moderation actions and appeals.',
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
    phase: 'P2',
    summary: 'Payment records, refunds and reconciliation.',
  },
  {
    slug: 'notifications',
    label: 'Notifications',
    href: '/notifications',
    permission: 'notification.broadcast',
    phase: 'P1',
    summary: 'Platform announcements and delivery health.',
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
    phase: 'P1',
    summary: 'Platform analytics.',
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
    phase: 'P1',
    summary: 'Platform settings and feature flags.',
  },
];

export const visibleNav = (permissions: readonly string[]): NavSection[] =>
  NAV.filter((s) => permissions.includes(s.permission));

export const sectionBySlug = (slug: string): NavSection | undefined =>
  NAV.find((s) => s.slug === slug);

export const phaseLabel = (phase: NavSection['phase']): string =>
  phase === 'live' ? '' : `Soon · ${phase}`;
