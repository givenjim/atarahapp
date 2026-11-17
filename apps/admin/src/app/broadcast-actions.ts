'use server';

import { redirect } from 'next/navigation';
import { revalidatePath } from 'next/cache';
import { errorOf, needsReauth, sessionRedirectFor } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import {
  audienceBody,
  broadcastMessage,
  toBroadcastPayload,
  validateBroadcastForm,
  type BroadcastForm,
} from '@/lib/broadcasts';
import { cancelBroadcast, createBroadcast, previewAudience } from '@/lib/broadcasts-api';
import type { ActionResult } from '@/app/actions';

const DENIED = 'You do not have permission to do that.';
const LIST = '/notifications';

async function allowed(): Promise<boolean> {
  const me = await currentAdmin();
  return can(me.permissions, 'notification.broadcast');
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
  return { ok: false, error: broadcastMessage(e.status, e.message) };
}

export type AudienceResult = { ok: true; recipients: number } | { ok: false; error: string };

/** How many members a target would reach. Needs no authenticator code. */
export async function previewAudienceAction(
  target: BroadcastForm['target'],
  targetValue: string,
): Promise<AudienceResult> {
  if (!(await allowed())) return { ok: false, error: DENIED };
  if (target !== 'ALL' && !targetValue)
    return { ok: false, error: 'Choose who should get it first.' };
  const { data, error, response } = await previewAudience(audienceBody({ target, targetValue }));
  if (response.ok && data) return { ok: true, recipients: data.data.recipients };
  const e = errorOf(error, response);
  const gone = sessionRedirectFor(e);
  if (gone) redirect(gone);
  return { ok: false, error: broadcastMessage(e.status, e.message) };
}

export type CreatedResult = ActionResult & { id?: string };

/** Send or schedule. Messaging members cannot be undone once sent, so the API asks for a fresh authenticator code. */
export async function createBroadcastAction(form: BroadcastForm): Promise<CreatedResult> {
  if (!(await allowed())) return { ok: false, error: DENIED };
  const problem = validateBroadcastForm(form);
  if (problem) return { ok: false, error: problem };
  const res = await createBroadcast(toBroadcastPayload(form));
  const out = settle(res.error, res.response, [LIST, '/audit-logs']);
  return out.ok ? { ok: true, id: res.data?.data.id } : out;
}

export async function cancelBroadcastAction(id: string): Promise<ActionResult> {
  if (!(await allowed())) return { ok: false, error: DENIED };
  const { error, response } = await cancelBroadcast(id);
  return settle(error, response, [LIST, '/audit-logs']);
}
