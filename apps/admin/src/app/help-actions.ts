'use server';

import { redirect } from 'next/navigation';
import { revalidatePath } from 'next/cache';
import { errorOf, needsReauth, sessionRedirectFor } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import {
  createFaq,
  createHelpArticle,
  createLegalVersion,
  deleteFaq,
  deleteHelpArticle,
  publishLegal,
  updateFaq,
  updateHelpArticle,
  updateLegalDraft,
} from '@/lib/help-api';
import {
  effectiveAtToIso,
  faqPayload,
  helpArticlePayload,
  helpMessage,
  legalPayload,
  validateFaq,
  validateHelpArticle,
  validateLegalForm,
  type FaqForm,
  type HelpArticleForm,
  type LegalForm,
} from '@/lib/help';
import type { ActionResult } from '@/app/actions';

const DENIED = 'You do not have permission to do that.';

async function holds(permission: string): Promise<boolean> {
  const me = await currentAdmin();
  return can(me.permissions, permission);
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
  return { ok: false, error: helpMessage(e.status, e.message) };
}

const HELP = '/content';
const FAQ = '/content/faq';
const LEGAL = '/content/legal';
const AUDIT = '/audit-logs';

export type SavedResult = ActionResult & { id?: string };

// ---- help articles ----

export async function saveHelpArticleAction(
  id: string | null,
  form: HelpArticleForm,
): Promise<SavedResult> {
  if (!(await holds('help.manage'))) return { ok: false, error: DENIED };
  const mode = id ? 'edit' : 'create';
  const problem = validateHelpArticle(form, mode);
  if (problem) return { ok: false, error: problem };
  const body = helpArticlePayload(form, mode);
  const res = id ? await updateHelpArticle(id, body) : await createHelpArticle(body);
  const out = settle(res.error, res.response, [HELP, AUDIT]);
  return out.ok ? { ok: true, id: res.data?.data.id ?? id ?? undefined } : out;
}

export async function setHelpArticlePublishedAction(
  id: string,
  published: boolean,
): Promise<ActionResult> {
  if (!(await holds('help.manage'))) return { ok: false, error: DENIED };
  const { error, response } = await updateHelpArticle(id, { published });
  return settle(error, response, [HELP, AUDIT]);
}

/** Moves an article by swapping the sort order with its neighbour (two updates computed by the caller). */
export async function reorderHelpArticlesAction(
  updates: Array<{ id: string; sortOrder: number }>,
): Promise<ActionResult> {
  if (!(await holds('help.manage'))) return { ok: false, error: DENIED };
  for (const u of updates) {
    const { error, response } = await updateHelpArticle(u.id, { sortOrder: u.sortOrder });
    if (!response.ok) return settle(error, response, [HELP]);
  }
  return settle(undefined, new Response(null, { status: 200 }), [HELP]);
}

export async function deleteHelpArticleAction(id: string): Promise<ActionResult> {
  if (!(await holds('help.manage'))) return { ok: false, error: DENIED };
  const { error, response } = await deleteHelpArticle(id);
  return settle(error, response, [HELP, AUDIT]);
}

// ---- FAQ ----

export async function saveFaqAction(
  id: string | null,
  form: FaqForm,
  sortOrder?: number,
): Promise<ActionResult> {
  if (!(await holds('help.manage'))) return { ok: false, error: DENIED };
  const problem = validateFaq(form);
  if (problem) return { ok: false, error: problem };
  const body = faqPayload(form, id ? undefined : sortOrder);
  const { error, response } = id ? await updateFaq(id, body) : await createFaq(body);
  return settle(error, response, [FAQ, AUDIT]);
}

export async function setFaqPublishedAction(id: string, published: boolean): Promise<ActionResult> {
  if (!(await holds('help.manage'))) return { ok: false, error: DENIED };
  const { error, response } = await updateFaq(id, { published });
  return settle(error, response, [FAQ, AUDIT]);
}

export async function reorderFaqAction(
  updates: Array<{ id: string; sortOrder: number }>,
): Promise<ActionResult> {
  if (!(await holds('help.manage'))) return { ok: false, error: DENIED };
  for (const u of updates) {
    const { error, response } = await updateFaq(u.id, { sortOrder: u.sortOrder });
    if (!response.ok) return settle(error, response, [FAQ]);
  }
  return settle(undefined, new Response(null, { status: 200 }), [FAQ]);
}

export async function deleteFaqAction(id: string): Promise<ActionResult> {
  if (!(await holds('help.manage'))) return { ok: false, error: DENIED };
  const { error, response } = await deleteFaq(id);
  return settle(error, response, [FAQ, AUDIT]);
}

// ---- legal documents ----

export async function saveLegalAction(id: string | null, form: LegalForm): Promise<SavedResult> {
  if (!(await holds('legal.manage'))) return { ok: false, error: DENIED };
  const mode = id ? 'edit' : 'create';
  const problem = validateLegalForm(form, mode);
  if (problem) return { ok: false, error: problem };
  const body = legalPayload(form, mode);
  const res = id ? await updateLegalDraft(id, body) : await createLegalVersion(body);
  const out = settle(res.error, res.response, [LEGAL, AUDIT]);
  return out.ok ? { ok: true, id: res.data?.data.id ?? id ?? undefined } : out;
}

/**
 * Publishing changes what every member agrees to, so the API asks for a fresh authenticator code. The previous
 * published version is archived by the API. `effectiveLocal` is a datetime-local value in Nairobi time, or blank for now.
 */
export async function publishLegalAction(
  id: string,
  effectiveLocal: string,
): Promise<ActionResult> {
  if (!(await holds('legal.manage'))) return { ok: false, error: DENIED };
  const iso = effectiveAtToIso(effectiveLocal);
  if (iso === null) return { ok: false, error: 'That is not a valid date and time.' };
  const { error, response } = await publishLegal(id, iso);
  return settle(error, response, [LEGAL, AUDIT]);
}
