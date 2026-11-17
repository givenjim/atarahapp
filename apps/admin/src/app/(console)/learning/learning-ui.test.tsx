import { render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { emptyContentForm, type ContentForm } from '@/lib/learning';
import { CategoryFormDialog } from './categories/category-form';
import { ContentActions } from './[id]/content-actions';
import { LessonEditor } from './[id]/lesson-editor';
import { LessonsManager, type LessonRow } from './[id]/lessons-manager';
import { OverrideDialog } from './[id]/override-dialog';
import { ContentFormView } from './content-form';

const nav = vi.hoisted(() => ({ refresh: vi.fn(), push: vi.fn(), back: vi.fn() }));
vi.mock('next/navigation', () => ({ useRouter: () => nav }));

const actions = vi.hoisted(() => ({
  saveContentAction: vi.fn(),
  transitionContentAction: vi.fn(),
  saveCategoryAction: vi.fn(),
  saveLessonAction: vi.fn(),
  deleteLessonAction: vi.fn(),
  reorderLessonsAction: vi.fn(),
  progressOverrideAction: vi.fn(),
  requestVideoUploadAction: vi.fn(),
  completeVideoUploadAction: vi.fn(),
}));
vi.mock('@/app/learning-actions', () => actions);
// The cover image field and the block editor come from the article editor, which imports its own actions.
vi.mock('@/app/articles-actions', () => ({
  requestImageUploadAction: vi.fn(),
  completeImageUploadAction: vi.fn(),
  saveArticleAction: vi.fn(),
  articleLifecycleAction: vi.fn(),
}));
const auth = vi.hoisted(() => ({ reauthAction: vi.fn() }));
vi.mock('@/app/actions', () => auth);

const HOSTS = ['www.youtube.com', 'www.youtube-nocookie.com', 'player.vimeo.com'];
const C1 = '5b4d0e3a-7c6f-4081-8c3d-2e1f9a8b7c6d';
const U1 = '3f2b8c1e-5a4d-4e6f-8a1b-0c9d7e6f5a4b';
const options = {
  categories: [
    { id: C1, name: 'Portfolio Building', group: 'PROFESSIONAL', isActive: true },
    { id: 'c2', name: 'Branding', group: 'BUSINESS', isActive: true },
  ],
  disciplines: [{ id: 'd1', name: 'Animation' }],
  skills: [{ id: 's1', name: 'Storyboarding' }],
  hosts: HOSTS,
};

// Typing into long forms is slow on a busy machine.
vi.setConfig({ testTimeout: 60_000 });

beforeEach(() => {
  vi.clearAllMocks();
  for (const fn of Object.values(actions)) fn.mockResolvedValue({ ok: true });
  auth.reauthAction.mockResolvedValue({ ok: true });
});

const form = (over: Partial<ContentForm> = {}): ContentForm => ({
  ...emptyContentForm(),
  title: 'Build a portfolio',
  summary: 'A short course on choosing and presenting your best work.',
  categoryId: C1,
  ...over,
});

describe('ContentFormView', () => {
  it('refuses an incomplete form without calling the API', async () => {
    const user = userEvent.setup();
    render(<ContentFormView initial={emptyContentForm()} {...options} />);
    await user.click(screen.getByRole('button', { name: 'Create draft' }));
    expect(await screen.findByRole('alert')).toHaveTextContent('title');
    expect(actions.saveContentAction).not.toHaveBeenCalled();
  });

  it('creates a course draft and opens it', async () => {
    actions.saveContentAction.mockResolvedValue({ ok: true, id: 'new-id' });
    const user = userEvent.setup();
    render(<ContentFormView initial={emptyContentForm()} {...options} />);
    await user.type(screen.getByLabelText('Title'), 'Pricing your work');
    await user.selectOptions(screen.getByLabelText('Category'), C1);
    await user.type(
      screen.getByLabelText(/Summary/),
      'Work out what to charge and say it with confidence.',
    );
    await user.click(screen.getByRole('button', { name: 'Create draft' }));
    await vi.waitFor(() => expect(actions.saveContentAction).toHaveBeenCalledTimes(1));
    const [id, sent, hosts, original] = actions.saveContentAction.mock.calls[0] as [
      string | null,
      ContentForm,
      string[],
      string | undefined,
    ];
    expect(id).toBeNull();
    expect(sent).toMatchObject({
      title: 'Pricing your work',
      type: 'COURSE',
      delivery: 'NATIVE',
      categoryId: C1,
    });
    expect(hosts).toEqual(HOSTS);
    expect(original).toBeUndefined();
    await vi.waitFor(() => expect(nav.push).toHaveBeenCalledWith('/learning/new-id'));
  });

  it('a course is taught in the app; other types choose embedded or external', async () => {
    const user = userEvent.setup();
    render(<ContentFormView initial={emptyContentForm()} {...options} />);
    const delivery = screen.getByLabelText('Delivery');
    expect(delivery).toBeDisabled();
    expect(
      within(delivery)
        .getAllByRole('option')
        .map((o) => o.textContent),
    ).toEqual(['In-app lessons']);
    expect(screen.queryByLabelText('Duration (minutes)')).not.toBeInTheDocument();
    expect(screen.getByLabelText('Lessons unlock one after another')).toBeChecked();

    await user.selectOptions(screen.getByLabelText('Type'), 'TOOLKIT');
    expect(screen.getByLabelText('Delivery')).toBeEnabled();
    expect(
      within(screen.getByLabelText('Delivery'))
        .getAllByRole('option')
        .map((o) => o.textContent),
    ).toEqual(['Embedded', 'Opens outside Atarah']);
    expect(screen.getByLabelText('Duration (minutes)')).toBeInTheDocument();
    await user.selectOptions(screen.getByLabelText('Delivery'), 'EXTERNAL_LINK');
    expect(screen.getByLabelText(/Address it opens/)).toBeInTheDocument();
  });

  it('shows the address members will see for a pasted watch link, and why a host is refused', async () => {
    const user = userEvent.setup();
    render(
      <ContentFormView
        initial={form({ type: 'MASTERCLASS', delivery: 'EMBEDDED' })}
        {...options}
      />,
    );
    const input = screen.getByLabelText(/Embedded player address/);
    expect(screen.getByText(/Allowed hosts: www.youtube.com/)).toBeInTheDocument();
    await user.type(input, 'https://www.youtube.com/watch?v=abcDEF12345');
    expect(
      await screen.findByText('https://www.youtube-nocookie.com/embed/abcDEF12345'),
    ).toBeInTheDocument();
    await user.clear(input);
    await user.type(input, 'https://evil.example.com/embed/abc123456');
    expect(await screen.findByRole('alert')).toHaveTextContent('cannot be embedded');
    await user.click(screen.getByRole('button', { name: 'Create draft' }));
    expect(actions.saveContentAction).not.toHaveBeenCalled();
  });

  it('editing keeps a course a course, saves with the original type and shows the API’s answer', async () => {
    actions.saveContentAction.mockResolvedValue({ ok: false, error: 'Members have started this.' });
    const user = userEvent.setup();
    render(<ContentFormView id="c1" originalType="COURSE" initial={form()} {...options} />);
    expect(
      within(screen.getByLabelText('Type'))
        .getAllByRole('option')
        .map((o) => o.textContent),
    ).toEqual(['Course']);
    await user.click(screen.getByRole('button', { name: 'Save changes' }));
    await vi.waitFor(() => expect(actions.saveContentAction).toHaveBeenCalledTimes(1));
    expect(actions.saveContentAction.mock.calls[0]?.[0]).toBe('c1');
    expect(actions.saveContentAction.mock.calls[0]?.[3]).toBe('COURSE');
    expect(await screen.findByRole('alert')).toHaveTextContent('Members have started this.');
    expect(screen.getByLabelText('Title')).toHaveValue('Build a portfolio');
    expect(nav.push).not.toHaveBeenCalled();
  });

  it('lists, adds and removes “what you’ll learn” lines and toggles disciplines and skills', async () => {
    const user = userEvent.setup();
    render(<ContentFormView initial={form()} {...options} />);
    await user.type(screen.getByLabelText('What you’ll learn 1'), 'Pick three projects');
    await user.click(screen.getByRole('button', { name: 'Add another' }));
    expect(screen.getByLabelText('What you’ll learn 2')).toBeInTheDocument();
    await user.click(screen.getByRole('button', { name: 'Remove what you’ll learn 2' }));
    expect(screen.queryByLabelText('What you’ll learn 2')).not.toBeInTheDocument();
    await user.click(screen.getByLabelText('Animation'));
    await user.click(screen.getByLabelText('Storyboarding'));
    expect(screen.getByLabelText('Animation')).toBeChecked();
    expect(screen.getByLabelText('Storyboarding')).toBeChecked();
  });
});

describe('ContentActions', () => {
  const names = () => screen.getAllByRole('button').map((b) => b.textContent);

  it('offers the moves that match the status and the learner count', () => {
    const { rerender } = render(<ContentActions id="c1" title="T" status="DRAFT" learners={0} />);
    expect(names()).toEqual(['Publish', 'Archive']);
    rerender(<ContentActions id="c1" title="T" status="PUBLISHED" learners={0} />);
    expect(names()).toEqual(['Unpublish', 'Archive']);
    rerender(<ContentActions id="c1" title="T" status="PUBLISHED" learners={4} />);
    expect(names()).toEqual(['Archive']);
    expect(screen.getByText(/4 members have started this/)).toBeInTheDocument();
    rerender(<ContentActions id="c1" title="T" status="ARCHIVED" learners={4} />);
    expect(names()).toEqual(['Publish']);
  });

  it('publishes after confirming and refreshes', async () => {
    const user = userEvent.setup();
    render(<ContentActions id="c1" title="Pricing" status="DRAFT" learners={0} />);
    await user.click(screen.getByRole('button', { name: 'Publish' }));
    const dialog = screen.getByRole('dialog', { name: /Publish “Pricing”/ });
    await user.click(within(dialog).getByRole('button', { name: 'Publish' }));
    await vi.waitFor(() =>
      expect(actions.transitionContentAction).toHaveBeenCalledWith('c1', 'publish'),
    );
    await vi.waitFor(() => expect(nav.refresh).toHaveBeenCalled());
  });

  it('shows what is missing in the API’s own words when publishing is refused', async () => {
    actions.transitionContentAction.mockResolvedValue({
      ok: false,
      error: 'Add at least one lesson before publishing.',
    });
    const user = userEvent.setup();
    render(<ContentActions id="c1" title="Pricing" status="DRAFT" learners={0} />);
    await user.click(screen.getByRole('button', { name: 'Publish' }));
    const dialog = screen.getByRole('dialog', { name: /Publish/ });
    await user.click(within(dialog).getByRole('button', { name: 'Publish' }));
    expect(await within(dialog).findByRole('alert')).toHaveTextContent(
      'Add at least one lesson before publishing.',
    );
    expect(nav.refresh).not.toHaveBeenCalled();
  });

  it('archives and unpublishes through the same dialog pattern', async () => {
    const user = userEvent.setup();
    render(<ContentActions id="c1" title="Pricing" status="PUBLISHED" learners={0} />);
    await user.click(screen.getByRole('button', { name: 'Unpublish' }));
    await user.click(
      within(screen.getByRole('dialog', { name: /Unpublish/ })).getByRole('button', {
        name: 'Unpublish',
      }),
    );
    await vi.waitFor(() =>
      expect(actions.transitionContentAction).toHaveBeenCalledWith('c1', 'unpublish'),
    );
    await user.click(screen.getByRole('button', { name: 'Archive' }));
    await user.click(
      within(screen.getByRole('dialog', { name: /Archive/ })).getByRole('button', {
        name: 'Archive',
      }),
    );
    await vi.waitFor(() =>
      expect(actions.transitionContentAction).toHaveBeenCalledWith('c1', 'archive'),
    );
  });
});

const lessons: LessonRow[] = [
  {
    id: 'l1',
    sequence: 1,
    title: 'What a portfolio is for',
    durationMinutes: 6,
    body: [{ type: 'paragraph', text: 'Text' }],
    videoMediaId: null,
    embedUrl: null,
  },
  {
    id: 'l2',
    sequence: 2,
    title: 'Choosing three projects',
    durationMinutes: 8,
    body: [],
    videoMediaId: 'v1',
    videoStatus: 'PROCESSING',
    embedUrl: null,
  },
  {
    id: 'l3',
    sequence: 3,
    title: 'Showing results',
    durationMinutes: 0,
    body: [],
    videoMediaId: null,
    embedUrl: 'https://player.vimeo.com/video/123456789',
  },
];

describe('LessonsManager', () => {
  const props = { courseId: 'c1', lessons, skills: options.skills, hosts: HOSTS };

  it('lists the lessons in order with their player and video state', () => {
    render(<LessonsManager {...props} />);
    const items = screen.getAllByRole('listitem');
    expect(items.map((i) => i.getAttribute('aria-label'))).toEqual([
      'Lesson 1',
      'Lesson 2',
      'Lesson 3',
    ]);
    expect(within(items[1]!).getByText('Being checked')).toBeInTheDocument();
    expect(within(items[1]!).getByText(/uploaded video/)).toBeInTheDocument();
    expect(within(items[2]!).getByText(/embedded player/)).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Move lesson 1 up' })).toBeDisabled();
    expect(screen.getByRole('button', { name: 'Move lesson 3 down' })).toBeDisabled();
  });

  it('says what an empty course needs', () => {
    render(<LessonsManager {...props} lessons={[]} />);
    expect(screen.getByText(/needs at least one before it can be published/)).toBeInTheDocument();
  });

  it('reorders at once with every lesson id in the new order', async () => {
    const user = userEvent.setup();
    render(<LessonsManager {...props} />);
    await user.click(screen.getByRole('button', { name: 'Move lesson 2 up' }));
    await vi.waitFor(() =>
      expect(actions.reorderLessonsAction).toHaveBeenCalledWith('c1', ['l2', 'l1', 'l3']),
    );
    await vi.waitFor(() => expect(nav.refresh).toHaveBeenCalled());
    await user.click(screen.getByRole('button', { name: 'Move lesson 2 down' }));
    await vi.waitFor(() =>
      expect(actions.reorderLessonsAction).toHaveBeenLastCalledWith('c1', ['l1', 'l3', 'l2']),
    );
  });

  it('shows the API’s reason when a reorder fails', async () => {
    actions.reorderLessonsAction.mockResolvedValue({
      ok: false,
      error: 'Send every lesson of the course exactly once.',
    });
    const user = userEvent.setup();
    render(<LessonsManager {...props} />);
    await user.click(screen.getByRole('button', { name: 'Move lesson 3 up' }));
    expect(await screen.findByRole('alert')).toHaveTextContent('exactly once');
  });

  it('deletes a lesson after confirming', async () => {
    const user = userEvent.setup();
    render(<LessonsManager {...props} />);
    await user.click(screen.getByRole('button', { name: 'Delete lesson 2' }));
    const dialog = screen.getByRole('dialog', { name: /Delete “Choosing three projects”/ });
    await user.click(within(dialog).getByRole('button', { name: 'Delete lesson' }));
    await vi.waitFor(() => expect(actions.deleteLessonAction).toHaveBeenCalledWith('c1', 'l2'));
    await vi.waitFor(() => expect(nav.refresh).toHaveBeenCalled());
  });

  it('opens a new-lesson editor and an editor filled with the lesson to edit', async () => {
    const user = userEvent.setup();
    render(<LessonsManager {...props} />);
    await user.click(screen.getByRole('button', { name: 'Add lesson' }));
    expect(screen.getByRole('region', { name: 'New lesson' })).toBeInTheDocument();
    expect(screen.getByLabelText('Lesson title')).toHaveValue('');
    await user.click(screen.getByRole('button', { name: 'Cancel' }));
    expect(screen.queryByRole('region', { name: 'New lesson' })).not.toBeInTheDocument();

    await user.click(screen.getByRole('button', { name: 'Edit lesson 3' }));
    expect(screen.getByRole('region', { name: 'Edit lesson' })).toBeInTheDocument();
    expect(screen.getByLabelText('Lesson title')).toHaveValue('Showing results');
    expect(screen.getByLabelText(/Embedded player address/)).toHaveValue(
      'https://player.vimeo.com/video/123456789',
    );
  });
});

describe('LessonEditor', () => {
  const base = {
    courseId: 'c1',
    lessonId: null as string | null,
    videoStatus: null,
    skills: options.skills,
    hosts: HOSTS,
    onDone: vi.fn(),
  };
  const empty = {
    title: '',
    durationMinutes: '',
    blocks: [],
    player: 'NONE' as const,
    videoMediaId: '',
    embedUrl: '',
    practicePrompt: '',
    practiceSkillId: '',
  };

  it('refuses a lesson without a title, and an empty block, before calling the API', async () => {
    const user = userEvent.setup();
    render(<LessonEditor {...base} initial={empty} />);
    await user.click(screen.getByRole('button', { name: 'Add lesson' }));
    expect(await screen.findByRole('alert')).toHaveTextContent('title');
    await user.type(screen.getByLabelText('Lesson title'), 'Know your minimum');
    await user.click(screen.getByRole('button', { name: 'Add paragraph' }));
    await user.click(screen.getByRole('button', { name: 'Add lesson' }));
    expect(await screen.findByRole('alert')).toHaveTextContent('Block 1');
    expect(actions.saveLessonAction).not.toHaveBeenCalled();
  });

  it('saves text blocks, a practice prompt and skill, and closes', async () => {
    const onDone = vi.fn();
    const user = userEvent.setup();
    render(<LessonEditor {...base} onDone={onDone} initial={empty} />);
    await user.type(screen.getByLabelText('Lesson title'), 'Know your minimum');
    await user.type(screen.getByLabelText('Length (minutes)'), '8');
    await user.click(screen.getByRole('button', { name: 'Add paragraph' }));
    await user.type(screen.getByLabelText(/Paragraph text/), 'Add up what you need each month.');
    await user.type(screen.getByLabelText(/Practice prompt/), 'Write your monthly number.');
    await user.selectOptions(screen.getByLabelText(/Practice skill/), 's1');
    await user.click(screen.getByRole('button', { name: 'Add lesson' }));
    await vi.waitFor(() => expect(actions.saveLessonAction).toHaveBeenCalledTimes(1));
    const [courseId, lessonId, sent, hosts] = actions.saveLessonAction.mock.calls[0] as [
      string,
      string | null,
      {
        title: string;
        durationMinutes: string;
        practiceSkillId: string;
        blocks: Array<{ type: string; text: string }>;
      },
      string[],
    ];
    expect([courseId, lessonId, hosts]).toEqual(['c1', null, HOSTS]);
    expect(sent).toMatchObject({
      title: 'Know your minimum',
      durationMinutes: '8',
      practiceSkillId: 's1',
    });
    expect(sent.blocks).toMatchObject([
      { type: 'paragraph', text: 'Add up what you need each month.' },
    ]);
    await vi.waitFor(() => expect(onDone).toHaveBeenCalled());
    expect(nav.refresh).toHaveBeenCalled();
  });

  it('a lesson plays one player: choosing a player shows only its field, and an embed is checked against the allow-list', async () => {
    const user = userEvent.setup();
    render(<LessonEditor {...base} initial={{ ...empty, title: 'Lesson', blocks: [] }} />);
    expect(screen.queryByLabelText(/Embedded player address/)).not.toBeInTheDocument();
    expect(screen.queryByLabelText('Lesson video file')).not.toBeInTheDocument();
    await user.click(screen.getByLabelText('Uploaded video'));
    expect(screen.getByLabelText('Lesson video file')).toBeInTheDocument();
    expect(screen.queryByLabelText(/Embedded player address/)).not.toBeInTheDocument();
    await user.click(screen.getByLabelText(/Embedded player/));
    expect(screen.queryByLabelText('Lesson video file')).not.toBeInTheDocument();
    await user.type(
      screen.getByLabelText(/Embedded player address/),
      'https://evil.example.com/embed/abc123456',
    );
    expect(await screen.findByText(/cannot be embedded/)).toBeInTheDocument();
    await user.click(screen.getByRole('button', { name: 'Add lesson' }));
    expect(actions.saveLessonAction).not.toHaveBeenCalled();
    await user.clear(screen.getByLabelText(/Embedded player address/));
    await user.type(
      screen.getByLabelText(/Embedded player address/),
      'https://vimeo.com/123456789',
    );
    expect(await screen.findByText('https://player.vimeo.com/video/123456789')).toBeInTheDocument();
  });

  it('shows the stored video’s status and refreshes it on request', async () => {
    const user = userEvent.setup();
    render(
      <LessonEditor
        {...base}
        lessonId="l2"
        videoStatus="PROCESSING"
        initial={{ ...empty, title: 'Lesson', player: 'VIDEO', videoMediaId: 'v1' }}
      />,
    );
    expect(screen.getByText('Being checked')).toBeInTheDocument();
    await user.click(screen.getByRole('button', { name: 'Refresh status' }));
    expect(nav.refresh).toHaveBeenCalled();
  });

  it('refuses a video of the wrong type without asking the API for an upload', async () => {
    const user = userEvent.setup({ applyAccept: false });
    render(<LessonEditor {...base} initial={{ ...empty, title: 'Lesson', player: 'VIDEO' }} />);
    await user.upload(
      screen.getByLabelText('Lesson video file'),
      new File(['x'], 'notes.mkv', { type: 'video/x-matroska' }),
    );
    expect(await screen.findByRole('alert')).toHaveTextContent('MP4, MOV or WebM');
    expect(actions.requestVideoUploadAction).not.toHaveBeenCalled();
  });

  it('uploads a valid video in three steps and shows it as waiting to be checked', async () => {
    actions.requestVideoUploadAction.mockResolvedValue({
      ok: true,
      ticket: {
        id: 'vid-9',
        uploadUrl: 'https://storage.example.org/put',
        headers: { 'content-type': 'video/mp4' },
      },
    });
    const put = vi.fn().mockResolvedValue({ ok: true, status: 200 });
    vi.stubGlobal('fetch', put);
    try {
      const user = userEvent.setup();
      render(<LessonEditor {...base} initial={{ ...empty, title: 'Lesson', player: 'VIDEO' }} />);
      await user.upload(
        screen.getByLabelText('Lesson video file'),
        new File(['abc'], 'lesson.mp4', { type: 'video/mp4' }),
      );
      await vi.waitFor(() =>
        expect(actions.completeVideoUploadAction).toHaveBeenCalledWith('vid-9'),
      );
      expect(put).toHaveBeenCalledWith(
        'https://storage.example.org/put',
        expect.objectContaining({ method: 'PUT' }),
      );
      expect(await screen.findByText('Uploaded, waiting to be checked')).toBeInTheDocument();
    } finally {
      vi.unstubAllGlobals();
    }
  });
});

describe('OverrideDialog', () => {
  const props = {
    courseId: 'c1',
    lessons: lessons.map(({ id, sequence, title }) => ({ id, sequence, title })),
  };

  async function open() {
    const user = userEvent.setup();
    render(<OverrideDialog {...props} />);
    await user.click(screen.getByRole('button', { name: 'Progress override' }));
    return { user, dialog: screen.getByRole('dialog', { name: 'Progress override' }) };
  }

  it('says that it is audited, needs a code and keeps issued certificates', async () => {
    const { dialog } = await open();
    expect(within(dialog).getByText(/fresh authenticator code/)).toBeInTheDocument();
    expect(
      within(dialog).getByText(/certificate that was already issued stays/),
    ).toBeInTheDocument();
  });

  it('refuses a short reason or a missing lesson before calling the API', async () => {
    const { user, dialog } = await open();
    await user.type(within(dialog).getByLabelText('Member (user id)'), U1);
    await user.click(within(dialog).getByRole('button', { name: 'Apply override' }));
    expect(await within(dialog).findByRole('alert')).toHaveTextContent('Choose the lesson');
    await user.selectOptions(within(dialog).getByLabelText('Lesson'), 'l1');
    await user.type(within(dialog).getByLabelText(/Reason/), 'short');
    await user.click(within(dialog).getByRole('button', { name: 'Apply override' }));
    expect(await within(dialog).findByRole('alert')).toHaveTextContent('10 characters');
    expect(actions.progressOverrideAction).not.toHaveBeenCalled();
  });

  it('hides the lesson for a whole-course reset and sends the override', async () => {
    const { user, dialog } = await open();
    await user.type(within(dialog).getByLabelText('Member (user id)'), U1);
    await user.selectOptions(within(dialog).getByLabelText('What to do'), 'RESET_COURSE');
    expect(within(dialog).queryByLabelText('Lesson')).not.toBeInTheDocument();
    await user.type(within(dialog).getByLabelText(/Reason/), 'Recorded against the wrong member');
    await user.click(within(dialog).getByRole('button', { name: 'Apply override' }));
    await vi.waitFor(() => expect(actions.progressOverrideAction).toHaveBeenCalledTimes(1));
    expect(actions.progressOverrideAction.mock.calls[0]).toMatchObject([
      'c1',
      { userId: U1, action: 'RESET_COURSE', reason: 'Recorded against the wrong member' },
    ]);
    await vi.waitFor(() => expect(nav.refresh).toHaveBeenCalled());
  });

  it('asks for the authenticator code when the API says the check is stale, then retries', async () => {
    actions.progressOverrideAction
      .mockResolvedValueOnce({ ok: false, reauth: true, error: 'Confirm with your authenticator.' })
      .mockResolvedValueOnce({ ok: true });
    const { user, dialog } = await open();
    await user.type(within(dialog).getByLabelText('Member (user id)'), U1);
    await user.selectOptions(within(dialog).getByLabelText('Lesson'), 'l1');
    await user.type(within(dialog).getByLabelText(/Reason/), 'Finished offline at a workshop');
    await user.click(within(dialog).getByRole('button', { name: 'Apply override' }));
    const reauth = await screen.findByLabelText(/Code/i);
    await user.type(reauth, '123456');
    await user.click(screen.getAllByRole('button', { name: /Confirm|Verify|Continue/i }).at(-1)!);
    await vi.waitFor(() => expect(auth.reauthAction).toHaveBeenCalledWith({ code: '123456' }));
    await vi.waitFor(() => expect(actions.progressOverrideAction).toHaveBeenCalledTimes(2));
  });
});

describe('CategoryFormDialog', () => {
  it('adds a category with its group and order', async () => {
    const user = userEvent.setup();
    render(<CategoryFormDialog />);
    await user.click(screen.getByRole('button', { name: 'New category' }));
    const dialog = screen.getByRole('dialog', { name: 'New category' });
    await user.type(within(dialog).getByLabelText('Name'), 'Sound Design');
    await user.selectOptions(within(dialog).getByLabelText('Group'), 'CREATIVE');
    await user.type(within(dialog).getByLabelText('Order in its group'), '4');
    await user.click(within(dialog).getByRole('button', { name: 'Add category' }));
    await vi.waitFor(() => expect(actions.saveCategoryAction).toHaveBeenCalledTimes(1));
    expect(actions.saveCategoryAction.mock.calls[0]).toMatchObject([
      null,
      { name: 'Sound Design', group: 'CREATIVE', sortOrder: '4', isActive: true },
    ]);
    await vi.waitFor(() => expect(nav.refresh).toHaveBeenCalled());
  });

  it('refuses a name that is too short and edits an existing category', async () => {
    const user = userEvent.setup();
    render(
      <CategoryFormDialog
        id="k1"
        initial={{ name: 'Branding', group: 'BUSINESS', sortOrder: '2', isActive: true }}
      />,
    );
    await user.click(screen.getByRole('button', { name: 'Edit' }));
    const dialog = screen.getByRole('dialog', { name: 'Edit category' });
    await user.clear(within(dialog).getByLabelText('Name'));
    await user.type(within(dialog).getByLabelText('Name'), 'B');
    await user.click(within(dialog).getByRole('button', { name: 'Save changes' }));
    expect(await within(dialog).findByRole('alert')).toHaveTextContent('2 to 60');
    expect(actions.saveCategoryAction).not.toHaveBeenCalled();
    await user.clear(within(dialog).getByLabelText('Name'));
    await user.type(within(dialog).getByLabelText('Name'), 'Personal branding');
    await user.click(within(dialog).getByLabelText(/Active/));
    await user.click(within(dialog).getByRole('button', { name: 'Save changes' }));
    await vi.waitFor(() => expect(actions.saveCategoryAction).toHaveBeenCalledTimes(1));
    expect(actions.saveCategoryAction.mock.calls[0]).toMatchObject([
      'k1',
      { name: 'Personal branding', isActive: false },
    ]);
  });
});
