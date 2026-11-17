import 'server-only';
import type { Schemas } from '@atarah/api-contracts';
import { api } from './api';

export type AdminContent = Schemas['AdminContentDto'];
export type AdminLesson = Schemas['AdminLessonDto'];
export type AdminCategory = Schemas['AdminCategoryDto'];
export type LearningAnalytics = Schemas['LearningAnalyticsDto'];
export type OverrideResult = Schemas['OverrideResultDto'];

export type Result<T> = { data?: T; error?: unknown; response: Response };
type List<T> = { data: T[]; meta?: unknown };

interface Client {
  GET: (path: string, init: unknown) => Promise<Result<unknown>>;
  POST: (path: string, init: unknown) => Promise<Result<unknown>>;
  PATCH: (path: string, init: unknown) => Promise<Result<unknown>>;
  PUT: (path: string, init: unknown) => Promise<Result<unknown>>;
  DELETE: (path: string, init: unknown) => Promise<Result<unknown>>;
}

/** The generated schema reuses generic operation ids across modules, so these wrappers pin the right types. */
const client = () => api() as unknown as Client;
const P = '/api/v1/admin';
const path = (params: Record<string, string>) => ({ params: { path: params } });

export interface ContentQuery {
  page: number;
  limit: number;
  status?: string;
  type?: string;
  categoryId?: string;
  q?: string;
  brokenLink?: boolean;
}

export const listContents = async (query: ContentQuery) =>
  (await client().GET(`${P}/learning/contents`, { params: { query } })) as Result<
    List<AdminContent>
  >;

type ContentResult = Result<{ data: AdminContent }>;

export const getContent = async (id: string) =>
  (await client().GET(`${P}/learning/contents/{id}`, path({ id }))) as ContentResult;

export const createContent = async (body: Record<string, unknown>) =>
  (await client().POST(`${P}/learning/contents`, { body })) as ContentResult;

export const updateContent = async (id: string, body: Record<string, unknown>) =>
  (await client().PATCH(`${P}/learning/contents/{id}`, { ...path({ id }), body })) as ContentResult;

export type Transition = 'publish' | 'unpublish' | 'archive';

export const transitionContent = async (id: string, verb: Transition) =>
  (await client().POST(`${P}/learning/contents/{id}/${verb}`, path({ id }))) as ContentResult;

export const listCategories = async () =>
  (await client().GET(`${P}/learning/categories`, {})) as Result<{ data: AdminCategory[] }>;

type CategoryResult = Result<{ data: AdminCategory }>;

export const createCategory = async (body: Record<string, unknown>) =>
  (await client().POST(`${P}/learning/categories`, { body })) as CategoryResult;

export const updateCategory = async (id: string, body: Record<string, unknown>) =>
  (await client().PATCH(`${P}/learning/categories/{id}`, {
    ...path({ id }),
    body,
  })) as CategoryResult;

export const embedHosts = async () =>
  (await client().GET(`${P}/learning/embed-hosts`, {})) as Result<{ data: { hosts: string[] } }>;

export const learningAnalytics = async () =>
  (await client().GET(`${P}/learning/analytics`, {})) as Result<{ data: LearningAnalytics }>;

export const addLesson = async (courseId: string, body: Record<string, unknown>) =>
  (await client().POST(`${P}/courses/{id}/lessons`, {
    ...path({ id: courseId }),
    body,
  })) as ContentResult;

export const updateLesson = async (
  courseId: string,
  lessonId: string,
  body: Record<string, unknown>,
) =>
  (await client().PATCH(`${P}/courses/{id}/lessons/{lessonId}`, {
    ...path({ id: courseId, lessonId }),
    body,
  })) as ContentResult;

export const deleteLesson = async (courseId: string, lessonId: string) =>
  (await client().DELETE(`${P}/courses/{id}/lessons/{lessonId}`, {
    ...path({ id: courseId, lessonId }),
  })) as ContentResult;

export const reorderLessons = async (courseId: string, lessonIds: string[]) =>
  (await client().PUT(`${P}/courses/{id}/lessons/order`, {
    ...path({ id: courseId }),
    body: { lessonIds },
  })) as ContentResult;

export const progressOverride = async (body: Record<string, unknown>) =>
  (await client().POST(`${P}/learning/progress-overrides`, { body })) as Result<{
    data: OverrideResult;
  }>;

/** Step 1 of a lesson-video upload: a signed address the browser PUTs the bytes to. Private, so only enrolled members see it. */
export const requestVideoUpload = async (mimeType: string, sizeBytes: number) =>
  (await client().POST(`${P}/media/uploads`, {
    body: { kind: 'VIDEO', mimeType, sizeBytes, visibility: 'PRIVATE' },
  })) as Result<{ data: { id: string; uploadUrl: string; headers: Record<string, string> } }>;

export const completeVideoUpload = async (id: string) =>
  (await client().POST(`${P}/media/{id}/complete`, path({ id }))) as Result<unknown>;
