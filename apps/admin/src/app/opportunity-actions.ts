'use server';

import { redirect } from 'next/navigation';
import { revalidatePath } from 'next/cache';
import { errorOf, needsReauth, sessionRedirectFor } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import {
  commitImport,
  createOpportunity,
  createProvider,
  featureOpportunity,
  previewImport,
  rejectOpportunity,
  setOpportunityTrust,
  transitionOpportunity,
  updateOpportunity,
  updateProvider,
  verifyOpportunity,
  verifyProvider,
  type ImportCommitResult,
  type ImportReport,
  type Transition,
} from '@/lib/opportunities-api';
import {
  canVerify,
  IMPORT_MAX_BYTES,
  opportunityMessage,
  providerPayload,
  toPayload,
  validateOppForm,
  validateProvider,
  type OppForm,
  type ProviderForm,
} from '@/lib/opportunities';
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
  return { ok: false, error: opportunityMessage(e.status, e.message) };
}

const LIST = ['/opportunities'];
const AUDIT = '/audit-logs';

export type SavedResult = ActionResult & { id?: string };

export async function saveOpportunityAction(
  id: string | null,
  form: OppForm,
): Promise<SavedResult> {
  if (!(await holds('opportunity.manage'))) return { ok: false, error: DENIED };
  const mode = id ? 'edit' : 'create';
  const problem = validateOppForm(form, mode);
  if (problem) return { ok: false, error: problem };
  const body = toPayload(form, mode);
  const res = id ? await updateOpportunity(id, body) : await createOpportunity(body);
  const out = settle(res.error, res.response, [...LIST, AUDIT]);
  return out.ok ? { ok: true, id: res.data?.data.id ?? id ?? undefined } : out;
}

/** Remove needs a fresh authenticator check; the others do not. */
export async function transitionOpportunityAction(
  id: string,
  verb: Transition,
): Promise<ActionResult> {
  if (!(await holds('opportunity.manage'))) return { ok: false, error: DENIED };
  const { error, response } = await transitionOpportunity(id, verb);
  return settle(error, response, [...LIST, AUDIT]);
}

export async function rejectOpportunityAction(id: string, reason: string): Promise<ActionResult> {
  if (!(await holds('opportunity.manage'))) return { ok: false, error: DENIED };
  if (reason.trim().length < 3) return { ok: false, error: 'Tell the provider what to change.' };
  const { error, response } = await rejectOpportunity(id, reason.trim());
  return settle(error, response, [...LIST, AUDIT]);
}

/** `until` is an ISO time, or null to remove the feature. */
export async function featureOpportunityAction(
  id: string,
  until: string | null,
): Promise<ActionResult> {
  if (!(await holds('opportunity.manage'))) return { ok: false, error: DENIED };
  if (until && new Date(until).getTime() <= Date.now())
    return { ok: false, error: 'Pick a time in the future.' };
  const { error, response } = await featureOpportunity(id, until);
  return settle(error, response, [...LIST, AUDIT]);
}

export async function setTrustAction(
  id: string,
  trust: string,
  reason: string,
): Promise<ActionResult> {
  if (!(await holds('opportunity.manage'))) return { ok: false, error: DENIED };
  if (trust === 'VERIFIED') return { ok: false, error: 'Use Verify for Verified by Atarah.' };
  const { error, response } = await setOpportunityTrust(id, trust, reason.trim() || undefined);
  return settle(error, response, [...LIST, AUDIT]);
}

/** Verified by Atarah: needs `opportunity.verify` and a fresh authenticator check. */
export async function verifyOpportunityAction(id: string, reason: string): Promise<ActionResult> {
  const me = await currentAdmin();
  if (!can(me.permissions, 'opportunity.manage') || !canVerify(me.permissions))
    return { ok: false, error: DENIED };
  const { error, response } = await verifyOpportunity(id, reason.trim() || undefined);
  return settle(error, response, [...LIST, AUDIT]);
}

export async function saveProviderAction(
  id: string | null,
  form: ProviderForm,
): Promise<ActionResult> {
  if (!(await holds('opportunity.manage'))) return { ok: false, error: DENIED };
  const problem = validateProvider(form);
  if (problem) return { ok: false, error: problem };
  const body = providerPayload(form, id ? 'edit' : 'create');
  const res = id ? await updateProvider(id, body) : await createProvider(body);
  return settle(res.error, res.response, ['/opportunities/providers', ...LIST, AUDIT]);
}

/** Verify, reject or revoke a provider. Needs `opportunity.verify` and a fresh authenticator check. */
export async function verifyProviderAction(
  id: string,
  status: 'VERIFIED' | 'REJECTED' | 'REVOKED',
  reason: string,
): Promise<ActionResult> {
  const me = await currentAdmin();
  if (!can(me.permissions, 'opportunity.manage') || !canVerify(me.permissions))
    return { ok: false, error: DENIED };
  const { error, response } = await verifyProvider(id, status, reason.trim() || undefined);
  return settle(error, response, ['/opportunities/providers', ...LIST, AUDIT]);
}

export type PreviewResult = { ok: true; report: ImportReport } | { ok: false; error: string };

export async function previewImportAction(csv: string): Promise<PreviewResult> {
  if (!(await holds('opportunity.manage'))) return { ok: false, error: DENIED };
  if (csv.trim().length < 10) return { ok: false, error: 'Choose a CSV file or paste its rows.' };
  if (new Blob([csv]).size > IMPORT_MAX_BYTES)
    return { ok: false, error: 'That file is too large (1 MB at most).' };
  const { data, error, response } = await previewImport(csv);
  if (data) return { ok: true, report: data.data };
  const out = settle(error, response, []);
  return { ok: false, error: out.ok ? 'Could not check the file.' : out.error };
}

export type CommitResult = { ok: true; result: ImportCommitResult } | { ok: false; error: string };

/** Creates the valid rows as drafts. An import never publishes. */
export async function commitImportAction(csv: string): Promise<CommitResult> {
  if (!(await holds('opportunity.manage'))) return { ok: false, error: DENIED };
  const { data, error, response } = await commitImport(csv);
  if (data) {
    for (const p of [...LIST, AUDIT]) revalidatePath(p, 'layout');
    return { ok: true, result: data.data };
  }
  const out = settle(error, response, []);
  return { ok: false, error: out.ok ? 'Could not import the file.' : out.error };
}
