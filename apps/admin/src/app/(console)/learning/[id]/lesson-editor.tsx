'use client';

import { useRouter } from 'next/navigation';
import { useReducer, useRef, useState, useTransition } from 'react';
import {
  completeVideoUploadAction,
  requestVideoUploadAction,
  saveLessonAction,
} from '@/app/learning-actions';
import {
  BLOCK_LABELS,
  BLOCK_TYPES,
  blocksReducer,
  type BlockAction,
  type BlockType,
  type EditorBlock,
} from '@/lib/articles';
import {
  embedPreview,
  VIDEO_TYPES,
  validateLessonForm,
  videoStatusMeta,
  type LessonForm,
  type Player,
} from '@/lib/learning';
import { uploadVideo } from '@/lib/video-upload';
import { BlockFields } from '../../articles/[id]/article-editor';

interface SkillOption {
  id: string;
  name: string;
}

const PLAYER_LABELS: Record<Player, string> = {
  NONE: 'No video',
  VIDEO: 'Uploaded video',
  EMBED: 'Embedded player (YouTube or Vimeo)',
};

/**
 * Create or edit one lesson: text blocks, a video (uploaded or embedded, never both) and a practice prompt. `lessonId`
 * null means a new lesson at the end of the course. `videoStatus` is the stored video's state from the last load.
 */
