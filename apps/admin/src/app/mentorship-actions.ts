'use server';

import { redirect } from 'next/navigation';
import { revalidatePath } from 'next/cache';
import { errorOf, needsReauth, sessionRedirectFor } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import {
  approveApplication,
  changeMentorStatus,
  featureMentor,
  rejectApplication,
  setSessionTypeDisabled,
  type MentorVerb,
} from '@/lib/mentorship-api';
import { mentorshipMessage, reasonProblem } from '@/lib/mentorship';
import type { ActionResult } from '@/app/actions';

const DENIED = 'You do not have permission to do that.';

async function allowed(): Promise<boolean> {
  const me = await currentAdmin();
  return can(me.permissions, 'mentor.manage');
}

/** An API response as an action result: a stale authenticator check asks for the code again. */
function settle(error: unknown, response: Response): ActionResult {
  if (response.ok) {
    revalidatePath('/mentorship', 'layout');
    revalidatePath('/audit-logs', 'layout');
    return { ok: true };
  }
  const e = errorOf(error, response);
  if (needsReauth(e)) return { ok: false, reauth: true, error: e.message };
  const gone = sessionRedirectFor(e);
  if (gone) redirect(gone);
  return { ok: false, error: mentorshipMessage(e.status, e.message) };
}

export async function approveApplicationAction(id: string, note: string): Promise<ActionResult> {
  if (!(await allowed())) return { ok: false, error: DENIED };
  const { error, response } = await approveApplication(id, note.trim() || undefined);
  return settle(error, response);
}

export async function rejectApplicationAction(id: string, reason: string): Promise<ActionResult> {
  if (!(await allowed())) return { ok: false, error: DENIED };
  const problem = reasonProblem(reason);
  if (problem) return { ok: false, error: problem };
  const { error, response } = await rejectApplication(id, reason.trim());
  return settle(error, response);
}

/** Removing a mentor revokes a role, so the API asks for a fresh authenticator code. */
export async function mentorStatusAction(
  id: string,
  verb: MentorVerb,
  reason: string,
): Promise<ActionResult> {
  if (!(await allowed())) return { ok: false, error: DENIED };
  const problem = reasonProblem(reason);
  if (problem) return { ok: false, error: problem };
  const { error, response } = await changeMentorStatus(id, verb, reason.trim());
  return settle(error, response);
}

export async function featureMentorAction(id: string, featured: boolean): Promise<ActionResult> {
  if (!(await allowed())) return { ok: false, error: DENIED };
  const { error, response } = await featureMentor(id, featured);
  return settle(error, response);
}

export async function sessionTypeDisabledAction(
  id: string,
  disabled: boolean,
  note: string,
): Promise<ActionResult> {
  if (!(await allowed())) return { ok: false, error: DENIED };
  const { error, response } = await setSessionTypeDisabled(id, disabled, note.trim() || undefined);
  return settle(error, response);
}
