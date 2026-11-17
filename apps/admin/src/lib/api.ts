import 'server-only';
import { createApiClient, toApiError, type ApiErrorBody } from '@atarah/api-contracts';
import { sessionProblemOf, sessionRedirect, type SessionProblem } from './auth-errors';
import { accessToken } from './session';

export const apiBaseUrl = (): string => process.env.ATARAH_API_BASE_URL ?? 'http://localhost:3000';

/** Server-side API client. It sends the admin access token from the session cookie. */
export const api = () =>
  createApiClient({ baseUrl: apiBaseUrl(), getAccessToken: () => accessToken() });

export type ActionError = ApiErrorBody & { status?: number };

export const errorOf = (error: unknown, response?: Response): ActionError => ({
  ...toApiError(error, response?.status),
  status: response?.status,
});

/** The API's reason for turning the session away (error.details.reason), if it gave one. */
export const problemOf = (e: ActionError): SessionProblem | null => sessionProblemOf(e.details);

/** A 401 with this reason means the action needs the authenticator code again (the re-auth dialog). */
export const needsReauth = (e: ActionError): boolean =>
  e.status === 401 && problemOf(e) === 'REAUTH_REQUIRED';

/** Where to send a session the API rejected (null when the error is about the request, not the session). */
export const sessionRedirectFor = (e: ActionError): string | null =>
  sessionRedirect(e.status, e.details);
