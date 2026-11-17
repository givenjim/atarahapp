import 'server-only';
import { createServerClient } from '@supabase/ssr';
import { cookies } from 'next/headers';
import { hardenCookie, supabaseConfig } from './config';

/**
 * Supabase client for Server Components, Server Actions and route handlers. It is used for Auth only; all
 * data goes through the NestJS API (Master Prompt 5.7 rule 1). In a Server Component cookies cannot be
 * written, which is fine: the proxy has already refreshed the session for the request.
 */
export async function supabaseServer() {
  const jar = await cookies();
  const { url, publishableKey } = supabaseConfig();
  return createServerClient(url, publishableKey, {
    cookies: {
      getAll: () => jar.getAll(),
      setAll: (list) => {
        try {
          for (const { name, value, options } of list) jar.set(name, value, hardenCookie(options));
        } catch {
          // Called from a Server Component: ignored, the proxy refreshes the session.
        }
      },
    },
  });
}
