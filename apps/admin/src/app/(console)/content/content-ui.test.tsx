import { render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { emptyHelpArticleForm } from '@/lib/help';
import { ArticleRowActions } from './article-row-actions';
import { FaqManager } from './faq/faq-manager';
import { HelpArticleForm } from './help-article-form';
import { LegalEditor } from './legal/[id]/legal-editor';
import { NewLegalVersion } from './legal/new-legal-version';

const nav = vi.hoisted(() => ({ refresh: vi.fn(), push: vi.fn(), back: vi.fn() }));
vi.mock('next/navigation', () => ({ useRouter: () => nav }));

const actions = vi.hoisted(() => ({
  saveHelpArticleAction: vi.fn(),
  setHelpArticlePublishedAction: vi.fn(),
  reorderHelpArticlesAction: vi.fn(),
  deleteHelpArticleAction: vi.fn(),
  saveFaqAction: vi.fn(),
  setFaqPublishedAction: vi.fn(),
  reorderFaqAction: vi.fn(),
  deleteFaqAction: vi.fn(),
  saveLegalAction: vi.fn(),
  publishLegalAction: vi.fn(),
}));
vi.mock('@/app/help-actions', () => actions);
// The text block editor comes from the article editor, which imports its own actions.
vi.mock('@/app/articles-actions', () => ({
  requestImageUploadAction: vi.fn(),
  completeImageUploadAction: vi.fn(),
  saveArticleAction: vi.fn(),
  articleLifecycleAction: vi.fn(),
}));
const auth = vi.hoisted(() => ({ reauthAction: vi.fn() }));
vi.mock('@/app/actions', () => auth);

vi.setConfig({ testTimeout: 60_000 });

beforeEach(() => {
  vi.clearAllMocks();
  for (const fn of Object.values(actions)) fn.mockResolvedValue({ ok: true });
  auth.reauthAction.mockResolvedValue({ ok: true });
});

const faq = [
  {
    id: 'f1',
    question: 'How do I report a post?',
    answer: 'Tap the dots, then Report.',
    sortOrder: 0,
    published: true,
  },
  {
    id: 'f2',
    question: 'Can I block someone?',
    answer: 'Yes, from their profile.',
    sortOrder: 1,
    published: false,
  },
  {
    id: 'f3',
    question: 'Who sees my contact details?',
    answer: 'Only who you allow.',
    sortOrder: 2,
    published: true,
  },
];

describe('FaqManager', () => {
  it('lists entries with their state and disables moves at the ends', () => {
    render(<FaqManager entries={faq} />);
    expect(screen.getByText('How do I report a post?')).toBeInTheDocument();
    expect(screen.getAllByText('Published')).toHaveLength(2);
    expect(screen.getByText('Draft')).toBeInTheDocument();
    expect(
      screen.getByRole('button', { name: /Move “How do I report a post\?” up/ }),
    ).toBeDisabled();
    expect(
      screen.getByRole('button', { name: /Move “Who sees my contact details\?” down/ }),
    ).toBeDisabled();
  });

  it('moves an entry by swapping the order with its neighbour', async () => {
    const user = userEvent.setup();
    render(<FaqManager entries={faq} />);
    await user.click(screen.getByRole('button', { name: /Move “Can I block someone\?” up/ }));
    expect(actions.reorderFaqAction).toHaveBeenCalledWith([
      { id: 'f2', sortOrder: 0 },
      { id: 'f1', sortOrder: 1 },
    ]);
    await vi.waitFor(() => expect(nav.refresh).toHaveBeenCalled());
  });

  it('adds a question at the end and checks it first', async () => {
    const user = userEvent.setup();
    render(<FaqManager entries={faq} />);
    await user.click(screen.getByRole('button', { name: 'New question' }));
    const dialog = screen.getByRole('dialog');
    await user.click(within(dialog).getByRole('button', { name: 'Add question' }));
    expect(within(dialog).getByRole('alert')).toHaveTextContent(/question/);
    expect(actions.saveFaqAction).not.toHaveBeenCalled();

    await user.type(within(dialog).getByLabelText('Question'), 'How do I delete my account?');
    await user.type(within(dialog).getByLabelText('Answer'), 'Settings, then Delete account.');
    await user.click(within(dialog).getByRole('button', { name: 'Add question' }));
    await vi.waitFor(() =>
      expect(actions.saveFaqAction).toHaveBeenCalledWith(
        null,
        {
          question: 'How do I delete my account?',
          answer: 'Settings, then Delete account.',
          published: true,
        },
        3,
      ),
    );
  });

  it('edits, toggles publishing and deletes after confirming', async () => {
    const user = userEvent.setup();
    render(<FaqManager entries={faq} />);
    await user.click(screen.getAllByRole('button', { name: 'Edit' })[1]!);
    expect(within(screen.getByRole('dialog')).getByLabelText('Question')).toHaveValue(
      'Can I block someone?',
    );
    await user.click(within(screen.getByRole('dialog')).getByRole('button', { name: 'Cancel' }));

    await user.click(screen.getAllByRole('button', { name: 'Publish' })[0]!);
    expect(actions.setFaqPublishedAction).toHaveBeenCalledWith('f2', true);

    await user.click(screen.getByRole('button', { name: /Delete “Can I block someone\?”/ }));
    expect(actions.deleteFaqAction).not.toHaveBeenCalled();
    await user.click(screen.getByRole('button', { name: 'Delete question' }));
    await vi.waitFor(() => expect(actions.deleteFaqAction).toHaveBeenCalledWith('f2'));
  });
});

describe('ArticleRowActions', () => {
  const items = [
    { id: 'a', sortOrder: 0 },
    { id: 'b', sortOrder: 1 },
  ];

  it('publishes, moves and deletes', async () => {
    const user = userEvent.setup();
    render(
      <ArticleRowActions
        id="b"
        title="Safety centre"
        published={false}
        items={items}
        reorderable
      />,
    );
    await user.click(screen.getByRole('button', { name: 'Publish' }));
    expect(actions.setHelpArticlePublishedAction).toHaveBeenCalledWith('b', true);
    await user.click(screen.getByRole('button', { name: 'Move Safety centre up' }));
    expect(actions.reorderHelpArticlesAction).toHaveBeenCalledWith([
      { id: 'b', sortOrder: 0 },
      { id: 'a', sortOrder: 1 },
    ]);
    await user.click(screen.getByRole('button', { name: 'Delete Safety centre' }));
    await user.click(screen.getByRole('button', { name: 'Delete article' }));
    await vi.waitFor(() => expect(actions.deleteHelpArticleAction).toHaveBeenCalledWith('b'));
  });

  it('hides the move buttons while a search narrows the list', () => {
    render(
      <ArticleRowActions
        id="b"
        title="Safety centre"
        published
        items={items}
        reorderable={false}
      />,
    );
    expect(screen.queryByRole('button', { name: /Move Safety centre/ })).not.toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Unpublish' })).toBeInTheDocument();
  });
});

describe('HelpArticleForm', () => {
  it('writes the address from the title, offers only text blocks and creates the article', async () => {
    const user = userEvent.setup();
    render(<HelpArticleForm id={null} initial={emptyHelpArticleForm()} />);
    await user.type(screen.getByLabelText('Title'), 'Report a post');
    expect(screen.getByLabelText(/^Address/)).toHaveValue('report-a-post');
    expect(screen.queryByRole('button', { name: 'Add image' })).not.toBeInTheDocument();
    await user.click(screen.getByRole('button', { name: 'Add paragraph' }));
    await user.type(
      screen.getByRole('textbox', { name: /Paragraph text .block 1./ }),
      'Tap the dots, then Report.',
    );
    await user.click(screen.getByRole('button', { name: 'Create article' }));
    await vi.waitFor(() =>
      expect(actions.saveHelpArticleAction).toHaveBeenCalledWith(
        null,
        expect.objectContaining({
          slug: 'report-a-post',
          title: 'Report a post',
          published: false,
        }),
      ),
    );
  });

  it('keeps the address of an existing article fixed', () => {
    render(
      <HelpArticleForm
        id="a1"
        initial={{
          ...emptyHelpArticleForm(),
          slug: 'safety-centre',
          title: 'Safety centre',
          published: true,
        }}
      />,
    );
    expect(screen.getByLabelText(/^Address/)).toBeDisabled();
    expect(screen.getByText(/never changes/)).toBeInTheDocument();
  });

  it('shows what is wrong before sending', async () => {
    const user = userEvent.setup();
    render(<HelpArticleForm id={null} initial={emptyHelpArticleForm()} />);
    await user.click(screen.getByRole('button', { name: 'Create article' }));
    expect(screen.getByRole('alert')).toHaveTextContent(/title/);
    expect(actions.saveHelpArticleAction).not.toHaveBeenCalled();
  });
});

describe('legal documents', () => {
  const draft = {
    type: 'PRIVACY',
    version: '2026.2',
    title: 'Privacy Policy',
    body: 'The new text of the policy, long enough.',
  };

  it('a published version is read-only with no publish button', () => {
    render(<LegalEditor id="l1" editable={false} initial={draft} />);
    expect(screen.getByLabelText('Text')).toHaveAttribute('readonly');
    expect(screen.queryByRole('button', { name: 'Publish this version' })).not.toBeInTheDocument();
    expect(screen.queryByRole('button', { name: 'Save draft' })).not.toBeInTheDocument();
  });

  it('a draft can be saved, and must be saved before it is published', async () => {
    const user = userEvent.setup();
    render(<LegalEditor id="l1" editable initial={draft} />);
    expect(screen.getByRole('button', { name: 'Publish this version' })).toBeEnabled();
    await user.type(screen.getByLabelText('Text'), ' More words.');
    expect(screen.getByRole('button', { name: 'Publish this version' })).toBeDisabled();
    expect(screen.getByText('Save before publishing.')).toBeInTheDocument();
    await user.click(screen.getByRole('button', { name: 'Save draft' }));
    await vi.waitFor(() =>
      expect(actions.saveLegalAction).toHaveBeenCalledWith(
        'l1',
        expect.objectContaining({ body: expect.stringContaining('More words.') }),
      ),
    );
  });

  it('publishing explains the archive, asks for the authenticator code, then retries', async () => {
    actions.publishLegalAction
      .mockResolvedValueOnce({ ok: false, reauth: true, error: 'Confirm it is you.' })
      .mockResolvedValueOnce({ ok: true });
    const user = userEvent.setup();
    render(<LegalEditor id="l1" editable initial={draft} />);
    await user.click(screen.getByRole('button', { name: 'Publish this version' }));
    expect(screen.getByText(/version it replaces is archived/)).toBeInTheDocument();
    expect(screen.getByText(/members who already accepted it are unaffected/)).toBeInTheDocument();
    await user.type(screen.getByLabelText(/Effective from/), '2026-12-01T09:00');
    await user.click(screen.getByRole('button', { name: 'Publish' }));
    await user.type(await screen.findByLabelText(/code/i), '654321');
    await user.keyboard('{Enter}');
    await vi.waitFor(() => expect(actions.publishLegalAction).toHaveBeenCalledTimes(2));
    expect(actions.publishLegalAction).toHaveBeenLastCalledWith('l1', '2026-12-01T09:00');
    expect(auth.reauthAction).toHaveBeenCalledWith({ code: '654321' });
    await vi.waitFor(() => expect(nav.refresh).toHaveBeenCalled());
  });

  it('creates a new version as a draft and opens it', async () => {
    actions.saveLegalAction.mockResolvedValue({ ok: true, id: 'new1' });
    const user = userEvent.setup();
    render(<NewLegalVersion />);
    await user.click(screen.getByRole('button', { name: 'New version' }));
    const dialog = screen.getByRole('dialog');
    await user.selectOptions(within(dialog).getByLabelText('Document'), 'PRIVACY');
    await user.type(within(dialog).getByLabelText('Version'), '2026.3');
    await user.type(within(dialog).getByLabelText('Title'), 'Privacy Policy');
    await user.type(
      within(dialog).getByLabelText('Text'),
      'A new version of the privacy policy text.',
    );
    await user.click(within(dialog).getByRole('button', { name: 'Create draft' }));
    await vi.waitFor(() =>
      expect(actions.saveLegalAction).toHaveBeenCalledWith(
        null,
        expect.objectContaining({ type: 'PRIVACY', version: '2026.3' }),
      ),
    );
    await vi.waitFor(() => expect(nav.push).toHaveBeenCalledWith('/content/legal/new1'));
  });

  it('shows the API error when a version name is already taken', async () => {
    actions.saveLegalAction.mockResolvedValue({ ok: false, error: 'That version already exists.' });
    const user = userEvent.setup();
    render(<NewLegalVersion />);
    await user.click(screen.getByRole('button', { name: 'New version' }));
    const dialog = screen.getByRole('dialog');
    await user.type(within(dialog).getByLabelText('Version'), '2026.1');
    await user.type(within(dialog).getByLabelText('Title'), 'Terms');
    await user.type(
      within(dialog).getByLabelText('Text'),
      'Some text that is long enough to count.',
    );
    await user.click(within(dialog).getByRole('button', { name: 'Create draft' }));
    expect(await within(dialog).findByText('That version already exists.')).toBeInTheDocument();
  });
});
