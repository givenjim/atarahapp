/** Test environment shared by integration suites. Supabase, Redis and the SMS hook secret come from global-setup. */
export function applyTestEnv(): void {
  Object.assign(process.env, {
    ATARAH_ENV: 'test',
    ATARAH_PUBLIC_URL: 'http://localhost:3000',
    ATARAH_CORS_ORIGINS: 'http://localhost:3001',
  });
  // The publishable key global-setup read from the local stack (password checks and contact changes use it).
  if (process.env.ATARAH_TEST_SUPABASE_PUBLISHABLE_KEY) {
    process.env.ATARAH_SUPABASE_PUBLISHABLE_KEY = process.env.ATARAH_TEST_SUPABASE_PUBLISHABLE_KEY;
  }
}