export function LessonEditor({
  courseId,
  lessonId,
  initial,
  videoStatus,
  skills,
  hosts,
  onDone,
}: {
  courseId: string;
  lessonId: string | null;
  initial: LessonForm;
  videoStatus: string | null;
  skills: SkillOption[];
  hosts: string[];
  onDone: () => void;
}) {
  const router = useRouter();
  const [f, setF] = useState<LessonForm>(initial);
  const [blocks, dispatch] = useReducer(
    (state: EditorBlock[], action: BlockAction) => blocksReducer(state, action),
    initial.blocks,
  );
  const [error, setError] = useState<string | null>(null);
  const [uploading, setUploading] = useState(false);
  const [uploaded, setUploaded] = useState(false);
  const [pending, start] = useTransition();
  const counter = useRef(0);
  const nextKey = () => `lesson-block-${(counter.current += 1)}`;
  const set = <K extends keyof LessonForm>(k: K, v: LessonForm[K]) =>
    setF((p) => ({ ...p, [k]: v }));
  const busy = pending || uploading;
  const form: LessonForm = { ...f, blocks };
  const embed = f.player === 'EMBED' && f.embedUrl.trim() ? embedPreview(f.embedUrl, hosts) : null;

  async function pickVideo(file: File | undefined, input: HTMLInputElement) {
    if (!file) return;
    setError(null);
    setUploading(true);
    const result = await uploadVideo(file, {
      request: requestVideoUploadAction,
      complete: completeVideoUploadAction,
    });
    setUploading(false);
    input.value = '';
    if (result.ok) {
      setUploaded(true);
      setF((p) => ({ ...p, videoMediaId: result.mediaId }));
    } else {
      setError(result.error);
    }
  }

  const save = () => {
    const problem = validateLessonForm(form, hosts);
    if (problem) return setError(problem);
    setError(null);
    start(async () => {
      const res = await saveLessonAction(courseId, lessonId, form, hosts);
      if (res.ok) {
        onDone();
        router.refresh();
      } else {
        setError(res.error);
      }
    });
  };

  const status = uploaded
    ? 'UPLOADED'
    : f.videoMediaId === initial.videoMediaId
      ? videoStatus
      : 'UPLOADED';

  return (
    <section
      className="card"
      aria-label={lessonId ? 'Edit lesson' : 'New lesson'}
      style={{ padding: 20, display: 'grid', gap: 16 }}
    >
      <h3>{lessonId ? 'Edit lesson' : 'New lesson'}</h3>
      <div className="filters">
        <label className="field" style={{ flex: 1 }}>
          Lesson title
          <input
            className="input"
            value={f.title}
            maxLength={140}
            onChange={(e) => set('title', e.target.value)}
          />
        </label>
        <label className="field">
          Length (minutes)
          <input
            className="input"
            inputMode="numeric"
            style={{ width: 110 }}
            value={f.durationMinutes}
            onChange={(e) => set('durationMinutes', e.target.value)}
          />
        </label>
      </div>

      <fieldset className="field" style={{ border: 0, padding: 0, margin: 0 }}>
        <legend>Video</legend>
        <div className="row-actions" role="radiogroup" aria-label="Video">
          {(Object.keys(PLAYER_LABELS) as Player[]).map((p) => (
            <label key={p} style={{ display: 'inline-flex', gap: 6, alignItems: 'center' }}>
              <input
                type="radio"
                name="player"
                checked={f.player === p}
                disabled={busy}
                onChange={() => set('player', p)}
              />
              {PLAYER_LABELS[p]}
            </label>
          ))}
        </div>
        {f.player === 'VIDEO' ? (
          <div style={{ display: 'grid', gap: 6, marginTop: 8 }}>
            <input
              type="file"
              accept={VIDEO_TYPES.join(',')}
              aria-label="Lesson video file"
              disabled={busy}
              onChange={(e) => void pickVideo(e.target.files?.[0], e.currentTarget)}
            />
            <span className="muted">
              MP4, MOV or WebM, up to 200 MB. It stays private: only members enrolled in the course
              can play it.
            </span>
            {uploading ? (
              <span className="muted" role="status">
                Uploading…
              </span>
            ) : null}
            {f.videoMediaId ? (
              <span role="status">
                <span className={`pill ${videoStatusMeta(status).tone}`.trim()}>
                  {videoStatusMeta(status).label}
                </span>{' '}
                <button
                  type="button"
                  className="button secondary small"
                  onClick={() => router.refresh()}
                >
                  Refresh status
                </button>
              </span>
            ) : (
              <span className="muted">No video uploaded yet.</span>
            )}
          </div>
        ) : null}
        {f.player === 'EMBED' ? (
          <label className="field" style={{ marginTop: 8 }}>
            Embedded player address
            <input
              className="input"
              type="url"
              value={f.embedUrl}
              placeholder="https://www.youtube.com/watch?v=…"
              onChange={(e) => set('embedUrl', e.target.value)}
            />
            <span className="muted">
              Allowed hosts: {hosts.length > 0 ? hosts.join(', ') : 'not loaded'}.
            </span>
            {embed?.ok ? (
              <span role="status">
                Members will see: <code>{embed.url}</code>
              </span>
            ) : embed ? (
              <span className="alert" role="alert">
                {embed.error}
              </span>
            ) : null}
          </label>
        ) : null}
      </fieldset>

      <div>
        <h4>Text</h4>
        {blocks.length === 0 ? <p className="empty">No text yet. Add a block below.</p> : null}
        <ol style={{ listStyle: 'none', padding: 0, display: 'grid', gap: 12 }}>
          {blocks.map((b, i) => (
            <li key={b.key} className="card" style={{ padding: 12 }}>
              <BlockFields
                block={b}
                index={i}
                last={i === blocks.length - 1}
                disabled={busy}
                onChange={(patch) => dispatch({ kind: 'update', key: b.key, patch })}
                onMove={(direction) => dispatch({ kind: 'move', key: b.key, direction })}
                onRemove={() => dispatch({ kind: 'remove', key: b.key })}
              />
            </li>
          ))}
        </ol>
        <div className="row-actions" role="group" aria-label="Add a block">
          {BLOCK_TYPES.map((t: BlockType) => (
            <button
              key={t}
              type="button"
              className="button secondary small"
              disabled={busy}
              onClick={() => dispatch({ kind: 'add', key: nextKey(), type: t })}
            >
              Add {BLOCK_LABELS[t].toLowerCase()}
            </button>
          ))}
        </div>
      </div>

      <label className="field">
        Practice prompt (optional)
        <textarea
          className="textarea"
          rows={2}
          maxLength={400}
          value={f.practicePrompt}
          placeholder="Try it yourself: …"
          onChange={(e) => set('practicePrompt', e.target.value)}
        />
      </label>
      <label className="field">
        Practice skill (the portfolio project it opens is pre-filled with this skill)
        <select
          className="select"
          value={f.practiceSkillId}
          onChange={(e) => set('practiceSkillId', e.target.value)}
        >
          <option value="">None</option>
          {skills.map((s) => (
            <option key={s.id} value={s.id}>
              {s.name}
            </option>
          ))}
        </select>
      </label>

      {error ? (
        <p className="alert" role="alert">
          {error}
        </p>
      ) : null}
      <div className="row-actions">
        <button type="button" className="button" disabled={busy} onClick={save}>
          {pending ? 'Saving…' : lessonId ? 'Save lesson' : 'Add lesson'}
        </button>
        <button type="button" className="button secondary" disabled={busy} onClick={onDone}>
          Cancel
        </button>
      </div>
    </section>
  );
}
