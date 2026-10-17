import { defineConfig, devices } from '@playwright/test';

const PORT = 3200;

/**
 * End-to-end flow against the real backend (default http://localhost:3000, started separately, with the
 * dev database migrated and seeded). The console is started from its production build.
 *   pnpm --filter @atarah/admin build && pnpm --filter @atarah/admin e2e
 */
export default defineConfig({
  testDir: './e2e',
  globalSetup: './e2e/global-setup.ts',
  globalTeardown: './e2e/global-teardown.ts',
  timeout: 90_000,
  fullyParallel: false,
  workers: 1,
  reporter: [['list']],
  use: {
    baseURL: `http://localhost:${PORT}`,
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
  },
  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }],
  webServer: {
    command: 'pnpm start',
    url: `http://localhost:${PORT}/login`,
    reuseExistingServer: true,
    timeout: 120_000,
    env: { ATARAH_API_BASE_URL: process.env.ATARAH_API_BASE_URL ?? 'http://localhost:3000' },
  },
});
