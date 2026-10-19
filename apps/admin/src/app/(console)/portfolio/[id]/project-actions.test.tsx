import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { ProjectActions } from './project-actions';

const nav = vi.hoisted(() => ({ refresh: vi.fn(), push: vi.fn() }));
vi.mock('next/navigation', () => ({ useRouter: () => nav }));

const actions = vi.hoisted(() => ({
  hideProjectAction: vi.fn(),
  restoreProjectAction: vi.fn(),
}));
vi.mock('@/app/portfolio-actions', () => actions);

const lastButton = (name: string) => screen.getAllByRole('button', { name }).at(-1)!;

beforeEach(() => {
  vi.clearAllMocks();
  actions.hideProjectAction.mockResolvedValue({ ok: true });
  actions.restoreProjectAction.mockResolvedValue({ ok: true });
});

describe('ProjectActions', () => {
  it('offers Hide for a visible project and Restore for a hidden one', () => {
    const { rerender } = render(<ProjectActions id="p1" title="Reel" hidden={false} />);
    expect(screen.getByRole('button', { name: 'Hide project' })).toBeInTheDocument();
    expect(screen.queryByRole('button', { name: 'Restore project' })).not.toBeInTheDocument();
    rerender(<ProjectActions id="p1" title="Reel" hidden />);
    expect(screen.getByRole('button', { name: 'Restore project' })).toBeInTheDocument();
  });

  it('refuses a reason that is too short without calling the API', async () => {
    const user = userEvent.setup();
    render(<ProjectActions id="p1" title="Reel" hidden={false} />);
    await user.click(screen.getByRole('button', { name: 'Hide project' }));
    await user.type(screen.getByLabelText('Reason for hiding'), 'no');
    await user.click(lastButton('Hide project'));
    expect(await screen.findByRole('alert')).toHaveTextContent(/at least 5/);
    expect(actions.hideProjectAction).not.toHaveBeenCalled();
  });

  it('hides with the reason and refreshes', async () => {
    const user = userEvent.setup();
    render(<ProjectActions id="p1" title="Reel" hidden={false} />);
    await user.click(screen.getByRole('button', { name: 'Hide project' }));
    await user.type(screen.getByLabelText('Reason for hiding'), 'Copied work');
    await user.click(lastButton('Hide project'));
    expect(actions.hideProjectAction).toHaveBeenCalledWith('p1', 'Copied work');
    await vi.waitFor(() => expect(nav.refresh).toHaveBeenCalled());
  });

  it('shows the API error in plain language when hiding fails', async () => {
    actions.hideProjectAction.mockResolvedValue({
      ok: false,
      error: 'This project is already hidden.',
    });
    const user = userEvent.setup();
    render(<ProjectActions id="p1" title="Reel" hidden={false} />);
    await user.click(screen.getByRole('button', { name: 'Hide project' }));
    await user.type(screen.getByLabelText('Reason for hiding'), 'Copied work');
    await user.click(lastButton('Hide project'));
    expect(await screen.findByRole('alert')).toHaveTextContent('already hidden');
    expect(nav.refresh).not.toHaveBeenCalled();
  });

  it('restores only after confirmation', async () => {
    const user = userEvent.setup();
    render(<ProjectActions id="p1" title="Reel" hidden />);
    await user.click(screen.getByRole('button', { name: 'Restore project' }));
    expect(actions.restoreProjectAction).not.toHaveBeenCalled();
    await user.click(lastButton('Restore project'));
    expect(actions.restoreProjectAction).toHaveBeenCalledWith('p1');
    await vi.waitFor(() => expect(nav.refresh).toHaveBeenCalled());
  });
});
