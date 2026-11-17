/** Browser-side lesson-video upload: ask the API for a signed URL, PUT the bytes to it, then confirm. */
import type { UploadDeps, UploadResult } from './image-upload';
import { validateVideoFile } from './learning';

/**
 * The same three steps as an image upload (ticket, PUT, complete). The video stays private: members get a short-lived
 * signed address only while enrolled. The worker checks the file afterwards, so the caller shows `videoStatus` from the
 * lesson until it is READY (or REFUSED).
 */
export async function uploadVideo(file: File, deps: UploadDeps): Promise<UploadResult> {
  const problem = validateVideoFile(file);
  if (problem) return { ok: false, error: problem };
  const asked = await deps.request(file.type, file.size);
  if (!asked.ok) return asked;
  try {
    const res = await (deps.put ?? fetch)(asked.ticket.uploadUrl, {
      method: 'PUT',
      headers: asked.ticket.headers,
      body: file,
    });
    if (!res.ok) return { ok: false, error: `The upload was refused (${res.status}). Try again.` };
  } catch {
    return { ok: false, error: 'The upload could not reach storage. Check your connection.' };
  }
  const done = await deps.complete(asked.ticket.id);
  if (!done.ok) return done;
  return { ok: true, mediaId: asked.ticket.id };
}
