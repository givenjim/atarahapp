/**
 * Roles and permissions (User Roles & Permissions Matrix with Master Prompt §6.1 applied).
 *
 * - Every active account is implicitly a member. Member capabilities are `isMemberDefault` permissions and
 *   are not attached to any role. Premium/Verified are entitlements/verification, never roles.
 * - Roles are additive. SUPER_ADMIN holds every permission.
 * - §6.1 overrides the matrix where they differ: content admins do NOT manage opportunities or decide
 *   verification cases; moderators handle reports and community content only; `payment.manage` is separate
 *   from PLATFORM_ADMIN.
 */
export interface PermissionDef {
  key: string;
  description: string;
  memberDefault?: boolean;
}

export const PERMISSIONS: readonly PermissionDef[] = [
  // ---- member defaults (every ACTIVE account) ----
  {
    key: 'profile.view',
    description: 'View profiles allowed by visibility rules.',
    memberDefault: true,
  },
  {
    key: 'profile.edit',
    description: 'Edit own profile, Creative Passport and visibility.',
    memberDefault: true,
  },
  {
    key: 'portfolio.manage',
    description: 'Create, edit and delete own projects, media and collaborators.',
    memberDefault: true,
  },
  { key: 'community.view', description: 'View the community.', memberDefault: true },
  { key: 'community.post', description: 'Create, edit and delete own posts.', memberDefault: true },
  { key: 'community.comment', description: 'Comment and react.', memberDefault: true },
  { key: 'report.create', description: 'Report users and content.', memberDefault: true },
  {
    key: 'learning.browse',
    description: 'Browse Skill Labs, enrol, track progress.',
    memberDefault: true,
  },
  {
    key: 'opportunity.view',
    description: 'View, save and track opportunities.',
    memberDefault: true,
  },
  {
    key: 'marketplace.browse',
    description: 'Browse, save and enquire about listings.',
    memberDefault: true,
  },
  {
    key: 'mentor.browse',
    description: 'Browse mentors. Booking additionally needs the MENTORSHIP_BOOKING entitlement.',
    memberDefault: true,
  },
  { key: 'mentor.apply', description: 'Apply to become a mentor.', memberDefault: true },
  {
    key: 'seller.apply',
    description: 'Become a seller by creating a first listing and accepting seller terms.',
    memberDefault: true,
  },
  {
    key: 'verification.request',
    description: 'Request verification. Creative and skill verification need their entitlements.',
    memberDefault: true,
  },
  {
    key: 'notification.manage.own',
    description: 'View notifications and manage own preferences.',
    memberDefault: true,
  },
  {
    key: 'saved.manage.own',
    description: 'Save and unsave supported content.',
    memberDefault: true,
  },
  { key: 'ai.use', description: 'Use contextual AI assistance on own data.', memberDefault: true },
  {
    key: 'account.manage.own',
    description: 'Manage own account, privacy and security settings.',
    memberDefault: true,
  },

  // ---- MENTOR ----
  { key: 'mentor.profile.manage', description: 'Manage own mentor profile and credentials.' },
  { key: 'mentor.availability.manage', description: 'Manage own availability and session types.' },
  {
    key: 'mentor.bookings.manage',
    description: 'View upcoming sessions, accept or decline booking requests.',
  },

  // ---- SELLER ----
  { key: 'listing.create', description: 'Create marketplace listings.' },
  { key: 'listing.manage.own', description: 'Edit, pause and delete own listings.' },
  { key: 'enquiry.manage.own', description: 'View and answer enquiries on own listings.' },

  // ---- OPPORTUNITY_PROVIDER ----
  { key: 'opportunity.submit', description: 'Submit opportunities for review.' },
  { key: 'opportunity.manage.own', description: 'Edit and view own submitted opportunities.' },

  // ---- INSTRUCTOR ----
  {
    key: 'learning.content.manage.own',
    description: 'Manage learning content assigned to the instructor.',
  },

  // ---- MODERATOR ----
  { key: 'admin.access', description: 'Sign in to the admin console.' },
  { key: 'report.view', description: 'View the report queue.' },
  { key: 'report.resolve', description: 'Resolve reports and record moderation decisions.' },
  {
    key: 'moderation.act',
    description: 'Hide or remove content and restrict accounts per policy.',
  },
  { key: 'community.moderate', description: 'Moderate posts, comments and groups.' },

  // ---- CONTENT_ADMIN ----
  { key: 'article.manage', description: 'Create, review, publish and archive articles.' },
  { key: 'learning.manage', description: 'Manage Skill Labs: categories, courses, lessons.' },
  { key: 'help.manage', description: 'Manage help articles and FAQ.' },
  { key: 'legal.manage', description: 'Manage legal documents and versions.' },
  { key: 'category.manage', description: 'Manage content and marketplace categories.' },
  { key: 'media.manage', description: 'Manage uploaded media.' },
  {
    key: 'creative-economy.manage',
    description: 'Manage organisations, county ecosystem data and rising talent.',
  },
  {
    key: 'taxonomy.manage',
    description: 'Manage disciplines, specialisations, skills and interests.',
  },

  // ---- PLATFORM_ADMIN ----
  { key: 'user.view', description: 'View users and their status history.' },
  { key: 'user.suspend', description: 'Suspend and reactivate accounts.' },
  {
    key: 'membership.manage',
    description: 'View, grant, revoke and extend memberships and scholarships.',
  },
  { key: 'opportunity.manage', description: 'Manage all opportunities and providers.' },
  { key: 'opportunity.verify', description: 'Set the trust badge on opportunities and providers.' },
  { key: 'mentor.manage', description: 'Approve, pause and remove mentors.' },
  { key: 'seller.manage', description: 'Manage sellers.' },
  { key: 'marketplace.manage', description: 'Review, approve and suspend listings.' },
  { key: 'verification.review', description: 'View verification cases and evidence.' },
  {
    key: 'verification.decide',
    description: "Approve, reject or revoke verification (never one's own case).",
  },
  { key: 'notification.broadcast', description: 'Send platform announcements.' },
  { key: 'analytics.view', description: 'View platform analytics.' },
  { key: 'audit.view', description: 'View the audit log.' },
  { key: 'settings.manage', description: 'Manage platform settings and feature flags.' },
  { key: 'ai.configure', description: 'Configure AI capabilities and limits.' },
  { key: 'payment.view', description: 'View payment records (metadata only).' },

  // ---- SUPER_ADMIN only ----
  {
    key: 'payment.manage',
    description: 'Refund, re-query and reconcile payments. Separate from platform admin.',
  },
  { key: 'role.manage', description: 'Assign and revoke roles.' },
  { key: 'permission.manage', description: 'Manage role permissions.' },
  { key: 'admin.manage', description: 'Create and manage administrator accounts.' },
  { key: 'security.manage', description: 'Manage security configuration and sessions.' },
  { key: 'emergency.control', description: 'Emergency controls (kill switches, mass sign-out).' },
];

