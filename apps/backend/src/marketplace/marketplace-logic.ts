import { type EnquiryStatus, type ListingStatus, type PricingType } from '@prisma/client';
import { ApiException } from '../common/api.exception';

/** Prices are whole shillings in the API and minor units (cents) in the database. */
export const toMinor = (shillings: number | null | undefined): number | null =>
  shillings === null || shillings === undefined ? null : Math.round(shillings * 100);
export const fromMinor = (minor: number | null): number | null =>
  minor === null ? null : Math.round(minor / 100);

export const MIN_TITLE = 4;
export const MAX_TITLE = 100;
export const MIN_DESCRIPTION = 30;
export const MAX_DESCRIPTION = 4000;
export const MAX_INCLUDED = 10;
export const MAX_INCLUDED_LENGTH = 120;
export const MAX_LISTING_MEDIA = 8;
export const MAX_LISTING_PROJECTS = 6;
export const MAX_LISTINGS_PER_SELLER = 30;
export const MAX_ENQUIRY_MESSAGE = 2000;

/**
 * The listing state machine (Master Prompt 6.6). Who may move a listing is checked by the service; this table says
 * which moves exist at all.
 *  - owner:  DRAFT to UNDER_REVIEW or PUBLISHED (submit), UNDER_REVIEW back to DRAFT (withdraw), REJECTED to
 *            DRAFT or UNDER_REVIEW (fix and resubmit), PUBLISHED to ARCHIVED (pause), ARCHIVED to DRAFT (restore)
 *  - staff:  UNDER_REVIEW to PUBLISHED or REJECTED, PUBLISHED to SUSPENDED, SUSPENDED to PUBLISHED, and
 *            suspending a seller moves their live listings to SUSPENDED
 */
export const LISTING_TRANSITIONS: Record<ListingStatus, readonly ListingStatus[]> = {
  DRAFT: ['UNDER_REVIEW', 'PUBLISHED', 'ARCHIVED'],
  UNDER_REVIEW: ['PUBLISHED', 'REJECTED', 'DRAFT', 'SUSPENDED'],
  PUBLISHED: ['ARCHIVED', 'SUSPENDED', 'UNDER_REVIEW'],
  REJECTED: ['DRAFT', 'UNDER_REVIEW', 'ARCHIVED'],
  SUSPENDED: ['PUBLISHED', 'UNDER_REVIEW', 'ARCHIVED'],
  ARCHIVED: ['DRAFT'],
};

export const canTransition = (from: ListingStatus, to: ListingStatus): boolean =>
  LISTING_TRANSITIONS[from].includes(to);

export function assertTransition(from: ListingStatus, to: ListingStatus): void {
  if (!canTransition(from, to)) {
    throw ApiException.invalidState(
      `A listing that is ${from.toLowerCase().replace('_', ' ')} cannot become ${to
        .toLowerCase()
        .replace('_', ' ')}.`,
      { from, to },
    );
  }
}

/** Statuses a seller may edit in place. A suspended listing is edited by staff decision only. */
export const OWNER_EDITABLE: readonly ListingStatus[] = [
  'DRAFT',
  'REJECTED',
  'ARCHIVED',
  'UNDER_REVIEW',
  'PUBLISHED',
];

export interface PricingInput {
  pricingType: PricingType;
  priceMin?: number | null;
  priceMax?: number | null;
}

/** Checks the price fields against the pricing type and returns minor units. */
export function checkPricing(p: PricingInput): { min: number | null; max: number | null } {
  if (p.pricingType === 'ON_REQUEST') return { min: null, max: null };
  const min = p.priceMin ?? null;
  const max = p.priceMax ?? null;
  if (min === null || min < 0) {
    throw ApiException.validation('Enter a price in Kenya shillings.', { field: 'priceMin' });
  }
  if (p.pricingType === 'FIXED') return { min: toMinor(min), max: null };
  if (max === null || max < min) {
    throw ApiException.validation('The highest price must be at least the lowest price.', {
      field: 'priceMax',
    });
  }
  return { min: toMinor(min), max: toMinor(max) };
}

const kes = (n: number) => `KES ${n.toLocaleString('en-US')}`;

