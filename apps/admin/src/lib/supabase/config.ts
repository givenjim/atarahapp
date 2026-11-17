/**
 * The only Supabase values the console knows: the project URL and the PUBLISHABLE key (safe to expose; it is
 * what the mobile app ships too). The service-role/secret key never appears in this app (Master Prompt 5.5).
 */
export function supabaseConfig(): { url: string; publishableKey: string } {
  // Read by name at run time (not inlined at build), so one build serves any environment. This code only
  // runs on the server; the browser never loads Supabase.
  const read = (name: string) => process.env[name];
  const url = read('NEXT_PUBLIC_SUPABASE_URL');
  const publishableKey = read('NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY');
  if (!url || !publishableKey) {
    throw new Error(
      'NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY must be set (see apps/admin/.env.example).',
    );
  }
  return { url, publishableKey };
}

/** Session cookies are httpOnly: the browser never runs Supabase code, so it never needs to read them. */
export const hardenCookie = <T extends object>(
  options: T,
): T & { httpOnly: true; sameSite: 'lax'; secure: boolean; path: '/' } => ({
  ...options,
  httpOnly: true,
  sameSite: 'lax',
  secure: process.env.NODE_ENV === 'production',
  path: '/',
});