export interface RoleDef {
  key:
    | 'MENTOR'
    | 'SELLER'
    | 'OPPORTUNITY_PROVIDER'
    | 'INSTRUCTOR'
    | 'MODERATOR'
    | 'CONTENT_ADMIN'
    | 'PLATFORM_ADMIN'
    | 'SUPER_ADMIN';
  name: string;
  description: string;
  isStaff: boolean;
  /** `*` means every permission. */
  permissions: readonly string[] | '*';
}

const PLATFORM_ADMIN_PERMISSIONS = [
  'admin.access',
  'user.view',
  'user.suspend',
  'membership.manage',
  'opportunity.manage',
  'opportunity.verify',
  'mentor.manage',
  'seller.manage',
  'marketplace.manage',
  'verification.review',
  'verification.decide',
  'notification.broadcast',
  'analytics.view',
  'audit.view',
  'settings.manage',
  'ai.configure',
  'payment.view',
  'report.view',
  'report.resolve',
  'moderation.act',
  'community.moderate',
  'taxonomy.manage',
] as const;

export const ROLES: readonly RoleDef[] = [
  {
    key: 'MENTOR',
    name: 'Mentor',
    description: 'An approved mentor offering paid sessions.',
    isStaff: false,
    permissions: ['mentor.profile.manage', 'mentor.availability.manage', 'mentor.bookings.manage'],
  },
  {
    key: 'SELLER',
    name: 'Seller',
    description: 'A member authorised to publish marketplace listings.',
    isStaff: false,
    permissions: ['listing.create', 'listing.manage.own', 'enquiry.manage.own'],
  },
  {
    key: 'OPPORTUNITY_PROVIDER',
    name: 'Opportunity provider',
    description: 'An approved organisation or individual that submits opportunities.',
    isStaff: false,
    permissions: ['opportunity.submit', 'opportunity.manage.own'],
  },
  {
    key: 'INSTRUCTOR',
    name: 'Instructor',
    description: 'Authors Skill Labs content assigned to them.',
    isStaff: false,
    permissions: ['learning.content.manage.own'],
  },
  {
    key: 'MODERATOR',
    name: 'Moderator',
    description:
      'Handles reports and community content only. No payments, roles, memberships or private account data.',
    isStaff: true,
    permissions: [
      'admin.access',
      'report.view',
      'report.resolve',
      'moderation.act',
      'community.moderate',
    ],
  },
  {
    key: 'CONTENT_ADMIN',
    name: 'Content admin',
    description:
      'Manages articles, learning, help, legal documents, categories and media. Does not manage opportunities or decide verification cases.',
    isStaff: true,
    permissions: [
      'admin.access',
      'article.manage',
      'learning.manage',
      'help.manage',
      'legal.manage',
      'category.manage',
      'media.manage',
      'creative-economy.manage',
      'taxonomy.manage',
    ],
  },
  {
    key: 'PLATFORM_ADMIN',
    name: 'Platform admin',
    description:
      'Operates users, memberships, opportunities, mentors, sellers, verification, marketplace and settings. Payment management needs payment.manage.',
    isStaff: true,
    permissions: PLATFORM_ADMIN_PERMISSIONS,
  },
  {
    key: 'SUPER_ADMIN',
    name: 'Super admin',
    description:
      'Roles, permissions, admin accounts, security settings and emergency controls. Holds every permission.',
    isStaff: true,
    permissions: '*',
  },
];

export const ENTITLEMENTS = [
  { key: 'MENTORSHIP_BOOKING', description: 'Book paid mentorship sessions.' },
  { key: 'CREATIVE_VERIFICATION', description: 'Apply for Verified Creative.' },
  { key: 'SKILL_VERIFICATION', description: 'Submit skills for verification.' },
  { key: 'REDUCED_MARKETPLACE_FEES', description: 'Reduced marketplace fees.' },
  { key: 'PREMIUM_CONTENT', description: 'Access premium learning content.' },
] as const;

export const PLANS = [
  {
    key: 'FREE',
    name: 'Free',
    description: 'Everything you need to build your creative identity.',
    entitlements: [] as string[],
  },
  {
    key: 'PRO',
    name: 'Atarah Pro',
    description:
      'Mentorship booking, Verified Creative, Skill Verification and reduced marketplace fees.',
    entitlements: ENTITLEMENTS.map((e) => e.key) as string[],
  },
] as const;
