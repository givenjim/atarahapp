/** Browser-side image upload: ask the API for a signed URL, PUT the bytes to it, then confirm. */
import { validateImageFile } from './articles';

export interface UploadTicket {
  id: string;
  uploadUrl: string;
  headers: Record<string, string>;
}

export type UploadResult = { ok: true; mediaId: string } | { ok: false; error: string };

export interface UploadDeps {
  request: (
    mimeType: string,
    sizeBytes: number,
  ) => Promise<{ ok: true; ticket: UploadTicket } | { ok: false; error: string }>;
  complete: (mediaId: string) => Promise<{ ok: true } | { ok: false; error: string }>;
  put?: typeof fetch;
}

export async function uploadImage(file: File, deps: UploadDeps): Promise<UploadResult> {
  const problem = validateImageFile(file);
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
