import { FcmPushProvider, type FcmMessaging } from './push';

const message = (n: number) => ({
  tokens: Array.from({ length: n }, (_, i) => `t${i}`),
  title: 'Hello',
  body: 'World',
  data: { deepLink: '/home' },
});

describe('FcmPushProvider (fake messaging client; not verified against Google)', () => {
  it('sends the notification and data payload with high priority', async () => {
    const calls: Array<Parameters<FcmMessaging['sendEachForMulticast']>[0]> = [];
    const messaging: FcmMessaging = {
      sendEachForMulticast: async (m) => {
        calls.push(m);
        return { responses: m.tokens.map(() => ({ success: true })) };
      },
    };
    const res = await new FcmPushProvider(messaging).send(message(2));
    expect(res.invalidTokens).toEqual([]);
    expect(calls[0]).toMatchObject({
      tokens: ['t0', 't1'],
      notification: { title: 'Hello', body: 'World' },
      data: { deepLink: '/home' },
      android: { priority: 'high' },
    });
  });

  it('splits more than 500 tokens into separate requests', async () => {
    const sizes: number[] = [];
    const messaging: FcmMessaging = {
      sendEachForMulticast: async (m) => {
        sizes.push(m.tokens.length);
        return { responses: m.tokens.map(() => ({ success: true })) };
      },
    };
    await new FcmPushProvider(messaging).send(message(1201));
    expect(sizes).toEqual([500, 500, 201]);
  });

  it('reports tokens FCM says are dead, so they can be revoked', async () => {
    const messaging: FcmMessaging = {
      sendEachForMulticast: async () => ({
        responses: [
          { success: true },
          { success: false, error: { code: 'messaging/registration-token-not-registered' } },
          { success: false, error: { code: 'messaging/invalid-registration-token' } },
        ],
      }),
    };
    const res = await new FcmPushProvider(messaging).send(message(3));
    expect(res.invalidTokens).toEqual(['t1', 't2']);
  });

  it('throws on other failures so the job is retried', async () => {
    const messaging: FcmMessaging = {
      sendEachForMulticast: async () => ({
        responses: [{ success: false, error: { code: 'messaging/internal-error' } }],
      }),
    };
    await expect(new FcmPushProvider(messaging).send(message(1))).rejects.toThrow(/internal-error/);
  });
});
