import createClient, { type Middleware } from 'openapi-fetch';
import type { components, paths } from './schema';

export type { components, paths };
export type Schemas = components['schemas'];

/** Body of every error response from the API (`{ error: { code, message, details, requestId } }`). */
export interface ApiErrorBody {
  code: string;
  message: string;
  details?: Record<string, unknown>;
  requestId?: string;
}

export interface ApiClientOptions {
  /** Origin of the API, without `/api/v1`, e.g. `http://localhost:3000`. */
  baseUrl: string;
  /** Returns the bearer token for the request, if any. */
  getAccessToken?: () => string | undefined | Promise<string | undefined>;
  fetch?: typeof fetch;
}

/** Typed client for the Atarah REST API. Paths and bodies come from the generated OpenAPI schema. */
export function createApiClient(options: ApiClientOptions) {
  const client = createClient<paths>({
    // Paths in the generated schema already include the `/api/v1` prefix.
    baseUrl: options.baseUrl.replace(/\/$/, ''),
    fetch: options.fetch,
  });
  const auth: Middleware = {
    async onRequest({ request }) {
      const token = await options.getAccessToken?.();
      if (token) request.headers.set('Authorization', `Bearer ${token}`);
      if (!request.headers.has('X-Request-Id')) {
        request.headers.set('X-Request-Id', crypto.randomUUID());
      }
      return request;
    },
  };
  client.use(auth);
  return client;
}

export type ApiClient = ReturnType<typeof createApiClient>;

/** Pulls the error envelope out of a failed `openapi-fetch` result, with a safe fallback message. */
export function toApiError(error: unknown, status?: number): ApiErrorBody {
  const body = (error as { error?: ApiErrorBody } | undefined)?.error;
  if (body && typeof body.code === 'string') return body;
  return {
    code: status && status >= 500 ? 'INTERNAL_ERROR' : 'UNKNOWN_ERROR',
    message: 'Something went wrong. Please try again.',
  };
}
