'use server';

import { redirect } from 'next/navigation';
import { revalidatePath } from 'next/cache';
import { errorOf, needsReauth, sessionRedirectFor } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import {
  coerceSetting,
  opsMessage,
  ROLE_REASON_MAX,
  settingKind,
  suspendPayload,
  validateSuspend,
  type SettingValue,
  type SuspendForm,
} from '@/lib/ops';
import { assignRole, retryJob, revokeRole, setFlag, setSetting, suspendUser } from '@/lib/ops-api';
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
  return { ok: false, error: opsMessage(e.status, e.message) };
}

export async function assignRoleAction(
  userId: string,
  role: string,
  reason: string,
): Promise<ActionResult> {
  if (!(await holds('role.assign'))) return { ok: false, error: DENIED };
  if (!role) return { ok: false, error: 'Choose a role.' };
  if (reason.length > ROLE_REASON_MAX)
    return { ok: false, error: `The reason can be up to ${ROLE_REASON_MAX} characters.` };
  const { error, response } = await assignRole(userId, {
    role,
    ...(reason.trim() ? { reason: reason.trim() } : {}),
  });
  return settle(error, response, [`/users/${userId}`, '/audit-logs']);
}

export async function revokeRoleAction(
  userId: string,
  role: string,
  reason: string,
): Promise<ActionResult> {
  if (!(await holds('role.assign'))) return { ok: false, error: DENIED };
  if (reason.length > ROLE_REASON_MAX)
    return { ok: false, error: `The reason can be up to ${ROLE_REASON_MAX} characters.` };
  const { error, response } = await revokeRole(userId, role, reason.trim() || undefined);
  return settle(error, response, [`/users/${userId}`, '/audit-logs']);
}

/** Suspends with a reason and, optionally, a number of days after which the account is reactivated automatically. */
export async function suspendTimedAction(userId: string, form: SuspendForm): Promise<ActionResult> {
  if (!(await holds('user.suspend'))) return { ok: false, error: DENIED };
  const problem = validateSuspend(form);
  if (problem) return { ok: false, error: problem };
  const { error, response } = await suspendUser(userId, suspendPayload(form));
  return settle(error, response, ['/users', `/users/${userId}`, '/audit-logs']);
}

export async function retryJobAction(queue: string, jobId: string): Promise<ActionResult> {
  if (!(await holds('settings.manage'))) return { ok: false, error: DENIED };
  const { error, response } = await retryJob(queue, jobId);
  return settle(error, response, ['/settings/jobs', '/', '/audit-logs']);
}

export async function setFlagAction(key: string, enabled: boolean): Promise<ActionResult> {
  if (!(await holds('settings.manage'))) return { ok: false, error: DENIED };
  const { error, response } = await setFlag(key, enabled);
  return settle(error, response, ['/settings', '/audit-logs']);
}

/** Changes an existing setting. The text is read as the kind the setting already holds; the API checks it again. */
export async function setSettingAction(
  key: string,
  currentValue: SettingValue,
  text: string,
): Promise<ActionResult> {
  if (!(await holds('settings.manage'))) return { ok: false, error: DENIED };
  const parsed = coerceSetting(settingKind(currentValue), text);
  if (!parsed.ok) return { ok: false, error: parsed.error };
  const { error, response } = await setSetting(key, { value: parsed.value });
  return settle(error, response, ['/settings', '/audit-logs']);
}
