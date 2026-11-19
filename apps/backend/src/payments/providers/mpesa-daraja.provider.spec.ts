import { type AppConfigService } from '../../config/app-config.service';
import { mapResultCode, MpesaDarajaProvider } from './mpesa-daraja.provider';
import { ProviderError } from './payment-provider';

const TOKEN = 'a'.repeat(40);

const make = (
  over: Partial<{ allowedIps: string[]; callbackToken: string; passkey: string }> = {},
) =>
  new MpesaDarajaProvider({
    payments: {
      mpesa: {
        env: 'sandbox',
        baseUrl: 'https://sandbox.safaricom.co.ke',
        consumerKey: 'key',
        consumerSecret: 'secret',
        shortcode: '174379',
        passkey: 'passkey',
        callbackToken: TOKEN,
        callbackUrl: `https://example.test/api/v1/webhooks/payments/mpesa/${TOKEN}`,
        allowedIps: [],
        ...over,
      },
    },
  } as unknown as AppConfigService);

const callback = (result: object, items: object[] = []) => ({
  Body: {
    stkCallback: {
      MerchantRequestID: 'm-1',
      CheckoutRequestID: 'ws_CO_1',
      ResultCode: 0,
      ResultDesc: 'The service request is processed successfully.',
      CallbackMetadata: { Item: items },
      ...result,
    },
  },
});

describe('MpesaDarajaProvider webhook handling', () => {
  it('parses a success callback and reads the amount in minor units', () => {
    const parsed = make().parseWebhook(
      callback({}, [
        { Name: 'Amount', Value: 1200 },
        { Name: 'MpesaReceiptNumber', Value: 'QGH7XYZ123' },
        { Name: 'PhoneNumber', Value: 254712345678 },
      ]),
    );
    expect(parsed).toMatchObject({
      providerReference: 'ws_CO_1',
      claimed: 'SUCCESS',
      amountMinor: 120_000,
      receiptNumber: 'QGH7XYZ123',
    });
  });

  it('maps the result codes to what the member should be told', () => {
    expect(mapResultCode(0)).toEqual({ outcome: 'SUCCESS' });
    expect(mapResultCode('1032')).toEqual({ outcome: 'CANCELLED', code: 'CANCELLED_BY_USER' });
    expect(mapResultCode(1)).toEqual({ outcome: 'FAILED', code: 'INSUFFICIENT_FUNDS' });
    expect(mapResultCode(2001)).toEqual({ outcome: 'FAILED', code: 'WRONG_PIN' });
    expect(mapResultCode(1037)).toEqual({ outcome: 'FAILED', code: 'TIMEOUT' });
    expect(mapResultCode(9999)).toEqual({ outcome: 'FAILED', code: 'PROVIDER_DECLINED' });
  });

  it('parses a cancelled callback that carries no metadata', () => {
    const body = callback({ ResultCode: 1032, ResultDesc: 'Request cancelled by user' });
    delete (body.Body.stkCallback as Record<string, unknown>).CallbackMetadata;
    expect(make().parseWebhook(body)).toMatchObject({
      claimed: 'CANCELLED',
      code: 'CANCELLED_BY_USER',
      amountMinor: undefined,
    });
  });

  it('ignores bodies that are not an STK callback', () => {
    expect(make().parseWebhook({})).toBeNull();
    expect(make().parseWebhook('nope')).toBeNull();
    expect(make().parseWebhook({ Body: { stkCallback: {} } })).toBeNull();
  });

  it('accepts only the exact path token', () => {
    const p = make();
    const base = { headers: {}, body: {} };
    expect(p.verifyWebhook({ ...base, token: TOKEN })).toBe(true);
    expect(p.verifyWebhook({ ...base, token: TOKEN.slice(0, -1) + 'b' })).toBe(false);
    expect(p.verifyWebhook({ ...base, token: '' })).toBe(false);
    expect(p.verifyWebhook({ ...base })).toBe(false);
  });

  it('refuses everything when the configured token is too short', () => {
    const p = make({ callbackToken: 'short' });
    expect(p.verifyWebhook({ headers: {}, body: {}, token: 'short' })).toBe(false);
    expect(p.isConfigured()).toBe(false);
  });

  it('applies the optional IP allow-list on top of the token', () => {
    const p = make({ allowedIps: ['196.201.214.200'] });
    const req = { headers: {}, body: {}, token: TOKEN };
    expect(p.verifyWebhook({ ...req, ip: '196.201.214.200' })).toBe(true);
    expect(p.verifyWebhook({ ...req, ip: '::ffff:196.201.214.200' })).toBe(true);
    expect(p.verifyWebhook({ ...req, ip: '10.0.0.1' })).toBe(false);
    expect(p.verifyWebhook(req)).toBe(false);
  });
});

