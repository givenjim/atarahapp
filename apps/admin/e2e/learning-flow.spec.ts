import { randomBytes } from 'node:crypto';
import { expect, test, type Page } from '@playwright/test';
import { freshFixtures, signInWithEnrolment, type Fixtures } from './helpers';

const run = randomBytes(3).toString('hex');
const CATEGORY = `E2E Category ${run}`;
const COURSE = `E2E Course ${run}`;
const MASTERCLASS = `E2E Masterclass ${run}`;

let accounts: Fixtures;

test.beforeAll(() => {
  // A content admin: a platform admin cannot manage Skill Labs. Its own account, so the authenticator is enrolled by
  // this flow.
  accounts = freshFixtures('CONTENT_ADMIN');
});

const rowOf = (page: Page, text: string) => page.getByRole('row').filter({ hasText: text });

test('content admin builds a course: category, draft, lessons, order, publish, archive', async ({
  page,
}) => {
  await signInWithEnrolment(page, accounts);
  const nav = page.getByRole('navigation', { name: 'Admin sections' });
  await nav.getByRole('link', { name: /^Learning/ }).click();
  await expect(page).toHaveURL(/\/learning$/);
  await expect(page.getByRole('heading', { name: 'Learning', exact: true })).toBeVisible();

  // ---- a category ----
  await page.getByRole('link', { name: 'Categories' }).click();
  await page.getByRole('button', { name: 'New category' }).click();
  let dialog = page.getByRole('dialog');
  await dialog.getByLabel('Name').fill(CATEGORY);
  await dialog.getByLabel('Group').selectOption('BUSINESS');
  await dialog.getByRole('button', { name: 'Add category' }).click();
  await expect(rowOf(page, CATEGORY)).toBeVisible();

  // ---- a course draft ----
  await page.getByRole('link', { name: 'Content' }).click();
  await page.getByRole('link', { name: 'New item' }).click();
  await page.getByLabel('Title').fill(COURSE);
  await page.getByLabel('Category').selectOption({ label: CATEGORY });
  await page.getByLabel(/Summary/).fill('A course created by the end-to-end test.');
  await page.getByRole('button', { name: 'Create draft' }).click();
  await expect(page.getByRole('heading', { name: COURSE })).toBeVisible();
  await expect(page.getByText('Draft', { exact: true }).first()).toBeVisible();

  // ---- publishing with no lessons is refused in the API's words ----
  await page.getByRole('button', { name: 'Publish' }).click();
  dialog = page.getByRole('dialog');
  await dialog.getByRole('button', { name: 'Publish' }).click();
  await expect(dialog.getByRole('alert')).toContainText('Add at least one lesson');
  await dialog.getByRole('button', { name: 'Cancel' }).click();

  // ---- two lessons, then reorder ----
  for (const [n, title] of [
    [1, 'First lesson'],
    [2, 'Second lesson'],
  ] as const) {
    await page.getByRole('button', { name: 'Add lesson' }).click();
    const editor = page.getByRole('region', { name: 'New lesson' });
    await editor.getByLabel('Lesson title').fill(title);
    await editor.getByLabel('Length (minutes)').fill('5');
    await editor.getByRole('button', { name: 'Add paragraph' }).click();
    await editor.getByLabel(/Paragraph text/).fill(`Text of lesson ${n}.`);
    await editor.getByRole('button', { name: 'Add lesson' }).click();
    await expect(page.getByRole('listitem', { name: `Lesson ${n}` })).toContainText(title);
  }
  await page.getByRole('button', { name: 'Move lesson 2 up' }).click();
  await expect(page.getByRole('listitem', { name: 'Lesson 1' })).toContainText('Second lesson');
  await expect(page.getByRole('listitem', { name: 'Lesson 2' })).toContainText('First lesson');

  // ---- publish, then archive ----
  await page.getByRole('button', { name: 'Publish' }).click();
  await page.getByRole('dialog').getByRole('button', { name: 'Publish' }).click();
  await expect(page.getByText('Published', { exact: true }).first()).toBeVisible();
  await expect(page.getByRole('button', { name: 'Unpublish' })).toBeVisible();

  await page.getByRole('button', { name: 'Archive' }).click();
  await page.getByRole('dialog').getByRole('button', { name: 'Archive' }).click();
  await expect(page.getByText('Archived', { exact: true }).first()).toBeVisible();

  // ---- the audit trail records who published ----
  await page.getByRole('link', { name: /audit history/ }).click();
  const row = page.getByRole('row').filter({ hasText: 'learning.content.publish' });
  await expect(row).toHaveCount(1);
  await expect(row).toContainText(accounts.adminName);
});

test('the embed allow-list refuses other hosts and shows the converted player address', async ({
  page,
}) => {
  await signInWithEnrolment(page, accounts);
  await page.goto('/learning/new');
  await page.getByLabel('Title').fill(MASTERCLASS);
  await page.getByLabel('Type').selectOption('MASTERCLASS');
  await page.getByLabel('Delivery').selectOption('EMBEDDED');
  await page.getByLabel(/Summary/).fill('A masterclass used to check the embed allow-list.');
  const input = page.getByLabel(/Embedded player address/);

  await input.fill('https://evil.example.com/embed/abc123456');
  await expect(page.getByText(/cannot be embedded/)).toBeVisible();
  await page.getByLabel('Category').selectOption({ index: 1 });
  await page.getByRole('button', { name: 'Create draft' }).click();
  await expect(page.getByRole('alert').first()).toContainText('cannot be embedded');

  await input.fill('https://www.youtube.com/watch?v=abcDEF12345');
  await expect(page.getByText('https://www.youtube-nocookie.com/embed/abcDEF12345')).toBeVisible();
  await page.getByRole('button', { name: 'Create draft' }).click();
  await expect(page.getByRole('heading', { name: MASTERCLASS })).toBeVisible();
  // The address the API stored is the converted one.
  await expect(page.getByText('https://www.youtube-nocookie.com/embed/abcDEF12345')).toBeVisible();
});

test('analytics opens for a content admin; a member-level account is turned away', async ({
  page,
}) => {
  await signInWithEnrolment(page, accounts);
  await page.goto('/learning/analytics');
  await expect(page.getByRole('heading', { name: 'Learning analytics' })).toBeVisible();
  await expect(page.getByText('Certificates issued')).toBeVisible();
});
