import { render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { useState } from 'react';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { emptyForm, type emptyRule, type OppForm } from '@/lib/opportunities';
import { ImportForm } from './import/import-form';
import { OpportunityActions } from './[id]/opportunity-actions';
import { OpportunityForm } from './opportunity-form';
import { ProviderVerify } from './providers/provider-verify';
import { RulesEditor } from './rules-editor';

const nav = vi.hoisted(() => ({ refresh: vi.fn(), push: vi.fn(), back: vi.fn() }));
vi.mock('next/navigation', () => ({ useRouter: () => nav }));

const actions = vi.hoisted(() => ({
  saveOpportunityAction: vi.fn(),
  transitionOpportunityAction: vi.fn(),
  rejectOpportunityAction: vi.fn(),
  featureOpportunityAction: vi.fn(),
  setTrustAction: vi.fn(),
  verifyOpportunityAction: vi.fn(),
  verifyProviderAction: vi.fn(),
  previewImportAction: vi.fn(),
  commitImportAction: vi.fn(),
}));
vi.mock('@/app/opportunity-actions', () => actions);
const auth = vi.hoisted(() => ({ reauthAction: vi.fn() }));
vi.mock('@/app/actions', () => auth);

const P1 = '3f0a1c2e-1b2c-4d3e-8f4a-5b6c7d8e9f00';
const options = {
  providers: [{ id: P1, name: 'Nairobi Creative Fund' }],
  counties: [{ id: 'c1', name: 'Nairobi' }],
  disciplines: [
    { id: 'd1', name: 'Film / Video' },
    { id: 'd2', name: 'Music' },
  ],
  skills: [{ id: 's1', name: 'Storyboarding' }],
};

// Typing into a long form is slow on a busy machine.
vi.setConfig({ testTimeout: 60_000 });

beforeEach(() => {
  vi.clearAllMocks();
  for (const fn of Object.values(actions)) fn.mockResolvedValue({ ok: true });
  auth.reauthAction.mockResolvedValue({ ok: true });
});

describe('RulesEditor', () => {
  function Harness({ initial = [] as ReturnType<typeof emptyRule>[] }) {
    // A tiny stateful wrapper, because the editor is controlled.

    const [rules, setRules] = useState(initial);
    return (
      <>
        <RulesEditor
          rules={rules}
          onChange={setRules}
          disciplines={options.disciplines}
          skills={options.skills}
        />
        <output data-testid="count">{rules.length}</output>
        <output data-testid="types">{rules.map((r) => r.ruleType).join(',')}</output>
      </>
    );
  }

  it('adds, edits, reorders and removes rows, with a parameter editor per type', async () => {
    const user = userEvent.setup();
    render(<Harness />);
    expect(screen.getByText(/No rules yet/)).toBeInTheDocument();
    await user.click(screen.getByRole('button', { name: 'Add a rule' }));
    await user.click(screen.getByRole('button', { name: 'Add a rule' }));
    expect(screen.getByTestId('count')).toHaveTextContent('2');

    const second = screen.getByRole('listitem', { name: 'Rule 2' });
    await user.selectOptions(within(second).getByLabelText('Type'), 'SKILL_IN');
    expect(within(second).getByLabelText('Storyboarding')).toBeInTheDocument();
    await user.selectOptions(within(second).getByLabelText('Type'), 'DISCIPLINE_IN');
    expect(within(second).getByLabelText('Film / Video')).toBeInTheDocument();
    await user.selectOptions(within(second).getByLabelText('Type'), 'RESIDENCY');
    expect(within(second).getByLabelText('Country code')).toHaveValue('KE');
    await user.selectOptions(within(second).getByLabelText('Type'), 'AGE_RANGE');
    expect(within(second).getByLabelText('Minimum age')).toBeInTheDocument();
    await user.selectOptions(within(second).getByLabelText('Type'), 'CUSTOM_TEXT');

    expect(screen.getByTestId('types')).toHaveTextContent('MIN_PROJECTS,CUSTOM_TEXT');
    await user.click(screen.getByRole('button', { name: 'Move rule 2 up' }));
    expect(screen.getByTestId('types')).toHaveTextContent('CUSTOM_TEXT,MIN_PROJECTS');
    expect(screen.getByRole('button', { name: 'Move rule 1 up' })).toBeDisabled();
    await user.click(screen.getByRole('button', { name: 'Remove rule 1' }));
    expect(screen.getByTestId('count')).toHaveTextContent('1');
  });
});

describe('OpportunityForm', () => {
  const props = { ...options, initial: emptyForm() };

  it('refuses an incomplete form without calling the API', async () => {
    const user = userEvent.setup();
    render(<OpportunityForm {...props} />);
    await user.click(screen.getByRole('button', { name: 'Create draft' }));
    expect(await screen.findByRole('alert')).toHaveTextContent('title');
    expect(actions.saveOpportunityAction).not.toHaveBeenCalled();
  });

  it('creates a draft with major-unit amounts and goes to the new listing', async () => {
    actions.saveOpportunityAction.mockResolvedValue({ ok: true, id: 'new-id' });
    const user = userEvent.setup();
    render(<OpportunityForm {...props} />);
    await user.type(screen.getByLabelText('Title'), 'Emerging Creatives Grant');
    await user.selectOptions(screen.getByLabelText('Provider'), P1);
    await user.type(screen.getByLabelText(/Summary/), 'Seed grants for early-career creatives.');
    await user.type(screen.getByLabelText('Smallest amount'), '100000');
    await user.type(screen.getByLabelText('Largest amount'), '500000');
    await user.type(screen.getByLabelText('Application link'), 'https://fund.example.org/apply');
    await user.click(screen.getByRole('button', { name: 'Create draft' }));
    await vi.waitFor(() => expect(actions.saveOpportunityAction).toHaveBeenCalledTimes(1));
    const [id, form] = actions.saveOpportunityAction.mock.calls[0] as [string | null, OppForm];
    expect(id).toBeNull();
    expect(form).toMatchObject({
      title: 'Emerging Creatives Grant',
      providerId: P1,
      valueMin: '100000',
      valueMax: '500000',
    });
    await vi.waitFor(() => expect(nav.push).toHaveBeenCalledWith('/opportunities/new-id'));
  });

  it('shows the API’s field error and keeps what was typed', async () => {
    actions.saveOpportunityAction.mockResolvedValue({
      ok: false,
      error: 'Give the web address where members apply.',
    });
    const user = userEvent.setup();
    render(
      <OpportunityForm
        {...props}
        initial={{
          ...emptyForm(),
          title: 'Fund',
          providerId: P1,
          summary: 'A fund for creatives.',
          applicationUrl: 'https://a.example.org',
        }}
      />,
    );
    await user.click(screen.getByRole('button', { name: 'Create draft' }));
    expect(await screen.findByRole('alert')).toHaveTextContent('Give the web address');
    expect(screen.getByLabelText('Title')).toHaveValue('Fund');
    expect(nav.push).not.toHaveBeenCalled();
  });

  it('edits an existing listing and shows Save changes', async () => {
    const user = userEvent.setup();
    render(
      <OpportunityForm
        {...props}
        id="opp-1"
        initial={{
          ...emptyForm(),
          title: 'Fund',
          providerId: P1,
          summary: 'A fund for creatives.',
          applicationUrl: 'https://a.example.org',
        }}
      />,
    );
    await user.click(screen.getByRole('button', { name: 'Save changes' }));
    await vi.waitFor(() =>
      expect(actions.saveOpportunityAction).toHaveBeenCalledWith('opp-1', expect.any(Object)),
    );
  });
});

describe('OpportunityActions', () => {
  const base = {
    id: 'o1',
    title: 'Fund',
    trust: 'EXTERNAL_SOURCE',
    featured: false,
    canVerify: false,
  };

  it('offers actions that fit the status', () => {
    const { rerender } = render(<OpportunityActions {...base} status="PENDING_REVIEW" />);
    expect(screen.getByRole('button', { name: 'Publish' })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Send back' })).toBeInTheDocument();
    expect(screen.queryByRole('button', { name: 'Close' })).toBeNull();
    rerender(<OpportunityActions {...base} status="PUBLISHED" />);
    expect(screen.queryByRole('button', { name: 'Publish' })).toBeNull();
    expect(screen.queryByRole('button', { name: 'Send back' })).toBeNull();
    expect(screen.getByRole('button', { name: 'Close' })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Feature' })).toBeInTheDocument();
    rerender(<OpportunityActions {...base} status="PUBLISHED" featured />);
    expect(screen.getByRole('button', { name: 'Remove feature' })).toBeInTheDocument();
  });

  it('hides Verify from administrators without opportunity.verify', () => {
    const { rerender } = render(<OpportunityActions {...base} status="PUBLISHED" />);
    expect(screen.queryByRole('button', { name: /Verify \(Verified by Atarah\)/ })).toBeNull();
    expect(screen.getByText(/cannot give the Verified badge/)).toBeInTheDocument();
    rerender(<OpportunityActions {...base} status="PUBLISHED" canVerify />);
    expect(
      screen.getByRole('button', { name: /Verify \(Verified by Atarah\)/ }),
    ).toBeInTheDocument();
  });

  it('publishes after confirmation and refreshes', async () => {
    const user = userEvent.setup();
    render(<OpportunityActions {...base} status="DRAFT" />);
    await user.click(screen.getByRole('button', { name: 'Publish' }));
    expect(actions.transitionOpportunityAction).not.toHaveBeenCalled();
    await user.click(screen.getAllByRole('button', { name: 'Publish' }).at(-1)!);
    await vi.waitFor(() =>
      expect(actions.transitionOpportunityAction).toHaveBeenCalledWith('o1', 'publish'),
    );
    await vi.waitFor(() => expect(nav.refresh).toHaveBeenCalled());
  });

  it('send back needs a reason', async () => {
    const user = userEvent.setup();
    render(<OpportunityActions {...base} status="PENDING_REVIEW" />);
    await user.click(screen.getByRole('button', { name: 'Send back' }));
    await user.type(
      screen.getByLabelText('What should the provider change?'),
      'Add the eligibility rules.',
    );
    await user.click(screen.getAllByRole('button', { name: 'Send back' }).at(-1)!);
    await vi.waitFor(() =>
      expect(actions.rejectOpportunityAction).toHaveBeenCalledWith(
        'o1',
        'Add the eligibility rules.',
      ),
    );
  });

  it('asks for a fresh authenticator code to verify, then retries', async () => {
    actions.verifyOpportunityAction
      .mockResolvedValueOnce({ ok: false, reauth: true, error: 'Confirm it is you.' })
      .mockResolvedValueOnce({ ok: true });
    const user = userEvent.setup();
    render(<OpportunityActions {...base} status="PUBLISHED" canVerify />);
    await user.click(screen.getByRole('button', { name: /Verify \(Verified by Atarah\)/ }));
    await user.type(screen.getByLabelText(/Why is it verified/), 'Confirmed by phone');
    await user.click(screen.getAllByRole('button', { name: 'Verify' }).at(-1)!);
    const code = await screen.findByLabelText(/code/i);
    await user.type(code, '654321');
    await user.keyboard('{Enter}');
    await vi.waitFor(() => expect(actions.verifyOpportunityAction).toHaveBeenCalledTimes(2));
    expect(actions.verifyOpportunityAction).toHaveBeenLastCalledWith('o1', 'Confirmed by phone');
    expect(auth.reauthAction).toHaveBeenCalledWith({ code: '654321' });
    await vi.waitFor(() => expect(nav.refresh).toHaveBeenCalled());
  });

  it('remove is a danger action that can ask for the code too', async () => {
    actions.transitionOpportunityAction
      .mockResolvedValueOnce({ ok: false, reauth: true, error: 'Confirm it is you.' })
      .mockResolvedValueOnce({ ok: true });
    const user = userEvent.setup();
    render(<OpportunityActions {...base} status="PUBLISHED" />);
    await user.click(screen.getByRole('button', { name: 'Remove' }));
    await user.click(screen.getAllByRole('button', { name: 'Remove' }).at(-1)!);
    await user.type(await screen.findByLabelText(/code/i), '111222');
    await user.keyboard('{Enter}');
    await vi.waitFor(() => expect(actions.transitionOpportunityAction).toHaveBeenCalledTimes(2));
    expect(actions.transitionOpportunityAction).toHaveBeenLastCalledWith('o1', 'remove');
  });

  it('shows an API refusal inside the dialog', async () => {
    actions.transitionOpportunityAction.mockResolvedValue({
      ok: false,
      error: 'Add the web address before publishing.',
    });
    const user = userEvent.setup();
    render(<OpportunityActions {...base} status="DRAFT" />);
    await user.click(screen.getByRole('button', { name: 'Publish' }));
    await user.click(screen.getAllByRole('button', { name: 'Publish' }).at(-1)!);
    expect(await screen.findByRole('alert')).toHaveTextContent('Add the web address');
  });
});

describe('ProviderVerify', () => {
  it('offers the decisions that fit the verification status', () => {
    const { rerender } = render(
      <ProviderVerify id="p1" name="Kilifi Arts" status="NOT_SUBMITTED" />,
    );
    expect(screen.getByRole('button', { name: 'Verify Kilifi Arts' })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Reject Kilifi Arts' })).toBeInTheDocument();
    rerender(<ProviderVerify id="p1" name="Kilifi Arts" status="VERIFIED" />);
    expect(screen.queryByRole('button', { name: 'Verify Kilifi Arts' })).toBeNull();
    expect(screen.getByRole('button', { name: 'Revoke Kilifi Arts' })).toBeInTheDocument();
  });

  it('verifies with a reason', async () => {
    const user = userEvent.setup();
    render(<ProviderVerify id="p1" name="Kilifi Arts" status="NOT_SUBMITTED" />);
    await user.click(screen.getByRole('button', { name: 'Verify Kilifi Arts' }));
    await user.type(screen.getByLabelText(/Reason/), 'Registered NGO');
    await user.click(screen.getAllByRole('button', { name: 'Verify' }).at(-1)!);
    await vi.waitFor(() =>
      expect(actions.verifyProviderAction).toHaveBeenCalledWith('p1', 'VERIFIED', 'Registered NGO'),
    );
  });
});

describe('ImportForm', () => {
  const report = {
    totalCount: 3,
    validCount: 2,
    issues: [{ line: 4, column: 'type', message: 'Type must be one of GRANT, JOB.' }],
    preview: [
      {
        line: 2,
        title: 'Film Fund',
        provider: 'Known Org',
        type: 'GRANT',
        deadlineAt: null,
        providerExists: true,
      },
      {
        line: 3,
        title: 'Residency',
        provider: 'Brand New',
        type: 'RESIDENCY',
        deadlineAt: '2027-03-31T20:59:00.000Z',
        providerExists: false,
      },
    ],
  };

  it('says imports are drafts and offers the template', () => {
    render(<ImportForm />);
    expect(screen.getByText(/always saved as/)).toHaveTextContent('drafts');
    const link = screen.getByRole('link', { name: 'Download the CSV template' });
    expect(link).toHaveAttribute('download', 'opportunities-template.csv');
    expect(decodeURIComponent(link.getAttribute('href')!)).toContain('title,provider,type');
    expect(screen.getByRole('button', { name: 'Check file' })).toBeDisabled();
  });

  it('checks the file, shows the report, then imports the valid rows as drafts', async () => {
    actions.previewImportAction.mockResolvedValue({ ok: true, report });
    actions.commitImportAction.mockResolvedValue({
      ok: true,
      result: { created: 2, skipped: 0, status: 'DRAFT', issues: [] },
    });
    const user = userEvent.setup();
    render(<ImportForm />);
    await user.click(screen.getByLabelText('Or paste the rows'));
    await user.paste('title,provider,type\nA,B,GRANT');
    await user.click(screen.getByRole('button', { name: 'Check file' }));
    expect(await screen.findByText(/2 of 3 rows can be imported/)).toBeInTheDocument();
    expect(screen.getByText('Type must be one of GRANT, JOB.')).toBeInTheDocument();
    expect(screen.getByText(/Brand New \(new, unverified\)/)).toBeInTheDocument();
    expect(actions.commitImportAction).not.toHaveBeenCalled();
    await user.click(screen.getByRole('button', { name: 'Import 2 valid rows as drafts' }));
    await vi.waitFor(() =>
      expect(actions.commitImportAction).toHaveBeenCalledWith('title,provider,type\nA,B,GRANT'),
    );
    expect(await screen.findByRole('status')).toHaveTextContent('Imported 2 drafts');
  });

  it('shows a refusal from the check', async () => {
    actions.previewImportAction.mockResolvedValue({ ok: false, error: 'Missing columns: type.' });
    const user = userEvent.setup();
    render(<ImportForm />);
    await user.click(screen.getByLabelText('Or paste the rows'));
    await user.paste('title,provider\nA,B');
    await user.click(screen.getByRole('button', { name: 'Check file' }));
    expect(await screen.findByRole('alert')).toHaveTextContent('Missing columns');
  });

  it('does not offer to import when no row is valid', async () => {
    actions.previewImportAction.mockResolvedValue({
      ok: true,
      report: { ...report, validCount: 0, preview: [] },
    });
    const user = userEvent.setup();
    render(<ImportForm />);
    await user.click(screen.getByLabelText('Or paste the rows'));
    await user.paste('title,provider,type\nbad');
    await user.click(screen.getByRole('button', { name: 'Check file' }));
    expect(
      await screen.findByRole('button', { name: 'Import 0 valid rows as drafts' }),
    ).toBeDisabled();
  });
});
