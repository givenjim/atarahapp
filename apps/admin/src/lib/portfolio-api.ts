import 'server-only';
import type { Schemas } from '@atarah/api-contracts';
import { api } from './api';

export type AdminProject = Schemas['AdminProjectDto'];
export type AdminProjectDetail = Schemas['AdminProjectDetailDto'];

type Result<T> = { data?: T; error?: unknown; response: Response };
type ListBody = { data: AdminProject[]; meta?: unknown };
type DetailBody = { data: AdminProjectDetail };

interface Client {
  GET: (path: string, init: unknown) => Promise<Result<unknown>>;
  POST: (path: string, init: unknown) => Promise<Result<unknown>>;
}

/**
 * The generated schema reuses the operation ids `list`, `get`, `hide` and `restore` across modules, so the
 * typed client can resolve these paths to the wrong response types. These wrappers restore the right types
 * (the calls themselves are unchanged), as the taxonomy wrapper does.
 */
const client = () => api() as unknown as Client;

export async function listAdminProjects(query: {
  q?: string;
  hiddenOnly?: boolean;
  page: number;
  limit: number;
}): Promise<Result<ListBody>> {
  return (await client().GET('/api/v1/admin/projects', { params: { query } })) as Result<ListBody>;
}

export async function getAdminProject(id: string): Promise<Result<DetailBody>> {
  return (await client().GET('/api/v1/admin/projects/{id}', {
    params: { path: { id } },
  })) as Result<DetailBody>;
}

export async function hideAdminProject(id: string, reason: string): Promise<Result<DetailBody>> {
  return (await client().POST('/api/v1/admin/projects/{id}/hide', {
    params: { path: { id } },
    body: { reason },
  })) as Result<DetailBody>;
}

export async function restoreAdminProject(id: string): Promise<Result<DetailBody>> {
  return (await client().POST('/api/v1/admin/projects/{id}/restore', {
    params: { path: { id } },
  })) as Result<DetailBody>;
}
