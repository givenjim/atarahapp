import { execSync } from 'node:child_process';
import { mkdirSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';

export const FIXTURE_FILE = join(__dirname, '.fixtures', 'accounts.json');

/**
 * Checks the backend is up, then creates a fresh administrator and member through the backend's dev-only
 * fixtures script, so every run starts from known state and never reuses a TOTP secret.
 */
export default async function globalSetup(): Promise<void> {
  const api = process.env.ATARAH_API_BASE_URL ?? 'http://localhost:3000';
  const ready = await fetch(`${api}/health/ready`).catch(() => null);
  if (!ready?.ok) {
    throw new Error(
      `The backend is not ready at ${api}. Start it (and the dev database) before running the e2e flow.`,
    );
  }
  const out = execSync('pnpm --silent --filter @atarah/backend e2e:fixtures', {
    cwd: join(__dirname, '..', '..', '..'),
    encoding: 'utf8',
  });
  const json = out.slice(out.indexOf('{'));
  mkdirSync(dirname(FIXTURE_FILE), { recursive: true });
  writeFileSync(FIXTURE_FILE, json);
}
