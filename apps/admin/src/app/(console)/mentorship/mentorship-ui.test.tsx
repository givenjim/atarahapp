import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import {
  formatMoney,
  mentorshipMessage,
  reasonProblem,
  statusTone,
} from '@/lib/mentorship';
import { ApplicationActions, MentorActions, SessionTypeToggle } from './mentorship-actions-ui';

const nav = vi.hoisted(() => ({ refresh: vi.fn(), push: vi.fn(), back: vi.fn() }));
vi.mock('next/navigation', () => ({ useRouter: () => nav }));

const actions = vi.hoisted(() => ({
  approveApplicationAction: vi.fn(),
  rejectApplicationAction: vi.fn(),
  mentorStatusAction: vi.fn(),
  featureMentorAction: vi.fn(),
  sessionTypeDisabledAction: vi.fn(),
}));
vi.mock('@/app/mentorship-actions', () => actions);
const auth = vi.hoisted(() => ({ reauthAction: vi.fn() }));
vi.mock('@/app/actions', () => auth);

vi.setConfig({ testTimeout: 30_000 });

beforeEach(() => {
  vi.clearAllMocks();
  for (const fn of Object.values(actions)) fn.mockResolvedValue({ ok: true });
  auth.reauthAction.mockResolvedValue({ ok: true });
});

describe('mentorship helpers', () => {
  it('formats minor units as KES', () => {
    expect(formatMoney(150000)).toBe('KES 1,500');
    expect(formatMoney(150050)).toBe('KES 1,500.50');
  });

  it('needs a real reason', () => {
    expect(reasonProblem('  ')).not.toBeNull();
    expect(reasonProblem('Add a reel')).toBeNull();
  });

  it('maps statuses to tones and errors to plain words', () => {
    expect(statusTone('APPROVED')).toBe('success');
    expect(statusTone('REMOVED')).toBe('danger');
    expect(mentorshipMessage(403, 'x')).toMatch(/permission/);
    expect(mentorshipMessage(409, 'Already decided')).toBe('Already decided');
  });
});

describe('ApplicationActions', () => {
  it('approves with an optional note', async () => {
    render(<ApplicationActions id="a1" name="Wanjiru" />);
    await userEvent.click(screen.getByRole('button', { name: 'Approve Wanjiru' }));
    await userEvent.click(screen.getByRole('button', { name: 'Approve' }));
    expect(actions.approveApplicationAction).toHaveBeenCalledWith('a1', '');
    expect(nav.refresh).toHaveBeenCalled();
  });

  it('will not reject without a reason, then sends it', async () => {
    render(<ApplicationActions id="a1" name="Wanjiru" />);
    await userEvent.click(screen.getByRole('button', { name: 'Reject Wanjiru' }));
    await userEvent.click(screen.getByRole('button', { name: 'Reject' }));
    expect(actions.rejectApplicationAction).not.toHaveBeenCalled();
    await userEvent.type(screen.getByLabelText(/Reason/), 'Add a longer reel');
    await userEvent.click(screen.getByRole('button', { name: 'Reject' }));
    expect(actions.rejectApplicationAction).toHaveBeenCalledWith('a1', 'Add a longer reel');
  });
});

describe('MentorActions', () => {
  it('offers pause and remove for an active mentor, and resume for a paused one', () => {
    const { rerender } = render(
      <MentorActions id="m1" name="Wanjiru" status="APPROVED" featured={false} />,
    );
    expect(screen.getByRole('button', { name: 'Pause Wanjiru' })).toBeTruthy();
    expect(screen.getByRole('button', { name: 'Remove Wanjiru' })).toBeTruthy();
    expect(screen.getByRole('button', { name: 'Feature Wanjiru' })).toBeTruthy();
    rerender(<MentorActions id="m1" name="Wanjiru" status="PAUSED" featured={false} />);
    expect(screen.getByRole('button', { name: 'Resume Wanjiru' })).toBeTruthy();
    expect(screen.queryByRole('button', { name: 'Feature Wanjiru' })).toBeNull();
    rerender(<MentorActions id="m1" name="Wanjiru" status="REMOVED" featured={false} />);
    expect(screen.queryByRole('button', { name: 'Pause Wanjiru' })).toBeNull();
  });

  it('removes with a reason and asks for the authenticator code when the API wants it', async () => {
    actions.mentorStatusAction.mockResolvedValueOnce({
      ok: false,
      reauth: true,
      error: 'Confirm your authenticator code to continue.',
    });
    render(<MentorActions id="m1" name="Wanjiru" status="APPROVED" featured={false} />);
    await userEvent.click(screen.getByRole('button', { name: 'Remove Wanjiru' }));
    await userEvent.type(screen.getByLabelText(/Reason/), 'Terms breach');
    await userEvent.click(screen.getByRole('button', { name: 'Remove' }));
    expect(actions.mentorStatusAction).toHaveBeenCalledWith('m1', 'remove', 'Terms breach');
    expect(await screen.findByLabelText(/code/i)).toBeTruthy();
  });

  it('features a mentor', async () => {
    render(<MentorActions id="m1" name="Wanjiru" status="APPROVED" featured={false} />);
    await userEvent.click(screen.getByRole('button', { name: 'Feature Wanjiru' }));
    expect(actions.featureMentorAction).toHaveBeenCalledWith('m1', true);
  });
});

describe('SessionTypeToggle', () => {
  it('switches a session type off with a note', async () => {
    render(<SessionTypeToggle id="s1" name="Portfolio review" disabled={false} />);
    await userEvent.click(screen.getByRole('button', { name: 'Switch off Portfolio review' }));
    await userEvent.type(screen.getByLabelText(/Note/), 'Price looks wrong');
    await userEvent.click(screen.getByRole('button', { name: 'Switch off' }));
    expect(actions.sessionTypeDisabledAction).toHaveBeenCalledWith('s1', true, 'Price looks wrong');
  });

  it('allows it again', async () => {
    render(<SessionTypeToggle id="s1" name="Portfolio review" disabled />);
    await userEvent.click(screen.getByRole('button', { name: 'Allow Portfolio review' }));
    await userEvent.click(screen.getByRole('button', { name: 'Allow' }));
    expect(actions.sessionTypeDisabledAction).toHaveBeenCalledWith('s1', false, '');
  });
});
