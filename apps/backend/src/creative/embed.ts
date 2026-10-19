/**
 * The address of an embeddable player for a YouTube or Vimeo link, or null for any other address. Only these two
 * hosts are ever embedded (Master Prompt, P1-M4): an arbitrary link is opened through the leaving-Atarah modal.
 */
export function embedUrlFor(link: string): string | null {
  let url: URL;
  try {
    url = new URL(link);
  } catch {
    return null;
  }
  if (url.protocol !== 'https:') return null;
  const host = url.hostname.toLowerCase().replace(/^(www\.|m\.)/, '');
  const id = /^[A-Za-z0-9_-]{6,20}$/;

  if (host === 'youtu.be') {
    const v = url.pathname.split('/')[1] ?? '';
    return id.test(v) ? `https://www.youtube-nocookie.com/embed/${v}` : null;
  }
  if (host === 'youtube.com') {
    const parts = url.pathname.split('/').filter(Boolean);
    let v: string | null = null;
    if (parts[0] === 'watch') v = url.searchParams.get('v');
    else if (parts[0] === 'shorts' || parts[0] === 'embed' || parts[0] === 'live')
      v = parts[1] ?? null;
    return v && id.test(v) ? `https://www.youtube-nocookie.com/embed/${v}` : null;
  }
  if (host === 'vimeo.com' || host === 'player.vimeo.com') {
    const parts = url.pathname.split('/').filter(Boolean);
    const v = host === 'player.vimeo.com' ? parts[1] : parts[0];
    return v && /^\d{6,12}$/.test(v) ? `https://player.vimeo.com/video/${v}` : null;
  }
  return null;
}
