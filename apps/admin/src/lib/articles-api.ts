import 'server-only';
import type { Schemas } from '@atarah/api-contracts';
import { api } from './api';

export type AdminArticle = Schemas['AdminArticleDto'];
export type AdminArticleSummary = Pick<
  AdminArticle,
  | 'id'
  | 'slug'
  | 'title'
  | 'authorName'
  | 'status'
  | 'source'
  | 'publishedAt'
  | 'scheduled'
  | 'featured'
  | 'updatedAt'
>;
export type HomeConfig = Schemas['HomeConfigDto'];
export type UploadTicket = Schemas['UploadTicketDto'];

export type Result<T> = { data?: T; error?: unknown; response: Response };

interface Client {
  GET: (path: string, init: unknown) => Promise<Result<unknown>>;
  POST: (path: string, init: unknown) => Promise<Result<unknown>>;
  PATCH: (path: string, init: unknown) => Promise<Result<unknown>>;
  PUT: (path: string, init: unknown) => Promise<Result<unknown>>;
}

/**
 * The generated schema reuses generic operation ids (`list`, `get`, `create`, `update`, `publish`...) across
 * modules, so the typed client can resolve these paths to the wrong response types. These wrappers restore
 * the right types (the calls themselves are unchanged), as the portfolio and taxonomy wrappers do.
 */
const client = () => api() as unknown as Client;

const byId = (id: string) => ({ params: { path: { id } } });

export type LifecyclePath = 'submit' | 'return' | 'publish' | 'archive' | 'restore';

export async function listAdminArticles(query: {
  status?: string;
  q?: string;
  page: number;
  limit: number;
}): Promise<Result<{ data: AdminArticleSummary[]; meta?: unknown }>> {
  return (await client().GET('/api/v1/admin/articles', { params: { query } })) as Result<{
    data: AdminArticleSummary[];
    meta?: unknown;
  }>;
}

export async function createAdminArticle(body: {
  title: string;
  authorName: string;
}): Promise<Result<{ data: AdminArticle }>> {
  return (await client().POST('/api/v1/admin/articles', { body })) as Result<{
    data: AdminArticle;
  }>;
}

export async function getAdminArticle(id: string): Promise<Result<{ data: AdminArticle }>> {
  return (await client().GET('/api/v1/admin/articles/{id}', byId(id))) as Result<{
    data: AdminArticle;
  }>;
}

export async function updateAdminArticle(
  id: string,
  body: Record<string, unknown>,
): Promise<Result<{ data: AdminArticle }>> {
  return (await client().PATCH('/api/v1/admin/articles/{id}', { ...byId(id), body })) as Result<{
    data: AdminArticle;
  }>;
}

export async function articleLifecycle(
  id: string,
  action: LifecyclePath,
  body?: { publishAt?: string },
): Promise<Result<{ data: AdminArticle }>> {
  const path = `/api/v1/admin/articles/{id}/${action}`;
  const init = action === 'publish' ? { ...byId(id), body: body ?? {} } : byId(id);
  return (await client().POST(path, init)) as Result<{ data: AdminArticle }>;
}

export async function getHomeConfig(): Promise<Result<{ data: HomeConfig }>> {
  return (await client().GET('/api/v1/admin/home', {})) as Result<{ data: HomeConfig }>;
}

export async function setHomeConfig(
  featuredArticleId: string | null,
): Promise<Result<{ data: HomeConfig }>> {
  return (await client().PUT('/api/v1/admin/home', {
    body: { featuredArticleId },
  })) as Result<{ data: HomeConfig }>;
}

export async function requestImageUpload(
  mimeType: string,
  sizeBytes: number,
): Promise<Result<{ data: UploadTicket }>> {
  return (await client().POST('/api/v1/admin/media/uploads', {
    body: { kind: 'IMAGE', mimeType, sizeBytes, visibility: 'PUBLIC' },
  })) as Result<{ data: UploadTicket }>;
}

export async function completeUpload(id: string): Promise<Result<unknown>> {
  return client().POST('/api/v1/admin/media/{id}/complete', byId(id));
}
