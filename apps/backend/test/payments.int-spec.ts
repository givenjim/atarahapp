import { type INestApplication } from '@nestjs/common';
import request from 'supertest';
import { DomainEventBus, type DomainEvent } from '../src/community-core/domain-events';
import { FeatureFlagService } from '../src/feature-flags/feature-flag.service';
import { PaymentProviderRegistry } from '../src/payments/payment-provider.registry';
import { PaymentPurposeRegistry } from '../src/payments/payment-purposes';
import { PaymentsService, PAYMENT_GRACE_SECONDS } from '../src/payments/payments.service';
import {
  PAYMENT_PROVIDERS,
  type PaymentProvider,
} from '../src/payments/providers/payment-provider';
import { PrismaService } from '../src/prisma/prisma.service';
import {
  adminSignIn,
  bearer,
  createTestApp,
  deleteUsers,
  loginMember,
  makeUser,
  uniq,
} from './helpers';

jest.setTimeout(180_000);

const CALLBACK_TOKEN = 'tok_0123456789abcdef0123456789abcdef0123456789';

/** Stands in for Safaricom: answers only the Daraja URLs, passes every other request (Supabase) through. */
class FakeDaraja {
  private readonly real = global.fetch;
  pushes: Array<Record<string, unknown>> = [];
  queries = 0;
  failPush = false;
  private seq = 0;
  private readonly results = new Map<string, { status: number; body: unknown }>();

  install(): void {
    global.fetch = ((url: string | URL | Request, init?: RequestInit) => {
      const u = String(url);
      if (!u.includes('safaricom.co.ke')) return this.real(url, init);
      const json = (status: number, body: unknown) =>
        Promise.resolve(new Response(JSON.stringify(body), { status }));
      if (u.includes('/oauth/v1/generate'))
        return json(200, { access_token: 't', expires_in: '3599' });
      const body = init?.body ? (JSON.parse(String(init.body)) as Record<string, unknown>) : {};
      if (u.includes('/stkpush/v1/processrequest')) {
        if (this.failPush) return json(500, { errorMessage: 'Service unavailable' });
        this.pushes.push(body);
        this.seq += 1;
        return json(200, {
          MerchantRequestID: `mr_${this.seq}`,
          CheckoutRequestID: `ws_CO_TEST_${uniq()}_${this.seq}`,
          ResponseCode: '0',
        });
      }
      if (u.includes('/stkpushquery/v1/query')) {
        this.queries += 1;
        const r = this.results.get(String(body.CheckoutRequestID));
        return r
          ? json(r.status, r.body)
          : json(500, {
              errorCode: '500.001.1001',
              errorMessage: 'The transaction is being processed',
            });
      }
      return json(404, {});
    }) as typeof fetch;
  }

  restore(): void {
    global.fetch = this.real;
  }

  /** What the provider will say when asked about a checkout request. */
  answer(ref: string, resultCode: number | null, status = 200): void {
    this.results.set(
      ref,
      resultCode === null
        ? { status: 503, body: {} }
        : {
            status,
            body: {
              ResponseCode: '0',
              ResultCode: String(resultCode),
              ResultDesc: `code ${resultCode}`,
            },
          },
    );
  }
}

const callbackBody = (
  ref: string,
  o: { code?: number; amountShillings?: number; receipt?: string } = {},
) => ({
  Body: {
    stkCallback: {
      MerchantRequestID: 'mr',
      CheckoutRequestID: ref,
      ResultCode: o.code ?? 0,
      ResultDesc: o.code ? 'failed' : 'The service request is processed successfully.',
      ...(o.code
        ? {}
        : {
            CallbackMetadata: {
              Item: [
                { Name: 'Amount', Value: o.amountShillings ?? 50 },
                { Name: 'MpesaReceiptNumber', Value: o.receipt ?? `RCP${uniq().toUpperCase()}` },
                { Name: 'PhoneNumber', Value: 254712345678 },
              ],
            },
          }),
    },
  },
});

