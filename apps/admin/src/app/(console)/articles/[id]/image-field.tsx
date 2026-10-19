'use client';

import { useRef, useState } from 'react';
import { completeImageUploadAction, requestImageUploadAction } from '@/app/articles-actions';
import { IMAGE_TYPES } from '@/lib/articles';
import { uploadImage } from '@/lib/image-upload';

/** Upload (or replace) one image. The browser PUTs the bytes straight to the signed URL. */
export function ImageField({
  label,
  mediaId,
  previewUrl,
  disabled,
  onChange,
  onRemove,
}: {
  label: string;
  mediaId: string;
  previewUrl: string;
  disabled: boolean;
  onChange: (mediaId: string, previewUrl: string) => void;
  onRemove?: () => void;
}) {
  const input = useRef<HTMLInputElement>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function pick(file: File | undefined) {
    if (!file) return;
    setError(null);
    setBusy(true);
    const result = await uploadImage(file, {
      request: requestImageUploadAction,
      complete: completeImageUploadAction,
    });
    setBusy(false);
    if (input.current) input.current.value = '';
    if (result.ok) onChange(result.mediaId, URL.createObjectURL(file));
    else setError(result.error);
  }

  return (
    <div className="field">
      <span>{label}</span>
      {mediaId && previewUrl ? (
        // eslint-disable-next-line @next/next/no-img-element
        <img
          src={previewUrl}
          alt={`${label} preview`}
          style={{ maxWidth: 320, maxHeight: 200, objectFit: 'cover', borderRadius: 8 }}
        />
      ) : mediaId ? (
        <span className="muted">Image attached (preview unavailable until you save).</span>
      ) : (
        <span className="muted">No image yet.</span>
      )}
      <div className="row-actions">
        <input
          ref={input}
          type="file"
          accept={IMAGE_TYPES.join(',')}
          aria-label={`${label} file`}
          disabled={disabled || busy}
          onChange={(e) => void pick(e.target.files?.[0])}
        />
        {mediaId && onRemove ? (
          <button
            type="button"
            className="button secondary small"
            disabled={disabled || busy}
            onClick={onRemove}
          >
            Remove image
          </button>
        ) : null}
      </div>
      {busy ? (
        <span className="muted" role="status">
          Uploading…
        </span>
      ) : null}
      {error ? (
        <p className="alert" role="alert">
          {error}
        </p>
      ) : null}
    </div>
  );
}
