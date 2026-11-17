export interface LinkPreview {
  title: string | null;
  description: string | null;
  image: string | null;
  siteName: string | null;
}

const ENTITIES: Record<string, string> = {
  '&amp;': '&',
  '&lt;': '<',
  '&gt;': '>',
  '&quot;': '"',
  '&#39;': "'",
  '&apos;': "'",
  '&nbsp;': ' ',
};

const decode = (s: string): string =>
  s
    .replace(/&(amp|lt|gt|quot|apos|nbsp|#39);/g, (m) => ENTITIES[m] ?? m)
    .replace(/&#(\d+);/g, (_, n: string) => {
      const code = Number(n);
      return code > 0 && code < 0x110000 ? String.fromCodePoint(code) : '';
    })
    .replace(/\s+/g, ' ')
    .trim();

const clip = (s: string | null | undefined, n: number): string | null => {
  const v = s ? decode(s) : '';
  return v ? (v.length > n ? `${v.slice(0, n - 1)}…` : v) : null;
};

/** Reads `<meta>` pairs in either attribute order. */
function metaTags(head: string): Map<string, string> {
  const out = new Map<string, string>();
  for (const tag of head.match(/<meta\b[^>]*>/gi) ?? []) {
    const key = /\b(?:property|name)\s*=\s*["']([^"']+)["']/i.exec(tag)?.[1]?.toLowerCase();
    const value = /\bcontent\s*=\s*"([^"]*)"|\bcontent\s*=\s*'([^']*)'/i.exec(tag);
    const content = value?.[1] ?? value?.[2];
    if (key && content !== undefined && !out.has(key)) out.set(key, content);
  }
  return out;
}

/**
 * Pulls a preview out of a page: Open Graph first, then Twitter cards, then the plain title and description.
 * Nothing in the page is executed or rendered; the image is only kept when it is an absolute https address
 * (the app loads it; the server never fetches it).
 */
export function parseLinkPreview(html: string, pageUrl: string): LinkPreview {
  const head = html.slice(0, html.search(/<\/head>/i) > 0 ? html.search(/<\/head>/i) : 64 * 1024);
  const meta = metaTags(head);
  const pick = (...keys: string[]) => keys.map((k) => meta.get(k)).find((v) => v && v.trim());
  const titleTag = /<title[^>]*>([\s\S]*?)<\/title>/i.exec(head)?.[1];

  let image: string | null = null;
  const rawImage = pick('og:image:secure_url', 'og:image', 'twitter:image', 'twitter:image:src');
  if (rawImage) {
    try {
      const abs = new URL(decode(rawImage), pageUrl);
      if (abs.protocol === 'https:' && !abs.username && !abs.password && abs.href.length <= 2048) {
        image = abs.href;
      }
    } catch {
      image = null;
    }
  }
  let siteName = clip(pick('og:site_name'), 80);
  if (!siteName) {
    try {
      siteName = new URL(pageUrl).hostname.replace(/^www\./, '');
    } catch {
      siteName = null;
    }
  }
  return {
    title: clip(pick('og:title', 'twitter:title') ?? titleTag, 200),
    description: clip(pick('og:description', 'twitter:description', 'description'), 300),
    image,
    siteName,
  };
}
