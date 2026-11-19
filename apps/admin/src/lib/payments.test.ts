import { describe, expect, it } from 'vitest';
import {
  formatMoney,
  parseShillings,
  paymentsMessage,
  statusLabel,
  statusTone,
  validateRefund,
} from './payments';

describe('payments helpers', () => {
  it('formats minor units as shillings', () => {
    expect(formatMoney(120_000)).toBe('KES 1,200');
    expect(formatMoney(120_050)).toBe('KES 1,200.50');
    expect(formatMoney(-50_000)).toBe('-KES 500');
  });

  it('parses a typed amount into minor units', () => {
    expect(parseShillings('500')).toBe(50_000);
    expect(parseShillings('1,200.50')).toBe(120_050);
    expect(parseShillings('0')).toBeNull();
    expect(parseShillings('12.345')).toBeNull();
    expect(parseShillings('abc')).toBeNull();
    expect(parseShillings('-5')).toBeNull();
  });

  it('validates a refund before it is sent', () => {
    const ok = { amount: '', reason: 'Customer asked for it', refundableMinor: 50_000 };
    expect(validateRefund(ok)).toBeNull();
    expect(validateRefund({ ...ok, amount: '200' })).toBeNull();
    expect(validateRefund({ ...ok, reason: 'no' })).toMatch(/reason/);
    expect(validateRefund({ ...ok, amount: '500.01' })).toMatch(/at most KES 500/);
    expect(validateRefund({ ...ok, amount: 'lots' })).toMatch(/shillings/);
    expect(validateRefund({ ...ok, refundableMinor: 0 })).toMatch(/nothing left/);
  });

  it('labels statuses in plain words', () => {
    expect(statusLabel('SUCCEEDED')).toBe('Paid');
    expect(statusLabel('PENDING')).toBe('Waiting for member');
    expect(statusTone('FAILED')).toBe('danger');
    expect(statusTone('SUCCEEDED')).toBe('success');
  });

  it('turns a forbidden answer into a plain message', () => {
    expect(paymentsMessage(403, 'Forbidden')).toMatch(/permission/);
    expect(paymentsMessage(409, 'Already done')).toBe('Already done');
  });
});
