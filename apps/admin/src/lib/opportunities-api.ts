import 'server-only';
import type { Schemas } from '@atarah/api-contracts';
import { api } from './api';

export type AdminOpportunity = Schemas['AdminOpportunityDto'];
export type AdminProvider = Schemas['AdminProviderDto'];
export type ImportReport = Schemas['ImportReportDto'];
export type ImportCommitResult = Schemas['ImportCommitResultDto'];
export type LinkHealthItem = Schemas['LinkHealthItemDto'];
export type County = Schemas['CountyDto'];

export type Result<T> = { data?: T; error?: unknown; response: Response };
type List<T> = { data: T[]; meta?: unknown };

interface Client {
  GET: (path: string, init: unknown) => Promise<Result<unknown>>;
  POST: (path: string, init: unknown) => Promise<Result<unknown>>;
  PATCH: (path: string, init: unknown) => Promise<Result<unknown>>;
}

/** The generated schema reuses generic operation ids across modules, so these wrappers pin the right types. */
const client = () => api() as unknown as Client;
const P = '/api/v1/admin';
const path = (params: Record<string, string>) => ({ params: { path: params } });

export interface OpportunityQuery {
  page: number;
  limit: number;
  status?: string;
  type?: string;
  providerId?: string;
  q?: string;
  brokenLink?: boolean;
}

export const listOpportunities = async (query: OpportunityQuery) =>
  (await client().GET(`${P}/opportunities`, { params: { query } })) as Result<
    List<AdminOpportunity>
  >;

type OppResult = Result<{ data: AdminOpportunity }>;

export const getOpportunity = async (id: string) =>
  (await client().GET(`${P}/opportunities/{id}`, path({ id }))) as OppResult;

export const createOpportunity = async (body: Record<string, unknown>) =>
  (await client().POST(`${P}/opportunities`, { body })) as OppResult;

export const updateOpportunity = async (id: string, body: Record<string, unknown>) =>
  (await client().PATCH(`${P}/opportunities/{id}`, { ...path({ id }), body })) as OppResult;

export type Transition = 'publish' | 'close' | 'archive' | 'remove';

export const transitionOpportunity = async (id: string, verb: Transition) =>
  (await client().POST(`${P}/opportunities/{id}/${verb}`, path({ id }))) as OppResult;

export const rejectOpportunity = async (id: string, reason: string) =>
  (await client().POST(`${P}/opportunities/{id}/reject`, {
    ...path({ id }),
    body: { reason },
  })) as OppResult;

export const featureOpportunity = async (id: string, until: string | null) =>
  (await client().POST(`${P}/opportunities/{id}/feature`, {
    ...path({ id }),
    body: { until },
  })) as OppResult;

export const setOpportunityTrust = async (id: string, trust: string, reason?: string) =>
  (await client().POST(`${P}/opportunities/{id}/set-trust`, {
    ...path({ id }),
    body: { trust, ...(reason ? { reason } : {}) },
  })) as OppResult;

export const verifyOpportunity = async (id: string, reason?: string) =>
  (await client().POST(`${P}/opportunities/{id}/verify`, {
    ...path({ id }),
    body: reason ? { reason } : {},
  })) as OppResult;

export const listProviders = async (query: {
  page: number;
  limit: number;
  q?: string;
  verification?: string;
}) =>
  (await client().GET(`${P}/opportunity-providers`, { params: { query } })) as Result<
    List<AdminProvider>
  >;

type ProviderResult = Result<{ data: AdminProvider }>;

export const createProvider = async (body: Record<string, unknown>) =>
  (await client().POST(`${P}/opportunity-providers`, { body })) as ProviderResult;

export const updateProvider = async (id: string, body: Record<string, unknown>) =>
  (await client().PATCH(`${P}/opportunity-providers/{id}`, {
    ...path({ id }),
    body,
  })) as ProviderResult;

export const verifyProvider = async (id: string, status: string, reason?: string) =>
  (await client().POST(`${P}/opportunity-providers/{id}/verify`, {
    ...path({ id }),
    body: { status, ...(reason ? { reason } : {}) },
  })) as ProviderResult;

export const linkHealth = async (query: { page: number; limit: number; result?: string }) =>
  (await client().GET(`${P}/opportunities/link-health`, { params: { query } })) as Result<
    List<LinkHealthItem>
  >;

export const previewImport = async (csv: string) =>
  (await client().POST(`${P}/opportunities/import/preview`, { body: { csv } })) as Result<{
    data: ImportReport;
  }>;

export const commitImport = async (csv: string) =>
  (await client().POST(`${P}/opportunities/import`, { body: { csv } })) as Result<{
    data: ImportCommitResult;
  }>;

/** Counties for the form's location select (public endpoint; Kenya is the default country). */
export const listCounties = async () =>
  (await client().GET('/api/v1/locations/counties', { params: {} })) as Result<List<County>>;
