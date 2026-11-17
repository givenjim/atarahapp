import { expect, test } from '@playwright/test';
import { freshFixtures, nextStepCode, signInWithEnrolment, type Fixtures } from './helpers';

/**
 * P1-M12 admin operations: dashboard, analytics, member overview with role and suspension actions, settings and the
 * failed-jobs view. Written against the API contract in docs/API.md; it has not been run yet (needs the stack up).
 * A super admin is used because staff roles and settings need the full permission set.
 */
let admin: Fixtures;

test.beforeAll(() => {
  admin = freshFixtures('SUPER_ADMIN');
});

test('dashboard shows attention queues and key counts', async ({ page }) => {
  await signInWithEnrolment(page, admin);
  await expect(page.getByRole('heading', { name: 'Needs attention' })).toBeVisible();
  await expect(page.getByRole('heading', { name: 'Key counts' })).toBeVisible();
  await expect(page.getByText('New members').first()).toBeVisible();
  await expect(page.getByText('Onboarding completion')).toBeVisible();
});

test('analytics shows a chart per event, refuses more than 120 days and offers a table', async ({
  page,
}) => {
  await signInWithEnrolment(page, admin);
  await page
    .getByRole('navigation', { name: 'Admin sections' })
    .getByRole('link', { name: /^Analytics/ })
    .click();
  await expect(page.getByRole('heading', { name: 'Analytics', exact: true })).toBeVisible();
  await expect(page.getByRole('img', { name: /Registrations, / })).toBeVisible();
  await page.getByText('View as table').first().click();
  await expect(page.getByRole('columnheader', { name: 'Events' }).first()).toBeVisible();

  await page.getByLabel('From').fill('2020-01-01');
  await page.getByRole('button', { name: 'Apply' }).click();
  await expect(page.getByRole('alert')).toContainText('at most 120 days');
});

test('super admin assigns and revokes a role, then suspends for a number of days', async ({
  page,
}) => {
  const secret = await signInWithEnrolment(page, admin);
  await page.goto('/users');
  await page.getByLabel(/Search/i).fill(admin.memberEmail);
  await page.getByRole('button', { name: /Search|Apply/ }).click();
  await page.getByRole('link', { name: admin.memberName }).first().click();
  await expect(page.getByRole('heading', { name: admin.memberName })).toBeVisible();
  for (const name of ['Roles', 'Status history', 'Sessions', 'Reports']) {
    await expect(page.getByRole('heading', { name, exact: true })).toBeVisible();
  }

  // ---- assign a member-level role (the authenticator is asked for again) ----
  await page.getByRole('button', { name: 'Assign a role' }).click();
  let dialog = page.getByRole('dialog', { name: /Assign a role to/ });
  await dialog.getByLabel('Role').selectOption('MENTOR');
  await dialog.getByLabel(/^Reason/).fill('Approved by the end-to-end test');
  await dialog.getByRole('button', { name: 'Assign role' }).click();
  await page.getByLabel('Authenticator code').fill(nextStepCode(secret));
  await page.getByRole('button', { name: 'Confirm' }).click();
  await expect(page.getByRole('button', { name: 'Revoke Mentor' })).toBeVisible();

  // ---- revoke it ----
  await page.getByRole('button', { name: 'Revoke Mentor' }).click();
  dialog = page.getByRole('dialog', { name: /Revoke Mentor from/ });
  await dialog.getByLabel(/^Reason/).fill('Clean-up after the test');
  await dialog.getByRole('button', { name: 'Revoke role' }).click();
  await expect(page.getByRole('button', { name: 'Revoke Mentor' })).toHaveCount(0);

  // ---- suspend for 7 days, then lift it ----
  await page.getByRole('button', { name: 'Suspend account' }).click();
  dialog = page.getByRole('dialog', { name: /Suspend / });
  await dialog.getByRole('button', { name: 'Suspend account' }).click();
  await expect(dialog.getByRole('alert')).toContainText('at least 5');
  await dialog.getByLabel('Reason for suspension').fill('End-to-end suspension');
  await dialog.getByLabel(/Number of days/).fill('7');
  await dialog.getByRole('button', { name: 'Suspend account' }).click();
  await expect(page.getByText('Suspended', { exact: true }).first()).toBeVisible();
  await expect(page.getByText(/· until /)).toBeVisible();
  await expect(page.getByRole('cell', { name: /^Suspended/ })).toBeVisible();

  await page.getByRole('button', { name: 'Reactivate account' }).click();
  await page
    .getByRole('dialog', { name: /Reactivate / })
    .getByRole('button', { name: 'Reactivate account' })
    .click();
  await expect(page.getByRole('button', { name: 'Suspend account' })).toBeVisible();
});

test('settings list flags and values, and the jobs page lists queues', async ({ page }) => {
  await signInWithEnrolment(page, admin);
  await page
    .getByRole('navigation', { name: 'Admin sections' })
    .getByRole('link', { name: /^Settings/ })
    .click();
  await expect(page.getByRole('heading', { name: 'Feature flags' })).toBeVisible();
  // Save stays disabled until a value changes.
  await expect(page.getByRole('button', { name: 'Save' }).first()).toBeDisabled();

  await page.getByRole('link', { name: 'Background jobs and failed jobs' }).click();
  await expect(page.getByRole('heading', { name: 'Background jobs' })).toBeVisible();
  await expect(page.getByRole('table', { name: 'Queues' })).toBeVisible();
});
