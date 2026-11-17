'use server';

import { redirect } from 'next/navigation';
import { revalidatePath } from 'next/cache';
import { errorOf, needsReauth, sessionRedirectFor } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import {
  addLesson,
  completeVideoUpload,
  createCategory,
  createContent,
  deleteLesson,
  progressOverride,
  reorderLessons,
  requestVideoUpload,
  transitionContent,
  updateCategory,
  updateContent,
  updateLesson,
  type Transition,
} from '@/lib/learning-api';
import {
  categoryPayload,
  learningMessage,
  lessonPayload,
  overridePayload,
  toContentPayload,
  validateCategory,
  validateContentForm,
  validateLessonForm,
  validateOverride,
  validateVideoFile,
  type CategoryForm,
  type ContentForm,
  type LessonForm,
  type OverrideForm,
} from '@/lib/learning';
import type { UploadTicket } from '@/lib/image-upload';
import type { ActionResult } from '@/app/actions';

const DENIED = 'You do not have permission to do that.';

async function holds(...permissions: string[]): Promise<boolean> {
  const me = await currentAdmin();
  return permissions.every((p) => can(me.permissions, p));
}

/** An API response as an action result: a stale authenticator check asks for the code again. */
function settle(error: unknown, response: Response, paths: string[]): ActionResult {
  if (response.ok) {
    for (const p of paths) revalidatePath(p, 'layout');
    return { ok: true };
  }
  const e = errorOf(error, response);
  if (needsReauth(e)) return { ok: false, reauth: true, error: e.message };
  const gone = sessionRedirectFor(e);
  if (gone) redirect(gone);
  return { ok: false, error: learningMessage(e.status, e.message) };
}

const LIST = ['/learning'];
const AUDIT = '/audit-logs';

export type SavedResult = ActionResult & { id?: string };

/** `hosts` is the allow-list the form was built with; the API checks the real one again. */
export async function saveContentAction(
  id: string | null,
  form: ContentForm,
  hosts: string[],
  originalType?: string,
): Promise<SavedResult> {
  if (!(await holds('learning.manage'))) return { ok: false, error: DENIED };
  const mode = id ? 'edit' : 'create';
  const problem = validateContentForm(form, mode, hosts);
  if (problem) return { ok: false, error: problem };
  const body = toContentPayload(form, mode, originalType);
  const res = id ? await updateContent(id, body) : await createContent(body);
  const out = settle(res.error, res.response, [...LIST, AUDIT]);
  return out.ok ? { ok: true, id: res.data?.data.id ?? id ?? undefined } : out;
}

/** Publish, unpublish or archive. The API names what is missing ("Add at least one lesson") and the page shows it. */
export async function transitionContentAction(id: string, verb: Transition): Promise<ActionResult> {
  if (!(await holds('learning.manage'))) return { ok: false, error: DENIED };
  const { error, response } = await transitionContent(id, verb);
  return settle(error, response, [...LIST, AUDIT]);
}

export async function saveCategoryAction(
  id: string | null,
  form: CategoryForm,
): Promise<ActionResult> {
  if (!(await holds('learning.manage'))) return { ok: false, error: DENIED };
  const problem = validateCategory(form);
  if (problem) return { ok: false, error: problem };
  const body = categoryPayload(form);
  const res = id ? await updateCategory(id, body) : await createCategory(body);
  return settle(res.error, res.response, ['/learning/categories', ...LIST, AUDIT]);
}

export async function saveLessonAction(
  courseId: string,
  lessonId: string | null,
  form: LessonForm,
  hosts: string[],
): Promise<ActionResult> {
  if (!(await holds('learning.manage'))) return { ok: false, error: DENIED };
  const problem = validateLessonForm(form, hosts);
  if (problem) return { ok: false, error: problem };
  const body = lessonPayload(form, lessonId ? 'edit' : 'create');
  const res = lessonId
    ? await updateLesson(courseId, lessonId, body)
    : await addLesson(courseId, body);
  return settle(res.error, res.response, [...LIST, AUDIT]);
}

export async function deleteLessonAction(
  courseId: string,
  lessonId: string,
): Promise<ActionResult> {
  if (!(await holds('learning.manage'))) return { ok: false, error: DENIED };
  const { error, response } = await deleteLesson(courseId, lessonId);
  return settle(error, response, [...LIST, AUDIT]);
}

/** `lessonIds` is every lesson of the course, once, in the new order. */
export async function reorderLessonsAction(
  courseId: string,
  lessonIds: string[],
): Promise<ActionResult> {
  if (!(await holds('learning.manage'))) return { ok: false, error: DENIED };
  const { error, response } = await reorderLessons(courseId, lessonIds);
  return settle(error, response, [...LIST]);
}

/** Needs a fresh authenticator code. An issued certificate stays; every override is audited. */
export async function progressOverrideAction(
  courseId: string,
  form: OverrideForm,
): Promise<ActionResult> {
  if (!(await holds('learning.manage'))) return { ok: false, error: DENIED };
  const problem = validateOverride(form);
  if (problem) return { ok: false, error: problem };
  const { error, response } = await progressOverride(overridePayload(courseId, form));
  return settle(error, response, [...LIST, AUDIT]);
}

/** Step 1 of a lesson-video upload. The browser then PUTs the bytes to the signed address itself. */
export async function requestVideoUploadAction(
  mimeType: string,
  sizeBytes: number,
): Promise<{ ok: true; ticket: UploadTicket } | { ok: false; error: string }> {
  if (!(await holds('learning.manage', 'media.manage')))
    return { ok: false, error: 'You do not have permission to upload media.' };
  const problem = validateVideoFile({ type: mimeType, size: sizeBytes });
  if (problem) return { ok: false, error: problem };
  const { data, error, response } = await requestVideoUpload(mimeType, sizeBytes);
  if (!data) return { ok: false, error: errorOf(error, response).message };
  const { id, uploadUrl, headers } = data.data;
  return { ok: true, ticket: { id, uploadUrl, headers } };
}

/** Step 3: tell the API the bytes arrived. The worker then checks the file. */
export async function completeVideoUploadAction(
  mediaId: string,
): Promise<{ ok: true } | { ok: false; error: string }> {
  if (!(await holds('learning.manage', 'media.manage')))
    return { ok: false, error: 'You do not have permission to upload media.' };
  const { error, response } = await completeVideoUpload(mediaId);
  if (!response.ok) return { ok: false, error: errorOf(error, response).message };
  return { ok: true };
}
