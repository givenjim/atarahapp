import { render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { CaseActions } from './case-actions';

const nav = vi.hoisted(() => ({ refresh: vi.fn(), push: vi.fn() }));
vi.mock('next/navigation', () => ({ useRouter: () => nav }));

const actions = vi.hoisted(() => ({ assignCaseAction: vi.fn(), decideCaseAction: vi.fn() }));
vi.mock('@/app/community-actions', () => actions);
const auth = vi.hoisted(() => ({ reauthAction: vi.fn() }));
vi.mock('@/app/actions', () => auth);

const lastButton = (name: string) => screen.getAllByRole('button', { name }).at(-1)!;

const props = {
  caseId: 'c1',
  meId: 'me',
  assigneeId: null,
  allowedActions: ['NO_ACTION', 'HIDE_CONTENT', 'RESTRICT_ACCOUNT', 'SUSPEND_ACCOUNT'],
  canSuspend: true,
  ownContent: false,
  targetLabel: 'post',
};

beforeEach(() => {
  vi.clearAllMocks();
  actions.assignCaseAction.mockResolvedValue({ ok: true });
  actions.decideCaseAction.mockResolvedValue({ ok: true });
  auth.reauthAction.mockResolvedValue({ ok: true });
});

describe('CaseActions', () => {
  it('offers only the allowed actions, hiding suspend without the permission', () => {
    const { rerender } = render(<CaseActions {...props} />);
    expect(screen.getByRole('button', { name: 'Suspend account' })).toBeInTheDocument();
    rerender(<CaseActions {...props} canSuspend={false} />);
    expect(screen.queryByRole('button', { name: 'Suspend account' })).not.toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Hide content' })).toBeInTheDocument();
  });

  it('offers no decisions on staff content', () => {
    render(<CaseActions {...props} ownContent />);
    expect(screen.queryByRole('button', { name: 'Hide content' })).not.toBeInTheDocument();
    expect(screen.getByText(/you cannot decide on it/)).toBeInTheDocument();
  });

  it('assigns to me and unassigns', async () => {
    const user = userEvent.setup();
    const { rerender } = render(<CaseActions {...props} />);
    await user.click(screen.getByRole('button', { name: 'Assign to me' }));
    expect(actions.assignCaseAction).toHaveBeenCalledWith('c1', 'me');
    rerender(<CaseActions {...props} assigneeId="me" />);
    await user.click(screen.getByRole('button', { name: 'Unassign' }));
    expect(actions.assignCaseAction).toHaveBeenLastCalledWith('c1', null);
  });

  it('requires a reason before hiding and does not call the API without one', async () => {
    const user = userEvent.setup();
    render(<CaseActions {...props} />);
    await user.click(screen.getByRole('button', { name: 'Hide content' }));
    await user.type(screen.getByLabelText('Reason (internal)'), 'no');
    await user.click(lastButton('Hide content'));
    expect(actions.decideCaseAction).not.toHaveBeenCalled();
  });

  it('hides content with a reason and refreshes', async () => {
    const user = userEvent.setup();
    render(<CaseActions {...props} />);
    await user.click(screen.getByRole('button', { name: 'Hide content' }));
    await user.type(screen.getByLabelText('Reason (internal)'), 'Abusive language');
    await user.click(lastButton('Hide content'));
    await vi.waitFor(() =>
      expect(actions.decideCaseAction).toHaveBeenCalledWith(
        'c1',
        'HIDE_CONTENT',
        'Abusive language',
        undefined,
      ),
    );
    await vi.waitFor(() => expect(nav.refresh).toHaveBeenCalled());
  });

  it('dismisses without a reason', async () => {
    const user = userEvent.setup();
    render(<CaseActions {...props} />);
    await user.click(screen.getByRole('button', { name: 'Dismiss (no action)' }));
    await user.click(lastButton('Dismiss report'));
    await vi.waitFor(() =>
      expect(actions.decideCaseAction).toHaveBeenCalledWith('c1', 'NO_ACTION', '', undefined),
    );
  });

  it('shows the API error and does not refresh when the decision fails', async () => {
    actions.decideCaseAction.mockResolvedValue({ ok: false, error: 'Case is already closed.' });
    const user = userEvent.setup();
    render(<CaseActions {...props} />);
    await user.click(screen.getByRole('button', { name: 'Hide content' }));
    await user.type(screen.getByLabelText('Reason (internal)'), 'Abusive language');
    await user.click(lastButton('Hide content'));
    expect(await screen.findByRole('alert')).toHaveTextContent('already closed');
    expect(nav.refresh).not.toHaveBeenCalled();
  });

  it('asks for the authenticator code on suspend, then retries with the same reason', async () => {
    actions.decideCaseAction
      .mockResolvedValueOnce({ ok: false, reauth: true, error: 'Confirm it is you.' })
      .mockResolvedValueOnce({ ok: true });
    const user = userEvent.setup();
    render(<CaseActions {...props} />);
    await user.click(screen.getByRole('button', { name: 'Suspend account' }));
    await user.type(screen.getByLabelText('Reason (internal)'), 'Fraud ring');
    await user.click(lastButton('Suspend account'));
    const code = await screen.findByLabelText(/code/i);
    await user.type(code, '123456');
    await user.keyboard('{Enter}');
    await vi.waitFor(() => expect(actions.decideCaseAction).toHaveBeenCalledTimes(2));
    expect(auth.reauthAction).toHaveBeenCalledWith({ code: '123456' });
    expect(actions.decideCaseAction).toHaveBeenLastCalledWith(
      'c1',
      'SUSPEND_ACCOUNT',
      'Fraud ring',
      undefined,
    );
    await vi.waitFor(() => expect(nav.refresh).toHaveBeenCalled());
  });

  it('restricts for a number of days', async () => {
    const user = userEvent.setup();
    render(<CaseActions {...props} />);
    await user.click(screen.getByRole('button', { name: 'Restrict account' }));
    await user.type(screen.getByLabelText(/Days/), '7');
    await user.type(screen.getByLabelText('Reason for restriction (internal)'), 'Repeated spam');
    const form = screen.getByLabelText(/Days/).closest('form')!;
    await user.click(within(form).getByRole('button', { name: 'Restrict account' }));
    await vi.waitFor(() =>
      expect(actions.decideCaseAction).toHaveBeenCalledWith(
        'c1',
        'RESTRICT_ACCOUNT',
        'Repeated spam',
        7,
      ),
    );
  });
});
