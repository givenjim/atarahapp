import { randomBytes } from 'node:crypto';
import { expect, test, type Page } from '@playwright/test';
import { cleanupTaxonomy, freshFixtures, signInWithEnrolment, type Fixtures } from './helpers';

const API = process.env.ATARAH_API_BASE_URL ?? 'http://localhost:3000';

const run = randomBytes(3).toString('hex');
/** Everything this flow creates lives under one discipline whose name starts with this prefix. */
const PREFIX = `E2E Taxonomy ${run}`;
const DISCIPLINE = `${PREFIX} Discipline`;
const SPEC_A = `Alpha ${run}`;
const SPEC_A_RENAMED = `Alpha renamed ${run}`;
const SPEC_B = `Beta ${run}`;
const SUGGEST_APPROVE = `Approve me ${run}`;
const SUGGEST_APPROVE_FIXED = `Approved name ${run}`;
const SUGGEST_MERGE = `Merge me ${run}`;
const SUGGEST_REJECT = `Reject me ${run}`;

let accounts: Fixtures;

test.beforeAll(() => {
  accounts = freshFixtures();
});

// The admin API can only archive taxonomy entries, so remove what this run created straight from the
// database. The prefix keeps seeded rows out of reach.
test.afterAll(() => {
  cleanupTaxonomy(PREFIX);
});

async function memberToken(f: Fixtures): Promise<string> {
  const res = await fetch(`${API}/api/v1/auth/login`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ identifier: f.memberEmail, password: f.password, client: 'WEB' }),
  });
  expect(res.ok, `member sign-in: ${res.status}`).toBe(true);
  return ((await res.json()) as { data: { accessToken: string } }).data.accessToken;
}

const memberGet = async (token: string, path: string) =>
  (
    (await (
      await fetch(`${API}${path}`, { headers: { authorization: `Bearer ${token}` } })
    ).json()) as {
      data: { id: string; name: string }[];
    }
  ).data;

async function suggest(token: string, disciplineId: string, name: string): Promise<void> {
  const res = await fetch(`${API}/api/v1/taxonomy/specialisations/suggestions`, {
    method: 'POST',
    headers: { 'content-type': 'application/json', authorization: `Bearer ${token}` },
    body: JSON.stringify({ disciplineId, name }),
  });
  expect(res.status, `suggest ${name}`).toBe(201);
}

const rowOf = (page: Page, text: string) => page.getByRole('row').filter({ hasText: text });

async function chooseDiscipline(page: Page, name: string) {
  await page.locator('.toolbar select').selectOption({ label: name });
  await expect(page).toHaveURL(/disciplineId=/);
}

