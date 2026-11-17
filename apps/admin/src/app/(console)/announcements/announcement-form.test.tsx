import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { AnnouncementForm } from './announcement-form';

const nav = vi.hoisted(() => ({ refresh: vi.fn(), push: vi.fn() }));
vi.mock('next/navigation', () => ({ useRouter: () => nav }));

const actions = vi.hoisted(() => ({ createAnnouncementAction: vi.fn() }));
vi.mock('@/app/community-actions', () => actions);
const auth = vi.hoisted(() => ({ reauthAction: vi.fn() }));
vi.mock('@/app/actions', () => auth);

const GROUP = '3f0a1c2e-1b2c-4d3e-8f4a-5b6c7d8e9f00';
const groups = [{ id: GROUP, name: 'Nairobi Filmmakers' }];

beforeEach(() => {
  vi.clearAllMocks();
  actions.createAnnouncementAction.mockResolvedValue({ ok: true });
  auth.reauthAction.mockResolvedValue({ ok: true });
});

describe('AnnouncementForm', () => {
  it('refuses an empty announcement without calling the API', async () => {
    const user = userEvent.setup();
    render(<AnnouncementForm groups={groups} />);
    await user.click(screen.getByRole('button', { name: 'Review and post' }));
    expect(await screen.findByRole('alert')).toHaveTextContent('Write the announcement');
    expect(actions.createAnnouncementAction).not.toHaveBeenCalled();
  });

  it('posts to the chosen group after confirmation', async () => {
    const user = userEvent.setup();
    render(<AnnouncementForm groups={groups} />);
    await user.type(screen.getByLabelText('Announcement'), 'Meet-up on Saturday');
    await user.selectOptions(screen.getByLabelText('Audience'), GROUP);
    await user.click(screen.getByRole('button', { name: 'Review and post' }));
    expect(actions.createAnnouncementAction).not.toHaveBeenCalled();
    await user.click(screen.getAllByRole('button', { name: 'Post announcement' }).at(-1)!);
    await vi.waitFor(() =>
      expect(actions.createAnnouncementAction).toHaveBeenCalledWith('Meet-up on Saturday', GROUP),
    );
    await vi.waitFor(() => expect(nav.refresh).toHaveBeenCalled());
  });

  it('asks for a fresh authenticator code, then retries', async () => {
    actions.createAnnouncementAction
      .mockResolvedValueOnce({ ok: false, reauth: true, error: 'Confirm it is you.' })
      .mockResolvedValueOnce({ ok: true });
    const user = userEvent.setup();
    render(<AnnouncementForm groups={groups} />);
    await user.type(screen.getByLabelText('Announcement'), 'Hello everyone');
    await user.click(screen.getByRole('button', { name: 'Review and post' }));
    await user.click(screen.getAllByRole('button', { name: 'Post announcement' }).at(-1)!);
    const code = await screen.findByLabelText(/code/i);
    await user.type(code, '654321');
    await user.keyboard('{Enter}');
    await vi.waitFor(() => expect(actions.createAnnouncementAction).toHaveBeenCalledTimes(2));
    expect(auth.reauthAction).toHaveBeenCalledWith({ code: '654321' });
    await vi.waitFor(() => expect(nav.refresh).toHaveBeenCalled());
  });
});
