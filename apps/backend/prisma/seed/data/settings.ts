/**
 * Default platform settings. Money is integer minor units. Created only if missing: operators' edits are
 * never overwritten by re-seeding. Application code reads these through PlatformSettingsService.
 */
export interface SettingDef {
  key: string;
  value: string | number | boolean;
  description: string;
}

export const SETTINGS: readonly SettingDef[] = [
  {
    key: 'membership.pro.price_minor',
    value: 120000,
    description: 'Atarah Pro monthly price in minor units (KES 1,200.00).',
  },
  {
    key: 'membership.pro.currency',
    value: 'KES',
    description: 'Currency of the Pro price (ISO 4217).',
  },
  {
    key: 'membership.renewal_reminder_days',
    value: 3,
    description: 'Days before renewal to remind the member.',
  },
  {
    key: 'membership.grace_period_days',
    value: 3,
    description: 'Days a PAST_DUE membership keeps entitlements before EXPIRED.',
  },
  {
    key: 'scholarship.default_grant_months',
    value: 6,
    description: 'Default Pro scholarship duration (owner decision #10).',
  },

  {
    key: 'mentorship.free_cancellation_hours',
    value: 24,
    description: 'Mentee may cancel free up to this many hours before the session.',
  },
  {
    key: 'mentorship.late_cancellation_refund_percent',
    value: 50,
    description: 'Refund percentage for cancellations inside the free window.',
  },
  {
    key: 'mentorship.slot_hold_minutes',
    value: 10,
    description: 'How long a slot is held while the mentee pays.',
  },
  {
    key: 'mentorship.service_fee_minor',
    value: 0,
    description: 'Service fee per booking in minor units.',
  },
  {
    key: 'mentorship.commission_percent',
    value: 0,
    description: 'Atarah commission on mentor earnings (owner decision #7).',
  },
  {
    key: 'mentorship.join_window_minutes',
    value: 15,
    description: 'Join call becomes available this many minutes before start.',
  },

  {
    key: 'marketplace.fee_percent',
    value: 0,
    description: 'Marketplace fee (owner decision #8; no checkout in scope).',
  },
  {
    key: 'marketplace.first_listing_requires_review',
    value: true,
    description: "A seller's first listings go to UNDER_REVIEW.",
  },

  {
    key: 'verification.sla_working_days',
    value: 5,
    description: 'Reviewer service level for verification cases.',
  },
  {
    key: 'verification.id_retention_days',
    value: 90,
    description: 'Days to keep government ID images after a decision.',
  },

  { key: 'auth.code_ttl_minutes', value: 10, description: 'One-time code lifetime.' },
  {
    key: 'auth.recovery_code_ttl_minutes',
    value: 15,
    description: 'Password recovery code lifetime.',
  },
  {
    key: 'auth.code_resend_cooldown_seconds',
    value: 60,
    description: 'Minimum time between code sends.',
  },
  { key: 'auth.access_token_ttl_minutes', value: 15, description: 'Access token lifetime.' },
  { key: 'auth.refresh_token_ttl_days', value: 30, description: 'Refresh token sliding lifetime.' },
  { key: 'auth.admin_idle_timeout_minutes', value: 30, description: 'Admin session idle timeout.' },

  {
    key: 'account.deletion_grace_days',
    value: 30,
    description: 'Days before personal data is purged after account deletion.',
  },

  { key: 'media.max_image_bytes', value: 10485760, description: 'Image upload limit (10 MB).' },
  { key: 'media.max_video_bytes', value: 209715200, description: 'Video upload limit (200 MB).' },
  { key: 'media.max_audio_bytes', value: 52428800, description: 'Audio upload limit (50 MB).' },
  {
    key: 'media.max_document_bytes',
    value: 10485760,
    description: 'Document upload limit (10 MB).',
  },

  {
    key: 'support.email',
    value: 'support@atarah.app',
    description: 'Support contact (owner decision #15; assumed).',
  },
];

export const LEGAL_PLACEHOLDER_TITLE_PREFIX = 'DRAFT — pending legal review';
export const LEGAL_PLACEHOLDER_BODY =
  'This document is a placeholder. The legal text has not been supplied or reviewed yet and must not be relied on.';

export const LEGAL_DOCUMENTS = [
  { type: 'TERMS', name: 'Terms of Service' },
  { type: 'PRIVACY', name: 'Privacy Policy' },
  { type: 'COMMUNITY_GUIDELINES', name: 'Community Guidelines' },
  { type: 'PAYMENTS_REFUNDS', name: 'Payments & Refunds' },
  { type: 'SELLER_TERMS', name: 'Seller Terms' },
  { type: 'MENTOR_TERMS', name: 'Mentor Terms' },
] as const;
