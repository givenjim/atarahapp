'use server';

import { redirect } from 'next/navigation';
import { revalidatePath } from 'next/cache';
import { errorOf, needsReauth, sessionRedirectFor } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import {
  changeSellerStatus,
  createCategory,
  decideListing,
  featureListing,
  moderateReview,
  resolveReport,
  setDirectPublish,
  updateCategory,
  type CategoryInput,
  type ListingVerb,
} from '@/lib/marketplace-api';
import { isCategoryTone, marketplaceMessage, reasonProblem } from '@/lib/marketplace';
import type { ActionResult } from '@/app/actions';

const DENIED = 'You do not have permission to do that.';

async function allowed(permission: string): Promise<boolean> {
  const me = await currentAdmin();
  return can(me.permissions, permission);
}

/** An API response as an action result: a stale authenticator check asks for the code again. */
function settle(error: unknown, response: Response): ActionResult {
  if (response.ok) {
    revalidatePath('/marketplace', 'layout');
    revalidatePath('/audit-logs', 'layout');
    return { ok: true };
  }
  const e = errorOf(error, response);
  if (needsReauth(e)) return { ok: false, reauth: true, error: e.message };
  const gone = sessionRedirectFor(e);
  if (gone) redirect(gone);
  return { ok: false, error: marketplaceMessage(e.status, e.message) };
}

export async function listingDecisionAction(
  id: string,
  verb: ListingVerb,
  reason: string,
): Promise<ActionResult> {
  if (!(await allowed('marketplace.manage'))) return { ok: false, error: DENIED };
  if (verb !== 'approve') {
    const problem = reasonProblem(reason);
    if (problem) return { ok: false, error: problem };
  }
  const { error, response } = await decideListing(id, verb, reason.trim() || undefined);
  return settle(error, response);
}

export async function featureListingAction(id: string, until: string | null): Promise<ActionResult> {
  if (!(await allowed('marketplace.manage'))) return { ok: false, error: DENIED };
  const { error, response } = await featureListing(id, until);
  return settle(error, response);
}

/** Suspending a seller hides their live listings, so the API asks for a fresh authenticator code. */
export async function sellerStatusAction(
  id: string,
  verb: 'suspend' | 'reinstate',
  reason: string,
): Promise<ActionResult> {
  if (!(await allowed('seller.manage'))) return { ok: false, error: DENIED };
  const problem = reasonProblem(reason);
  if (problem) return { ok: false, error: problem };
  const { error, response } = await changeSellerStatus(id, verb, reason.trim());
  return settle(error, response);
}

export async function directPublishAction(id: string, value: boolean): Promise<ActionResult> {
  if (!(await allowed('seller.manage'))) return { ok: false, error: DENIED };
  const { error, response } = await setDirectPublish(id, value);
  return settle(error, response);
}

export async function resolveReportAction(
  id: string,
  action: 'DISMISS' | 'SUSPEND_LISTING',
  note: string,
): Promise<ActionResult> {
  if (!(await allowed('marketplace.manage'))) return { ok: false, error: DENIED };
  const problem = reasonProblem(note);
  if (problem) return { ok: false, error: problem };
  const { error, response } = await resolveReport(id, action, note.trim());
  return settle(error, response);
}

export async function reviewModerationAction(
  id: string,
  verb: 'hide' | 'restore',
  reason: string,
): Promise<ActionResult> {
  if (!(await allowed('marketplace.manage'))) return { ok: false, error: DENIED };
  const problem = reasonProblem(reason);
  if (problem) return { ok: false, error: problem };
  const { error, response } = await moderateReview(id, verb, reason.trim());
  return settle(error, response);
}

function categoryProblem(input: Partial<CategoryInput>): string | null {
  if (input.name !== undefined && input.name.trim().length < 2) return 'Give the category a name.';
  if (input.icon !== undefined && input.icon.trim().length < 2) return 'Enter a Lucide icon name.';
  if (input.tone !== undefined && !isCategoryTone(input.tone)) return 'Pick one of the tones.';
  return null;
}

export async function createCategoryAction(input: CategoryInput): Promise<ActionResult> {
  if (!(await allowed('category.manage'))) return { ok: false, error: DENIED };
  const problem = categoryProblem(input);
  if (problem) return { ok: false, error: problem };
  const { error, response } = await createCategory(input);
  return settle(error, response);
}

export async function updateCategoryAction(
  id: string,
  input: Partial<CategoryInput>,
): Promise<ActionResult> {
  if (!(await allowed('category.manage'))) return { ok: false, error: DENIED };
  const problem = categoryProblem(input);
  if (problem) return { ok: false, error: problem };
  const { error, response } = await updateCategory(id, input);
  return settle(error, response);
}
