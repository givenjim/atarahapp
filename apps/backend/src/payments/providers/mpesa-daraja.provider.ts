import { createHash, timingSafeEqual } from 'node:crypto';
import { Injectable, Logger } from '@nestjs/common';
import { AppConfigService } from '../../config/app-config.service';
import { darajaTimestamp, isWholeShillings, toMinor, toShillings } from '../payment-money';
import {
  type InitiateInput,
  type InitiateResult,
  type ParsedWebhook,
  type PaymentProvider,
  ProviderError,
  type RefundInput,
  type RefundResult,
  type StatusResult,
  type WebhookRequest,
} from './payment-provider';

const REQUEST_TIMEOUT_MS = 15_000;

/** Daraja ResultCodes that mean something specific to the member. Anything else is a generic decline. */
export function mapResultCode(code: string | number | undefined): {
  outcome: 'SUCCESS' | 'FAILED' | 'CANCELLED';
  code?: string;
} {
  const c = String(code ?? '');
  if (c === '0') return { outcome: 'SUCCESS' };
  if (c === '1032') return { outcome: 'CANCELLED', code: 'CANCELLED_BY_USER' };
  if (c === '1') return { outcome: 'FAILED', code: 'INSUFFICIENT_FUNDS' };
  if (c === '2001') return { outcome: 'FAILED', code: 'WRONG_PIN' };
  if (c === '1037') return { outcome: 'FAILED', code: 'TIMEOUT' };
  return { outcome: 'FAILED', code: 'PROVIDER_DECLINED' };
}

const asRecord = (v: unknown): Record<string, unknown> | null =>
  v && typeof v === 'object' && !Array.isArray(v) ? (v as Record<string, unknown>) : null;

const safeEqual = (a: string, b: string): boolean => {
  const x = Buffer.from(a);
  const y = Buffer.from(b);
  return x.length === y.length && timingSafeEqual(x, y);
};

const stripV6 = (ip: string): string => ip.replace(/^::ffff:/i, '');

/**
 * Safaricom Daraja: M-Pesa Express (STK Push). Sandbox or production by `ATARAH_MPESA_ENV`.
 *
 * Daraja callbacks are not signed. The route is therefore protected by an unguessable path token (and an optional IP
 * allow-list), the payment is matched by CheckoutRequestID, and `PaymentsService` confirms every success with an STK
 * status query (`queryStatus`) before the payment is marked paid.
 */
@Injectable()
export class MpesaDarajaProvider implements PaymentProvider {
  readonly key = 'MPESA_DARAJA' as const;
  readonly method = 'MPESA' as const;
  private readonly log = new Logger(MpesaDarajaProvider.name);
  private token: { value: string; expiresAt: number } | null = null;

  constructor(private readonly config: AppConfigService) {}

  private get cfg() {
    return this.config.payments.mpesa;
  }

  isConfigured(): boolean {
    const c = this.cfg;
    return Boolean(
      c.consumerKey && c.consumerSecret && c.shortcode && c.passkey && c.callbackToken.length >= 32,
    );
  }

  async initiate(input: InitiateInput): Promise<InitiateResult> {
    if (!input.msisdn) throw new ProviderError('An M-Pesa number is required.', false);
    if (!isWholeShillings(input.amountMinor)) {
      throw new ProviderError('M-Pesa takes whole shillings only.', false);
    }
    const c = this.cfg;
    const timestamp = darajaTimestamp();
    const body = {
      BusinessShortCode: c.shortcode,
      Password: this.password(timestamp),
      Timestamp: timestamp,
      TransactionType: 'CustomerPayBillOnline',
      Amount: toShillings(input.amountMinor),
      PartyA: input.msisdn,
      PartyB: c.shortcode,
      PhoneNumber: input.msisdn,
      CallBackURL: c.callbackUrl,
      AccountReference: input.accountReference.slice(0, 12),
      TransactionDesc: input.description.slice(0, 13),
    };
    const res = await this.call('/mpesa/stkpush/v1/processrequest', body);
    const json = asRecord(res.json);
    if (!res.ok || !json || String(json.ResponseCode) !== '0' || !json.CheckoutRequestID) {
      throw new ProviderError(
        `STK push was not accepted (${res.status}): ${String(json?.errorMessage ?? json?.ResponseDescription ?? 'no detail')}`,
        res.status >= 500 || res.status === 429,
      );
    }
    return {
      providerReference: String(json.CheckoutRequestID),
      merchantReference: json.MerchantRequestID ? String(json.MerchantRequestID) : undefined,
      action: {
        type: 'STK_PROMPT',
        message: "You'll get an M-Pesa prompt to confirm with your PIN.",
      },
    };
  }

