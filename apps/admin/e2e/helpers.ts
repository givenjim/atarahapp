import { execSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { expect, type Page } from '@playwright/test';
import { createClient } from '@supabase/supabase-js';
import { generateSync } from 'otplib';
import { FIXTURE_FILE } from './global-setup';

export interface Fixtures {
  adminEmail: string;
  adminName: string;
  password: string;
  memberEmail: string;
  memberName: string;
  memberId?: string;
}

/** The accounts created once by global setup. */
export const fx = (): Fixtures => JSON.parse(readFileSync(FIXTURE_FILE, 'utf8')) as Fixtures;

const REPO_ROOT = join(__dirname, '..', '..', '..');

/** Creates one more throwaway administrator and member, for a flow that must enrol its own authenticator. */
export function freshFixtures(adminRole?: string): Fixtures {
  const out = execSync('pnpm --silent --filter @atarah/backend e2e:fixtures', {
    cwd: REPO_ROOT,
    encoding: 'utf8',
    env: { ...process.env, ...(adminRole ? { E2E_ADMIN_ROLE: adminRole } : {}) },
  });
  return JSON.parse(out.slice(out.indexOf('{'))) as Fixtures;
}

/** Deletes the E2E disciplines (and their specialisations and suggestions) whose name starts with `prefix`. */
export function cleanupTaxonomy(prefix: string): void {
  execSync(`pnpm --silent --filter @atarah/backend e2e:fixtures cleanup-taxonomy "${prefix}"`, {
    cwd: REPO_ROOT,
    encoding: 'utf8',
  });
}

/** A code from the next 30-second step: the one used at enrolment or sign-in is not reused for re-authentication. */
export const nextStepCode = (secret: string) =>
  generateSync({ secret, epoch: Math.floor(Date.now() / 1000) + 30 });

export async function signInWithEnrolment(page: Page, f: Fixtures): Promise<string> {
  await page.goto('/login');
  await page.getByLabel('Email').fill(f.adminEmail);
  await page.getByLabel('Password').fill(f.password);
  await page.getByRole('button', { name: 'Continue' }).click();

  await expect(page.getByRole('heading', { name: 'Set up your authenticator' })).toBeVisible();
  const secret = (await page.getByTestId('totp-secret').textContent())!.trim();
  await page.getByLabel('Code from your authenticator app').fill(generateSync({ secret }));
  await page.getByRole('button', { name: 'Verify and finish' }).click();

  await expect(page.getByRole('heading', { name: 'Dashboard', exact: true })).toBeVisible();
  return secret;
}

/** A member's API access token, from Supabase Auth with the publishable key (as the apps do). */
export async function memberAccessToken(f: Fixtures): Promise<string> {
  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY!,
    { auth: { autoRefreshToken: false, persistSession: false } },
  );
  const { data, error } = await supabase.auth.signInWithPassword({
    email: f.memberEmail,
    password: f.password,
  });
  if (error || !data.session) throw new Error(`member sign-in: ${error?.message}`);
  return data.session.access_token;
}
