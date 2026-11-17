import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { emptyBroadcastForm } from '@/lib/broadcasts';
import { BroadcastForm } from './broadcast-form';
import { CancelBroadcast } from './[id]/cancel-broadcast';

const nav = vi.hoisted(() => ({ refresh: vi.fn(), push: vi.fn(), back: vi.fn() }));
vi.mock('next/navigation', () => ({ useRouter: () => nav }));

const actions = vi.hoisted(() => ({
  createBroadcastAction: vi.fn(),
  previewAudienceAction: vi.fn(),
  cancelBroadcastAction: vi.fn(),
}));
vi.mock('@/app/broadcast-actions', () => actions);
const auth = vi.hoisted(() => ({ reauthAction: vi.fn() }));
vi.mock('@/app/actions', () => auth);

const options = {
  disciplines: [
    { id: 'd1', name: 'Film / Video' },
    { id: 'd2', name: 'Music' },
  ],
  counties: [{ id: 'c1', name: 'Nairobi' }],
};

// Typing into a long form is slow on a busy machine.
vi.setConfig({ testTimeout: 60_000 });

beforeEach(() => {
  vi.clearAllMocks();
  actions.createBroadcastAction.mockResolvedValue({ ok: true, id: 'b1' });
  actions.previewAudienceAction.mockResolvedValue({ ok: true, recipients: 42 });
  actions.cancelBroadcastAction.mockResolvedValue({ ok: true });
  auth.reauthAction.mockResolvedValue({ ok: true });
});

async function fillMessage(user: ReturnType<typeof userEvent.setup>) {
  await user.type(screen.getByLabelText(/^Title/), 'New opportunities this week');
  await user.type(screen.getByLabelText(/^Message/), 'Twelve new listings were added.');
}

describe('BroadcastForm', () => {
  it('checks the form before anything is sent', async () => {
    const user = userEvent.setup();
    render(<BroadcastForm initial={emptyBroadcastForm()} {...options} />);
    await user.click(screen.getByRole('button', { name: 'Send broadcast' }));
    expect(screen.getByRole('alert')).toHaveTextContent(/title/);
    expect(actions.createBroadcastAction).not.toHaveBeenCalled();
  });

  it('shows a picker for the audience and counts the recipients', async () => {
    const user = userEvent.setup();
    render(<BroadcastForm initial={emptyBroadcastForm()} {...options} />);
    expect(screen.queryByLabelText('Discipline')).not.toBeInTheDocument();

    await user.selectOptions(screen.getByLabelText('Audience'), 'DISCIPLINE');
    expect(screen.getByRole('option', { name: 'Film / Video' })).toBeInTheDocument();
    await user.selectOptions(screen.getByLabelText('Discipline'), 'd2');
    await user.click(screen.getByRole('button', { name: 'Count recipients' }));
    expect(actions.previewAudienceAction).toHaveBeenCalledWith('DISCIPLINE', 'd2');
    expect(await screen.findByRole('status')).toHaveTextContent('42 members would receive this.');

    // Changing the audience clears the old count.
    await user.selectOptions(screen.getByLabelText('Audience'), 'COUNTY');
    expect(screen.getByRole('status')).toHaveTextContent('');
    await user.selectOptions(screen.getByLabelText('County'), 'c1');
    expect(screen.getByLabelText('County')).toHaveValue('c1');

    await user.selectOptions(screen.getByLabelText('Audience'), 'ROLE');
    expect(screen.getByRole('option', { name: 'Mentor' })).toBeInTheDocument();
  });

  it('shows an error when counting fails', async () => {
    actions.previewAudienceAction.mockResolvedValue({
      ok: false,
      error: 'That audience does not exist.',
    });
    const user = userEvent.setup();
    render(<BroadcastForm initial={emptyBroadcastForm()} {...options} />);
    await user.click(screen.getByRole('button', { name: 'Count recipients' }));
    expect(await screen.findByRole('alert')).toHaveTextContent('That audience does not exist.');
  });

  it('sends to everyone, asks for the authenticator code, then retries and opens the broadcast', async () => {
    actions.createBroadcastAction
      .mockResolvedValueOnce({ ok: false, reauth: true, error: 'Confirm it is you.' })
      .mockResolvedValueOnce({ ok: true, id: 'b9' });
    const user = userEvent.setup();
    render(<BroadcastForm initial={emptyBroadcastForm()} {...options} />);
    await fillMessage(user);
    await user.click(screen.getByRole('button', { name: 'Send broadcast' }));
    await user.type(await screen.findByLabelText(/code/i), '654321');
    await user.keyboard('{Enter}');
    await vi.waitFor(() => expect(actions.createBroadcastAction).toHaveBeenCalledTimes(2));
    expect(auth.reauthAction).toHaveBeenCalledWith({ code: '654321' });
    expect(actions.createBroadcastAction).toHaveBeenLastCalledWith(
      expect.objectContaining({
        title: 'New opportunities this week',
        target: 'ALL',
        when: 'now',
      }),
    );
    await vi.waitFor(() => expect(nav.push).toHaveBeenCalledWith('/notifications/b9'));
  });

  it('scheduling shows the Nairobi-time field and changes the button', async () => {
    const user = userEvent.setup();
    render(<BroadcastForm initial={emptyBroadcastForm()} {...options} />);
    expect(screen.queryByLabelText(/Send at/)).not.toBeInTheDocument();
    await user.click(screen.getByLabelText('Schedule'));
    expect(screen.getByLabelText('Send at (Nairobi time)')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Schedule broadcast' })).toBeInTheDocument();
    await fillMessage(user);
    await user.click(screen.getByRole('button', { name: 'Schedule broadcast' }));
    expect(screen.getByRole('alert')).toHaveTextContent(/date and time/);
    expect(actions.createBroadcastAction).not.toHaveBeenCalled();
  });

  it('shows an API refusal on the form', async () => {
    actions.createBroadcastAction.mockResolvedValue({
      ok: false,
      error: 'Pick a time in the future.',
    });
    const user = userEvent.setup();
    render(<BroadcastForm initial={emptyBroadcastForm()} {...options} />);
    await fillMessage(user);
    await user.click(screen.getByRole('button', { name: 'Send broadcast' }));
    expect(await screen.findByRole('alert')).toHaveTextContent('Pick a time in the future.');
    expect(nav.push).not.toHaveBeenCalled();
  });
});

describe('CancelBroadcast', () => {
  it('confirms, cancels and refreshes', async () => {
    const user = userEvent.setup();
    render(<CancelBroadcast id="b1" />);
    await user.click(screen.getByRole('button', { name: 'Cancel broadcast' }));
    expect(screen.getByText(/nobody is told/i)).toBeInTheDocument();
    await user.click(screen.getAllByRole('button', { name: 'Cancel broadcast' }).at(-1)!);
    await vi.waitFor(() => expect(actions.cancelBroadcastAction).toHaveBeenCalledWith('b1'));
    await vi.waitFor(() => expect(nav.refresh).toHaveBeenCalled());
  });

  it('shows why a broadcast could not be cancelled', async () => {
    actions.cancelBroadcastAction.mockResolvedValue({
      ok: false,
      error: 'It has already started sending.',
    });
    const user = userEvent.setup();
    render(<CancelBroadcast id="b1" />);
    await user.click(screen.getByRole('button', { name: 'Cancel broadcast' }));
    await user.click(screen.getAllByRole('button', { name: 'Cancel broadcast' }).at(-1)!);
    expect(await screen.findByText('It has already started sending.')).toBeInTheDocument();
    expect(nav.refresh).not.toHaveBeenCalled();
  });
});
