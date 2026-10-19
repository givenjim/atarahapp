'use server';

import { revalidatePath } from 'next/cache';
import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import {
  articleLifecycle,
  completeUpload,
  createAdminArticle,
  requestImageUpload,
  setHomeConfig,
  updateAdminArticle,
} from '@/lib/articles-api';
import {
  lifecycleMessage,
  validateImageFile,
  validateNewArticle,
  type LifecycleKind,
} from '@/lib/articles';
import type { UploadTicket } from '@/lib/image-upload';

export type ArticleResult = { ok: true } | { ok: false; error: string };

const DENIED = 'You do not have permission to manage articles.';
const UPLOAD_DENIED = 'You do not have permission to upload media.';

/** The backend enforces `article.manage` on every call; this only gives a clearer answer sooner. */
async function allowed(extra?: string): Promise<boolean> {
  const me = await currentAdmin();
  return can(me.permissions, 'article.manage') && (!extra || can(me.permissions, extra));
}

function refresh(): void {
  revalidatePath('/articles', 'layout');
  revalidatePath('/home-curation');
}

export async function createArticleAction(
  title: string,
  authorName: string,
): Promise<{ ok: true; id: string } | { ok: false; error: string }> {
  if (!(await allowed())) return { ok: false, error: DENIED };
  const problem = validateNewArticle(title, authorName);
  if (problem) return { ok: false, error: problem };
  const { data, error, response } = await createAdminArticle({
    title: title.trim(),
    authorName: authorName.trim(),
  });
  if (!data) return { ok: false, error: errorOf(error, response).message };
  refresh();
  return { ok: true, id: data.data.id };
}

export async function saveArticleAction(
  id: string,
  body: Record<string, unknown>,
): Promise<ArticleResult> {
  if (!(await allowed())) return { ok: false, error: DENIED };
  const { error, response } = await updateAdminArticle(id, body);
  if (!response.ok) {
    const e = errorOf(error, response);
    return {
      ok: false,
      error:
        e.status === 409
          ? 'Archived articles cannot be edited. Restore it to a draft first.'
          : lifecycleMessage(e.status, e.message),
    };
  }
  refresh();
  return { ok: true };
}

export async function articleLifecycleAction(
  id: string,
  kind: LifecycleKind,
  publishAt?: string,
): Promise<ArticleResult> {
  if (!(await allowed())) return { ok: false, error: DENIED };
  const { error, response } =
    kind === 'schedule'
      ? await articleLifecycle(id, 'publish', { publishAt })
      : await articleLifecycle(id, kind, kind === 'publish' ? {} : undefined);
  if (!response.ok) {
    const e = errorOf(error, response);
    return { ok: false, error: lifecycleMessage(e.status, e.message) };
  }
  refresh();
  return { ok: true };
}

export async function setFeaturedArticleAction(
  featuredArticleId: string | null,
): Promise<ArticleResult> {
  if (!(await allowed())) return { ok: false, error: DENIED };
  const { error, response } = await setHomeConfig(featuredArticleId);
  if (!response.ok) return { ok: false, error: errorOf(error, response).message };
  refresh();
  return { ok: true };
}

/** Step 1 of an image upload. The browser then PUTs the bytes to the signed URL itself. */
export async function requestImageUploadAction(
  mimeType: string,
  sizeBytes: number,
): Promise<{ ok: true; ticket: UploadTicket } | { ok: false; error: string }> {
  if (!(await allowed('media.manage'))) return { ok: false, error: UPLOAD_DENIED };
  const problem = validateImageFile({ type: mimeType, size: sizeBytes });
  if (problem) return { ok: false, error: problem };
  const { data, error, response } = await requestImageUpload(mimeType, sizeBytes);
  if (!data) return { ok: false, error: errorOf(error, response).message };
  const { id, uploadUrl, headers } = data.data;
  return { ok: true, ticket: { id, uploadUrl, headers } };
}

/** Step 3 of an image upload: tell the API the bytes arrived. */
export async function completeImageUploadAction(mediaId: string): Promise<ArticleResult> {
  if (!(await allowed('media.manage'))) return { ok: false, error: UPLOAD_DENIED };
  const { error, response } = await completeUpload(mediaId);
  if (!response.ok) return { ok: false, error: errorOf(error, response).message };
  return { ok: true };
}