  async queryStatus(providerReference: string): Promise<StatusResult> {
    const c = this.cfg;
    const timestamp = darajaTimestamp();
    const res = await this.call('/mpesa/stkpushquery/v1/query', {
      BusinessShortCode: c.shortcode,
      Password: this.password(timestamp),
      Timestamp: timestamp,
      CheckoutRequestID: providerReference,
    });
    const json = asRecord(res.json);
    // While a request is still being processed Daraja answers with an error body, not a ResultCode.
    if (!res.ok) {
      const code = String(json?.errorCode ?? '');
      if (code === '500.001.1001' || /being processed/i.test(String(json?.errorMessage ?? ''))) {
        return { outcome: 'PENDING', message: String(json?.errorMessage ?? 'Still processing') };
      }
      throw new ProviderError(`Status query failed (${res.status}).`);
    }
    if (!json || json.ResultCode === undefined)
      throw new ProviderError('Status query gave no result.');
    const mapped = mapResultCode(json.ResultCode as string | number);
    return {
      outcome: mapped.outcome,
      code: mapped.code,
      message: json.ResultDesc ? String(json.ResultDesc) : undefined,
    };
  }

  async refund(input: RefundInput): Promise<RefundResult> {
    // Daraja's Transaction Reversal API needs an initiator name and a security credential issued by Safaricom, and
    // answers asynchronously on a second callback. Neither exists yet, so refunds are paid back by finance and
    // confirmed in the console. This is recorded in DECISIONS (DEC-103); do not pretend it is automatic.
    return {
      outcome: 'MANUAL_REQUIRED',
      note: `Pay KES ${toShillings(input.amountMinor)} back to the payer of M-Pesa receipt ${input.receiptNumber ?? input.providerReference} (B2C or reversal in the Safaricom portal), then confirm the refund here.`,
    };
  }

  verifyWebhook(req: WebhookRequest): boolean {
    const expected = this.cfg.callbackToken;
    if (expected.length < 32 || !req.token || !safeEqual(req.token, expected)) return false;
    const allowed = this.cfg.allowedIps;
    if (allowed.length > 0) {
      return Boolean(req.ip && allowed.map(stripV6).includes(stripV6(req.ip)));
    }
    return true;
  }

  parseWebhook(body: unknown): ParsedWebhook | null {
    const cb = asRecord(asRecord(asRecord(body)?.Body)?.stkCallback);
    if (!cb || !cb.CheckoutRequestID) return null;
    const mapped = mapResultCode(cb.ResultCode as string | number | undefined);
    const items = asRecord(cb.CallbackMetadata)?.Item;
    const meta = new Map<string, unknown>();
    if (Array.isArray(items)) {
      for (const it of items) {
        const r = asRecord(it);
        if (r && typeof r.Name === 'string') meta.set(r.Name, r.Value);
      }
    }
    const amount = meta.get('Amount');
    const receipt = meta.get('MpesaReceiptNumber');
    return {
      providerReference: String(cb.CheckoutRequestID),
      claimed: mapped.outcome,
      code: mapped.code,
      message: cb.ResultDesc ? String(cb.ResultDesc) : undefined,
      amountMinor:
        typeof amount === 'number' || typeof amount === 'string'
          ? toMinor(Number(amount))
          : undefined,
      receiptNumber: typeof receipt === 'string' ? receipt : undefined,
    };
  }

  // ---- HTTP ----------------------------------------------------------------------------------------

  private password(timestamp: string): string {
    const c = this.cfg;
    return Buffer.from(`${c.shortcode}${c.passkey}${timestamp}`).toString('base64');
  }

  private async accessToken(): Promise<string> {
    if (this.token && this.token.expiresAt > Date.now() + 30_000) return this.token.value;
    const c = this.cfg;
    const basic = Buffer.from(`${c.consumerKey}:${c.consumerSecret}`).toString('base64');
    const res = await this.fetchJson(
      `${c.baseUrl}/oauth/v1/generate?grant_type=client_credentials`,
      {
        method: 'GET',
        headers: { Authorization: `Basic ${basic}` },
      },
    );
    const json = asRecord(res.json);
    if (!res.ok || !json?.access_token)
      throw new ProviderError(`Daraja sign-in failed (${res.status}).`);
    const ttl = Number(json.expires_in ?? 3000);
    this.token = { value: String(json.access_token), expiresAt: Date.now() + ttl * 1000 };
    return this.token.value;
  }

  private async call(path: string, body: unknown) {
    const token = await this.accessToken();
    return this.fetchJson(`${this.cfg.baseUrl}${path}`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    });
  }

  private async fetchJson(url: string, init: RequestInit) {
    try {
      const res = await fetch(url, { ...init, signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS) });
      let json: unknown = null;
      try {
        json = await res.json();
      } catch {
        json = null;
      }
      return { ok: res.ok, status: res.status, json };
    } catch (e) {
      this.log.warn(`Daraja request failed: ${e instanceof Error ? e.message : String(e)}`);
      throw new ProviderError('Could not reach M-Pesa.');
    }
  }
}

/** Stable hash of a callback body, used to recognise a duplicate delivery. */
export const bodyDigest = (raw: string): string => createHash('sha256').update(raw).digest('hex');
