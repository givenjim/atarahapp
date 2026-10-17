import 'server-only';
import { createApiClient, toApiError, type ApiErrorBody } from '@atarah/api-contracts';
import { accessToken } from './session';

export const apiBaseUrl = (): string => process.env.ATARAH_API_BASE_URL ?? 'http://localhost:3000';

/** Server-side API client. It sends the admin access token from the session cookie. */
export const api = () =>
  createApiClient({ baseUrl: apiBaseUrl(), getAccessToken: () => accessToken() });

/** Server-side client without a token, for the sign-in steps. */
export const anonymousApi = () => createApiClient({ baseUrl: apiBaseUrl() });

export type ActionError = ApiErrorBody & { status?: number };

export const errorOf = (error: unknown, response?: Response): ActionError => ({
  ...toApiError(error, response?.status),
  status: response?.status,
});

/** A 401 with this reason means the action needs a fresh password + code (the re-auth dialog). */
export const needsReauth = (e: ActionError): boolean =>
  e.status === 401 && (e.details as { reason?: string } | undefined)?.reason === 'REAUTH_REQUIRED';
