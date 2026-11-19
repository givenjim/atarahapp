import 'server-only';
import type { Schemas } from '@atarah/api-contracts';
import { api } from './api';

export type AdminListing = Schemas['AdminListingDto'];
export type AdminSeller = Schemas['AdminSellerDto'];
export type AdminListingReport = Schemas['AdminListingReportDto'];
export type AdminCategory = Schemas['AdminCategoryDto'];
export type AdminReview = Schemas['AdminReviewDto'];

export type Result<T> = { data?: T; error?: unknown; response: Response };
type List<T> = { data: T[]; meta?: unknown };

interface Client {
  GET: (path: string, init: unknown) => Promise<Result<unknown>>;
  POST: (path: string, init: unknown) => Promise<Result<unknown>>;
  PATCH: (path: string, init: unknown) => Promise<Result<unknown>>;
}

/** The generated schema reuses generic operation ids across modules, so these wrappers pin the right types. */
const client = () => api() as unknown as Client;
const P = '/api/v1/admin/marketplace';
const path = (params: Record<string, string>) => ({ params: { path: params } });

export interface PageQuery {
  page: number;
  limit: number;
}

// ---- listings ----

export const listListings = async (
  query: PageQuery & { status?: string; q?: string; reported?: boolean },
) => (await client().GET(`${P}/listings`, { params: { query } })) as Result<List<AdminListing>>;

export type ListingVerb = 'approve' | 'reject' | 'suspend' | 'reinstate';

export const decideListing = async (id: string, verb: ListingVerb, reason?: string) =>
  (await client().POST(`${P}/listings/{id}/${verb}`, {
    ...path({ id }),
    body: verb === 'approve' ? {} : { reason },
  })) as Result<{ data: AdminListing }>;

export const featureListing = async (id: string, until: string | null) =>
  (await client().POST(`${P}/listings/{id}/feature`, {
    ...path({ id }),
    body: { until },
  })) as Result<{ data: AdminListing }>;

// ---- sellers ----

export const listSellers = async (query: PageQuery & { status?: string; q?: string }) =>
  (await client().GET(`${P}/sellers`, { params: { query } })) as Result<List<AdminSeller>>;

export const changeSellerStatus = async (
  id: string,
  verb: 'suspend' | 'reinstate',
  reason: string,
) =>
  (await client().POST(`${P}/sellers/{id}/${verb}`, {
    ...path({ id }),
    body: { reason },
  })) as Result<{ data: AdminSeller }>;

export const setDirectPublish = async (id: string, canPublishDirectly: boolean) =>
  (await client().PATCH(`${P}/sellers/{id}/direct-publish`, {
    ...path({ id }),
    body: { canPublishDirectly },
  })) as Result<{ data: AdminSeller }>;

// ---- reports ----

export const listReports = async (query: PageQuery & { status?: string }) =>
  (await client().GET(`${P}/reports`, { params: { query } })) as Result<
    List<AdminListingReport>
  >;

export const resolveReport = async (
  id: string,
  action: 'DISMISS' | 'SUSPEND_LISTING',
  note: string,
) =>
  (await client().POST(`${P}/reports/{id}/resolve`, {
    ...path({ id }),
    body: { action, note },
  })) as Result<{ data: AdminListingReport }>;

// ---- categories ----

export const listCategories = async () =>
  (await client().GET(`${P}/categories`, {})) as Result<{ data: AdminCategory[] }>;

export interface CategoryInput {
  name: string;
  icon: string;
  tone: string;
  sortOrder?: number;
  isActive?: boolean;
}

export const createCategory = async (body: CategoryInput) =>
  (await client().POST(`${P}/categories`, { body })) as Result<{ data: AdminCategory }>;

export const updateCategory = async (id: string, body: Partial<CategoryInput>) =>
  (await client().PATCH(`${P}/categories/{id}`, { ...path({ id }), body })) as Result<{
    data: AdminCategory;
  }>;

// ---- reviews ----

export const listReviews = async (query: PageQuery & { status?: string }) =>
  (await client().GET(`${P}/reviews`, { params: { query } })) as Result<List<AdminReview>>;

export const moderateReview = async (id: string, verb: 'hide' | 'restore', reason: string) =>
  (await client().POST(`${P}/reviews/{id}/${verb}`, {
    ...path({ id }),
    body: { reason },
  })) as Result<{ data: AdminReview }>;
