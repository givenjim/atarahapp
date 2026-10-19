'use server';

import { revalidatePath } from 'next/cache';
import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import { hideAdminProject, restoreAdminProject } from '@/lib/portfolio-api';
import { moderationMessage, validateHideReason } from '@/lib/portfolio';

export type PortfolioResult = { ok: true } | { ok: false; error: string };

const DENIED = 'You do not have permission to moderate portfolios.';

/** The backend enforces `moderation.act` on every call; this only gives a clearer answer sooner. */
async function allowed(): Promise<boolean> {
  const me = await currentAdmin();
  return can(me.permissions, 'moderation.act');
}

export async function hideProjectAction(id: string, reason: string): Promise<PortfolioResult> {
  if (!(await allowed())) return { ok: false, error: DENIED };
  const problem = validateHideReason(reason);
  if (problem) return { ok: false, error: problem };
  const { error, response } = await hideAdminProject(id, reason.trim());
  if (!response.ok) {
    const e = errorOf(error, response);
    return { ok: false, error: moderationMessage(e.status, e.message, true) };
  }
  revalidatePath('/portfolio', 'layout');
  return { ok: true };
}

export async function restoreProjectAction(id: string): Promise<PortfolioResult> {
  if (!(await allowed())) return { ok: false, error: DENIED };
  const { error, response } = await restoreAdminProject(id);
  if (!response.ok) {
    const e = errorOf(error, response);
    return { ok: false, error: moderationMessage(e.status, e.message, false) };
  }
  revalidatePath('/portfolio', 'layout');
  return { ok: true };
}
