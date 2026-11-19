/** Pure helpers for the Marketplace admin screens (no server imports): labels, tones, money, validation. */

export const LISTING_STATUSES = [
  'UNDER_REVIEW',
  'PUBLISHED',
  'REJECTED',
  'SUSPENDED',
  'ARCHIVED',
  'DRAFT',
] as const;
export const SELLER_STATUSES = ['ACTIVE', 'SUSPENDED'] as const;
export const REPORT_STATUSES = ['OPEN', 'RESOLVED', 'DISMISSED'] as const;
export const REVIEW_STATUSES = ['VISIBLE', 'HIDDEN'] as const;
export const CATEGORY_TONES = [
  'violet',
  'pink',
  'orange',
  'green',
  'blue',
  'purple',
  'amber',
] as const;

export const titleCase = (v: string): string =>
  v.charAt(0) + v.slice(1).toLowerCase().replace(/_/g, ' ');

export const statusTone = (status: string): string => {
  switch (status) {
    case 'PUBLISHED':
    case 'ACTIVE':
    case 'VISIBLE':
    case 'RESOLVED':
      return 'success';
    case 'UNDER_REVIEW':
    case 'OPEN':
      return 'warning';
    case 'REJECTED':
    case 'SUSPENDED':
    case 'HIDDEN':
      return 'danger';
    default:
      return '';
  }
};

export const MIN_REASON = 5;

/** A reason is needed to reject, suspend, hide or resolve with an action. Members and the audit log read it. */
export const reasonProblem = (reason: string): string | null =>
  reason.trim().length >= MIN_REASON ? null : 'Say why, in at least a few words.';

export function marketplaceMessage(status: number | undefined, message: string): string {
  if (status === 403) return 'You do not have permission to do that.';
  if (status === 404) return 'That item no longer exists.';
  if (status === 409) return message || 'That is not possible in the current state.';
  return message;
}

/** Which of the review-queue actions a listing offers in its current status. */
export function listingVerbs(status: string): Array<'approve' | 'reject' | 'suspend' | 'reinstate'> {
  switch (status) {
    case 'UNDER_REVIEW':
      return ['approve', 'reject', 'suspend'];
    case 'PUBLISHED':
      return ['suspend'];
    case 'SUSPENDED':
      return ['reinstate'];
    default:
      return [];
  }
}

export const isCategoryTone = (v: string): v is (typeof CATEGORY_TONES)[number] =>
  (CATEGORY_TONES as readonly string[]).includes(v);
