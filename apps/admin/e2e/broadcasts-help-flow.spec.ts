import { randomBytes } from 'node:crypto';
import { expect, test, type Page } from '@playwright/test';
import { freshFixtures, signInWithEnrolment, type Fixtures } from './helpers';

const run = randomBytes(3).toString('hex');
const BROADCAST = `E2E broadcast ${run}`;
const SCHEDULED = `E2E scheduled ${run}`;
const ARTICLE = `E2E help article ${run}`;
const QUESTION = `E2E question ${run}?`;
const VERSION = `e2e-${run}`;

let platform: Fixtures;
let content: Fixtures;

test.beforeAll(() => {
  // Each flow has its own administrator, so the authenticator is enrolled by that flow and the code is fresh.
  // Broadcasts belong to platform admins; help articles, the FAQ and legal documents to content admins.
  platform = freshFixtures();
  content = freshFixtures('CONTENT_ADMIN');
});

const rowOf = (page: Page, text: string) => page.getByRole('row').filter({ hasText: text });

test('platform admin sends and schedules a broadcast, cancels it, and reads the privacy log', async ({
  page,
}) => {
  await signInWithEnrolment(page, platform);
  const nav = page.getByRole('navigation', { name: 'Admin sections' });
  await nav.getByRole('link', { name: /^Notifications/ }).click();
  await expect(page).toHaveURL(/\/notifications$/);
  await expect(page.getByRole('heading', { name: 'Notifications', exact: true })).toBeVisible();

  // ---- send now (to a small audience, so the test does not message every member) ----
  await page.getByRole('link', { name: 'New broadcast' }).click();
  await page.getByLabel(/^Title/).fill(BROADCAST);
  await page.getByLabel(/^Message/).fill('Written by the end-to-end test. Nothing to do.');
  await page.getByLabel('Audience').selectOption('ROLE');
  await page.getByLabel('Role').selectOption('SUPER_ADMIN');
  await page.getByRole('button', { name: 'Count recipients' }).click();
  await expect(page.getByRole('status')).toContainText(/member/);
  // An invalid link is refused before anything is sent.
  await page.getByLabel('Opens in the app (optional)').fill('https://evil.example.com');
  await page.getByRole('button', { name: 'Send broadcast' }).click();
  await expect(page.getByRole('alert')).toContainText('in-app path');
  await page.getByLabel('Opens in the app (optional)').fill('/notifications');
  // The code entered at sign-in is under 5 minutes old, so there is no prompt.
  await page.getByRole('button', { name: 'Send broadcast' }).click();
  await expect(page.getByRole('heading', { name: BROADCAST })).toBeVisible();
  await expect(page.getByText('Members with a role: Super admin')).toBeVisible();

  // ---- schedule for tomorrow, then cancel it ----
  await page.goto('/notifications/new');
  await page.getByLabel(/^Title/).fill(SCHEDULED);
  await page.getByLabel(/^Message/).fill('Scheduled by the end-to-end test.');
  await page.getByLabel('Schedule').check();
  const tomorrow = new Date(Date.now() + 86_400_000 + 3 * 3_600_000).toISOString().slice(0, 16);
  await page.getByLabel('Send at (Nairobi time)').fill(tomorrow);
  await page.getByRole('button', { name: 'Schedule broadcast' }).click();
  await expect(page.getByRole('heading', { name: SCHEDULED })).toBeVisible();
  await expect(page.getByText('Scheduled', { exact: true }).first()).toBeVisible();
  await page.getByRole('button', { name: 'Cancel broadcast' }).click();
  await page.getByRole('dialog').getByRole('button', { name: 'Cancel broadcast' }).click();
  await expect(page.getByText('Cancelled', { exact: true }).first()).toBeVisible();

  // Both appear in the list with their status.
  await page.goto('/notifications');
  await expect(rowOf(page, BROADCAST)).toBeVisible();
  await expect(rowOf(page, SCHEDULED)).toContainText('Cancelled');

  // ---- the privacy requests log (needs user.view, which platform admins hold) ----
  await nav.getByRole('link', { name: /^Privacy requests/ }).click();
  await expect(page.getByRole('heading', { name: 'Privacy requests' })).toBeVisible();
  await page.getByLabel('Type').selectOption('DELETION');
  await page.getByRole('button', { name: 'Apply' }).click();
  await expect(page).toHaveURL(/kind=DELETION/);
});

