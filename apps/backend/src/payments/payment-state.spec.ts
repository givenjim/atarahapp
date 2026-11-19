import { type PaymentStatus } from '@prisma/client';
import {
  canTransition,
  isOpen,
  isPaid,
  statusAfterRefund,
  statusesBefore,
  TRANSITIONS,
} from './payment-state';

const ALL = Object.keys(TRANSITIONS) as PaymentStatus[];

describe('payment state machine', () => {
  it('allows exactly the documented moves', () => {
    expect(canTransition('INITIATED', 'PENDING')).toBe(true);
    expect(canTransition('PENDING', 'SUCCEEDED')).toBe(true);
    expect(canTransition('PENDING', 'FAILED')).toBe(true);
    expect(canTransition('PENDING', 'CANCELLED')).toBe(true);
    expect(canTransition('SUCCEEDED', 'PARTIALLY_REFUNDED')).toBe(true);
    expect(canTransition('SUCCEEDED', 'REFUNDED')).toBe(true);
    expect(canTransition('PARTIALLY_REFUNDED', 'REFUNDED')).toBe(true);
  });

  it('never reaches SUCCEEDED from INITIATED or from a cancelled payment', () => {
    expect(canTransition('INITIATED', 'SUCCEEDED')).toBe(false);
    expect(canTransition('CANCELLED', 'SUCCEEDED')).toBe(false);
    expect(statusesBefore('SUCCEEDED').sort()).toEqual(['FAILED', 'PENDING']);
  });

  it('refunded and cancelled payments are final', () => {
    for (const to of ALL) {
      expect(canTransition('REFUNDED', to)).toBe(false);
      expect(canTransition('CANCELLED', to)).toBe(false);
    }
  });

  it('cannot go backwards', () => {
    expect(canTransition('PENDING', 'INITIATED')).toBe(false);
    expect(canTransition('SUCCEEDED', 'PENDING')).toBe(false);
    expect(canTransition('SUCCEEDED', 'FAILED')).toBe(false);
    expect(canTransition('REFUNDED', 'PARTIALLY_REFUNDED')).toBe(false);
  });

  it('classifies open and paid statuses', () => {
    expect(ALL.filter(isOpen)).toEqual(['INITIATED', 'PENDING']);
    expect(ALL.filter(isPaid).sort()).toEqual(['PARTIALLY_REFUNDED', 'REFUNDED', 'SUCCEEDED']);
  });

  it('picks the status after a refund from the running total', () => {
    expect(statusAfterRefund(100_000, 40_000)).toBe('PARTIALLY_REFUNDED');
    expect(statusAfterRefund(100_000, 100_000)).toBe('REFUNDED');
  });
});
