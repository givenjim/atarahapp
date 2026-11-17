import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { GroupManager } from './group-manager';

const nav = vi.hoisted(() => ({ refresh: vi.fn(), push: vi.fn() }));
vi.mock('next/navigation', () => ({ useRouter: () => nav }));

const actions = vi.hoisted(() => ({
  addModeratorAction: vi.fn(),
  removeModeratorAction: vi.fn(),
  pinPostAction: vi.fn(),
  unpinPostAction: vi.fn(),
  archiveGroupAction: vi.fn(),
}));
vi.mock('@/app/community-actions', () => actions);
const auth = vi.hoisted(() => ({ reauthAction: vi.fn() }));
vi.mock('@/app/actions', () => auth);

const USER = '3f0a1c2e-1b2c-4d3e-8f4a-5b6c7d8e9f00';
const POST = '4a1b2c3d-1b2c-4d3e-8f4a-5b6c7d8e9f11';

const props = {
  groupId: 'g1',
  name: 'Nairobi Filmmakers',
  moderators: [{ id: 'u1', name: 'Wanjiru', handle: 'wanjiru', role: 'MODERATOR' }],
  pinnedPostIds: [POST],
};

beforeEach(() => {
  vi.clearAllMocks();
  for (const fn of Object.values(actions)) fn.mockResolvedValue({ ok: true });
  auth.reauthAction.mockResolvedValue({ ok: true });
});

describe('GroupManager', () => {
  it('adds a moderator by user id', async () => {
    const user = userEvent.setup();
    render(<GroupManager {...props} />);
    await user.type(screen.getByLabelText('Member user id'), USER);
    await user.click(screen.getByRole('button', { name: 'Add moderator' }));
    await vi.waitFor(() =>
      expect(actions.addModeratorAction).toHaveBeenCalledWith('g1', USER, 'MODERATOR'),
    );
    await vi.waitFor(() => expect(nav.refresh).toHaveBeenCalled());
  });

  it('removes a moderator and unpins a post', async () => {
    const user = userEvent.setup();
    render(<GroupManager {...props} />);
    await user.click(screen.getByRole('button', { name: 'Remove Wanjiru' }));
    await vi.waitFor(() => expect(actions.removeModeratorAction).toHaveBeenCalledWith('g1', 'u1'));
    await user.click(screen.getByRole('button', { name: `Unpin ${POST}` }));
    await vi.waitFor(() => expect(actions.unpinPostAction).toHaveBeenCalledWith('g1', POST));
  });

  it('pins a post and shows the API error when it fails', async () => {
    actions.pinPostAction.mockResolvedValue({
      ok: false,
      error: 'That post is not in this group.',
    });
    const user = userEvent.setup();
    render(<GroupManager {...props} />);
    await user.type(screen.getByLabelText('Post id'), POST);
    await user.click(screen.getByRole('button', { name: 'Pin post' }));
    expect(await screen.findByRole('alert')).toHaveTextContent('not in this group');
    expect(nav.refresh).not.toHaveBeenCalled();
  });

  it('archives only after confirmation and a fresh authenticator code', async () => {
    actions.archiveGroupAction
      .mockResolvedValueOnce({ ok: false, reauth: true, error: 'Confirm it is you.' })
      .mockResolvedValueOnce({ ok: true });
    const user = userEvent.setup();
    render(<GroupManager {...props} />);
    await user.click(screen.getByRole('button', { name: 'Archive group' }));
    expect(actions.archiveGroupAction).not.toHaveBeenCalled();
    await user.click(screen.getAllByRole('button', { name: 'Archive group' }).at(-1)!);
    const code = await screen.findByLabelText(/code/i);
    await user.type(code, '123456');
    await user.keyboard('{Enter}');
    await vi.waitFor(() => expect(actions.archiveGroupAction).toHaveBeenCalledTimes(2));
    await vi.waitFor(() => expect(nav.push).toHaveBeenCalledWith('/groups'));
  });
});
