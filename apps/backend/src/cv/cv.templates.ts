import { type CvDocument, type CvProject } from './cv.model';

/** HTML-escape everything that comes from a member. Templates never concatenate raw member text. */
export const esc = (v: unknown): string =>
  String(v ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');

/** Only http(s) links become clickable; anything else (javascript:, data:) is shown as text. */
const safeUrl = (u: string): string | null => (/^https?:\/\//i.test(u) ? u : null);
/** Avatars are inlined by the backend as data URIs of raster images only. */
const safeImage = (u: string | null): string | null =>
  u && /^data:image\/(png|jpeg|webp);base64,[A-Za-z0-9+/=]+$/.test(u) ? u : null;

const para = (text: string): string =>
  text
    .split(/\n{2,}/)
    .map((p) => `<p>${esc(p.trim()).replace(/\n/g, '<br>')}</p>`)
    .join('');

const CSS = `
@page { size: A4; margin: 16mm 15mm; }
* { box-sizing: border-box; }
html { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
body { margin: 0; font-family: "Helvetica Neue", Helvetica, Arial, sans-serif; color: #1c1a3a; font-size: 10.5pt; line-height: 1.5; background: #fff; }
.page { max-width: 780px; margin: 0 auto; padding: 0; }
h1 { font-size: 24pt; margin: 0; letter-spacing: -0.01em; }
h2 { font-size: 8.5pt; letter-spacing: .14em; text-transform: uppercase; color: #5145D8; margin: 20px 0 8px; border-bottom: 1px solid #e7e4ff; padding-bottom: 4px; }
h3 { font-size: 11pt; margin: 0; }
p { margin: 0 0 6px; }
a { color: #5145D8; text-decoration: none; }
.muted { color: #6a6888; }
.sub { color: #5145D8; font-weight: 600; font-size: 11pt; margin-top: 2px; }
.head { display: flex; gap: 16px; align-items: center; padding-bottom: 14px; border-bottom: 3px solid #5145D8; }
.avatar { width: 72px; height: 72px; border-radius: 50%; object-fit: cover; flex: none; }
.avatar-fallback { width: 72px; height: 72px; border-radius: 50%; background: #5145D8; color: #fff; display: grid; place-items: center; font-size: 24pt; font-weight: 700; flex: none; }
.tick { display: inline-block; background: #5145D8; color: #fff; border-radius: 999px; font-size: 7.5pt; padding: 1px 7px; margin-left: 6px; vertical-align: middle; font-weight: 600; }
.item { margin-bottom: 11px; break-inside: avoid; }
.row { display: flex; justify-content: space-between; gap: 12px; }
.pill { display: inline-block; border-radius: 999px; background: #f2f1f6; padding: 2px 9px; margin: 0 4px 4px 0; font-size: 9pt; }
.pill.ok { background: #efedff; color: #5145D8; font-weight: 600; }
.foot { margin-top: 26px; padding-top: 8px; border-top: 1px solid #ecebf4; font-size: 8pt; color: #8a88a3; display: flex; justify-content: space-between; }
.cover { min-height: 235mm; display: flex; flex-direction: column; justify-content: center; background: linear-gradient(135deg,#7968FF,#5145D8); color: #fff; padding: 30mm 18mm; border-radius: 6px; }
.cover h1 { font-size: 34pt; } .cover .sub { color: #e7e4ff; font-size: 14pt; }
.slide { break-before: page; min-height: 235mm; padding-top: 6mm; }
.slide h2 { margin-top: 0; }
.big { font-size: 16pt; font-weight: 700; margin-bottom: 6px; }
.kit { background: #f6f5fc; border-radius: 10px; padding: 12px 14px; margin-top: 14px; }
.hero { padding: 18px 20px; border-radius: 10px; background: linear-gradient(135deg,#efedff,#f6f5fc); margin-bottom: 8px; }
`;

function verifiedTick(doc: CvDocument): string {
  return doc.identityVerified ? '<span class="tick">Verified</span>' : '';
}

function avatar(doc: CvDocument): string {
  const img = safeImage(doc.avatarDataUri);
  if (img) return `<img class="avatar" src="${img}" alt="">`;
  return `<div class="avatar-fallback">${esc(doc.displayName.trim().charAt(0).toUpperCase() || 'A')}</div>`;
}

function header(doc: CvDocument): string {
  const sub = [doc.formatLabel, doc.discipline].filter(Boolean).join(' · ');
  return `<div class="head">${avatar(doc)}<div>
    <h1>${esc(doc.displayName)}${verifiedTick(doc)}</h1>
    ${doc.headline ? `<div>${esc(doc.headline)}</div>` : ''}
    <div class="sub">${esc(sub)}${doc.location ? ` <span class="muted">· ${esc(doc.location)}</span>` : ''}</div>
  </div></div>`;
}

function skillPills(doc: CvDocument): string {
  if (!doc.skills?.length) return '';
  return doc.skills
    .map(
      (s) =>
        `<span class="pill${s.verified ? ' ok' : ''}">${esc(s.name)}${s.verified ? ' ✓' : ''}</span>`,
    )
    .join('');
}

function linkList(doc: CvDocument): string {
  if (!doc.links?.length) return '';
  return doc.links
    .map((l) => {
      const href = safeUrl(l.url);
      return `<div>${esc(l.label)}: ${href ? `<a href="${esc(href)}">${esc(l.url)}</a>` : esc(l.url)}</div>`;
    })
    .join('');
}

function contactBlock(doc: CvDocument): string {
  if (!doc.contact) return '';
  const lines = [doc.contact.email, doc.contact.phone]
    .filter(Boolean)
    .map((l) => `<div>${esc(l)}</div>`);
  return lines.length ? `<h2>Contact</h2>${lines.join('')}` : '';
}

const when = (p: { year: number | null }) => (p.year ? String(p.year) : '');

function projectItem(p: CvProject, detailed: boolean): string {
  const meta = [p.role, p.client ? `for ${p.client}` : null].filter(Boolean).join(' ');
  return `<div class="item">
    <div class="row"><h3>${esc(p.title)}</h3><span class="muted">${esc(when(p))}</span></div>
    ${meta ? `<div class="muted">${esc(meta)}</div>` : ''}
    ${p.description ? `<div>${para(detailed ? p.description : p.description.slice(0, 280))}</div>` : ''}
    ${p.outcome && detailed ? `<div><b>Outcome:</b> ${esc(p.outcome)}</div>` : ''}
    ${p.skills.length ? `<div>${p.skills.map((s) => `<span class="pill">${esc(s)}</span>`).join('')}</div>` : ''}
  </div>`;
}

function experienceBlock(doc: CvDocument): string {
  if (!doc.experience?.length) return '';
  const rows = doc.experience
    .map(
      (e) => `<div class="item"><div class="row"><h3>${esc(e.title)} · ${esc(e.organisation)}</h3>
      <span class="muted">${esc(e.start.slice(0, 7))} – ${esc(e.current ? 'Present' : (e.end ?? '').slice(0, 7))}</span></div>
      ${e.location ? `<div class="muted">${esc(e.location)}</div>` : ''}
      ${e.description ? para(e.description) : ''}</div>`,
    )
    .join('');
  return `<h2>Experience</h2>${rows}`;
}

function achievementsBlock(doc: CvDocument): string {
  if (!doc.achievements?.length) return '';
  const rows = doc.achievements
    .map(
      (
        a,
      ) => `<div class="item"><div class="row"><h3>${esc(a.title)}</h3><span class="muted">${esc(when(a))}</span></div>
      ${a.issuer ? `<div class="muted">${esc(a.issuer)}</div>` : ''}${a.description ? para(a.description) : ''}</div>`,
    )
    .join('');
  return `<h2>Achievements and recognition</h2>${rows}`;
}

function servicesBlock(doc: CvDocument): string {
  if (!doc.services?.length) return '';
  const rows = doc.services
    .map(
      (
        s,
      ) => `<div class="item"><div class="row"><h3>${esc(s.title)}</h3><span class="muted">${esc(s.price ?? '')}</span></div>
      ${s.description ? para(s.description) : ''}</div>`,
    )
    .join('');
  return `<h2>Services</h2>${rows}`;
}

function footer(doc: CvDocument, generatedAt: Date): string {
  const date = generatedAt.toISOString().slice(0, 10);
  return `<div class="foot"><span>Created with Atarah${doc.handle ? ` · atarah.app/${esc(doc.handle)}` : ''}</span><span>${esc(date)}</span></div>`;
}

function cv(doc: CvDocument): string {
  return `${header(doc)}
    ${doc.bio ? `<h2>Profile</h2>${para(doc.bio)}` : ''}
    ${doc.projects?.length ? `<h2>Selected work</h2>${doc.projects.map((p) => projectItem(p, false)).join('')}` : ''}
    ${experienceBlock(doc)}${achievementsBlock(doc)}
    ${doc.skills?.length ? `<h2>Skills</h2><div>${skillPills(doc)}</div>` : ''}
    ${servicesBlock(doc)}
    ${doc.links?.length ? `<h2>Links</h2>${linkList(doc)}` : ''}
    ${contactBlock(doc)}`;
}

function bio(doc: CvDocument): string {
  const highlights = doc.achievements?.slice(0, 5) ?? [];
  return `${header(doc)}
    <h2>Biography</h2>
    ${doc.bio ? `<div style="font-size:12pt;line-height:1.65">${para(doc.bio)}</div>` : '<p class="muted">No biography has been added yet.</p>'}
    ${highlights.length ? `<h2>Highlights</h2><ul>${highlights.map((a) => `<li>${esc(a.title)}${a.issuer ? ` — ${esc(a.issuer)}` : ''}${a.year ? ` (${a.year})` : ''}</li>`).join('')}</ul>` : ''}
    ${doc.experience?.length ? `<h2>Career</h2><ul>${doc.experience.map((e) => `<li>${esc(e.title)}, ${esc(e.organisation)}</li>`).join('')}</ul>` : ''}
    ${doc.skills?.length ? `<h2>Skills</h2><div>${skillPills(doc)}</div>` : ''}
    ${doc.links?.length ? `<h2>Find me online</h2>${linkList(doc)}` : ''}
    ${contactBlock(doc)}`;
}

function epk(doc: CvDocument): string {
  return `${header(doc)}
    ${doc.openToCommissions ? '<div class="hero"><b>Open to commissions.</b> Get in touch to work together.</div>' : ''}
    ${doc.bio ? `<h2>About</h2>${para(doc.bio)}` : ''}
    ${doc.projects?.length ? `<h2>Featured work</h2>${doc.projects.map((p) => projectItem(p, true)).join('')}` : ''}
    ${achievementsBlock(doc)}${experienceBlock(doc)}
    ${doc.skills?.length ? `<h2>Skills</h2><div>${skillPills(doc)}</div>` : ''}
    ${servicesBlock(doc)}
    ${doc.links?.length ? `<h2>Press and links</h2>${linkList(doc)}` : ''}
    ${doc.contact ? `<div class="kit">${contactBlock(doc).replace(/<h2>.*?<\/h2>/, '<b>Booking and press contact</b>')}</div>` : ''}`;
}

function deck(doc: CvDocument): string {
  const cover = `<div class="cover">
    <div style="display:flex;gap:16px;align-items:center;margin-bottom:18px">${avatar(doc)}</div>
    <h1>${esc(doc.displayName)}${verifiedTick(doc)}</h1>
    ${doc.headline ? `<div class="sub">${esc(doc.headline)}</div>` : ''}
    <div style="margin-top:14px;opacity:.9">Portfolio presentation${doc.discipline ? ` · ${esc(doc.discipline)}` : ''}${doc.location ? ` · ${esc(doc.location)}` : ''}</div>
  </div>`;
  const about = doc.bio
    ? `<div class="slide"><h2>About</h2><div style="font-size:13pt;line-height:1.7">${para(doc.bio)}</div></div>`
    : '';
  const slides = (doc.projects ?? [])
    .map(
      (p) => `<div class="slide"><h2>Selected work</h2><div class="big">${esc(p.title)}</div>
      <div class="muted">${esc([p.role, p.client, when(p)].filter(Boolean).join(' · '))}</div>
      ${p.description ? `<div style="font-size:12pt;margin-top:10px">${para(p.description)}</div>` : ''}
      ${p.outcome ? `<div class="kit"><b>Outcome</b><br>${esc(p.outcome)}</div>` : ''}
      ${p.skills.length ? `<div style="margin-top:10px">${p.skills.map((s) => `<span class="pill">${esc(s)}</span>`).join('')}</div>` : ''}</div>`,
    )
    .join('');
  const skills = doc.skills?.length
    ? `<div class="slide"><h2>Skills</h2><div>${skillPills(doc)}</div></div>`
    : '';
  const services = doc.services?.length ? `<div class="slide">${servicesBlock(doc)}</div>` : '';
  const close =
    doc.links?.length || doc.contact
      ? `<div class="slide"><h2>Let's work together</h2>${linkList(doc)}${contactBlock(doc).replace(/<h2>Contact<\/h2>/, '')}</div>`
      : '';
  return `${cover}${about}${slides}${skills}${services}${close}`;
}

/**
 * The branded HTML of one document. The same markup is the print source of the PDF (A4 through `@page`) and the
 * body of the public share page.
 */
export function renderCvHtml(doc: CvDocument, generatedAt: Date): string {
  const body =
    doc.format === 'CV'
      ? cv(doc)
      : doc.format === 'BIO'
        ? bio(doc)
        : doc.format === 'EPK'
          ? epk(doc)
          : deck(doc);
  return `<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="Content-Security-Policy" content="default-src 'none'; img-src data:; style-src 'unsafe-inline'">
<meta name="robots" content="noindex, nofollow">
<title>${esc(doc.displayName)} · ${esc(doc.formatLabel)}</title>
<style>${CSS}</style></head>
<body><div class="page">${body}${footer(doc, generatedAt)}</div></body></html>`;
}
