import {
  darajaTimestamp,
  formatMoney,
  isWholeShillings,
  last4,
  toMsisdn,
  toShillings,
} from './payment-money';

describe('toMsisdn', () => {
  it.each([
    ['+254712345678', '254712345678'],
    ['0712345678', '254712345678'],
    ['254712345678', '254712345678'],
    ['0112345678', '254112345678'],
    ['+254 712 345 678', '254712345678'],
    ['0712-345-678', '254712345678'],
  ])('accepts %s', (input, out) => expect(toMsisdn(input)).toBe(out));

  it.each(['', '12345', '+255712345678', '071234567', '07123456789', '+254212345678', 'abc'])(
    'rejects %p',
    (input) => expect(toMsisdn(input)).toBeNull(),
  );

  it('keeps only the last four digits for storage', () => {
    expect(last4('254712345678')).toBe('5678');
  });
});

describe('money', () => {
  it('formats minor units', () => {
    expect(formatMoney(120_000)).toBe('KES 1,200');
    expect(formatMoney(120_050)).toBe('KES 1,200.50');
    expect(formatMoney(5)).toBe('KES 0.05');
  });

  it('knows whole shillings', () => {
    expect(isWholeShillings(120_000)).toBe(true);
    expect(isWholeShillings(120_050)).toBe(false);
    expect(toShillings(120_000)).toBe(1200);
  });

  it('formats the Daraja timestamp in Nairobi time', () => {
    // 21:30:05 UTC on 31 Dec is 00:30:05 on 1 Jan in Nairobi.
    expect(darajaTimestamp(new Date('2026-12-31T21:30:05Z'))).toBe('20270101003005');
  });
});
