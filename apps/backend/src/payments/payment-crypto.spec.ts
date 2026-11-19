import { type AppConfigService } from '../config/app-config.service';
import { PaymentCrypto } from './payment-crypto';

const config = (encryptionKey: string, isDeployed = false) =>
  ({ payments: { encryptionKey }, isDeployed }) as unknown as AppConfigService;

describe('PaymentCrypto', () => {
  const key = Buffer.alloc(32, 7).toString('base64');

  it('round-trips a payload and never stores it readable', () => {
    const c = new PaymentCrypto(config(key));
    const token = c.encrypt('{"Body":{"stkCallback":{"ResultCode":0}}}');
    expect(token).not.toContain('stkCallback');
    expect(token.startsWith('v1.')).toBe(true);
    expect(c.decrypt(token)).toBe('{"Body":{"stkCallback":{"ResultCode":0}}}');
  });

  it('uses a fresh IV each time', () => {
    const c = new PaymentCrypto(config(key));
    expect(c.encrypt('same')).not.toBe(c.encrypt('same'));
  });

  it('rejects a tampered payload', () => {
    const c = new PaymentCrypto(config(key));
    const [v, iv, tag, body] = c.encrypt('secret').split('.');
    const flipped = Buffer.from(body!, 'base64url');
    flipped[0] = flipped[0]! ^ 1;
    expect(() => c.decrypt([v, iv, tag, flipped.toString('base64url')].join('.'))).toThrow();
  });

  it('uses a development stand-in only outside deployed environments', () => {
    expect(new PaymentCrypto(config('')).isAvailable).toBe(true);
    const deployed = new PaymentCrypto(config('', true));
    expect(deployed.isAvailable).toBe(false);
    expect(() => deployed.encrypt('x')).toThrow(/ATARAH_PAYMENTS_ENCRYPTION_KEY/);
  });
});
