/**
 * Supabase Auth configuration for the web app. Plumbing only: member sign-in on the web is a later milestone.
 * Only the project URL and the PUBLISHABLE key exist client-side; the service-role key never does, and the
 * client is used for Auth only (all data goes through the NestJS API; Master Prompt 5.7 rule 1).
 */
export function supabaseConfig(env: Record<string, string | undefined> = process.env): {
  url: string;
  publishableKey: string;
} {
  const url = env.NEXT_PUBLIC_SUPABASE_URL;
  const publishableKey = env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;
  if (!url || !publishableKey) {
    throw new Error(
      'NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY must be set (see apps/web/.env.example).',
    );
  }
  return { url, publishableKey };
}
