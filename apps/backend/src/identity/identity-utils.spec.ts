import { ApiException } from '../common/api.exception';
import { maskIdentifier, normalisePhone, parseIdentifier } from '../common/contact';
import {
  decryptSecret,
  encryptSecret,
  hmacHex,
  randomCode,
  randomRecoveryCode,
  randomToken,
  safeEqualHex,
} from '../common/crypto';
import { PASSWORD_PATTERN, PasswordService } from './password.service';
import { renderCodeMessage } from '../messaging/templates';

describe('normalisePhone', () => {
  it.each([
    ['0712345678', '+254712345678'],
    ['0112345678', '+254112345678'],
    ['712345678', '+254712345678'],
    ['254712345678', '+254712345678'],
    ['+254 712 345 678', '+254712345678'],
    ['+254-712-345-678', '+254712345678'],
    ['00254712345678', '+254712345678'],
    ['+447911123456', '+447911123456'],
  ])('%s -> %s', (raw, expected) => {
    expect(normalisePhone(raw)).toBe(expected);
  });

  it.each(['', 'abc', '12345', '+0123456789', '07123'])('rejects %j', (raw) => {
    expect(normalisePhone(raw)).toBeNull();
  });
});

describe('parseIdentifier', () => {
  it('lower-cases and trims email', () => {
    expect(parseIdentifier('  Nia@Example.COM ')).toEqual({
      kind: 'email',
      value: 'nia@example.com',
    });
  });
  it('detects phone numbers', () => {
    expect(parseIdentifier('0712 345 678')).toEqual({ kind: 'phone', value: '+254712345678' });
  });
  it('rejects malformed input with a field-level VALIDATION_ERROR', () => {
    for (const bad of ['not-an-email@', 'hello', '@x.co']) {
      try {
        parseIdentifier(bad);
        fail(`expected ${bad} to throw`);
      } catch (err) {
        expect(err).toBeInstanceOf(ApiException);
        expect((err as ApiException).details).toHaveProperty('fields');
      }
    }
  });
  it('masks identifiers for display and logs', () => {
    expect(maskIdentifier({ kind: 'email', value: 'nia@gmail.com' })).toBe('n***@gmail.com');
    expect(maskIdentifier({ kind: 'phone', value: '+254712345678' })).toBe('+254*****78');
  });
});

describe('crypto helpers', () => {
  it('hmacHex is deterministic per pepper and differs across peppers', () => {
    expect(hmacHex('p1', 'v')).toBe(hmacHex('p1', 'v'));
    expect(hmacHex('p1', 'v')).not.toBe(hmacHex('p2', 'v'));
  });
  it('safeEqualHex compares in constant time and rejects mismatched lengths', () => {
    const h = hmacHex('p', 'v');
    expect(safeEqualHex(h, h)).toBe(true);
    expect(safeEqualHex(h, hmacHex('p', 'w'))).toBe(false);
    expect(safeEqualHex(h, 'ab')).toBe(false);
    expect(safeEqualHex('', '')).toBe(false);
  });
  it('randomCode is six digits, zero padded', () => {
    for (let i = 0; i < 200; i++) expect(randomCode()).toMatch(/^\d{6}$/);
  });
  it('randomToken is long, url-safe and unique', () => {
    const a = randomToken();
    expect(a).toMatch(/^[A-Za-z0-9_-]{43}$/);
    expect(randomToken()).not.toBe(a);
  });
  it('recovery codes use the unambiguous XXXX-XXXX-XXXX format', () => {
    expect(randomRecoveryCode()).toMatch(/^[A-HJ-NP-Z2-9]{4}-[A-HJ-NP-Z2-9]{4}-[A-HJ-NP-Z2-9]{4}$/);
  });
  it('AES-GCM round-trips and detects tampering or the wrong key', () => {
    const enc = encryptSecret('key-one-key-one-key-one-key-one-00', 'JBSWY3DPEHPK3PXP');
    expect(enc).not.toContain('JBSWY3DP');
    expect(decryptSecret('key-one-key-one-key-one-key-one-00', enc)).toBe('JBSWY3DPEHPK3PXP');
    expect(() => decryptSecret('another-key-another-key-another-00', enc)).toThrow();
    const [iv, tag, ct] = enc.split('.');
    const flipped = `${iv}.${tag}.${ct!.slice(0, -2)}AA`;
    expect(() => decryptSecret('key-one-key-one-key-one-key-one-00', flipped)).toThrow();
  });
});

describe('password rules', () => {
  it.each([
    ['abcdefg1', true],
    ['Atarah-demo-1', true],
    ['short1', false],
    ['nodigitshere', false],
    ['12345678', true],
  ])('%s -> %s', (pw, ok) => {
    expect(PASSWORD_PATTERN.test(pw)).toBe(ok);
  });

  it('hashes with Argon2id and verifies', async () => {
    const svc = new PasswordService();
    const hash = await svc.hash('correct horse 9');
    expect(hash).toMatch(/^\$argon2id\$/);
    expect(await svc.verify(hash, 'correct horse 9')).toBe(true);
    expect(await svc.verify(hash, 'wrong horse 9')).toBe(false);
    expect(await svc.verify('not-a-hash', 'x')).toBe(false);
  });
});

describe('code message', () => {
  it('names the code, the expiry and the brand', () => {
    const m = renderCodeMessage('verify', '482913', 10);
    expect(m.text).toContain('482913');
    expect(m.text).toContain('10 minutes');
    expect(m.html).toContain('ATARA');
    expect(m.subject).toMatch(/Atarah/);
  });
});