describe('Payments (integration)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  let payments: PaymentsService;
  let flags: FeatureFlagService;
  const daraja = new FakeDaraja();
  const http = () => request(app.getHttpServer());
  const users: string[] = [];
  const events: DomainEvent[] = [];
  const eventsOf = <T extends DomainEvent['type']>(type: T, paymentId: string) =>
    events.filter(
      (e): e is Extract<DomainEvent, { type: T }> =>
        e.type === type && (e as { paymentId?: string }).paymentId === paymentId,
    );
  let adminId: string;
  let adminToken: string;

  beforeAll(async () => {
    Object.assign(process.env, {
      ATARAH_MPESA_ENV: 'sandbox',
      ATARAH_MPESA_CONSUMER_KEY: 'test-key',
      ATARAH_MPESA_CONSUMER_SECRET: 'test-secret',
      ATARAH_MPESA_SHORTCODE: '174379',
      ATARAH_MPESA_PASSKEY: 'test-passkey',
      ATARAH_MPESA_CALLBACK_TOKEN: CALLBACK_TOKEN,
    });
    daraja.install();
    app = await createTestApp();
    prisma = app.get(PrismaService);
    payments = app.get(PaymentsService);
    flags = app.get(FeatureFlagService);
    const bus = app.get(DomainEventBus);
    for (const t of ['PaymentSucceeded', 'PaymentFailed', 'PaymentRefunded'] as const) {
      bus.on(t, (e) => {
        events.push(e);
        return Promise.resolve();
      });
    }
    const admin = await staff('SUPER_ADMIN');
    adminId = admin.id;
    adminToken = admin.token;
    await flags.set('payments-mpesa', true, { id: adminId });
  });

  afterAll(async () => {
    daraja.restore();
    // Leave the flags as the registry defines them (the database baseline suite expects every flag off).
    await flags.set('payments-mpesa', false, { id: adminId });
    await flags.set('card-payments', false, { id: adminId });
    // The ledger refuses DELETE by design; clear the payment tables before the accounts that own them.
    await prisma.$executeRawUnsafe(
      'TRUNCATE "transactions", "refunds", "payment_events", "payments" CASCADE',
    );
    await deleteUsers(app, users);
    await app.close();
  });

  const as = (token?: string) => {
    const wrap = (r: request.Test) => (token ? r.set(...bearer(token)) : r);
    return {
      get: (p: string, query: object = {}) => wrap(http().get(`/api/v1${p}`).query(query)),
      post: (p: string, b: object = {}, headers: Record<string, string> = {}) => {
        let r = http().post(`/api/v1${p}`).send(b);
        for (const [k, v] of Object.entries(headers)) r = r.set(k, v);
        return wrap(r);
      },
    };
  };

  async function member(label = 'Payer') {
    const { user, email } = await makeUser(app, { fullName: `${label} ${uniq()}` });
    users.push(user.id);
    return { id: user.id, token: (await loginMember(app, email)).accessToken };
  }

  async function staff(role: 'SUPER_ADMIN' | 'PLATFORM_ADMIN' | 'MODERATOR') {
    const { user, email } = await makeUser(app, { roles: [role], fullName: `Staff ${uniq()}` });
    users.push(user.id);
    const { session } = await adminSignIn(app, email);
    return { id: user.id, token: session.accessToken };
  }

  /** Starts a sandbox payment of KES 50 and returns the stored row. */
  async function start(
    m: { token: string },
    over: { key?: string; amountMinor?: number; phone?: string } = {},
  ) {
    const res = await as(m.token)
      .post(
        '/payments',
        {
          purpose: 'OTHER',
          method: 'MPESA',
          phone: over.phone ?? '0712345678',
          sandboxAmountMinor: over.amountMinor ?? 5000,
        },
        { 'Idempotency-Key': over.key ?? `key-${uniq()}-padding` },
      )
      .expect(201);
    const id = res.body.data.id as string;
    return { res: res.body.data, row: await prisma.payment.findUniqueOrThrow({ where: { id } }) };
  }

  const callback = (ref: string, body: object, token = CALLBACK_TOKEN) =>
    http().post(`/api/v1/webhooks/payments/mpesa/${token}`).send(body);

  const ledgerOf = (paymentId: string) =>
    prisma.ledgerTransaction.findMany({ where: { paymentId }, orderBy: { createdAt: 'asc' } });

  /** Succeeds a payment end to end (callback + status query) so refund tests start from SUCCEEDED. */
  async function paid(m: { token: string }, amountMinor = 5000) {
    const { row } = await start(m, { amountMinor });
    daraja.answer(row.providerReference!, 0);
    await callback(
      row.providerReference!,
      callbackBody(row.providerReference!, { amountShillings: amountMinor / 100 }),
    ).expect(200);
    const after = await prisma.payment.findUniqueOrThrow({ where: { id: row.id } });
    expect(after.status).toBe('SUCCEEDED');
    return after;
  }

  // ---- starting a payment -----------------------------------------------------------------------

  describe('initiation', () => {
    it('requires sign-in and an Idempotency-Key, and validates the number', async () => {
      const m = await member();
      await as().post('/payments', { purpose: 'OTHER', method: 'MPESA' }).expect(401);
      const body = {
        purpose: 'OTHER',
        method: 'MPESA',
        phone: '0712345678',
        sandboxAmountMinor: 5000,
      };
      const noKey = await as(m.token).post('/payments', body).expect(400);
      expect(noKey.body.error.code).toBe('VALIDATION_ERROR');
      await as(m.token)
        .post(
          '/payments',
          { ...body, phone: '12345' },
          { 'Idempotency-Key': `k-${uniq()}-padding` },
        )
        .expect(400);
      await as(m.token)
        .post(
          '/payments',
          { ...body, sandboxAmountMinor: 5050 },
          { 'Idempotency-Key': `k-${uniq()}-padding` },
        )
        .expect(400);
    });

    it('is off until the payments-mpesa flag is on', async () => {
      const m = await member();
      await flags.set('payments-mpesa', false, { id: adminId });
      const list = await as(m.token).get('/payments/methods').expect(200);
      expect(list.body.data.methods).toEqual([]);
      const res = await as(m.token)
        .post(
          '/payments',
          { purpose: 'OTHER', method: 'MPESA', phone: '0712345678', sandboxAmountMinor: 5000 },
          { 'Idempotency-Key': `k-${uniq()}-padding` },
        )
        .expect(503);
      expect(res.body.error.code).toBe('PAYMENT_ERROR');
      await flags.set('payments-mpesa', true, { id: adminId });
      const on = await as(m.token).get('/payments/methods').expect(200);
      expect(on.body.data.methods).toEqual([
        { method: 'MPESA', label: 'M-Pesa', description: 'Pay with your Safaricom line' },
      ]);
    });

    it('hides Card until the flag is on and a provider is connected (it is not connected yet)', async () => {
      const m = await member();
      await flags.set('card-payments', true, { id: adminId });
      const list = await as(m.token).get('/payments/methods').expect(200);
      expect(list.body.data.methods.map((x: { method: string }) => x.method)).toEqual(['MPESA']);
      const res = await as(m.token)
        .post(
          '/payments',
          { purpose: 'OTHER', method: 'CARD', sandboxAmountMinor: 5000 },
          { 'Idempotency-Key': `k-${uniq()}-padding` },
        )
        .expect(503);
      expect(res.body.error.code).toBe('PAYMENT_ERROR');
      await flags.set('card-payments', false, { id: adminId });
    });

    it('sends the STK push with the number and amount, stores only the last four digits, and goes PENDING', async () => {
      const m = await member();
      const before = daraja.pushes.length;
      const { res, row } = await start(m, { phone: '+254 712 345 678' });
      expect(res).toMatchObject({
        status: 'PENDING',
        method: 'MPESA',
        amountMinor: 5000,
        currency: 'KES',
        timedOut: false,
        action: {
          type: 'STK_PROMPT',
          message: "You'll get an M-Pesa prompt to confirm with your PIN.",
        },
      });
      const push = daraja.pushes[before]!;
      expect(push).toMatchObject({ Amount: 50, PhoneNumber: '254712345678' });
      expect(row.msisdnLast4).toBe('5678');
      expect(JSON.stringify(row, (_k, v) => (typeof v === 'bigint' ? Number(v) : v))).not.toContain(
        '254712345678',
      );
      expect(row.providerReference).toMatch(/^ws_CO_TEST_/);
      const events = await prisma.paymentEvent.findMany({ where: { paymentId: row.id } });
      expect(events.map((e) => e.toStatus)).toEqual(['INITIATED', 'PENDING']);
    });

    it('is idempotent per key: a repeat returns the same payment and sends one prompt', async () => {
      const m = await member();
      const key = `idem-${uniq()}-padding`;
      const before = daraja.pushes.length;
      const a = await start(m, { key });
      const again = await as(m.token).post(
        '/payments',
        { purpose: 'OTHER', method: 'MPESA', phone: '0712345678', sandboxAmountMinor: 5000 },
        { 'Idempotency-Key': key },
      );
      expect(again.body.data.id).toBe(a.row.id);
      expect(daraja.pushes.length - before).toBe(1);
      expect(await prisma.payment.count({ where: { payerId: m.id } })).toBe(1);
    });

    it('records a refused prompt as FAILED and says what to do', async () => {
      const m = await member();
      daraja.failPush = true;
      const res = await as(m.token)
        .post(
          '/payments',
          { purpose: 'OTHER', method: 'MPESA', phone: '0712345678', sandboxAmountMinor: 5000 },
          { 'Idempotency-Key': `k-${uniq()}-padding` },
        )
        .expect(502);
      daraja.failPush = false;
      expect(res.body.error.code).toBe('PAYMENT_ERROR');
      expect(res.body.error.message).toMatch(/try again/i);
      const row = await prisma.payment.findFirstOrThrow({ where: { payerId: m.id } });
      expect(row).toMatchObject({ status: 'FAILED', failureCode: 'PROVIDER_UNAVAILABLE' });
      expect(eventsOf('PaymentFailed', row.id)).toHaveLength(1);
    });

    it('refuses a purpose nobody sells yet, and one open payment per purchase', async () => {
      const m = await member();
      const res = await as(m.token)
        .post(
          '/payments',
          { purpose: 'MEMBERSHIP', method: 'MPESA', phone: '0712345678' },
          { 'Idempotency-Key': `k-${uniq()}-padding` },
        )
        .expect(400);
      expect(res.body.error.details).toMatchObject({ soon: 'P2' });

      const order = '5b4d0e3a-7c6f-4081-8c3d-2e1f9a8b7c6d';
      app.get(PaymentPurposeRegistry).register({
        purpose: 'MEMBERSHIP',
        quote: (ctx) =>
          Promise.resolve({
            amountMinor: 120_000,
            description: 'Atarah Pro',
            referenceType: 'membership_order',
            referenceId: ctx.referenceId,
          }),
      });
      const first = await as(m.token)
        .post(
          '/payments',
          { purpose: 'MEMBERSHIP', method: 'MPESA', phone: '0712345678', referenceId: order },
          { 'Idempotency-Key': `k-${uniq()}-padding` },
        )
        .expect(201);
      expect(first.body.data.amountMinor).toBe(120_000);
      const second = await as(m.token)
        .post(
          '/payments',
          { purpose: 'MEMBERSHIP', method: 'MPESA', phone: '0712345678', referenceId: order },
          { 'Idempotency-Key': `k-${uniq()}-padding` },
        )
        .expect(409);
      expect(second.body.error.details.paymentId).toBe(first.body.data.id);
      // Past its time limit, the member may try again.
      await prisma.payment.update({
        where: { id: first.body.data.id },
        data: { expiresAt: new Date(Date.now() - 1000) },
      });
      await as(m.token)
        .post(
          '/payments',
          { purpose: 'MEMBERSHIP', method: 'MPESA', phone: '0712345678', referenceId: order },
          { 'Idempotency-Key': `k-${uniq()}-padding` },
        )
        .expect(201);
    });

    it('a member cannot choose the amount of a real purpose, and the key cannot be reused for another purchase', async () => {
      const m = await member();
      const order = '6c5e1f4b-8d70-4192-9d4e-3f2a0b9c8d7e';
      const key = `k-${uniq()}-padding`;
      const res = await as(m.token)
        .post(
          '/payments',
          {
            purpose: 'MEMBERSHIP',
            method: 'MPESA',
            phone: '0712345678',
            referenceId: order,
            sandboxAmountMinor: 100,
          },
          { 'Idempotency-Key': key },
        )
        .expect(201);
      expect(res.body.data.amountMinor).toBe(120_000);
      await as(m.token)
        .post(
          '/payments',
          { purpose: 'OTHER', method: 'MPESA', phone: '0712345678', sandboxAmountMinor: 5000 },
          { 'Idempotency-Key': key },
        )
        .expect(409);
    });
  });

  // ---- callbacks ----------------------------------------------------------------------------------

  describe('webhook and verification', () => {
    it('rejects a callback on a wrong path token as if the route did not exist', async () => {
      const m = await member();
      const { row } = await start(m);
      await callback(
        row.providerReference!,
        callbackBody(row.providerReference!),
        'x'.repeat(44),
      ).expect(404);
      await http().post('/api/v1/webhooks/payments/mpesa/short').send({}).expect(404);
      expect((await prisma.payment.findUniqueOrThrow({ where: { id: row.id } })).status).toBe(
        'PENDING',
      );
    });

    it('confirms a success with a status query, then settles once: receipt, ledger, event, notification', async () => {
      const m = await member();
      const { row } = await start(m);
      const ref = row.providerReference!;
      daraja.answer(ref, 0);
      const queriesBefore = daraja.queries;
      await callback(ref, callbackBody(ref, { receipt: 'QGH7XYZ123' })).expect(200);
      expect(daraja.queries).toBeGreaterThan(queriesBefore);

      const after = await prisma.payment.findUniqueOrThrow({ where: { id: row.id } });
      expect(after).toMatchObject({ status: 'SUCCEEDED', receiptNumber: 'QGH7XYZ123' });
      expect(after.completedAt).not.toBeNull();
      const ledger = await ledgerOf(row.id);
      expect(ledger).toHaveLength(1);
      // The platform is the payee: it keeps the whole amount, nothing is owed onward.
      expect(ledger[0]).toMatchObject({
        type: 'PAYMENT',
        payerId: m.id,
        payeeId: null,
        grossMinor: 5000n,
        platformFeeMinor: 5000n,
        netMinor: 0n,
        currency: 'KES',
      });
      expect(eventsOf('PaymentSucceeded', row.id)).toHaveLength(1);
      expect(eventsOf('PaymentSucceeded', row.id)[0]).toMatchObject({
        payerId: m.id,
        amountMinor: 5000,
      });

      // The raw callback is stored encrypted, never in clear.
      const stored = await prisma.paymentEvent.findFirstOrThrow({
        where: { paymentId: row.id, kind: 'CALLBACK' },
      });
      expect(stored.payloadEncrypted).toMatch(/^v1\./);
      expect(stored.payloadEncrypted).not.toContain('QGH7XYZ123');

      const note = await prisma.notification.findFirst({
        where: { userId: m.id, type: 'payment.succeeded' },
      });
      expect(note?.category).toBe('SYSTEM');
      const audit = await prisma.auditLog.findFirst({
        where: { entityType: 'payment', entityId: row.id, action: 'payment.status_change' },
      });
      expect(audit).not.toBeNull();
    });

    it('processes duplicate callbacks idempotently', async () => {
      const m = await member();
      const { row } = await start(m);
      const ref = row.providerReference!;
      daraja.answer(ref, 0);
      const body = callbackBody(ref, { receipt: 'DUPRCP1' });
      await Promise.all([callback(ref, body), callback(ref, body), callback(ref, body)]);
      await callback(ref, body).expect(200);
      expect(await ledgerOf(row.id)).toHaveLength(1);
      expect(eventsOf('PaymentSucceeded', row.id)).toHaveLength(1);
      expect(
        await prisma.notification.count({ where: { userId: m.id, type: 'payment.succeeded' } }),
      ).toBe(1);
      expect(
        await prisma.paymentEvent.count({ where: { paymentId: row.id, kind: 'CALLBACK' } }),
      ).toBe(1);
    });

    it('does not trust a success callback the provider does not confirm', async () => {
      const m = await member();
      const { row } = await start(m);
      const ref = row.providerReference!;
      // Still being processed: the forged or early callback changes nothing.
      await callback(ref, callbackBody(ref)).expect(200);
      expect((await prisma.payment.findUniqueOrThrow({ where: { id: row.id } })).status).toBe(
        'PENDING',
      );
      expect(await ledgerOf(row.id)).toHaveLength(0);
      // The provider says it failed: the payment fails, however the callback read.
      daraja.answer(ref, 1);
      await callback(ref, callbackBody(ref, { receipt: 'OTHER-BODY' })).expect(200);
      const after = await prisma.payment.findUniqueOrThrow({ where: { id: row.id } });
      expect(after).toMatchObject({ status: 'FAILED', failureCode: 'INSUFFICIENT_FUNDS' });
      expect(after.failureReason).toMatch(/top up/i);
      expect(await ledgerOf(row.id)).toHaveLength(0);
    });

    it('rejects an amount mismatch and never marks it paid', async () => {
      const m = await member();
      const { row } = await start(m, { amountMinor: 5000 });
      const ref = row.providerReference!;
      daraja.answer(ref, 0);
      await callback(ref, callbackBody(ref, { amountShillings: 1 })).expect(200);
      const after = await prisma.payment.findUniqueOrThrow({ where: { id: row.id } });
      expect(after).toMatchObject({ status: 'FAILED', failureCode: 'AMOUNT_MISMATCH' });
      expect(await ledgerOf(row.id)).toHaveLength(0);
      expect(eventsOf('PaymentSucceeded', row.id)).toHaveLength(0);
      const ev = await prisma.paymentEvent.findFirstOrThrow({
        where: { paymentId: row.id, toStatus: 'FAILED' },
      });
      expect(ev.summary).toMatch(/mismatch/i);
    });

    it('maps cancelled and failed callbacks to what the member should do', async () => {
      const m = await member();
      const a = (await start(m)).row;
      await callback(
        a.providerReference!,
        callbackBody(a.providerReference!, { code: 1032 }),
      ).expect(200);
      expect(await prisma.payment.findUniqueOrThrow({ where: { id: a.id } })).toMatchObject({
        status: 'CANCELLED',
        failureCode: 'CANCELLED_BY_USER',
      });
      expect(eventsOf('PaymentFailed', a.id)[0]).toMatchObject({ status: 'CANCELLED' });
      const b = (await start(m)).row;
      await callback(
        b.providerReference!,
        callbackBody(b.providerReference!, { code: 2001 }),
      ).expect(200);
      const failed = await prisma.payment.findUniqueOrThrow({ where: { id: b.id } });
      expect(failed).toMatchObject({ status: 'FAILED', failureCode: 'WRONG_PIN' });
      expect(failed.failureReason).toMatch(/try again/i);
    });

    it('handles out-of-order callbacks: a late failure cannot undo a success, a late success cannot revive a cancel', async () => {
      const m = await member();
      const p = await paid(m);
      const ref = p.providerReference!;
      await callback(ref, callbackBody(ref, { code: 1032 })).expect(200);
      expect((await prisma.payment.findUniqueOrThrow({ where: { id: p.id } })).status).toBe(
        'SUCCEEDED',
      );
      expect(await ledgerOf(p.id)).toHaveLength(1);
      expect(eventsOf('PaymentFailed', p.id)).toHaveLength(0);
      const note = await prisma.paymentEvent.findFirst({
        where: { paymentId: p.id, kind: 'REVIEW' },
      });
      expect(note?.summary).toMatch(/ignored/i);

      const c = (await start(m)).row;
      await callback(
        c.providerReference!,
        callbackBody(c.providerReference!, { code: 1032 }),
      ).expect(200);
      daraja.answer(c.providerReference!, 0);
      await callback(c.providerReference!, callbackBody(c.providerReference!)).expect(200);
      expect((await prisma.payment.findUniqueOrThrow({ where: { id: c.id } })).status).toBe(
        'CANCELLED',
      );
      expect(await ledgerOf(c.id)).toHaveLength(0);
    });

    it('ignores callbacks for unknown references and garbage bodies', async () => {
      await callback('x', callbackBody('ws_CO_UNKNOWN')).expect(200);
      await callback('x', { hello: 'world' }).expect(200);
    });
  });

  // ---- reading and the fallback -------------------------------------------------------------------

  describe('status polling and the fallback job', () => {
    it('only the payer can read a payment, and a client cannot set its status', async () => {
      const m = await member();
      const other = await member();
      const { row } = await start(m);
      await as(other.token).get(`/payments/${row.id}`).expect(404);
      await as().get(`/payments/${row.id}`).expect(401);
      await as(m.token).post(`/payments/${row.id}`, { status: 'SUCCEEDED' }).expect(404);
      const res = await as(m.token).get(`/payments/${row.id}`).expect(200);
      expect(res.body.data).toMatchObject({ id: row.id, status: 'PENDING', pollAfterSeconds: 3 });
      expect(await ledgerOf(row.id)).toHaveLength(0);
      const mine = await as(m.token).get('/payments').expect(200);
      expect(mine.body.data.map((p: { id: string }) => p.id)).toContain(row.id);
      const theirs = await as(other.token).get('/payments').expect(200);
      expect(theirs.body.data).toEqual([]);
    });

    it('a poll asks the provider when the callback is slow, and settles the payment', async () => {
      const m = await member();
      const { row } = await start(m);
      daraja.answer(row.providerReference!, 0);
      await prisma.payment.update({
        where: { id: row.id },
        data: { initiatedAt: new Date(Date.now() - 60_000) },
      });
      const res = await as(m.token).get(`/payments/${row.id}`).expect(200);
      expect(res.body.data.status).toBe('SUCCEEDED');
      expect(await ledgerOf(row.id)).toHaveLength(1);
    });

    it('timeout: no callback, the fallback job asks the provider and settles', async () => {
      const m = await member();
      const ok = (await start(m)).row;
      const declined = (await start(m)).row;
      const silent = (await start(m)).row;
      daraja.answer(ok.providerReference!, 0);
      daraja.answer(declined.providerReference!, 1032);
      for (const p of [ok, declined, silent]) {
        await prisma.payment.update({
          where: { id: p.id },
          data: { expiresAt: new Date(Date.now() - 5_000) },
        });
      }
      const view = await as(m.token).get(`/payments/${silent.id}`).expect(200);
      expect(view.body.data.timedOut).toBe(true);

      const result = await payments.reconcilePending();
      expect(result.checked).toBeGreaterThanOrEqual(3);
      expect((await prisma.payment.findUniqueOrThrow({ where: { id: ok.id } })).status).toBe(
        'SUCCEEDED',
      );
      expect(await ledgerOf(ok.id)).toHaveLength(1);
      expect(await prisma.payment.findUniqueOrThrow({ where: { id: declined.id } })).toMatchObject({
        status: 'CANCELLED',
        failureCode: 'CANCELLED_BY_USER',
      });
      // Still processing and inside the grace period: left alone.
      expect((await prisma.payment.findUniqueOrThrow({ where: { id: silent.id } })).status).toBe(
        'PENDING',
      );

      // A second run changes nothing (idempotent).
      await payments.reconcilePending();
      expect(await ledgerOf(ok.id)).toHaveLength(1);
      expect(eventsOf('PaymentSucceeded', ok.id)).toHaveLength(1);
    });

    it('fails a payment as TIMEOUT only after the grace period, and still accepts a later verified success', async () => {
      const m = await member();
      const { row } = await start(m);
      await prisma.payment.update({
        where: { id: row.id },
        data: { expiresAt: new Date(Date.now() - (PAYMENT_GRACE_SECONDS + 30) * 1000) },
      });
      await payments.reconcilePending();
      const failed = await prisma.payment.findUniqueOrThrow({ where: { id: row.id } });
      expect(failed).toMatchObject({ status: 'FAILED', failureCode: 'TIMEOUT' });
      expect(failed.failureReason).toMatch(/automatically/i);

      // The money was taken after all: the provider confirms it, the payment is corrected.
      daraja.answer(row.providerReference!, 0);
      await prisma.payment.update({ where: { id: row.id }, data: { lastQueriedAt: null } });
      await payments.reconcilePending();
      const fixed = await prisma.payment.findUniqueOrThrow({ where: { id: row.id } });
      expect(fixed).toMatchObject({ status: 'SUCCEEDED', failureCode: null });
      expect(await ledgerOf(row.id)).toHaveLength(1);
    });

    it('fails a prompt that never reached the provider', async () => {
      const m = await member();
      const row = await prisma.payment.create({
        data: {
          purpose: 'OTHER',
          payerId: m.id,
          amountMinor: 5000n,
          method: 'MPESA',
          provider: 'MPESA_DARAJA',
          idempotencyKey: `stuck-${uniq()}`,
          createdAt: new Date(Date.now() - 10 * 60_000),
        },
      });
      const r = await payments.reconcilePending();
      expect(r.abandoned).toBeGreaterThanOrEqual(1);
      expect(await prisma.payment.findUniqueOrThrow({ where: { id: row.id } })).toMatchObject({
        status: 'FAILED',
        failureCode: 'INITIATION_INTERRUPTED',
      });
    });
  });

  // ---- refunds ------------------------------------------------------------------------------------

  describe('refunds', () => {
    /** Swaps the M-Pesa adapter's refund for a controllable one (Daraja has no automatic refund route yet). */
    function refundBehaviour(impl: PaymentProvider['refund'] | null): () => void {
      const arr = app.get<PaymentProvider[]>(PAYMENT_PROVIDERS);
      const mpesa = arr.find((p) => p.key === 'MPESA_DARAJA')!;
      const original = mpesa.refund.bind(mpesa);
      if (impl) mpesa.refund = impl;
      return () => {
        mpesa.refund = original;
      };
    }
    const COMPLETED: PaymentProvider['refund'] = () =>
      Promise.resolve({ outcome: 'COMPLETED', providerReference: 'RFD1' });

    it('refunds in full: payment REFUNDED, a negative ledger row nets the books to zero, PaymentRefunded raised', async () => {
      const m = await member();
      const p = await paid(m, 10_000);
      const restore = refundBehaviour(COMPLETED);
      try {
        const res = await as(adminToken)
          .post(`/admin/payments/${p.id}/refunds`, { reason: 'Customer asked for a refund' })
          .expect(201);
        expect(res.body.data.status).toBe('REFUNDED');
        expect(res.body.data.refundedMinor).toBe(10_000);
        expect(res.body.data.refundableMinor).toBe(0);
        expect(res.body.data.refunds[0]).toMatchObject({
          status: 'SUCCEEDED',
          mode: 'AUTOMATIC',
          amountMinor: 10_000,
        });
      } finally {
        restore();
      }
      const ledger = await ledgerOf(p.id);
      expect(ledger.map((l) => l.type)).toEqual(['PAYMENT', 'REFUND']);
      expect(ledger.reduce((s, l) => s + l.grossMinor, 0n)).toBe(0n);
      expect(ledger.reduce((s, l) => s + l.platformFeeMinor, 0n)).toBe(0n);
      expect(ledger.reduce((s, l) => s + l.netMinor, 0n)).toBe(0n);
      const ev = eventsOf('PaymentRefunded', p.id);
      expect(ev).toHaveLength(1);
      expect(ev[0]).toMatchObject({ payerId: m.id, amountMinor: 10_000, fullyRefunded: true });
      expect(
        await prisma.notification.count({ where: { userId: m.id, type: 'payment.refunded' } }),
      ).toBe(1);
      const audit = await prisma.auditLog.findMany({
        where: { entityType: 'payment', entityId: p.id, action: { startsWith: 'payment.refund' } },
      });
      expect(audit.map((a) => a.action).sort()).toEqual([
        'payment.refund.complete',
        'payment.refund.request',
      ]);
      expect(audit.every((a) => a.actorId === adminId)).toBe(true);
    });

    it('partial refunds accumulate to PARTIALLY_REFUNDED then REFUNDED, and cannot exceed the amount', async () => {
      const m = await member();
      const p = await paid(m, 10_000);
      const restore = refundBehaviour(COMPLETED);
      try {
        const a = await as(adminToken)
          .post(`/admin/payments/${p.id}/refunds`, {
            amountMinor: 4_000,
            reason: 'Partial goodwill refund',
          })
          .expect(201);
        expect(a.body.data.status).toBe('PARTIALLY_REFUNDED');
        expect(a.body.data.refundableMinor).toBe(6_000);
        const tooMuch = await as(adminToken)
          .post(`/admin/payments/${p.id}/refunds`, {
            amountMinor: 6_001,
            reason: 'Too much by one cent',
          })
          .expect(400);
        expect(tooMuch.body.error.details.refundableMinor).toBe(6_000);
        const b = await as(adminToken)
          .post(`/admin/payments/${p.id}/refunds`, { amountMinor: 6_000, reason: 'The remainder' })
          .expect(201);
        expect(b.body.data.status).toBe('REFUNDED');
        await as(adminToken)
          .post(`/admin/payments/${p.id}/refunds`, { amountMinor: 1, reason: 'Nothing is left' })
          .expect(409);
      } finally {
        restore();
      }
      const ledger = await ledgerOf(p.id);
      expect(ledger).toHaveLength(3);
      expect(ledger.reduce((s, l) => s + l.grossMinor, 0n)).toBe(0n);
    });

    it('splits the ledger between payee and platform, and refunds proportionally', async () => {
      const payer = await member();
      const mentor = await member('Mentor');
      app.get(PaymentPurposeRegistry).register({
        purpose: 'MENTORSHIP',
        quote: (ctx) =>
          Promise.resolve({
            amountMinor: 100_000,
            description: 'Mentorship session',
            referenceType: 'mentorship_booking',
            referenceId: ctx.referenceId,
            payeeId: mentor.id,
            platformFeeMinor: 20_000,
          }),
      });
      const res = await as(payer.token)
        .post(
          '/payments',
          {
            purpose: 'MENTORSHIP',
            method: 'MPESA',
            phone: '0712345678',
            referenceId: '7d6f2a5c-9e81-42a3-8e5f-4a3b1c0d9e8f',
          },
          { 'Idempotency-Key': `k-${uniq()}-padding` },
        )
        .expect(201);
      const row = await prisma.payment.findUniqueOrThrow({ where: { id: res.body.data.id } });
      daraja.answer(row.providerReference!, 0);
      await callback(
        row.providerReference!,
        callbackBody(row.providerReference!, { amountShillings: 1000 }),
      );
      expect(await ledgerOf(row.id)).toMatchObject([
        { payeeId: mentor.id, grossMinor: 100_000n, platformFeeMinor: 20_000n, netMinor: 80_000n },
      ]);
      const restore = refundBehaviour(COMPLETED);
      try {
        // A booking refund of half: 50,000 back, of which the platform returns 10,000.
        await payments.refund({
          paymentId: row.id,
          amountMinor: 50_000,
          reason: 'Late cancellation',
          actor: {},
        });
        await payments.refund({ paymentId: row.id, reason: 'Mentor declined', actor: {} });
      } finally {
        restore();
      }
      const ledger = await ledgerOf(row.id);
      expect(ledger.map((l) => [l.grossMinor, l.platformFeeMinor, l.netMinor])).toEqual([
        [100_000n, 20_000n, 80_000n],
        [-50_000n, -10_000n, -40_000n],
        [-50_000n, -10_000n, -40_000n],
      ]);
      expect(ledger.reduce((s, l) => s + l.netMinor, 0n)).toBe(0n);
      expect(await prisma.payment.findUniqueOrThrow({ where: { id: row.id } })).toMatchObject({
        status: 'REFUNDED',
        refundedMinor: 100_000n,
      });
      // The system refund has no staff actor.
      const sys = await prisma.auditLog.findFirst({
        where: { entityId: row.id, action: 'payment.refund.complete', actorType: 'SYSTEM' },
      });
      expect(sys).not.toBeNull();
    });

    it('only a succeeded payment can be refunded', async () => {
      const m = await member();
      const { row } = await start(m);
      const res = await as(adminToken)
        .post(`/admin/payments/${row.id}/refunds`, { reason: 'It never succeeded' })
        .expect(409);
      expect(res.body.error.code).toBe('INVALID_STATE');
      await as(adminToken).post(`/admin/payments/${row.id}/refunds`, { reason: 'x' }).expect(400);
    });

    it('M-Pesa refunds wait for finance: the amount is held, confirming completes it, cancelling frees it', async () => {
      const m = await member();
      const p = await paid(m, 10_000);
      // The real adapter answers MANUAL_REQUIRED: nothing is refunded automatically.
      const a = await as(adminToken)
        .post(`/admin/payments/${p.id}/refunds`, { amountMinor: 6_000, reason: 'Duplicate charge' })
        .expect(201);
      expect(a.body.data.status).toBe('SUCCEEDED');
      expect(a.body.data.refunds[0]).toMatchObject({ status: 'PENDING', mode: 'MANUAL' });
      expect(a.body.data.refundableMinor).toBe(4_000);
      expect(await ledgerOf(p.id)).toHaveLength(1);
      expect(eventsOf('PaymentRefunded', p.id)).toHaveLength(0);
      const refundId = a.body.data.refunds[0].id as string;

      // Held amount cannot be refunded twice.
      await as(adminToken)
        .post(`/admin/payments/${p.id}/refunds`, {
          amountMinor: 5_000,
          reason: 'Would exceed the rest',
        })
        .expect(400);

      const done = await as(adminToken)
        .post(`/admin/payments/${p.id}/refunds/${refundId}/complete`, {
          providerReference: 'QGH-REFUND-1',
        })
        .expect(200);
      expect(done.body.data.status).toBe('PARTIALLY_REFUNDED');
      expect(done.body.data.refunds[0]).toMatchObject({
        status: 'SUCCEEDED',
        providerReference: 'QGH-REFUND-1',
      });
      expect(eventsOf('PaymentRefunded', p.id)).toHaveLength(1);
      expect(await ledgerOf(p.id)).toHaveLength(2);
      await as(adminToken)
        .post(`/admin/payments/${p.id}/refunds/${refundId}/complete`, {})
        .expect(409);

      const b = await as(adminToken)
        .post(`/admin/payments/${p.id}/refunds`, { reason: 'Refund the rest' })
        .expect(201);
      const second = b.body.data.refunds.find((r: { status: string }) => r.status === 'PENDING').id;
      const cancelled = await as(adminToken)
        .post(`/admin/payments/${p.id}/refunds/${second}/cancel`)
        .expect(200);
      expect(cancelled.body.data.refundableMinor).toBe(4_000);
    });

    it('a rejected or unreachable provider leaves nothing refunded', async () => {
      const m = await member();
      const p = await paid(m, 10_000);
      let restore = refundBehaviour(() =>
        Promise.resolve({ outcome: 'REJECTED', reason: 'Not allowed' }),
      );
      try {
        const res = await as(adminToken)
          .post(`/admin/payments/${p.id}/refunds`, { reason: 'Provider says no' })
          .expect(502);
        expect(res.body.error.code).toBe('PAYMENT_ERROR');
      } finally {
        restore();
      }
      restore = refundBehaviour(() => Promise.reject(new Error('network down')));
      try {
        await as(adminToken)
          .post(`/admin/payments/${p.id}/refunds`, { reason: 'Provider is down' })
          .expect(503);
      } finally {
        restore();
      }
      const row = await prisma.payment.findUniqueOrThrow({ where: { id: p.id } });
      expect(row).toMatchObject({ status: 'SUCCEEDED', refundedMinor: 0n });
      expect(await prisma.refund.findMany({ where: { paymentId: p.id } })).toEqual(
        expect.arrayContaining([expect.objectContaining({ status: 'FAILED' })]),
      );
      expect(await payments.refundable(prisma, row)).toBe(10_000);
      expect(await ledgerOf(p.id)).toHaveLength(1);
    });

    it('a repeated refund request with the same key creates one refund', async () => {
      const m = await member();
      const p = await paid(m, 10_000);
      const restore = refundBehaviour(COMPLETED);
      try {
        const key = `refund-${uniq()}`;
        const send = () =>
          as(adminToken).post(
            `/admin/payments/${p.id}/refunds`,
            { amountMinor: 3_000, reason: 'Partial refund once' },
            { 'Idempotency-Key': key },
          );
        await send().expect(201);
        await send().expect(201);
        expect(await prisma.refund.count({ where: { paymentId: p.id } })).toBe(1);
        expect(
          (await prisma.payment.findUniqueOrThrow({ where: { id: p.id } })).refundedMinor,
        ).toBe(3_000n);
      } finally {
        restore();
      }
    });
  });

  // ---- the console --------------------------------------------------------------------------------

  describe('admin payments', () => {
    it('lists metadata only, filters, and shows the event history on the detail', async () => {
      const m = await member('Wanjiru Console');
      const p = await paid(m, 5_000);
      const list = await as(adminToken)
        .get('/admin/payments', { q: 'Wanjiru Console' })
        .expect(200);
      expect(list.body.meta.total).toBeGreaterThanOrEqual(1);
      const item = list.body.data.find((x: { id: string }) => x.id === p.id);
      expect(item).toMatchObject({
        status: 'SUCCEEDED',
        method: 'MPESA',
        provider: 'MPESA_DARAJA',
        amountMinor: 5_000,
        payer: { id: m.id },
      });
      const byReceipt = await as(adminToken)
        .get('/admin/payments', { q: p.receiptNumber! })
        .expect(200);
      expect(byReceipt.body.data.map((x: { id: string }) => x.id)).toEqual([p.id]);
      const failed = await as(adminToken)
        .get('/admin/payments', { status: 'FAILED', paymentMethod: 'MPESA' })
        .expect(200);
      expect(failed.body.data.every((x: { status: string }) => x.status === 'FAILED')).toBe(true);
      await as(adminToken).get('/admin/payments', { status: 'NOPE' }).expect(400);

      const detail = await as(adminToken).get(`/admin/payments/${p.id}`).expect(200);
      const d = detail.body.data;
      expect(d.events.map((e: { kind: string }) => e.kind)).toEqual(
        expect.arrayContaining(['INITIATED', 'CALLBACK', 'STATUS_CHANGE']),
      );
      expect(d.ledger).toHaveLength(1);
      expect(d.msisdnLast4).toBe('5678');
      // Metadata only: no raw payloads, no full number, no card data, no idempotency key.
      const text = JSON.stringify(d);
      expect(text).not.toMatch(/payloadEncrypted|v1\.|254712345678|idempotencyKey/);
      await as(adminToken).get('/admin/payments/not-a-uuid').expect(400);
      await as(adminToken).get('/admin/payments/0e7f2a5c-9e81-42a3-8e5f-4a3b1c0d9e8f').expect(404);
    });

    it('re-queries a stuck payment on demand and audits it', async () => {
      const m = await member();
      const { row } = await start(m);
      daraja.answer(row.providerReference!, 0);
      const res = await as(adminToken).post(`/admin/payments/${row.id}/requery`).expect(200);
      expect(res.body.data.status).toBe('SUCCEEDED');
      expect(res.body.data.events.some((e: { source: string }) => e.source === 'ADMIN')).toBe(true);
      const audit = await prisma.auditLog.findMany({
        where: { entityId: row.id, action: 'payment.requery' },
      });
      expect(audit).toHaveLength(1);
      expect(audit[0]).toMatchObject({ actorId: adminId, actorType: 'ADMIN' });
      // A payment with its final answer has nothing to re-query.
      await as(adminToken).post(`/admin/payments/${row.id}/requery`).expect(409);
    });

    it('permissions: members and moderators are refused; platform admins read but cannot manage', async () => {
      const m = await member();
      const p = await paid(m, 5_000);
      await as().get('/admin/payments').expect(401);
      await as(m.token).get('/admin/payments').expect(403);
      await as(m.token).get(`/admin/payments/${p.id}`).expect(403);
      await as(m.token)
        .post(`/admin/payments/${p.id}/refunds`, { reason: 'I want my money' })
        .expect(403);

      const mod = await staff('MODERATOR');
      await as(mod.token).get('/admin/payments').expect(403);
      await as(mod.token).post(`/admin/payments/${p.id}/requery`).expect(403);

      const platform = await staff('PLATFORM_ADMIN');
      await as(platform.token).get('/admin/payments').expect(200);
      await as(platform.token).get(`/admin/payments/${p.id}`).expect(200);
      await as(platform.token).post(`/admin/payments/${p.id}/requery`).expect(403);
      await as(platform.token)
        .post(`/admin/payments/${p.id}/refunds`, { reason: 'Not my permission' })
        .expect(403);
      await as(platform.token)
        .post(`/admin/payments/${p.id}/refunds/${p.id}/complete`, {})
        .expect(403);
      expect(await prisma.refund.count({ where: { paymentId: p.id } })).toBe(0);
    });

    it('finance actions need a fresh authenticator check', async () => {
      const m = await member();
      const p = await paid(m, 5_000);
      const fresh = await staff('SUPER_ADMIN');
      const realNow = Date.now;
      jest.spyOn(Date, 'now').mockImplementation(() => realNow() + 6 * 60_000);
      try {
        const res = await as(fresh.token)
          .post(`/admin/payments/${p.id}/refunds`, { reason: 'Stale authenticator' })
          .expect(401);
        expect(res.body.error.details).toMatchObject({ reason: 'REAUTH_REQUIRED' });
      } finally {
        jest.restoreAllMocks();
      }
      expect(await prisma.refund.count({ where: { paymentId: p.id } })).toBe(0);
    });
  });

  // ---- data guarantees ----------------------------------------------------------------------------

  describe('database guarantees', () => {
    it('the ledger is append-only and one payment can only be credited once', async () => {
      const m = await member();
      const p = await paid(m, 5_000);
      const [entry] = await ledgerOf(p.id);
      await expect(
        prisma.ledgerTransaction.update({ where: { id: entry!.id }, data: { netMinor: 1n } }),
      ).rejects.toThrow();
      await expect(prisma.ledgerTransaction.delete({ where: { id: entry!.id } })).rejects.toThrow();
      await expect(
        prisma.ledgerTransaction.create({
          data: {
            paymentId: p.id,
            type: 'PAYMENT',
            payerId: m.id,
            grossMinor: 5_000n,
            platformFeeMinor: 5_000n,
            netMinor: 0n,
            currency: 'KES',
          },
        }),
      ).rejects.toThrow();
      expect(await ledgerOf(p.id)).toHaveLength(1);
    });

    it('rejects impossible rows (refunded more than paid, unbalanced ledger)', async () => {
      const m = await member();
      const p = await paid(m, 5_000);
      await expect(
        prisma.payment.update({ where: { id: p.id }, data: { refundedMinor: 5_001n } }),
      ).rejects.toThrow();
      await expect(
        prisma.ledgerTransaction.create({
          data: {
            paymentId: p.id,
            refundId: null,
            type: 'REFUND',
            payerId: m.id,
            grossMinor: -5n,
            platformFeeMinor: 0n,
            netMinor: -5n,
            currency: 'KES',
          },
        }),
      ).rejects.toThrow();
    });

    it('stays correct when the provider registry is the real one', () => {
      const registry = app.get(PaymentProviderRegistry);
      expect(registry.forMethod('MPESA')?.isConfigured()).toBe(true);
      expect(registry.forMethod('CARD')?.isConfigured()).toBe(false);
    });
  });
});
