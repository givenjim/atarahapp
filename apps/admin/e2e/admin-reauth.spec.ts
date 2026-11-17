import { expect, test } from '@playwright/test';
import { freshFixtures, nextStepCode, signInWithEnrolment } from './helpers';

// The API accepts a sensitive action only within 5 minutes of the last authenticator verification, so this
// flow has to let the real window lapse. It takes about six minutes and is opt-in:
//   E2E_REAUTH=1 pnpm e2e e2e/admin-reauth.spec.ts
test.skip(
  !process.env.E2E_REAUTH,
  'Slow: waits for the 5-minute re-authentication window to lapse.',
);
test.setTimeout(10 * 60_000);

test('a stale verification makes the console ask for the authenticator code again', async ({
  page,
}) => {
  const f = freshFixtures();
  const secret = await signInWithEnrolment(page, f);

  await page.waitForTimeout(5 * 60_000 + 15_000);

  await page.goto('/users');
  await page.getByLabel('Search').fill(f.memberName);
  await page.getByRole('button', { name: 'Apply' }).click();
  await page.getByRole('link', { name: f.memberName }).click();
  await page.getByRole('button', { name: 'Suspend account' }).click();
  await page.getByLabel('Reason for suspension').fill('E2E: stale verification');
  await page.getByRole('dialog').getByRole('button', { name: 'Suspend account' }).click();

  const reauth = page.getByRole('dialog', { name: "Confirm it's you" });
  await expect(reauth).toBeVisible();
  await expect(reauth.getByLabel('Password')).toHaveCount(0);

  // A wrong code is refused and nothing changes.
  await reauth.getByLabel('Authenticator code').fill('000000');
  await reauth.getByRole('button', { name: 'Confirm' }).click();
  await expect(reauth.getByRole('alert')).toContainText('not valid');
  await expect(page.getByText('Suspended', { exact: true })).toHaveCount(0);

  // The right code verifies the factor again and the suspension goes through with the new token.
  await reauth.getByLabel('Authenticator code').fill(nextStepCode(secret));
  await reauth.getByRole('button', { name: 'Confirm' }).click();
  await expect(page.getByText('Suspended', { exact: true })).toBeVisible();
  await expect(page.getByText('E2E: stale verification')).toBeVisible();
});
