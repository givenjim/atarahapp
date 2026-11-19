import { type ListingStatus } from '@prisma/client';
import {
  assertCanClose,
  assertTransition,
  canTransition,
  checkPricing,
  LISTING_TRANSITIONS,
  median,
  missingForSubmit,
  priceLabel,
  submitTarget,
} from './marketplace-logic';
import { replyLabel } from './marketplace.service';

describe('listing state machine', () => {
  const all = Object.keys(LISTING_TRANSITIONS) as ListingStatus[];

  it('allows the documented moves', () => {
    expect(canTransition('DRAFT', 'UNDER_REVIEW')).toBe(true);
    expect(canTransition('DRAFT', 'PUBLISHED')).toBe(true);
    expect(canTransition('UNDER_REVIEW', 'PUBLISHED')).toBe(true);
    expect(canTransition('UNDER_REVIEW', 'REJECTED')).toBe(true);
    expect(canTransition('REJECTED', 'UNDER_REVIEW')).toBe(true);
    expect(canTransition('PUBLISHED', 'ARCHIVED')).toBe(true);
    expect(canTransition('PUBLISHED', 'SUSPENDED')).toBe(true);
    expect(canTransition('SUSPENDED', 'PUBLISHED')).toBe(true);
    expect(canTransition('ARCHIVED', 'DRAFT')).toBe(true);
  });

  it('refuses everything else', () => {
    expect(canTransition('DRAFT', 'REJECTED')).toBe(false);
    expect(canTransition('DRAFT', 'SUSPENDED')).toBe(false);
    expect(canTransition('REJECTED', 'PUBLISHED')).toBe(false);
    expect(canTransition('ARCHIVED', 'PUBLISHED')).toBe(false);
    expect(canTransition('ARCHIVED', 'UNDER_REVIEW')).toBe(false);
    for (const s of all) expect(canTransition(s, s)).toBe(false);
  });

  it('throws INVALID_STATE for a refused move', () => {
    expect(() => assertTransition('ARCHIVED', 'PUBLISHED')).toThrow();
    expect(() => assertTransition('DRAFT', 'UNDER_REVIEW')).not.toThrow();
  });
});

describe('pricing', () => {
  it('on request has no price', () => {
    expect(checkPricing({ pricingType: 'ON_REQUEST', priceMin: 500 })).toEqual({
      min: null,
      max: null,
    });
  });
  it('fixed needs a price and stores minor units', () => {
    expect(checkPricing({ pricingType: 'FIXED', priceMin: 5000 })).toEqual({
      min: 500_000,
      max: null,
    });
    expect(() => checkPricing({ pricingType: 'FIXED' })).toThrow();
  });
  it('range needs max at least min', () => {
    expect(checkPricing({ pricingType: 'RANGE', priceMin: 100, priceMax: 200 })).toEqual({
      min: 10_000,
      max: 20_000,
    });
    expect(() => checkPricing({ pricingType: 'RANGE', priceMin: 300, priceMax: 200 })).toThrow();
    expect(() => checkPricing({ pricingType: 'RANGE', priceMin: 300 })).toThrow();
  });
  it('labels', () => {
    expect(priceLabel('ON_REQUEST', null, null)).toEqual({ label: 'Price on request', from: null });
    expect(priceLabel('FIXED', 500_000, null)).toEqual({
      label: 'KES 5,000',
      from: 'From KES 5,000',
    });
    expect(priceLabel('RANGE', 500_000, 900_000).label).toBe('KES 5,000 to KES 9,000');
  });
});

describe('submit rules', () => {
  const ok = {
    title: 'Wedding photography',
    description: 'A full day of coverage with edited gallery delivered in two weeks.',
    categoryId: 'c',
    mediaCount: 1,
    pricingType: 'FIXED' as const,
    priceMinMinor: 1000,
  };
  it('is ready when complete', () => expect(missingForSubmit(ok)).toEqual([]));
  it('lists what is missing', () => {
    const m = missingForSubmit({
      ...ok,
      title: '',
      mediaCount: 0,
      description: 'short',
      priceMinMinor: null,
    });
    expect(m.map((x) => x.field).sort()).toEqual(['description', 'mediaIds', 'priceMin', 'title']);
  });
  it('on request needs no price', () => {
    expect(missingForSubmit({ ...ok, pricingType: 'ON_REQUEST', priceMinMinor: null })).toEqual([]);
  });
});

describe('who publishes directly', () => {
  const base = {
    canPublishDirectly: false,
    newSellersNeedReview: true,
    approvedBefore: 0,
    rejectedOrSuspendedBefore: 0,
    directAfterApprovals: 3,
  };
  it('a new seller goes to review', () => expect(submitTarget(base)).toBe('UNDER_REVIEW'));
  it('a seller staff marked publishes directly', () => {
    expect(submitTarget({ ...base, canPublishDirectly: true })).toBe('PUBLISHED');
  });
  it('the platform setting can switch review off', () => {
    expect(submitTarget({ ...base, newSellersNeedReview: false })).toBe('PUBLISHED');
  });
  it('a clean history earns direct publishing', () => {
    expect(submitTarget({ ...base, approvedBefore: 3 })).toBe('PUBLISHED');
    expect(submitTarget({ ...base, approvedBefore: 2 })).toBe('UNDER_REVIEW');
    expect(submitTarget({ ...base, approvedBefore: 5, rejectedOrSuspendedBefore: 1 })).toBe(
      'UNDER_REVIEW',
    );
    expect(submitTarget({ ...base, approvedBefore: 5, directAfterApprovals: 0 })).toBe(
      'UNDER_REVIEW',
    );
  });
});

describe('closing a request', () => {
  it('needs a seller reply first', () => {
    expect(() => assertCanClose('NEW')).toThrow();
    expect(() => assertCanClose('CLOSED')).toThrow();
    expect(() => assertCanClose('REPLIED')).not.toThrow();
  });
});

describe('stats helpers', () => {
  it('median', () => {
    expect(median([])).toBeNull();
    expect(median([5])).toBe(5);
    expect(median([1, 9, 3])).toBe(3);
    expect(median([2, 4])).toBe(3);
  });
  it('reply label', () => {
    expect(replyLabel(null)).toBeNull();
    expect(replyLabel(20)).toBe('Replies within an hour');
    expect(replyLabel(180)).toBe('Replies within 3 hours');
    expect(replyLabel(60 * 50)).toBe('Replies within 2 days');
  });
});