/** "From KES 5,000", "KES 5,000 to KES 9,000", "Price on request". */
export function priceLabel(
  type: PricingType,
  minMinor: number | null,
  maxMinor: number | null,
): { label: string; from: string | null } {
  const min = fromMinor(minMinor);
  const max = fromMinor(maxMinor);
  if (type === 'ON_REQUEST' || min === null) return { label: 'Price on request', from: null };
  if (type === 'FIXED') return { label: kes(min), from: `From ${kes(min)}` };
  return { label: `${kes(min)} to ${kes(max ?? min)}`, from: `From ${kes(min)}` };
}

export interface SubmitCheck {
  title: string;
  description: string;
  categoryId: string | null;
  mediaCount: number;
  pricingType: PricingType;
  priceMinMinor: number | null;
}

/** What is missing before a listing can be submitted. Empty means ready. */
export function missingForSubmit(l: SubmitCheck): Array<{ field: string; message: string }> {
  const out: Array<{ field: string; message: string }> = [];
  if (l.title.trim().length < MIN_TITLE) {
    out.push({ field: 'title', message: 'Give your listing a title.' });
  }
  if (!l.categoryId) out.push({ field: 'categoryId', message: 'Pick a category.' });
  if (l.description.trim().length < MIN_DESCRIPTION) {
    out.push({
      field: 'description',
      message: `Describe what you offer in at least ${MIN_DESCRIPTION} characters.`,
    });
  }
  if (l.mediaCount < 1) out.push({ field: 'mediaIds', message: 'Add at least one picture.' });
  if (l.pricingType !== 'ON_REQUEST' && l.priceMinMinor === null) {
    out.push({ field: 'priceMin', message: 'Enter a price.' });
  }
  return out;
}

export interface PublishPolicy {
  canPublishDirectly: boolean;
  /** Platform setting `marketplace.first_listing_requires_review`. */
  newSellersNeedReview: boolean;
  approvedBefore: number;
  rejectedOrSuspendedBefore: number;
  /** Platform setting `marketplace.direct_publish_after_approvals`. */
  directAfterApprovals: number;
}

/**
 * Where a submitted listing goes. First listings from a new seller are reviewed; a seller staff marked, or one with
 * enough approved listings and none rejected or suspended, publishes directly.
 */
export function submitTarget(p: PublishPolicy): 'UNDER_REVIEW' | 'PUBLISHED' {
  if (p.canPublishDirectly) return 'PUBLISHED';
  if (!p.newSellersNeedReview) return 'PUBLISHED';
  if (
    p.directAfterApprovals > 0 &&
    p.approvedBefore >= p.directAfterApprovals &&
    p.rejectedOrSuspendedBefore === 0
  ) {
    return 'PUBLISHED';
  }
  return 'UNDER_REVIEW';
}

/** An enquiry is closed once both sides have spoken: a seller reply must exist. */
export function assertCanClose(status: EnquiryStatus): void {
  if (status === 'CLOSED') throw ApiException.invalidState('This request is already closed.');
  if (status !== 'REPLIED') {
    throw ApiException.invalidState('You can close a request once the seller has replied.');
  }
}

export function median(values: number[]): number | null {
  if (values.length === 0) return null;
  const s = [...values].sort((a, b) => a - b);
  const mid = Math.floor(s.length / 2);
  return s.length % 2 ? s[mid]! : Math.round((s[mid - 1]! + s[mid]!) / 2);
}

export const cleanText = (v: string | undefined | null): string =>
  (v ?? '').trim().replace(/[ \t]+/g, ' ');

export const cleanList = (items: string[] | undefined): string[] =>
  (items ?? []).map((i) => cleanText(i)).filter((i) => i.length > 0);

/**
 * Draft seller terms (DEC-122). The product owner supplies the real text (Master Prompt section 12); until then the
 * app shows this clearly marked placeholder and records the version the member accepted.
 */
export const SELLER_TERMS = {
  version: 'draft-1',
  isDraft: true,
  title: 'Seller terms (draft)',
  body: [
    'DRAFT PLACEHOLDER. These seller terms have not been supplied by the product owner yet and are not legal text.',
    'Before launch this screen shows the approved Atarah seller terms. Until then, accepting records only that you saw this notice.',
    'What is already true today: listings are reviewed before they appear, Atarah does not take payment for marketplace work, and you agree details and payment directly with your buyer.',
  ].join('\n\n'),
} as const;

/** The CTA note under "Request booking" (DEC-121). */
export const REQUEST_NOTE = "You'll agree details and payment directly with the seller.";
