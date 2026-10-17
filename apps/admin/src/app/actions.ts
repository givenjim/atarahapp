'use server';

import { redirect } from 'next/navigation';
import { revalidatePath } from 'next/cache';
import { anonymousApi, api, errorOf, needsReauth } from '@/lib/api';
import {
  clearSessionCookies,
  readChallenge,
  setChallengeCookie,
  setSessionCookies,
  accessToken,
  clearRecoveryCookie,
  setRecoveryCookie,
} from '@/lib/session';

export interface FormState {
  error?: string;
}

const PASSWORD_STEP_FAILED = 'That email and password do not match an administrator account.';

export async function loginAction(_: FormState, formData: FormData): Promise<FormState> {
  const email = String(formData.get('email') ?? '').trim();
  const password = String(formData.get('password') ?? '');
  if (!email || !password) return { error: 'Enter your email and password.' };

  const { data, error, response } = await anonymousApi().POST('/api/v1/admin/auth/login', {
    body: { email, password },
  });
  if (!data) {
    const e = errorOf(error, response);
    return {
      error: e.status === 429 ? e.message : e.status === 401 ? PASSWORD_STEP_FAILED : e.message,
    };
  }
  await setChallengeCookie(data.data.challengeToken, data.data.step);
  redirect('/login/totp');
}

export async function totpAction(_: FormState, formData: FormData): Promise<FormState> {
  const challenge = await readChallenge();
  if (!challenge) redirect('/login');
  const code = String(formData.get('code') ?? '').trim();
  const recovery = String(formData.get('recoveryCode') ?? '')
    .trim()
    .toUpperCase();
  if (!code && !recovery) return { error: 'Enter the 6-digit code from your authenticator app.' };

  const { data, error, response } = await anonymousApi().POST('/api/v1/admin/auth/totp/verify', {
    body: {
      challengeToken: challenge.token,
      ...(code ? { code } : { recoveryCode: recovery }),
    },
  });
  if (!data) {
    const e = errorOf(error, response);
    // An expired challenge cannot be retried: start again from the password step.
    if (e.status === 401 && e.code === 'AUTHENTICATION_REQUIRED') redirect('/login');
    return { error: e.message };
  }
  await setSessionCookies(data.data);
  if (data.data.recoveryCodes?.length) {
    await setRecoveryCookie(data.data.recoveryCodes);
    redirect('/login/recovery');
  }
  redirect('/');
}

export async function recoveryAcknowledgedAction(): Promise<void> {
  await clearRecoveryCookie();
  redirect('/');
}

export async function logoutAction(): Promise<void> {
  if (await accessToken()) await api().POST('/api/v1/admin/auth/logout');
  await clearSessionCookies();
  redirect('/login');
}

export type ActionResult =
  | { ok: true }
  | { ok: false; reauth: true; error: string }
  | { ok: false; reauth?: false; error: string };

export async function reauthAction(input: {
  password: string;
  code: string;
}): Promise<ActionResult> {
  const { error, response } = await api().POST('/api/v1/admin/auth/reauth', { body: input });
  if (response.ok) return { ok: true };
  return { ok: false, error: errorOf(error, response).message };
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
  return { ok: false, error: e.message };
}

export async function suspendUserAction(userId: string, reason: string): Promise<ActionResult> {
  return changeStatus(userId, 'suspend', reason);
}

export async function reactivateUserAction(userId: string, reason: string): Promise<ActionResult> {
  return changeStatus(userId, 'reactivate', reason);
}
