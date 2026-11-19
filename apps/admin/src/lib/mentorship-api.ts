import 'server-only';
import type { Schemas } from '@atarah/api-contracts';
import { api } from './api';

export type AdminApplication = Schemas['AdminApplicationDto'];
export type AdminMentor = Schemas['AdminMentorDto'];
export type AdminSessionType = Schemas['AdminSessionTypeDto'];

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

export interface PageQuery {
  page: number;
  limit: number;
}

export const listApplications = async (query: PageQuery & { status?: string }) =>
  (await client().GET(`${P}/mentor-applications`, { params: { query } })) as Result<
    List<AdminApplication>
  >;

export const approveApplication = async (id: string, reason?: string) =>
  (await client().POST(`${P}/mentor-applications/{id}/approve`, {
    ...path({ id }),
    body: { reason },
  })) as Result<{ data: AdminApplication }>;

export const rejectApplication = async (id: string, reason: string) =>
  (await client().POST(`${P}/mentor-applications/{id}/reject`, {
    ...path({ id }),
    body: { reason },
  })) as Result<{ data: AdminApplication }>;

export const listMentors = async (
  query: PageQuery & { status?: string; q?: string; featured?: boolean },
) => (await client().GET(`${P}/mentors`, { params: { query } })) as Result<List<AdminMentor>>;

export type MentorVerb = 'pause' | 'resume' | 'remove';

export const changeMentorStatus = async (id: string, verb: MentorVerb, reason: string) =>
  (await client().POST(`${P}/mentors/{id}/${verb}`, {
    ...path({ id }),
    body: { reason },
  })) as Result<{ data: AdminMentor }>;

export const featureMentor = async (id: string, featured: boolean) =>
  (await client().PATCH(`${P}/mentors/{id}/featured`, {
    ...path({ id }),
    body: { featured },
  })) as Result<{ data: AdminMentor }>;

export const listSessionTypes = async (
  query: PageQuery & { mentorId?: string; disabledByStaff?: boolean },
) =>
  (await client().GET(`${P}/mentor-session-types`, { params: { query } })) as Result<
    List<AdminSessionType>
  >;

export const setSessionTypeDisabled = async (id: string, disabled: boolean, note?: string) =>
  (await client().PATCH(`${P}/mentor-session-types/{id}`, {
    ...path({ id }),
    body: { disabled, note },
  })) as Result<{ data: AdminSessionType }>;
