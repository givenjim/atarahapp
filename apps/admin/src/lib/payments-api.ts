import 'server-only';
import type { Schemas } from '@atarah/api-contracts';
import { api } from './api';

export type AdminPayment = Schemas['AdminPaymentDto'];
export type AdminPaymentDetail = Schemas['AdminPaymentDetailDto'];

export type Result<T> = { data?: T; error?: unknown; response: Response };
type List<T> = { data: T[]; meta?: unknown };

interface Client {
  GET: (path: string, init: unknown) => Promise<Result<unknown>>;
  POST: (path: string, init: unknown) => Promise<Result<unknown>>;
}

/** Same typing escape hatch as the other admin API wrappers: the calls are unchanged. */
const client = () => api() as unknown as Client;
const P = '/api/v1/admin/payments';
const path = (params: Record<string, string>) => ({ params: { path: params } });

export interface PaymentsQuery {
  page: number;
  limit: number;
  status?: string;
  paymentMethod?: string;
  purpose?: string;
  q?: string;
}

export const listPayments = async (query: PaymentsQuery) =>
  (await client().GET(P, { params: { query } })) as Result<List<AdminPayment>>;

type DetailResult = Result<{ data: AdminPaymentDetail }>;

export const getPayment = async (id: string) =>
  (await client().GET(`${P}/{id}`, path({ id }))) as DetailResult;

export const requeryPayment = async (id: string) =>
  (await client().POST(`${P}/{id}/requery`, path({ id }))) as DetailResult;

export const refundPayment = async (
  id: string,
  body: { amountMinor?: number; reason: string },
  idempotencyKey: string,
) =>
  (await client().POST(`${P}/{id}/refunds`, {
    ...path({ id }),
    body,
    headers: { 'Idempotency-Key': idempotencyKey },
  })) as DetailResult;

export const completeRefund = async (id: string, refundId: string, providerReference?: string) =>
  (await client().POST(`${P}/{id}/refunds/{refundId}/complete`, {
    ...path({ id, refundId }),
    body: providerReference ? { providerReference } : {},
  })) as DetailResult;

export const cancelRefund = async (id: string, refundId: string) =>
  (await client().POST(
    `${P}/{id}/refunds/{refundId}/cancel`,
    path({ id, refundId }),
  )) as DetailResult;
