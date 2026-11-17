import { expect, test } from '@playwright/test';
import { freshFixtures, nextStepCode, signInWithEnrolment } from './helpers';

test('an administrator with an authenticator signs in with a code, and the console stays behind it', async ({
  page,
}) => {
  const f = freshFixtures();
  const secret = await signInWithEnrolment(page, f);
  await page.getByRole('button', { name: 'Sign out' }).click();
  await expect(page).toHaveURL(/\/login$/);

  // After the password step alone (AAL1) the console is closed: every page sends you to the code step.
  await page.getByLabel('Email').fill(f.adminEmail);
  await page.getByLabel('Password').fill(f.password);
  await page.getByRole('button', { name: 'Continue' }).click();
  await expect(page).toHaveURL(/\/login\/totp$/);
  await page.goto('/audit-logs');
  await expect(page).toHaveURL(/\/login\/totp$/);

  // A wrong code is refused; there is no recovery-code route.
  await page.getByLabel('Authenticator code').fill('000000');
  await page.getByRole('button', { name: 'Sign in' }).click();
  await expect(page.locator('p.alert')).toContainText('not valid');
  await expect(page.getByText('recovery', { exact: false })).toHaveCount(0);

  await page.getByLabel('Authenticator code').fill(nextStepCode(secret));
  await page.getByRole('button', { name: 'Sign in' }).click();
  await expect(page.getByRole('heading', { name: 'Dashboard', exact: true })).toBeVisible();

  // The session cookies are httpOnly: page scripts cannot read them.
  expect(await page.evaluate(() => document.cookie)).not.toContain('auth-token');
  await page.getByRole('button', { name: 'Sign out' }).click();
  await expect(page).toHaveURL(/\/login$/);
});
