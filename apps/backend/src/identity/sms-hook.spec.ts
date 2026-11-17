import { createHmac } from 'node:crypto';
import { ApiException } from '../common/api.exception';
import { type AppConfigService } from '../config/app-config.service';
import { type SmsMessage } from '../messaging/messaging';
import { SmsHookService } from './sms-hook.service';

const SECRET_B64 = Buffer.from('a-test-secret-that-is-long-enough!').toString('base64');
const config = { supabase: { smsHookSecret: `v1,whsec_${SECRET_B64}` } } as AppConfigService;

function sign(id: string, timestamp: string, body: Buffer): string {
  const mac = createHmac('sha256', Buffer.from(SECRET_B64, 'base64'))
    .update(`${id}.${timestamp}.`)
    .update(body)
    .digest('base64');
  return `v1,${mac}`;
}

describe('SmsHookService', () => {
  const sent: SmsMessage[] = [];
  const service = new SmsHookService(config, { send: async (m: SmsMessage) => void sent.push(m) });
  const now = 1_800_000_000_000;
  const ts = String(now / 1000);
  const body = Buffer.from(
    JSON.stringify({ user: { phone: '254712345678' }, sms: { otp: '123456' } }),
  );

  beforeEach(() => (sent.length = 0));

  it('accepts a correctly signed request', () => {
    const signature = sign('msg_1', ts, body);
    expect(() =>
      service.verifySignature(body, { id: 'msg_1', timestamp: ts, signature }, now),
    ).not.toThrow();
  });

  it('accepts when one of several space-separated signatures matches', () => {
    const signature = `v1,AAAA ${sign('msg_1', ts, body)}`;
    expect(() =>
      service.verifySignature(body, { id: 'msg_1', timestamp: ts, signature }, now),
    ).not.toThrow();
  });

  it.each([
    ['a tampered body', Buffer.from('{"sms":{"otp":"000000"}}'), 'msg_1', ts, undefined],
    ['a wrong id', body, 'msg_2', ts, undefined],
    ['a stale timestamp', body, 'msg_1', String(now / 1000 - 3600), undefined],
    ['a missing signature', body, 'msg_1', ts, ''],
  ])('rejects %s', (_label, raw, id, timestamp, forced) => {
    const signature = forced ?? sign('msg_1', ts, body);
    expect(() => service.verifySignature(raw, { id, timestamp, signature }, now)).toThrow(
      ApiException,
    );
  });

  it('rejects a request without a raw body', () => {
    expect(() =>
      service.verifySignature(undefined, { id: 'a', timestamp: ts, signature: 'v1,x' }, now),
    ).toThrow(ApiException);
  });

  it('sends the code to the number in E.164 form', async () => {
    await service.send({ user: { phone: '254712345678' }, sms: { otp: '123456' } });
    expect(sent).toHaveLength(1);
    expect(sent[0]!.to).toBe('+254712345678');
    expect(sent[0]!.text).toContain('123456');
  });

  it('refuses a payload with no phone or code', async () => {
    await expect(service.send({ sms: { otp: '1' } })).rejects.toThrow(ApiException);
  });
});
