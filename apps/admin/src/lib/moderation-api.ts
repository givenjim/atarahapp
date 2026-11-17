import 'server-only';
import type { Schemas } from '@atarah/api-contracts';
import { api } from './api';

export type AdminCase = Schemas['AdminCaseDto'];
export type AdminCaseDetail = Schemas['AdminCaseDetailDto'];
export type AdminGroup = Schemas['AdminGroupDto'];
export type AdminAnnouncement = Schemas['PostViewDto'];

export type Result<T> = { data?: T; error?: unknown; response: Response };
type List<T> = { data: T[]; meta?: unknown };

interface Client {
  GET: (path: string, init: unknown) => Promise<Result<unknown>>;
  POST: (path: string, init: unknown) => Promise<Result<unknown>>;
  PATCH: (path: string, init: unknown) => Promise<Result<unknown>>;
  DELETE: (path: string, init: unknown) => Promise<Result<unknown>>;
}

/**
 * The generated schema reuses generic operation ids across modules, so the typed client can resolve these
 * paths to the wrong types. These wrappers restore the right types (the calls are unchanged).
 */
const client = () => api() as unknown as Client;
const P = '/api/v1/admin';
const path = (params: Record<string, string>) => ({ params: { path: params } });

export interface CaseQuery {
  page: number;
  limit: number;
  status?: string;
  priority?: string;
  targetType?: string;
  assigneeId?: string;
  open?: boolean;
  olderThanHours?: number;
}

export const listCases = async (query: CaseQuery) =>
  (await client().GET(`${P}/moderation-cases`, { params: { query } })) as Result<List<AdminCase>>;

export const getCase = async (id: string) =>
  (await client().GET(`${P}/moderation-cases/{id}`, path({ id }))) as Result<{
    data: AdminCaseDetail;
  }>;

export const assignCase = async (id: string, assigneeId: string | null) =>
  (await client().POST(`${P}/moderation-cases/{id}/assign`, {
    ...path({ id }),
    body: { assigneeId },
  })) as Result<{ data: AdminCase }>;

export const decideCase = async (
  id: string,
  body: { action: string; reason?: string; restrictDays?: number },
) =>
  (await client().POST(`${P}/moderation-cases/{id}/actions`, {
    ...path({ id }),
    body,
  })) as Result<{ data: AdminCaseDetail }>;

export const listGroups = async (query: {
  page: number;
  limit: number;
  type?: string;
  q?: string;
  includeArchived?: boolean;
}) => (await client().GET(`${P}/groups`, { params: { query } })) as Result<List<AdminGroup>>;

type GroupResult = Result<{ data: AdminGroup }>;

export const getGroup = async (id: string) =>
  (await client().GET(`${P}/groups/{id}`, path({ id }))) as GroupResult;

export const createGroup = async (body: Record<string, unknown>) =>
  (await client().POST(`${P}/groups`, { body })) as GroupResult;

export const updateGroup = async (id: string, body: Record<string, unknown>) =>
  (await client().PATCH(`${P}/groups/{id}`, { ...path({ id }), body })) as GroupResult;

export const archiveGroup = async (id: string) =>
  (await client().DELETE(`${P}/groups/{id}`, path({ id }))) as Result<unknown>;

export const addGroupModerator = async (id: string, userId: string, role: string) =>
  (await client().POST(`${P}/groups/{id}/moderators`, {
    ...path({ id }),
    body: { userId, role },
  })) as GroupResult;

export const removeGroupModerator = async (id: string, userId: string) =>
  (await client().DELETE(
    `${P}/groups/{id}/moderators/{userId}`,
    path({ id, userId }),
  )) as GroupResult;

export const pinGroupPost = async (id: string, postId: string) =>
  (await client().POST(`${P}/groups/{id}/pins`, {
    ...path({ id }),
    body: { postId },
  })) as GroupResult;

export const unpinGroupPost = async (id: string, postId: string) =>
  (await client().DELETE(`${P}/groups/{id}/pins/{postId}`, path({ id, postId }))) as GroupResult;

export const listAnnouncements = async (query: { page: number; limit: number }) =>
  (await client().GET(`${P}/announcements`, { params: { query } })) as Result<
    List<AdminAnnouncement>
  >;

export const createAnnouncement = async (body: { body: string; groupId?: string }) =>
  (await client().POST(`${P}/announcements`, { body })) as Result<{ data: AdminAnnouncement }>;
