/** Branded notification email. Plain text is the source of truth; the HTML mirrors it. */
const escapeHtml = (s: string) =>
  s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

export function renderNotificationEmail(input: {
  title: string;
  body: string;
  /** Absolute URL to open, built from the in-app deep link, or undefined. */
  link?: string;
}): { subject: string; text: string; html: string } {
  const { title, body, link } = input;
  const text = [
    title,
    '',
    body,
    ...(link ? ['', `Open in Atarah: ${link}`] : []),
    '',
    'Atarah · Create · Connect · Grow',
  ].join('\n');
  const html = `<!doctype html>
<html lang="en"><body style="margin:0;background:#f8f6ff;font-family:'Plus Jakarta Sans',Arial,sans-serif;color:#4a4868">
<table role="presentation" width="100%" cellpadding="0" cellspacing="0"><tr><td align="center" style="padding:24px">
<table role="presentation" width="480" cellpadding="0" cellspacing="0" style="max-width:480px;background:#ffffff;border-radius:16px;padding:28px">
<tr><td style="font-weight:800;font-size:22px;letter-spacing:-0.01em;color:#15133d">ATARA<span style="color:#5b45f0">H</span></td></tr>
<tr><td style="padding-top:18px;font-weight:800;font-size:18px;color:#15133d">${escapeHtml(title)}</td></tr>
<tr><td style="padding-top:8px;font-size:15px;line-height:1.5">${escapeHtml(body)}</td></tr>
${link ? `<tr><td style="padding-top:20px"><a href="${escapeHtml(link)}" style="display:inline-block;background:#5b45f0;color:#ffffff;text-decoration:none;font-weight:700;padding:13px 24px;border-radius:999px">Open in Atarah</a></td></tr>` : ''}
<tr><td style="padding-top:24px;font-size:12px;letter-spacing:0.14em;text-transform:uppercase;color:#6f6d85;font-weight:600">Create · Connect · Grow</td></tr>
</table></td></tr></table></body></html>`;
  return { subject: title, text, html };
}