test('content admin writes a help article and an FAQ entry, then publishes a legal version', async ({
  page,
}) => {
  await signInWithEnrolment(page, content);
  const nav = page.getByRole('navigation', { name: 'Admin sections' });
  // A content admin does not see broadcasts.
  await expect(nav.getByRole('link', { name: /^Notifications/ })).toHaveCount(0);
  await nav.getByRole('link', { name: /^Content/ }).click();
  await expect(page.getByRole('heading', { name: 'Help articles' })).toBeVisible();

  // ---- a help article ----
  await page.getByRole('link', { name: 'New article' }).click();
  await page.getByLabel(/^Title/).fill(ARTICLE);
  await expect(page.getByLabel(/^Address/)).toHaveValue(/^e2e-help-article-/);
  await expect(page.getByRole('button', { name: 'Add image' })).toHaveCount(0);
  await page.getByRole('button', { name: 'Add paragraph' }).click();
  await page
    .getByRole('textbox', { name: /Paragraph text/ })
    .fill('Written by the end-to-end test.');
  await page.getByLabel(/Published/).check();
  await page.getByRole('button', { name: 'Create article' }).click();
  await expect(page.getByRole('heading', { name: ARTICLE })).toBeVisible();
  await expect(page.getByLabel(/^Address/)).toBeDisabled();

  await page.getByRole('link', { name: 'Help articles' }).click();
  await expect(rowOf(page, ARTICLE)).toContainText('Published');

  // ---- an FAQ entry ----
  await page.getByRole('link', { name: 'FAQ' }).click();
  await page.getByRole('button', { name: 'New question' }).click();
  const dialog = page.getByRole('dialog');
  await dialog.getByLabel('Question').fill(QUESTION);
  await dialog.getByLabel('Answer').fill('An answer written by the end-to-end test.');
  await dialog.getByRole('button', { name: 'Add question' }).click();
  await expect(page.getByText(QUESTION)).toBeVisible();

  // ---- a legal document: new version, edit, publish ----
  await page.getByRole('link', { name: 'Legal documents' }).click();
  await expect(page.getByText(/DRAFT — pending legal review/).first()).toBeVisible();
  await page.getByRole('button', { name: 'New version' }).click();
  const legal = page.getByRole('dialog');
  await legal.getByLabel('Document').selectOption('COMMUNITY_GUIDELINES');
  await legal.getByLabel('Version').fill(VERSION);
  await legal.getByLabel('Title').fill('Community Guidelines (e2e)');
  await legal.getByLabel('Text').fill('The end-to-end test wrote this version of the guidelines.');
  await legal.getByRole('button', { name: 'Create draft' }).click();
  await expect(page.getByRole('heading', { name: new RegExp(`version ${VERSION}`) })).toBeVisible();
  await expect(page.getByText(/DRAFT — pending legal review/).first()).toBeVisible();

  await page
    .getByLabel('Text')
    .fill('The end-to-end test wrote this version of the guidelines, then edited it.');
  await page.getByRole('button', { name: 'Save draft' }).click();
  await expect(page.getByText('Saved.')).toBeVisible();

  await page.getByRole('button', { name: 'Publish this version' }).click();
  const confirm = page.getByRole('dialog');
  await expect(confirm).toContainText('version it replaces is archived');
  await confirm.getByRole('button', { name: 'Publish' }).click();
  await expect(page.getByText('Published', { exact: true }).first()).toBeVisible();
  // A published version is a record: it is read-only now.
  await expect(page.getByLabel('Text')).toHaveAttribute('readonly', '');
  await expect(page.getByRole('button', { name: 'Publish this version' })).toHaveCount(0);
});
