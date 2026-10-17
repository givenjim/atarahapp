import { expect, test } from '@playwright/test';
import { fx, nextStepCode, signInWithEnrolment } from './helpers';

test('admin signs in with TOTP, suspends a member, sees the audit entry, and reactivates', async ({
  page,
}) => {
  const f = fx();

  // Unauthenticated visitors are sent to sign-in.
  await page.goto('/users');
  await expect(page).toHaveURL(/\/login$/);

  // A wrong password does not reveal whether the account exists.
  await page.getByLabel('Email').fill(f.adminEmail);
  await page.getByLabel('Password').fill('Wrong-password-1');
  await page.getByRole('button', { name: 'Continue' }).click();
  await expect(page.getByText('do not match an administrator account')).toBeVisible();

  const secret = await signInWithEnrolment(page, f);

  // The sidebar shows only what a platform admin may see; Roles & Permissions needs role.manage.
  const nav = page.getByRole('navigation', { name: 'Admin sections' });
  await expect(nav.getByRole('link', { name: /^Users/ })).toBeVisible();
  await expect(nav.getByRole('link', { name: /^Audit Logs/ })).toBeVisible();
  await expect(nav.getByRole('link', { name: /Roles & Permissions/ })).toHaveCount(0);

  // An unbuilt section opens a labelled panel, not a dead page.
  await nav.getByRole('link', { name: /^Payments/ }).click();
  await expect(page.getByText('Soon · P2').first()).toBeVisible();

  // Users: search, open, suspend.
  await nav.getByRole('link', { name: /^Users/ }).click();
  await page.getByLabel('Search').fill(f.memberName);
  await page.getByRole('button', { name: 'Apply' }).click();
  await page.getByRole('link', { name: f.memberName }).click();
  await expect(page.getByRole('heading', { name: f.memberName })).toBeVisible();
  await expect(page.getByText('Active', { exact: true })).toBeVisible();

  await page.getByRole('button', { name: 'Suspend account' }).click();
  await page.getByLabel('Reason for suspension').fill('E2E: repeated harassment reports');
  await page.getByRole('dialog').getByRole('button', { name: 'Suspend account' }).click();

  // Sensitive action: the API asks for a fresh password and authenticator code first.
  const reauth = page.getByRole('dialog', { name: "Confirm it's you" });
  await expect(reauth).toBeVisible();
  await reauth.getByLabel('Password').fill('Wrong-password-1');
  await reauth.getByLabel('Authenticator code').fill(nextStepCode(secret));
  await reauth.getByRole('button', { name: 'Confirm' }).click();
  await expect(reauth.getByRole('alert')).toBeVisible();
  await expect(page.getByText('Suspended', { exact: true })).toHaveCount(0);

  await reauth.getByLabel('Password').fill(f.password);
  await reauth.getByLabel('Authenticator code').fill(nextStepCode(secret));
  await reauth.getByRole('button', { name: 'Confirm' }).click();

  await expect(page.getByText('Suspended', { exact: true })).toBeVisible();
  await expect(page.getByText('E2E: repeated harassment reports')).toBeVisible();

  // The audit entry is there, with who did it.
  await page.getByRole('link', { name: /audit history/ }).click();
  const row = page.getByRole('row').filter({ hasText: 'user.suspend' });
  await expect(row).toHaveCount(1);
  await expect(row).toContainText(f.adminName);
  await expect(row).toContainText('SUSPENDED');

  // Reactivate (the re-authentication still holds for a few minutes, so no second prompt).
  await page.getByRole('link', { name: 'Users' }).first().click();
  await page.getByLabel('Search').fill(f.memberName);
  await page.getByRole('button', { name: 'Apply' }).click();
  await page.getByRole('link', { name: f.memberName }).click();
  await page.getByRole('button', { name: 'Reactivate account' }).click();
  await page.getByRole('dialog').getByRole('button', { name: 'Reactivate account' }).click();
  await expect(page.getByText('Active', { exact: true })).toBeVisible();

  await page.getByRole('link', { name: /audit history/ }).click();
  await expect(page.getByRole('row').filter({ hasText: 'user.reactivate' })).toHaveCount(1);

  // Sign out ends the session: protected pages send you back to sign-in.
  await page.getByRole('button', { name: 'Sign out' }).click();
  await expect(page).toHaveURL(/\/login$/);
  await page.goto('/audit-logs');
  await expect(page).toHaveURL(/\/login$/);
});
