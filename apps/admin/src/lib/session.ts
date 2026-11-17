import 'server-only';
import { supabaseServer } from './supabase/server';

/**
 * Admin sessions are Supabase Auth sessions held in httpOnly cookies set by this Next server (the BFF,
 * DEC-018). The browser never sees a token. Mutations are Server Actions, which Next protects with an Origin
 * check, and the cookies are SameSite=Lax, so cross-site requests cannot ride the session.
 */
export async function accessToken(): Promise<string | undefined> {
  const supabase = await supabaseServer();
  // getSession refreshes an expired token; the API verifies the signature on every request.
  const { data } = await supabase.auth.getSession();
  return data.session?.access_token;
}