describe('MpesaDarajaProvider requests', () => {
  const realFetch = global.fetch;
  afterEach(() => {
    global.fetch = realFetch;
  });

  const respond = (routes: Record<string, { status?: number; body: unknown }>) => {
    const calls: Array<{ url: string; body?: unknown }> = [];
    global.fetch = jest.fn((url: string | URL | Request, init?: RequestInit) => {
      const u = String(url);
      calls.push({ url: u, body: init?.body ? JSON.parse(String(init.body)) : undefined });
      const key = Object.keys(routes).find((k) => u.includes(k));
      if (!key) return Promise.reject(new Error(`unexpected ${u}`));
      const r = routes[key]!;
      return Promise.resolve(new Response(JSON.stringify(r.body), { status: r.status ?? 200 }));
    }) as typeof fetch;
    return calls;
  };

  const oauth = { '/oauth/v1/generate': { body: { access_token: 'tok', expires_in: '3599' } } };

  it('sends an STK push with whole shillings, the callback URL and returns the checkout id', async () => {
    const calls = respond({
      ...oauth,
      '/stkpush/v1/processrequest': {
        body: { MerchantRequestID: 'm-9', CheckoutRequestID: 'ws_CO_9', ResponseCode: '0' },
      },
    });
    const res = await make().initiate({
      paymentId: 'p1',
      amountMinor: 120_000,
      currency: 'KES',
      msisdn: '254712345678',
      accountReference: 'Atarah Pro membership',
      description: 'Atarah Pro one month',
    });
    expect(res.providerReference).toBe('ws_CO_9');
    expect(res.action.type).toBe('STK_PROMPT');
    const push = calls.find((c) => c.url.includes('processrequest'))!.body as Record<
      string,
      unknown
    >;
    expect(push).toMatchObject({
      Amount: 1200,
      PhoneNumber: '254712345678',
      BusinessShortCode: '174379',
      CallBackURL: `https://example.test/api/v1/webhooks/payments/mpesa/${TOKEN}`,
    });
    expect(String(push.AccountReference).length).toBeLessThanOrEqual(12);
  });

  it('refuses cents before calling Daraja', async () => {
    const calls = respond(oauth);
    await expect(
      make().initiate({
        paymentId: 'p1',
        amountMinor: 120_050,
        currency: 'KES',
        msisdn: '254712345678',
        accountReference: 'A',
        description: 'd',
      }),
    ).rejects.toBeInstanceOf(ProviderError);
    expect(calls).toHaveLength(0);
  });

  it('treats "being processed" as still pending, not as a failure', async () => {
    respond({
      ...oauth,
      '/stkpushquery/v1/query': {
        status: 500,
        body: { errorCode: '500.001.1001', errorMessage: 'The transaction is being processed' },
      },
    });
    await expect(make().queryStatus('ws_CO_9')).resolves.toMatchObject({ outcome: 'PENDING' });
  });

  it('maps query results and throws when the provider cannot be asked', async () => {
    respond({
      ...oauth,
      '/stkpushquery/v1/query': { body: { ResultCode: '0', ResultDesc: 'ok' } },
    });
    await expect(make().queryStatus('x')).resolves.toMatchObject({ outcome: 'SUCCESS' });
    respond({
      ...oauth,
      '/stkpushquery/v1/query': { body: { ResultCode: '1032', ResultDesc: 'cancelled' } },
    });
    await expect(make().queryStatus('x')).resolves.toMatchObject({
      outcome: 'CANCELLED',
      code: 'CANCELLED_BY_USER',
    });
    respond({ ...oauth, '/stkpushquery/v1/query': { status: 503, body: {} } });
    await expect(make().queryStatus('x')).rejects.toBeInstanceOf(ProviderError);
  });

  it('does not pretend a refund is automatic', async () => {
    const r = await make().refund({
      paymentId: 'p1',
      providerReference: 'ws_CO_9',
      receiptNumber: 'QGH7XYZ123',
      amountMinor: 50_000,
      currency: 'KES',
      reason: 'test',
    });
    expect(r.outcome).toBe('MANUAL_REQUIRED');
  });
});