test('content admin manages the taxonomy and decides specialisation suggestions', async ({
  page,
}) => {
  await signInWithEnrolment(page, accounts);
  const nav = page.getByRole('navigation', { name: 'Admin sections' });

  // ---- Disciplines: create, reject a duplicate, rename ----
  await nav.getByRole('link', { name: /^Taxonomy/ }).click();
  await expect(page).toHaveURL(/\/taxonomy\/disciplines$/);
  await expect(page.getByRole('link', { name: 'Disciplines' })).toHaveAttribute(
    'aria-current',
    'page',
  );

  await page.getByRole('button', { name: 'Add discipline' }).click();
  let dialog = page.getByRole('dialog');
  await dialog.getByLabel('Name', { exact: true }).fill(DISCIPLINE);
  await dialog.getByRole('button', { name: 'Add' }).click();
  await expect(dialog.getByRole('alert')).toContainText('icon');
  await dialog.getByLabel('Icon (Lucide name)').fill('palette');
  await dialog.getByRole('button', { name: 'Add' }).click();
  await expect(dialog).toBeHidden();
  await expect(rowOf(page, DISCIPLINE)).toContainText('Active');

  await page.getByRole('button', { name: 'Add discipline' }).click();
  dialog = page.getByRole('dialog');
  await dialog.getByLabel('Name', { exact: true }).fill(DISCIPLINE);
  await dialog.getByLabel('Icon (Lucide name)').fill('palette');
  await dialog.getByRole('button', { name: 'Add' }).click();
  await expect(dialog.getByRole('alert')).toBeVisible(); // 409: the name exists already
  await dialog.getByRole('button', { name: 'Cancel' }).click();
  await expect(rowOf(page, DISCIPLINE)).toHaveCount(1);

  const renamed = `${DISCIPLINE} renamed`;
  await page.getByRole('button', { name: `Edit ${DISCIPLINE}` }).click();
  dialog = page.getByRole('dialog');
  await dialog.getByLabel('Name', { exact: true }).fill(renamed);
  await dialog.getByLabel('Icon (Lucide name)').fill('brush');
  await dialog.getByRole('button', { name: 'Save' }).click();
  await expect(dialog).toBeHidden();
  await expect(rowOf(page, renamed)).toContainText('brush');
  // Rename back so the cleanup prefix and later steps use one name.
  await page.getByRole('button', { name: `Edit ${renamed}` }).click();
  dialog = page.getByRole('dialog');
  await dialog.getByLabel('Name', { exact: true }).fill(DISCIPLINE);
  await dialog.getByRole('button', { name: 'Save' }).click();
  await expect(rowOf(page, DISCIPLINE)).toHaveCount(1);

  // ---- Specialisations: create two in the new discipline, rename, reorder ----
  await page.getByRole('link', { name: 'Specialisations' }).click();
  await expect(page.getByText('Choose a discipline to change the order')).toBeVisible();
  await chooseDiscipline(page, DISCIPLINE);
  await expect(page.getByText('No specialisations in this discipline yet.')).toBeVisible();

  for (const name of [SPEC_A, SPEC_B]) {
    await page.getByRole('button', { name: 'Add specialisation' }).click();
    dialog = page.getByRole('dialog');
    await dialog.getByLabel('Name', { exact: true }).fill(name);
    await expect(dialog.getByLabel('Discipline')).toHaveValue(/.+/); // preselected from the filter
    await dialog.getByRole('button', { name: 'Add' }).click();
    await expect(dialog).toBeHidden();
    await expect(rowOf(page, name)).toBeVisible();
  }

  await page.getByRole('button', { name: `Edit ${SPEC_A}` }).click();
  dialog = page.getByRole('dialog');
  await dialog.getByLabel('Name', { exact: true }).fill(SPEC_A_RENAMED);
  await dialog.getByRole('button', { name: 'Save' }).click();
  await expect(rowOf(page, SPEC_A_RENAMED)).toBeVisible();

  const dataRows = page.locator('table.data tbody tr');
  await expect(dataRows.first()).toContainText(SPEC_A_RENAMED);
  await page.getByRole('button', { name: `Move ${SPEC_B} up` }).click();
  await expect(dataRows.first()).toContainText(SPEC_B);
  await page.reload();
  await expect(dataRows.first()).toContainText(SPEC_B); // the order was saved
  await page.getByRole('button', { name: `Move ${SPEC_B} down` }).click();
  await expect(dataRows.first()).toContainText(SPEC_A_RENAMED);

  // ---- Suggestions: a member suggests three names; approve, merge, reject ----
  const token = await memberToken(accounts);
  const disciplineId = (await memberGet(token, '/api/v1/taxonomy/disciplines')).find(
    (d) => d.name === DISCIPLINE,
  )?.id;
  expect(disciplineId, 'the new discipline is visible to members').toBeTruthy();
  for (const name of [SUGGEST_APPROVE, SUGGEST_MERGE, SUGGEST_REJECT]) {
    await suggest(token, disciplineId!, name);
  }

  await page.getByRole('link', { name: 'Suggestions' }).click();
  await expect(page.getByLabel('Status')).toHaveValue('PENDING');
  for (const name of [SUGGEST_APPROVE, SUGGEST_MERGE, SUGGEST_REJECT]) {
    const row = rowOf(page, name);
    await expect(row).toContainText(DISCIPLINE);
    await expect(row).toContainText(accounts.memberName);
  }

  // Approve under a corrected name.
  await page.getByRole('button', { name: `Approve ${SUGGEST_APPROVE}` }).click();
  dialog = page.getByRole('dialog');
  await dialog.getByLabel('Corrected name (optional)').fill(SUGGEST_APPROVE_FIXED);
  await dialog.getByRole('button', { name: 'Approve' }).click();
  await expect(dialog).toBeHidden();
  await expect(rowOf(page, SUGGEST_APPROVE)).toHaveCount(0);

  // Merge into the specialisation created above (only the same discipline's entries are offered).
  await page.getByRole('button', { name: `Merge ${SUGGEST_MERGE}` }).click();
  dialog = page.getByRole('dialog');
  const picker = dialog.getByLabel('Existing specialisation');
  await expect(picker.getByRole('option', { name: SPEC_A_RENAMED })).toBeAttached();
  await expect(picker.getByRole('option')).toHaveCount(1 + 3); // "Choose one" + Alpha, Beta, Approved name
  await picker.selectOption({ label: SPEC_A_RENAMED });
  await dialog.getByRole('button', { name: 'Merge' }).click();
  await expect(dialog).toBeHidden();
  await expect(rowOf(page, SUGGEST_MERGE)).toHaveCount(0);

  // Reject with a note.
  await page.getByRole('button', { name: `Reject ${SUGGEST_REJECT}` }).click();
  dialog = page.getByRole('dialog');
  await dialog.getByLabel('Note (optional)').fill('Too niche for the shared list');
  await dialog.getByRole('button', { name: 'Reject' }).click();
  await expect(dialog).toBeHidden();
  await expect(rowOf(page, SUGGEST_REJECT)).toHaveCount(0);

  // Decided rows show their outcome under "All statuses".
  await page.getByLabel('Status').selectOption('ALL');
  await page.getByRole('button', { name: 'Apply' }).click();
  await expect(rowOf(page, SUGGEST_APPROVE)).toContainText('Approved');
  await expect(rowOf(page, SUGGEST_MERGE)).toContainText('Merged');
  await expect(rowOf(page, SUGGEST_REJECT)).toContainText('Rejected');
  await expect(rowOf(page, SUGGEST_REJECT)).toContainText('Too niche for the shared list');

  // The approved name is now a real specialisation in the discipline.
  await page.goto('/taxonomy/specialisations');
  await chooseDiscipline(page, DISCIPLINE);
  await expect(rowOf(page, SUGGEST_APPROVE_FIXED)).toContainText('Active');

  // ---- Archive and restore (the member list follows) ----
  await page.getByRole('button', { name: `Archive ${SPEC_B}` }).click();
  dialog = page.getByRole('dialog');
  await dialog.getByRole('button', { name: 'Archive' }).click();
  await expect(rowOf(page, SPEC_B)).toContainText('Archived');
  await expect(rowOf(page, SPEC_B)).toHaveClass(/archived/);
  await page.getByRole('button', { name: `Restore ${SPEC_B}` }).click();
  await page.getByRole('dialog').getByRole('button', { name: 'Restore' }).click();
  await expect(rowOf(page, SPEC_B)).toContainText('Active');

  await page.getByRole('link', { name: 'Disciplines' }).click();
  await page.getByRole('button', { name: `Archive ${DISCIPLINE}` }).click();
  await page.getByRole('dialog').getByRole('button', { name: 'Archive' }).click();
  await expect(rowOf(page, DISCIPLINE)).toContainText('Archived');
  expect((await memberGet(token, '/api/v1/taxonomy/disciplines')).map((d) => d.name)).not.toContain(
    DISCIPLINE,
  );
  await page.getByRole('button', { name: `Restore ${DISCIPLINE}` }).click();
  await page.getByRole('dialog').getByRole('button', { name: 'Restore' }).click();
  await expect(rowOf(page, DISCIPLINE)).toContainText('Active');
  expect((await memberGet(token, '/api/v1/taxonomy/disciplines')).map((d) => d.name)).toContain(
    DISCIPLINE,
  );
});
