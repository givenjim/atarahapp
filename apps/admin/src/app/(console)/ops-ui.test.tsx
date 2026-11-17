import { render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { EventChartCard } from '@/components/ops/event-chart';
import { PriorityPill } from '@/components/ops/priority-pill';
import { buildCharts } from '@/lib/ops';
import { RoleManager } from './users/[id]/role-manager';
import { UserActions } from './users/[id]/user-actions';
import { FlagSwitch, SettingRow } from './settings/settings-controls';
import { RetryJob } from './settings/jobs/retry-job';

const nav = vi.hoisted(() => ({ refresh: vi.fn(), push: vi.fn() }));
vi.mock('next/navigation', () => ({ useRouter: () => nav }));

const ops = vi.hoisted(() => ({
  assignRoleAction: vi.fn(),
  revokeRoleAction: vi.fn(),
  suspendTimedAction: vi.fn(),
  retryJobAction: vi.fn(),
  setFlagAction: vi.fn(),
  setSettingAction: vi.fn(),
}));
vi.mock('@/app/ops-actions', () => ops);
const auth = vi.hoisted(() => ({ reauthAction: vi.fn(), reactivateUserAction: vi.fn() }));
vi.mock('@/app/actions', () => auth);

vi.setConfig({ testTimeout: 60_000 });

beforeEach(() => {
  vi.clearAllMocks();
  for (const f of Object.values(ops)) f.mockResolvedValue({ ok: true });
  auth.reauthAction.mockResolvedValue({ ok: true });
  auth.reactivateUserAction.mockResolvedValue({ ok: true });
});

const reauthNeeded = { ok: false, reauth: true, error: 'Authenticator check needed.' };

describe('EventChartCard', () => {
  const chart = buildCharts(
    {
      from: '2026-11-01',
      to: '2026-11-03',
      series: [{ day: '2026-11-02', name: 'post_created', events: 4, actors: 3 }],
      totals: [{ name: 'post_created', events: 4, activeMemberDays: 3 }],
    },
    ['post_created'],
  )[0]!;

  it('describes the chart in text and offers the same numbers as a table', () => {
    render(
      <ul>
        <EventChartCard chart={chart} />
      </ul>,
    );
    expect(screen.getByRole('img')).toHaveAttribute(
      'aria-label',
      expect.stringContaining('4 events in total, busiest day 2026-11-02 with 4'),
    );
    expect(screen.getByRole('heading', { name: 'Posts created' })).toBeInTheDocument();
    expect(screen.getAllByRole('row')).toHaveLength(4); // header + 3 days
    expect(screen.getByText('2026-11-02: 4 events, 3 members')).toBeInTheDocument();
  });
});

describe('PriorityPill', () => {
  it('states priority in words', () => {
    render(<PriorityPill priority="URGENT" />);
    expect(screen.getByText('Urgent')).toHaveClass('danger');
  });
});

describe('RoleManager', () => {
  const grants = [
    {
      key: 'MENTOR',
      name: 'Mentor',
      isStaff: false,
      grantedAt: '2026-11-01T09:00:00Z',
      grantedBy: 'Wanjiru',
      revocable: true,
    },
    {
      key: 'MODERATOR',
      name: 'Moderator',
      isStaff: true,
      grantedAt: '2026-11-02T09:00:00Z',
      grantedBy: null,
      revocable: false,
    },
  ];
  const props = {
    userId: 'u1',
    name: 'Nia',
    grants,
    assignable: [{ key: 'SELLER', name: 'Seller' }],
    canAssign: true,
  };

  it('shows who granted each role and only the Revoke buttons the caller may use', () => {
    render(<RoleManager {...props} />);
    expect(screen.getByText('Wanjiru')).toBeInTheDocument();
    expect(screen.getByText('System')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Revoke Mentor' })).toBeInTheDocument();
    expect(screen.queryByRole('button', { name: 'Revoke Moderator' })).toBeNull();
  });

  it('hides Assign without the permission or without roles left to offer', () => {
    const { rerender } = render(<RoleManager {...props} canAssign={false} />);
    expect(screen.queryByRole('button', { name: 'Assign a role' })).toBeNull();
    rerender(<RoleManager {...props} assignable={[]} />);
    expect(screen.queryByRole('button', { name: 'Assign a role' })).toBeNull();
  });

  it('assigns a role with a reason, asking for the authenticator code first', async () => {
    const user = userEvent.setup();
    ops.assignRoleAction.mockResolvedValueOnce(reauthNeeded);
    render(<RoleManager {...props} />);
    await user.click(screen.getByRole('button', { name: 'Assign a role' }));
    const dialog = screen.getByRole('dialog', { name: /Assign a role to Nia/ });
    await user.type(within(dialog).getByLabelText(/^Reason/), 'Approved as a seller');
    await user.click(within(dialog).getByRole('button', { name: 'Assign role' }));
    expect(ops.assignRoleAction).toHaveBeenCalledWith('u1', 'SELLER', 'Approved as a seller');
    await user.type(await screen.findByLabelText('Authenticator code'), '123456');
    await user.click(screen.getByRole('button', { name: 'Confirm' }));
    expect(auth.reauthAction).toHaveBeenCalledWith({ code: '123456' });
    expect(ops.assignRoleAction).toHaveBeenCalledTimes(2);
    expect(nav.refresh).toHaveBeenCalled();
  });

  it('revokes with the reason', async () => {
    const user = userEvent.setup();
    render(<RoleManager {...props} />);
    await user.click(screen.getByRole('button', { name: 'Revoke Mentor' }));
    const dialog = screen.getByRole('dialog', { name: /Revoke Mentor from Nia/ });
    await user.type(within(dialog).getByLabelText(/^Reason/), 'Left the programme');
    await user.click(within(dialog).getByRole('button', { name: 'Revoke role' }));
    expect(ops.revokeRoleAction).toHaveBeenCalledWith('u1', 'MENTOR', 'Left the programme');
  });
});

describe('UserActions', () => {
  it('suspends with a reason and a number of days', async () => {
    const user = userEvent.setup();
    render(<UserActions userId="u1" name="Nia" status="ACTIVE" isSelf={false} />);
    await user.click(screen.getByRole('button', { name: 'Suspend account' }));
    const dialog = screen.getByRole('dialog', { name: /Suspend Nia/ });
    await user.type(within(dialog).getByLabelText('Reason for suspension'), 'Repeated harassment');
    await user.type(within(dialog).getByLabelText(/Number of days/), '14');
    await user.click(within(dialog).getByRole('button', { name: 'Suspend account' }));
    expect(ops.suspendTimedAction).toHaveBeenCalledWith('u1', {
      reason: 'Repeated harassment',
      days: '14',
    });
  });

  it('checks the form before calling the API', async () => {
    const user = userEvent.setup();
    render(<UserActions userId="u1" name="Nia" status="ACTIVE" isSelf={false} />);
    await user.click(screen.getByRole('button', { name: 'Suspend account' }));
    const dialog = screen.getByRole('dialog', { name: /Suspend Nia/ });
    await user.click(within(dialog).getByRole('button', { name: 'Suspend account' }));
    expect(within(dialog).getByRole('alert')).toHaveTextContent(/at least 5/);
    expect(ops.suspendTimedAction).not.toHaveBeenCalled();
  });

  it('offers Reactivate for a suspended account and nothing for your own', () => {
    const { rerender } = render(
      <UserActions userId="u1" name="Nia" status="SUSPENDED" isSelf={false} />,
    );
    expect(screen.getByRole('button', { name: 'Reactivate account' })).toBeInTheDocument();
    rerender(<UserActions userId="u1" name="Nia" status="ACTIVE" isSelf />);
    expect(screen.getByText(/cannot change the status of your own/)).toBeInTheDocument();
  });
});

describe('settings controls', () => {
  it('flips a feature flag through the re-auth dialog', async () => {
    const user = userEvent.setup();
    ops.setFlagAction.mockResolvedValueOnce(reauthNeeded);
    render(
      <FlagSwitch flag={{ key: 'opportunities', description: 'Opps', enabled: true, phase: 1 }} />,
    );
    await user.click(screen.getByRole('button', { name: 'Turn off' }));
    expect(ops.setFlagAction).toHaveBeenCalledWith('opportunities', false);
    await user.type(await screen.findByLabelText('Authenticator code'), '654321');
    await user.click(screen.getByRole('button', { name: 'Confirm' }));
    expect(ops.setFlagAction).toHaveBeenCalledTimes(2);
  });

  it('keeps a number a number and disables Save until the value changes', async () => {
    const user = userEvent.setup();
    render(
      <SettingRow
        setting={{
          key: 'membership.pro.price_minor',
          value: 500,
          description: null,
          updatedAt: '',
        }}
      />,
    );
    const save = screen.getByRole('button', { name: 'Save' });
    expect(save).toBeDisabled();
    const field = screen.getByLabelText('membership.pro.price_minor');
    expect(field).toHaveAttribute('type', 'number');
    await user.clear(field);
    await user.type(field, '750');
    await user.click(save);
    expect(ops.setSettingAction).toHaveBeenCalledWith('membership.pro.price_minor', 500, '750');
  });

  it('offers true or false for a boolean setting', () => {
    render(
      <SettingRow
        setting={{ key: 'x.flag', value: true, description: 'A switch', updatedAt: '' }}
      />,
    );
    expect(screen.getByRole('combobox', { name: 'x.flag' })).toHaveValue('true');
  });
});

describe('RetryJob', () => {
  it('retries a failed job and refreshes the list', async () => {
    const user = userEvent.setup();
    render(<RetryJob queue="exports" jobId="42" />);
    await user.click(screen.getByRole('button', { name: 'Retry job 42 in exports' }));
    expect(ops.retryJobAction).toHaveBeenCalledWith('exports', '42');
    expect(nav.refresh).toHaveBeenCalled();
  });

  it('shows a refusal from the API', async () => {
    const user = userEvent.setup();
    ops.retryJobAction.mockResolvedValueOnce({ ok: false, error: 'That job is gone.' });
    render(<RetryJob queue="exports" jobId="42" />);
    await user.click(screen.getByRole('button', { name: /Retry job 42/ }));
    expect(await screen.findByRole('alert')).toHaveTextContent('That job is gone.');
  });
});
