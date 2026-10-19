import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { HomePin } from './home-pin';

const nav = vi.hoisted(() => ({ refresh: vi.fn(), push: vi.fn() }));
vi.mock('next/navigation', () => ({ useRouter: () => nav }));

const actions = vi.hoisted(() => ({ setFeaturedArticleAction: vi.fn() }));
vi.mock('@/app/articles-actions', () => actions);

const options = [
  { id: 'a1', title: 'First', authorName: 'Ama' },
  { id: 'a2', title: 'Second', authorName: 'Kofi' },
];

beforeEach(() => {
  vi.clearAllMocks();
  actions.setFeaturedArticleAction.mockResolvedValue({ ok: true });
});

describe('HomePin', () => {
  it('pins the chosen published article', async () => {
    const user = userEvent.setup();
    render(<HomePin current={{ id: null, title: null }} options={options} />);
    expect(screen.getByRole('button', { name: 'Pin' })).toBeDisabled();
    await user.selectOptions(screen.getByLabelText('Published article'), 'a2');
    await user.click(screen.getByRole('button', { name: 'Pin' }));
    expect(actions.setFeaturedArticleAction).toHaveBeenCalledWith('a2');
    await vi.waitFor(() => expect(nav.refresh).toHaveBeenCalled());
  });

  it('shows the pinned article and un-pins with null', async () => {
    const user = userEvent.setup();
    render(<HomePin current={{ id: 'a1', title: 'First' }} options={options} />);
    expect(screen.getByText('First', { selector: 'strong' })).toBeInTheDocument();
    await user.click(screen.getByRole('button', { name: 'Un-pin' }));
    expect(actions.setFeaturedArticleAction).toHaveBeenCalledWith(null);
  });

  it('shows the API error and does not refresh', async () => {
    actions.setFeaturedArticleAction.mockResolvedValue({
      ok: false,
      error: 'Only a published article can be pinned.',
    });
    const user = userEvent.setup();
    render(<HomePin current={{ id: null, title: null }} options={options} />);
    await user.selectOptions(screen.getByLabelText('Published article'), 'a1');
    await user.click(screen.getByRole('button', { name: 'Pin' }));
    expect(await screen.findByRole('alert')).toHaveTextContent('Only a published article');
    expect(nav.refresh).not.toHaveBeenCalled();
  });

  it('explains when there is nothing to pin', () => {
    render(<HomePin current={{ id: null, title: null }} options={[]} />);
    expect(screen.getByText(/no published articles/i)).toBeInTheDocument();
    expect(screen.queryByRole('button', { name: 'Pin' })).not.toBeInTheDocument();
  });
});
