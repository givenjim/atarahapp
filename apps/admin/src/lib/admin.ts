import 'server-only';
import { redirect } from 'next/navigation';
import { cache } from 'react';
import { api, errorOf, sessionRedirectFor } from './api';
import { accessToken } from './session';

/** The signed-in administrator and their effective permissions, fetched once per request. */
export const currentAdmin = cache(async () => {
  if (!(await accessToken())) redirect('/login');
  const { data, error, response } = await api().GET('/api/v1/admin/auth/me');
  if (!data) {
    // 401/403: MFA_REQUIRED goes to the code step; idle, not-staff and ended sessions sign in again.
    if (response.status === 401 || response.status === 403) {
      const e = errorOf(error, response);
      redirect(sessionRedirectFor(e) ?? '/auth/exit?reason=expired');
    }
    throw new Error(`Could not load the administrator profile (${response.status}).`);
  }
  return data.data;
});

export const can = (permissions: readonly string[], permission: string): boolean =>
  permissions.includes(permission);
