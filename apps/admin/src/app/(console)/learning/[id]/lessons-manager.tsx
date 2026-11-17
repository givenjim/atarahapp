'use client';

import { useRouter } from 'next/navigation';
import { useState, useTransition } from 'react';
import { deleteLessonAction, reorderLessonsAction } from '@/app/learning-actions';
import { ConfirmDialog } from '@/components/ui/confirm-dialog';
import {
  emptyLessonForm,
  lessonFormFromDto,
  moveItem,
  orderChanged,
  orderIds,
  videoStatusMeta,
  type LessonDtoLike,
} from '@/lib/learning';
import { LessonEditor } from './lesson-editor';

export interface LessonRow extends LessonDtoLike {
  id: string;
  sequence: number;
  videoStatus?: string | null;
}

/**
 * The lessons of a course: list in order, move up or down (saved at once), add, edit and delete. Editing happens in a
 * panel under the list. Deleting closes the gap in the numbering.
 */
export function LessonsManager({
  courseId,
  lessons,
  skills,
  hosts,
}: {
  courseId: string;
  lessons: LessonRow[];
  skills: Array<{ id: string; name: string }>;
  hosts: string[];
}) {
  const router = useRouter();
  // `null` means closed, `'new'` a new lesson, otherwise the id being edited.
  const [editing, setEditing] = useState<string | null>(null);
  const [removing, setRemoving] = useState<LessonRow | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [pending, start] = useTransition();

  const move = (index: number, direction: -1 | 1) => {
    const next = moveItem(lessons, index, direction);
    if (!orderChanged(lessons, next)) return;
    setError(null);
    start(async () => {
      const res = await reorderLessonsAction(courseId, orderIds(next));
      if (res.ok) router.refresh();
      else setError(res.ok ? null : res.error);
    });
  };

  const remove = () => {
    if (!removing) return;
    setError(null);
    start(async () => {
      const res = await deleteLessonAction(courseId, removing.id);
      if (res.ok) {
        setRemoving(null);
        router.refresh();
      } else {
        setRemoving(null);
        setError(res.error);
      }
    });
  };

  const current = editing && editing !== 'new' ? lessons.find((l) => l.id === editing) : undefined;

  return (
    <section className="card" aria-label="Lessons" style={{ padding: 20 }}>
      <div className="toolbar">
        <h2>Lessons</h2>
        <button
          type="button"
          className="button"
          disabled={pending || editing !== null}
          onClick={() => setEditing('new')}
        >
          Add lesson
        </button>
      </div>
      {lessons.length === 0 ? (
        <p className="empty">
          No lessons yet. A course needs at least one before it can be published.
        </p>
      ) : (
        <ol className="plain-list" style={{ listStyle: 'none', padding: 0 }}>
          {lessons.map((l, i) => (
            <li
              key={l.id}
              aria-label={`Lesson ${l.sequence}`}
              className="row-actions"
              style={{
                justifyContent: 'space-between',
                padding: '8px 0',
                borderBottom: '1px solid var(--border, #ddd)',
              }}
            >
              <span>
                <strong>
                  {l.sequence}. {l.title}
                </strong>{' '}
                <span className="muted">
                  {l.durationMinutes > 0 ? `${l.durationMinutes} min` : 'no length'}
                  {l.videoMediaId ? ' · uploaded video' : l.embedUrl ? ' · embedded player' : ''}
                  {l.body.length > 0
                    ? ` · ${l.body.length} text block${l.body.length === 1 ? '' : 's'}`
                    : ''}
                </span>
                {l.videoMediaId ? (
                  <>
                    {' '}
                    <span className={`pill ${videoStatusMeta(l.videoStatus).tone}`.trim()}>
                      {videoStatusMeta(l.videoStatus).label}
                    </span>
                  </>
                ) : null}
              </span>
              <span className="row-actions">
                <button
                  type="button"
                  className="button secondary small"
                  aria-label={`Move lesson ${l.sequence} up`}
                  disabled={pending || i === 0}
                  onClick={() => move(i, -1)}
                >
                  Up
                </button>
                <button
                  type="button"
                  className="button secondary small"
                  aria-label={`Move lesson ${l.sequence} down`}
                  disabled={pending || i === lessons.length - 1}
                  onClick={() => move(i, 1)}
                >
                  Down
                </button>
                <button
                  type="button"
                  className="button secondary small"
                  aria-label={`Edit lesson ${l.sequence}`}
                  disabled={pending || editing !== null}
                  onClick={() => setEditing(l.id)}
                >
                  Edit
                </button>
                <button
                  type="button"
                  className="button danger small"
                  aria-label={`Delete lesson ${l.sequence}`}
                  disabled={pending}
                  onClick={() => setRemoving(l)}
                >
                  Delete
                </button>
              </span>
            </li>
          ))}
        </ol>
      )}
      {error ? (
        <p className="alert" role="alert">
          {error}
        </p>
      ) : null}

      {editing === 'new' ? (
        <LessonEditor
          key="new"
          courseId={courseId}
          lessonId={null}
          initial={emptyLessonForm()}
          videoStatus={null}
          skills={skills}
          hosts={hosts}
          onDone={() => setEditing(null)}
        />
      ) : current ? (
        <LessonEditor
          key={current.id}
          courseId={courseId}
          lessonId={current.id}
          initial={lessonFormFromDto(current, (i) => `${current.id}-block-${i}`)}
          videoStatus={current.videoStatus ?? null}
          skills={skills}
          hosts={hosts}
          onDone={() => setEditing(null)}
        />
      ) : null}

      <ConfirmDialog
        open={removing !== null}
        title={removing ? `Delete “${removing.title}”?` : 'Delete lesson'}
        confirmLabel="Delete lesson"
        tone="danger"
        pending={pending}
        onCancel={() => setRemoving(null)}
        onConfirm={remove}
      >
        <p className="muted" style={{ margin: 0 }}>
          The lesson and members’ progress on it are removed, and the later lessons move up. A
          published course must keep at least one lesson.
        </p>
      </ConfirmDialog>
    </section>
  );
}
