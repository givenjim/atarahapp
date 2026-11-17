import { randomBytes } from 'node:crypto';
import { expect, test, type Page } from '@playwright/test';
import { freshFixtures, signInWithEnrolment, type Fixtures } from './helpers';

const run = randomBytes(3).toString('hex');
const PROVIDER = `E2E Provider ${run}`;
const TITLE = `E2E Fund ${run}`;
const IMPORTED = `E2E Imported ${run}`;

let accounts: Fixtures;

test.beforeAll(() => {
  // Its own administrator, so the authenticator is enrolled by this flow and the code is fresh for Verify.
  accounts = freshFixtures();
});

const rowOf = (page: Page, text: string) => page.getByRole('row').filter({ hasText: text });

test('platform admin creates, reviews, publishes and verifies an opportunity', async ({ page }) => {
  await signInWithEnrolment(page, accounts);
  const nav = page.getByRole('navigation', { name: 'Admin sections' });
  await nav.getByRole('link', { name: /^Opportunities/ }).click();
  await expect(page).toHaveURL(/\/opportunities$/);
  await expect(page.getByRole('heading', { name: 'Opportunities', exact: true })).toBeVisible();

  // ---- a provider ----
  await page.getByRole('link', { name: 'Providers' }).click();
  await page.getByRole('button', { name: 'New provider' }).click();
  let dialog = page.getByRole('dialog');
  await dialog.getByLabel('Name').fill(PROVIDER);
  await dialog.getByLabel('Website').fill('https://e2e-provider.example.org');
  await dialog.getByRole('button', { name: 'Add provider' }).click();
  await expect(rowOf(page, PROVIDER)).toBeVisible();

  // ---- a draft with a rule ----
  await page.getByRole('link', { name: 'Opportunities' }).first().click();
  await page.getByRole('link', { name: 'New opportunity' }).click();
  await page.getByLabel('Title').fill(TITLE);
  await page.getByLabel('Provider').selectOption({ label: PROVIDER });
  await page.getByLabel(/Summary/).fill('A fund created by the end-to-end test.');
  await page.getByLabel('Smallest amount').fill('100000');
  await page.getByLabel('Largest amount').fill('500000');
  await page.getByLabel('Application link').fill('https://e2e-provider.example.org/apply');
  await page.getByRole('button', { name: 'Add a rule' }).click();
  const rule = page.getByRole('listitem', { name: 'Rule 1' });
  await rule.getByLabel('Label members read').fill('At least 2 published projects');
  await rule.getByLabel('Published projects needed').fill('2');

  // The server's own validation is shown: a rule without a label is refused before anything is saved.
  await page.getByRole('button', { name: 'Add a rule' }).click();
  await page.getByRole('button', { name: 'Create draft' }).click();
  await expect(page.getByRole('alert')).toContainText('label');
  await page.getByRole('button', { name: 'Remove rule 2' }).click();

  await page.getByRole('button', { name: 'Create draft' }).click();
  await expect(page.getByRole('heading', { name: TITLE })).toBeVisible();
  await expect(page.getByText('Draft', { exact: true }).first()).toBeVisible();
  await expect(page.getByText('External source').first()).toBeVisible();
  await expect(page.getByText('At least 2 published projects')).toBeVisible();

  // ---- publish, then verify (the code entered at sign-in is under 5 minutes old, so no prompt) ----
  await page.getByRole('button', { name: 'Publish' }).click();
  await page.getByRole('dialog').getByRole('button', { name: 'Publish' }).click();
  await expect(page.getByText('Published', { exact: true }).first()).toBeVisible();

  await page.getByRole('button', { name: /Verify \(Verified by Atarah\)/ }).click();
  dialog = page.getByRole('dialog');
  await dialog.getByLabel(/Why is it verified/).fill('E2E: confirmed with the organiser');
  await dialog.getByRole('button', { name: 'Verify' }).click();
  await expect(page.getByText('Verified by Atarah').first()).toBeVisible();

  // ---- the audit trail records who verified ----
  await page.getByRole('link', { name: /audit history/ }).click();
  const row = page.getByRole('row').filter({ hasText: 'opportunity.verify' });
  await expect(row).toHaveCount(1);
  await expect(row).toContainText(accounts.adminName);

  // ---- tidy up: remove the listing ----
  await page.goBack();
  await page.getByRole('button', { name: 'Remove' }).click();
  await page.getByRole('dialog').getByRole('button', { name: 'Remove' }).click();
  await expect(page.getByText('Removed', { exact: true }).first()).toBeVisible();
});

test('platform admin imports a CSV as drafts after reading the report', async ({ page }) => {
  await signInWithEnrolment(page, accounts);
  await page.goto('/opportunities/import');
  await expect(page.getByText(/always saved as/)).toContainText('drafts');

  const header = 'title,provider,type,summary,application_url,deadline';
  const good = `${IMPORTED},${PROVIDER},GRANT,An imported listing for the end-to-end test.,https://e2e-provider.example.org/imported,2099-03-31`;
  const bad = `${IMPORTED} bad,${PROVIDER},NOPE,short,http://insecure.example.org,2001-01-01`;
  await page.getByLabel('Or paste the rows').fill([header, good, bad].join('\n'));
  await page.getByRole('button', { name: 'Check file' }).click();

  await expect(page.getByText(/1 of 2 rows can be imported/)).toBeVisible();
  const problems = page.getByRole('table', { name: 'Problems found' });
  await expect(problems).toContainText('type');
  await expect(problems).toContainText('application_url');

  await page.getByRole('button', { name: 'Import 1 valid row as drafts' }).click();
  await expect(page.getByRole('status')).toContainText('Imported 1 draft');

  // It is a draft: nothing was published.
  await page.getByRole('link', { name: 'Review the drafts' }).click();
  const draft = rowOf(page, IMPORTED);
  await expect(draft).toContainText('Draft');
  await expect(draft).toContainText('External source');
});

test('link health lists the report and never offers to delete', async ({ page }) => {
  await signInWithEnrolment(page, accounts);
  await page.goto('/opportunities/link-health');
  await expect(page.getByRole('heading', { name: 'Link health' })).toBeVisible();
  await expect(page.getByRole('link', { name: /^Link broken/ })).toHaveAttribute(
    'aria-current',
    'page',
  );
  await expect(page.getByRole('button', { name: /remove|delete/i })).toHaveCount(0);
});
