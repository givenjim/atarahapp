'use server';

import { redirect } from 'next/navigation';
import { revalidatePath } from 'next/cache';
import { api, errorOf, needsReauth, sessionRedirectFor } from '@/lib/api';
import { mfaStep, reauthenticate, signInWithPassword, verifyCode } from '@/lib/mfa';
import { supabaseServer } from '@/lib/supabase/server';

export interface FormState {
  error?: string;
}

export async function loginAction(_: FormState, formData: FormData): Promise<FormState> {
  const email = String(formData.get('email') ?? '').trim();
  const password = String(formData.get('password') ?? '');

  const supabase = await supabaseServer();
  const result = await signInWithPassword(supabase, email, password);
  if (!result.ok) return { error: result.error };
  // The code page decides between "enter your code" and "set up your authenticator".
  redirect('/login/totp');
}

/** Verifies the code for sign-in or for the authenticator just enrolled. Success is an AAL2 session. */
export async function totpAction(_: FormState, formData: FormData): Promise<FormState> {
  const factorId = String(formData.get('factorId') ?? '');
  const supabase = await supabaseServer();
  const step = await mfaStep(supabase);
  if (step.step === 'login') redirect('/login?reason=expired');
  if (step.step === 'done') redirect('/');
  if (!factorId) redirect('/login/totp');

  const result = await verifyCode(supabase, factorId, String(formData.get('code') ?? ''));
  if (!result.ok) return { error: result.error };
  redirect('/');
}

export async function logoutAction(): Promise<void> {
  const supabase = await supabaseServer();
  await supabase.auth.signOut();
  redirect('/login');
}

export type ActionResult =
  | { ok: true }
  | { ok: false; reauth: true; error: string }
  | { ok: false; reauth?: false; error: string };

/**
 * Re-authentication: verify the user's authenticator again. The refreshed session cookies carry the new
 * access token, which the retried request sends.
 */
export async function reauthAction(input: { code: string }): Promise<ActionResult> {
  const supabase = await supabaseServer();
  const result = await reauthenticate(supabase, input.code);
  return result.ok ? { ok: true } : { ok: false, error: result.error };
}

async function changeStatus(
  userId: string,
  verb: 'suspend' | 'reactivate',
  reason: string,
): Promise<ActionResult> {
  const client = api();
  const params = { path: { id: userId } };
  const { error, response } =
    verb === 'suspend'
      ? await client.POST('/api/v1/admin/users/{id}/suspend', { params, body: { reason } })
      : await client.POST('/api/v1/admin/users/{id}/reactivate', { params, body: { reason } });
  if (response.ok) {
    revalidatePath('/users');
    revalidatePath(`/users/${userId}`);
    revalidatePath('/audit-logs');
    return { ok: true };
  }
  const e = errorOf(error, response);
  if (needsReauth(e)) return { ok: false, reauth: true, error: e.message };
  const gone = sessionRedirectFor(e);
  if (gone) redirect(gone);
  return { ok: false, error: e.message };
}

export async function suspendUserAction(userId: string, reason: string): Promise<ActionResult> {
  return changeStatus(userId, 'suspend', reason);
}

export async function reactivateUserAction(userId: string, reason: string): Promise<ActionResult> {
  return changeStatus(userId, 'reactivate', reason);
}
