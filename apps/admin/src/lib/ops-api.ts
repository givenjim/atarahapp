import 'server-only';
import { api } from './api';
import type {
  AnalyticsSeries,
  Dashboard,
  FailedJob,
  FeatureFlag,
  PlatformSetting,
  QueueCounts,
  RoleInfo,
  UserOverview,
} from './ops';

export type Result<T> = { data?: T; error?: unknown; response: Response };
type One<T> = Result<{ data: T }>;

interface Client {
  GET: (path: string, init?: unknown) => Promise<Result<unknown>>;
  POST: (path: string, init?: unknown) => Promise<Result<unknown>>;
  PUT: (path: string, init?: unknown) => Promise<Result<unknown>>;
  PATCH: (path: string, init?: unknown) => Promise<Result<unknown>>;
  DELETE: (path: string, init?: unknown) => Promise<Result<unknown>>;
}

/** Typed wrappers over the generated client; they pin the response types so the screens do not depend on schema regeneration. */
const client = () => api() as unknown as Client;
const P = '/api/v1/admin';
const path = (params: Record<string, string>) => ({ params: { path: params } });

export const getDashboard = async () => (await client().GET(`${P}/dashboard`)) as One<Dashboard>;

export const getAnalytics = async (query: Record<string, string>) =>
  (await client().GET(`${P}/analytics/events`, { params: { query } })) as One<AnalyticsSeries>;

export const listQueues = async () => (await client().GET(`${P}/jobs`)) as One<QueueCounts[]>;

export const listFailedJobs = async (queue: string) =>
  (await client().GET(`${P}/jobs/{queue}/failed`, path({ queue }))) as One<FailedJob[]>;

export const retryJob = async (queue: string, jobId: string) =>
  (await client().POST(`${P}/jobs/{queue}/{jobId}/retry`, path({ queue, jobId }))) as Result<never>;

export const listRoles = async () => (await client().GET(`${P}/roles`)) as One<RoleInfo[]>;

export const getOverview = async (id: string) =>
  (await client().GET(`${P}/users/{id}/overview`, path({ id }))) as One<UserOverview>;

export const assignRole = async (id: string, body: { role: string; reason?: string }) =>
  (await client().POST(`${P}/users/{id}/roles`, { ...path({ id }), body })) as Result<unknown>;

export const revokeRole = async (id: string, role: string, reason?: string) =>
  (await client().DELETE(`${P}/users/{id}/roles/{role}`, {
    params: { path: { id, role }, query: reason ? { reason } : {} },
  })) as Result<unknown>;

export const suspendUser = async (id: string, body: { reason: string; durationDays?: number }) =>
  (await client().POST(`${P}/users/{id}/suspend`, { ...path({ id }), body })) as Result<unknown>;

export const listFlags = async () =>
  (await client().GET(`${P}/feature-flags`)) as One<FeatureFlag[]>;

export const setFlag = async (key: string, enabled: boolean) =>
  (await client().PATCH(`${P}/feature-flags/{key}`, {
    ...path({ key }),
    body: { enabled },
  })) as Result<unknown>;

export const listSettings = async () =>
  (await client().GET(`${P}/settings`)) as One<PlatformSetting[]>;

export const setSetting = async (key: string, body: { value: string | number | boolean }) =>
  (await client().PUT(`${P}/settings/{key}`, { ...path({ key }), body })) as Result<unknown>;
