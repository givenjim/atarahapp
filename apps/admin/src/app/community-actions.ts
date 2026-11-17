'use server';

import { redirect } from 'next/navigation';
import { revalidatePath } from 'next/cache';
import { errorOf, needsReauth, sessionRedirectFor } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import {
  addGroupModerator,
  archiveGroup,
  assignCase,
  createAnnouncement,
  createGroup,
  decideCase,
  pinGroupPost,
  removeGroupModerator,
  unpinGroupPost,
  updateGroup,
} from '@/lib/moderation-api';
import {
  communityMessage,
  isUuid,
  validateAnnouncement,
  validateDecision,
  validateGroup,
} from '@/lib/moderation';
import type { ActionResult } from '@/app/actions';

const DENIED = 'You do not have permission to do that.';

/** The backend enforces these on every call; checking here only gives a clearer answer sooner. */
async function holds(...permissions: string[]): Promise<boolean> {
  const me = await currentAdmin();
  return permissions.every((p) => can(me.permissions, p));
}

/** Turns an API response into an action result: a stale authenticator check asks for the code again. */
function settle(error: unknown, response: Response, paths: string[]): ActionResult {
  if (response.ok) {
    for (const p of paths) revalidatePath(p, 'layout');
    return { ok: true };
  }
  const e = errorOf(error, response);
  if (needsReauth(e)) return { ok: false, reauth: true, error: e.message };
  const gone = sessionRedirectFor(e);
  if (gone) redirect(gone);
  return { ok: false, error: communityMessage(e.status, e.message) };
}

const CASES = ['/community'];
const GROUPS = ['/groups'];

export async function assignCaseAction(
  caseId: string,
  assigneeId: string | null,
): Promise<ActionResult> {
  if (!(await holds('report.resolve'))) return { ok: false, error: DENIED };
  const { error, response } = await assignCase(caseId, assigneeId);
  return settle(error, response, CASES);
}

/** SUSPEND_ACCOUNT needs a fresh authenticator check (the API answers REAUTH_REQUIRED). */
export async function decideCaseAction(
  caseId: string,
  action: string,
  reason: string,
  restrictDays?: number,
): Promise<ActionResult> {
  const needed = ['report.resolve', 'moderation.act'];
  if (action === 'SUSPEND_ACCOUNT') needed.push('user.suspend');
  if (!(await holds(...needed))) return { ok: false, error: DENIED };
  const problem = validateDecision({ action, reason, restrictDays });
  if (problem) return { ok: false, error: problem };
  const body: { action: string; reason?: string; restrictDays?: number } = { action };
  if (reason.trim()) body.reason = reason.trim();
  if (action === 'RESTRICT_ACCOUNT' && restrictDays) body.restrictDays = restrictDays;
  const { error, response } = await decideCase(caseId, body);
  return settle(error, response, [...CASES, '/users', '/audit-logs']);
}

export interface GroupFormInput {
  name: string;
  slug?: string;
  type?: string;
  description: string;
  visibility: string;
  isOfficial: boolean;
}

export async function createGroupAction(input: GroupFormInput): Promise<ActionResult> {
  if (!(await holds('community.group.manage'))) return { ok: false, error: DENIED };
  const problem = validateGroup(input, true);
  if (problem) return { ok: false, error: problem };
  const body: Record<string, unknown> = {
    name: input.name.trim(),
    type: input.type,
    description: input.description.trim(),
    visibility: input.visibility,
    isOfficial: input.isOfficial,
  };
  if (input.slug?.trim()) body.slug = input.slug.trim();
  const { error, response } = await createGroup(body);
  return settle(error, response, GROUPS);
}

export async function updateGroupAction(id: string, input: GroupFormInput): Promise<ActionResult> {
  if (!(await holds('community.group.manage'))) return { ok: false, error: DENIED };
  const problem = validateGroup(input, false);
  if (problem) return { ok: false, error: problem };
  const { error, response } = await updateGroup(id, {
    name: input.name.trim(),
    description: input.description.trim(),
    visibility: input.visibility,
    isOfficial: input.isOfficial,
  });
  return settle(error, response, GROUPS);
}

/** Needs a fresh authenticator check. */
export async function archiveGroupAction(id: string): Promise<ActionResult> {
  if (!(await holds('community.group.manage'))) return { ok: false, error: DENIED };
  const { error, response } = await archiveGroup(id);
  return settle(error, response, [...GROUPS, '/audit-logs']);
}

export async function addModeratorAction(
  groupId: string,
  userId: string,
  role: string,
): Promise<ActionResult> {
  if (!(await holds('community.group.manage'))) return { ok: false, error: DENIED };
  if (!isUuid(userId)) return { ok: false, error: 'Enter the member’s user id (a UUID).' };
  const { error, response } = await addGroupModerator(groupId, userId.trim(), role);
  return settle(error, response, GROUPS);
}

export async function removeModeratorAction(
  groupId: string,
  userId: string,
): Promise<ActionResult> {
  if (!(await holds('community.group.manage'))) return { ok: false, error: DENIED };
  const { error, response } = await removeGroupModerator(groupId, userId);
  return settle(error, response, GROUPS);
}

export async function pinPostAction(groupId: string, postId: string): Promise<ActionResult> {
  if (!(await holds('community.group.manage'))) return { ok: false, error: DENIED };
  if (!isUuid(postId)) return { ok: false, error: 'Enter the post id (a UUID).' };
  const { error, response } = await pinGroupPost(groupId, postId.trim());
  return settle(error, response, GROUPS);
}

export async function unpinPostAction(groupId: string, postId: string): Promise<ActionResult> {
  if (!(await holds('community.group.manage'))) return { ok: false, error: DENIED };
  const { error, response } = await unpinGroupPost(groupId, postId);
  return settle(error, response, GROUPS);
}

/** Needs a fresh authenticator check. */
export async function createAnnouncementAction(
  body: string,
  groupId: string,
): Promise<ActionResult> {
  if (!(await holds('community.announce'))) return { ok: false, error: DENIED };
  const problem = validateAnnouncement(body, groupId);
  if (problem) return { ok: false, error: problem };
  const { error, response } = await createAnnouncement({
    body: body.trim(),
    ...(groupId ? { groupId } : {}),
  });
  return settle(error, response, ['/announcements', '/audit-logs']);
}
