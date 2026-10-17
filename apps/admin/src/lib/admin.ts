import 'server-only';
import { redirect } from 'next/navigation';
import { cache } from 'react';
import { api } from './api';
import { accessToken } from './session';

/** The signed-in administrator and their effective permissions, fetched once per request. */
export const currentAdmin = cache(async () => {
  if (!(await accessToken())) redirect('/login');
  const { data, response } = await api().GET('/api/v1/admin/auth/me');
  if (!data) {
    // 401/403: the session ended (idle timeout, suspension, role removed). Sign in again.
    if (response.status === 401 || response.status === 403) redirect('/login');
    throw new Error(`Could not load the administrator profile (${response.status}).`);
  }
  return data.data;
});

export const can = (permissions: readonly string[], permission: string): boolean =>
  permissions.includes(permission);
