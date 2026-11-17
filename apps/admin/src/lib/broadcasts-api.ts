import 'server-only';
import type { Schemas } from '@atarah/api-contracts';
import { api } from './api';

export type Broadcast = Schemas['BroadcastDto'];
export type AudiencePreview = Schemas['AudiencePreviewDto'];
export type PrivacyRequest = Schemas['PrivacyRequestDto'];

export type Result<T> = { data?: T; error?: unknown; response: Response };
type List<T> = { data: T[]; meta?: unknown };

interface Client {
  GET: (path: string, init: unknown) => Promise<Result<unknown>>;
  POST: (path: string, init: unknown) => Promise<Result<unknown>>;
}

/** The generated schema reuses generic operation ids across modules, so these wrappers pin the right types. */
const client = () => api() as unknown as Client;
const P = '/api/v1/admin';
const path = (params: Record<string, string>) => ({ params: { path: params } });

export const listBroadcasts = async (query: { page: number; limit: number; status?: string }) =>
  (await client().GET(`${P}/notifications/broadcasts`, { params: { query } })) as Result<
    List<Broadcast>
  >;

type One = Result<{ data: Broadcast }>;

export const getBroadcast = async (id: string) =>
  (await client().GET(`${P}/notifications/broadcasts/{id}`, path({ id }))) as One;

export const previewAudience = async (body: Record<string, unknown>) =>
  (await client().POST(`${P}/notifications/broadcasts/preview`, { body })) as Result<{
    data: AudiencePreview;
  }>;

export const createBroadcast = async (body: Record<string, unknown>) =>
  (await client().POST(`${P}/notifications/broadcasts`, { body })) as One;

export const cancelBroadcast = async (id: string) =>
  (await client().POST(`${P}/notifications/broadcasts/{id}/cancel`, path({ id }))) as One;

export const listPrivacyRequests = async (query: {
  page: number;
  limit: number;
  kind?: string;
  status?: string;
}) =>
  (await client().GET(`${P}/privacy-requests`, { params: { query } })) as Result<
    List<PrivacyRequest>
  >;
