// Generates the Atarah placeholder image library (offline). Usage: node gen.js OUT_DIR
const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');
const { createAvatar } = require('@dicebear/core');
const { openPeeps } = require('@dicebear/collection');

const OUT = process.argv[2];
const ICONS = path.join(__dirname, 'node_modules/lucide-static/icons');
const FONT = fs.readFileSync(path.join(__dirname, '../newlogo/fonts/jakarta-800.ttf')).toString('base64');

// ---- seeded random ----
function rng(seedStr) {
  let h = 2166136261;
  for (const c of seedStr) h = Math.imul(h ^ c.charCodeAt(0), 16777619);
  return () => {
    h += 0x6d2b79f5;
    let t = h;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}
const pick = (r, a) => a[Math.floor(r() * a.length)];

function icon(name) {
  const s = fs.readFileSync(path.join(ICONS, `${name}.svg`), 'utf8');
  return s.replace(/<!--.*?-->/s, '').replace(/^[\s\S]*?<svg[^>]*>/, '').replace(/<\/svg>\s*$/, '');
}

// Logo palette (Ascent) plus deep tones for depth.
const PALETTES = {
  violet: ['#2708C8', '#7B26FF', '#F43AAB'],
  sunset: ['#D20E8C', '#FC6727', '#FEB120'],
  dusk: ['#17153F', '#5325E8', '#FC6727'],
  ocean: ['#0F3B5F', '#22DAAE', '#FEB120'],
  berry: ['#3A0050', '#DC064E', '#FCD03A'],
  teal: ['#0D4F4A', '#22DAAE', '#7B26FF'],
  ember: ['#4A1504', '#FC6727', '#FDB42A'],
  night: ['#0D0A2E', '#2708C8', '#22DAAE'],
};

const THEMES = {
  animation: { icons: ['clapperboard', 'wand-sparkles', 'sparkles', 'pen-tool', 'layers'], pals: ['violet', 'sunset', 'teal'] },
  music: { icons: ['music', 'headphones', 'mic-vocal', 'audio-waveform', 'disc-3', 'piano', 'guitar', 'drum'], pals: ['dusk', 'berry', 'night'] },
  visualart: { icons: ['palette', 'brush', 'pen-tool', 'feather', 'shapes'], pals: ['sunset', 'ember', 'ocean'] },
  film: { icons: ['film', 'clapperboard', 'video', 'tv', 'aperture'], pals: ['night', 'dusk', 'ember'] },
  photo: { icons: ['camera', 'aperture', 'image', 'sun', 'mountain'], pals: ['ocean', 'teal', 'sunset'] },
  design: { icons: ['shapes', 'layers', 'lightbulb', 'presentation', 'pen-tool'], pals: ['violet', 'teal', 'berry'] },
  business: { icons: ['briefcase', 'lightbulb', 'presentation', 'award', 'graduation-cap'], pals: ['night', 'violet', 'ember'] },
  learning: { icons: ['book-open', 'graduation-cap', 'lightbulb', 'presentation'], pals: ['teal', 'violet', 'sunset'] },
  rights: { icons: ['scale', 'feather', 'book-open', 'award'], pals: ['dusk', 'ocean', 'berry'] },
  community: { icons: ['users', 'sparkles', 'map-pin', 'calendar-heart'], pals: ['sunset', 'violet', 'teal'] },
  city: { icons: ['building-2', 'map-pin', 'users', 'sun'], pals: ['ember', 'dusk', 'ocean'] },
};

function art(seed, theme, w, h, opts = {}) {
  const r = rng(seed);
  const t = THEMES[theme];
  const [c1, c2, c3] = PALETTES[opts.palette || pick(r, t.pals)];
  const ang = Math.floor(r() * 360);
  let blobs = '';
  for (let i = 0; i < 5; i++) {
    const cx = r() * w, cy = r() * h, rad = (0.25 + r() * 0.45) * Math.max(w, h);
    const col = pick(r, [c2, c3, '#ffffff']);
    blobs += `<circle cx="${cx}" cy="${cy}" r="${rad}" fill="url(#g${i})"/>
      <radialGradient id="g${i}"><stop offset="0" stop-color="${col}" stop-opacity="${0.35 + r() * 0.35}"/><stop offset="1" stop-color="${col}" stop-opacity="0"/></radialGradient>`;
  }
  // layered hills / waves for depth
  let hills = '';
  const layers = 2 + Math.floor(r() * 2);
  for (let i = 0; i < layers; i++) {
    const base = h * (0.62 + i * 0.12);
    const amp = h * (0.06 + r() * 0.08);
    const p = [`M0 ${base}`];
    const n = 4;
    for (let k = 1; k <= n; k++) {
      const x = (w * k) / n;
      p.push(`Q ${x - w / n / 2} ${base + (r() - 0.5) * 2 * amp} ${x} ${base + (r() - 0.5) * amp}`);
    }
    p.push(`L ${w} ${h} L 0 ${h} Z`);
    hills += `<path d="${p.join(' ')}" fill="${i === layers - 1 ? c1 : '#000'}" fill-opacity="${0.18 + i * 0.12}"/>`;
  }
  // rings and dots
  let deco = '';
  for (let i = 0; i < 3; i++) {
    deco += `<circle cx="${r() * w}" cy="${r() * h * 0.7}" r="${20 + r() * h * 0.25}" fill="none" stroke="#fff" stroke-opacity="${0.08 + r() * 0.12}" stroke-width="${1 + r() * 3}"/>`;
  }
  for (let i = 0; i < 18; i++) {
    deco += `<circle cx="${r() * w}" cy="${r() * h}" r="${1 + r() * 3}" fill="#fff" fill-opacity="${0.2 + r() * 0.5}"/>`;
  }
  const main = opts.icon || pick(r, t.icons);
  const size = h * (0.34 + r() * 0.12);
  const ix = w * (0.18 + r() * 0.5), iy = h * (0.16 + r() * 0.22);
  const tilt = (r() - 0.5) * 18;
  let smalls = '';
  for (let i = 0; i < 4; i++) {
    const s = h * (0.06 + r() * 0.06);
    smalls += `<g transform="translate(${r() * (w - s)} ${r() * (h - s)}) rotate(${(r() - 0.5) * 40} ${s / 2} ${s / 2}) scale(${s / 24})" fill="none" stroke="#fff" stroke-opacity="0.35" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">${icon(pick(r, t.icons))}</g>`;
  }
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}">
  <defs>
    <linearGradient id="bg" gradientTransform="rotate(${ang} .5 .5)"><stop offset="0" stop-color="${c1}"/><stop offset=".6" stop-color="${c2}"/><stop offset="1" stop-color="${c3}"/></linearGradient>
    <filter id="grain"><feTurbulence type="fractalNoise" baseFrequency=".9" numOctaves="2" stitchTiles="stitch"/><feColorMatrix values="0 0 0 0 1  0 0 0 0 1  0 0 0 0 1  0 0 0 .07 0"/></filter>
    <filter id="sh" x="-30%" y="-30%" width="160%" height="160%"><feDropShadow dx="0" dy="${h * 0.012}" stdDeviation="${h * 0.02}" flood-color="#000" flood-opacity=".35"/></filter>
  </defs>
  <rect width="${w}" height="${h}" fill="url(#bg)"/>
  ${blobs}${hills}${deco}${smalls}
  <g filter="url(#sh)" transform="translate(${ix} ${iy}) rotate(${tilt} ${size / 2} ${size / 2}) scale(${size / 24})" fill="none" stroke="#fff" stroke-width="1.35" stroke-linecap="round" stroke-linejoin="round">${icon(main)}</g>
  <rect width="${w}" height="${h}" filter="url(#grain)"/>
</svg>`;
}

const AV_BG = ['#EDE7FF', '#FFE3EF', '#FFE9D6', '#DDF7F0', '#FFF3CF', '#E3E8FF'];
function avatar(seed, opts) {
  const r = rng(seed);
  const peep = createAvatar(openPeeps, {
    seed,
    size: 600,
    skinColor: [opts.skin],
    head: [opts.head],
    face: [opts.face || pick(r, ['smile', 'smileBig', 'calm', 'cute', 'lovingGrin1', 'smileTeethGap'])],
    facialHairProbability: opts.beard ? 100 : 0,
    facialHair: opts.beard ? [opts.beard] : undefined,
    accessoriesProbability: opts.glasses ? 100 : 0,
    accessories: opts.glasses ? [opts.glasses] : undefined,
    maskProbability: 0,
    clothingColor: [pick(r, ['e78276', 'ffcf77', '78e185', '9ddadb', '8fa7df', 'e279c7'])],
    backgroundColor: [(opts.bg || pick(r, AV_BG)).slice(1)],
    scale: 92,
    translateY: 4,
  }).toString();
  return peep;
}

function logo(name, palette, shape) {
  const [c1, c2, c3] = PALETTES[palette];
  const initials = name.split(/\s+/).filter((w) => /^[A-Z]/.test(w)).slice(0, 2).map((w) => w[0]).join('');
  const shapes = {
    circle: `<circle cx="300" cy="140" r="54" fill="${c3}" opacity=".9"/>`,
    arc: `<path d="M190 500 A110 70 0 0 1 410 500" fill="none" stroke="${c3}" stroke-width="26" stroke-linecap="round" opacity=".9"/>`,
    wave: `<path d="M90 470 C170 420 230 520 300 470 S430 420 510 470" fill="none" stroke="${c3}" stroke-width="22" stroke-linecap="round"/>`,
    diamond: `<rect x="270" y="90" width="60" height="60" transform="rotate(45 300 120)" fill="${c3}"/>`,
  };
  return `<svg xmlns="http://www.w3.org/2000/svg" width="600" height="600" viewBox="0 0 600 600">
  <defs><style>@font-face{font-family:J;src:url(data:font/ttf;base64,${FONT})}</style>
  <linearGradient id="b" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="${c1}"/><stop offset="1" stop-color="${c2}"/></linearGradient></defs>
  <rect width="600" height="600" rx="0" fill="url(#b)"/>
  ${shapes[shape]}
  <text x="300" y="${initials.length > 1 ? 372 : 380}" text-anchor="middle" font-family="J" font-weight="800" font-size="${initials.length > 1 ? 196 : 240}" fill="#fff" letter-spacing="-6">${initials}</text>
</svg>`;
}

// ---------------- the library ----------------
const jobs = []; // [relPath, svg, w, h]
const A = (rel, svg) => jobs.push([`avatars/${rel}.jpg`, svg, 600, 600]);

// Demo members (see demo.ts / demo-community.ts) and a pool for any other profile without a picture.
A('nia-wairimu', avatar('nia', { skin: 'ae5d29', head: 'bantuKnots', face: 'smileBig', bg: '#FFE3EF' }));
A('amani-otieno', avatar('amani', { skin: '694d3d', head: 'shaved2', face: 'calm', beard: 'goatee1', bg: '#EDE7FF' }));
A('zuri-mwangi', avatar('zuri', { skin: 'd08b5b', head: 'longAfro', face: 'cute', bg: '#FFE9D6' }));
A('kiptoo-langat', avatar('kiptoo', { skin: '694d3d', head: 'short2', face: 'smile', glasses: 'glasses2', bg: '#DDF7F0' }));
A('wanjiku-njeri', avatar('wanjiku', { skin: 'ae5d29', head: 'cornrows', face: 'lovingGrin1', bg: '#FFF3CF' }));
A('demo-moderator', avatar('moderator', { skin: 'd08b5b', head: 'medium1', face: 'smile', bg: '#E3E8FF' }));
A('demo-admin', avatar('admin', { skin: 'ae5d29', head: 'hijab', face: 'smile', bg: '#EDE7FF' }));
A('demo-super-admin', avatar('super', { skin: '694d3d', head: 'dreads1', face: 'calm', glasses: 'glasses4', bg: '#DDF7F0' }));
const POOL = [
  ['afro', 'ae5d29', 'smileBig', null, null], ['short1', '694d3d', 'calm', 'full', null], ['bun', 'd08b5b', 'cute', null, null],
  ['dreads2', 'ae5d29', 'smile', null, null], ['longCurly', '694d3d', 'smile', null, 'glasses3'], ['flatTop', 'd08b5b', 'smileBig', 'moustache1', null],
  ['buns', 'ae5d29', 'lovingGrin2', null, null], ['short4', '694d3d', 'smileTeethGap', 'chin', null], ['cornrows2', 'd08b5b', 'calm', null, null],
  ['mediumBangs', 'edb98a', 'smileBig', null, 'glasses'], ['shaved1', 'ae5d29', 'calm', 'goatee2', null], ['twists', '694d3d', 'cute', null, null],
];
POOL.forEach(([head, skin, face, beard, glasses], i) =>
  A(`pool-${String(i + 1).padStart(2, '0')}`, avatar(`pool${i}`, { skin, head, face, beard, glasses, bg: AV_BG[i % AV_BG.length] })),
);

// Portfolio: three projects per demo creative, two pictures each (1600 x 1000).
const P = (rel, theme, opts) => jobs.push([`portfolio/${rel}.jpg`, art(rel, theme, 1600, 1000, opts), 1600, 1000]);
const PORTFOLIO = {
  'nia-wairimu': 'animation', 'amani-otieno': 'music', 'zuri-mwangi': 'visualart', 'kiptoo-langat': 'film', 'wanjiku-njeri': 'photo',
};
for (const [who, theme] of Object.entries(PORTFOLIO)) {
  const pals = THEMES[theme].pals;
  for (let p = 1; p <= 3; p++) for (let k = 1; k <= 2; k++) P(`${who}-${p}-${k}`, theme, { palette: pals[(p + k) % pals.length] });
}

// Articles (hero 1600 x 900), groups (1600 x 600), learning (1600 x 900), posts (1600 x 1200).
const W = (dir, rel, theme, w, h, opts) => jobs.push([`${dir}/${rel}.jpg`, art(rel, theme, w, h, opts), w, h]);
W('articles', 'how-to-price-commissioned-illustration-in-kenya', 'visualart', 1600, 900, { palette: 'sunset', icon: 'brush' });
W('articles', 'building-a-portfolio-that-gets-replies', 'design', 1600, 900, { palette: 'violet', icon: 'layers' });
W('articles', 'inline-studio', 'visualart', 1600, 1000, { palette: 'ocean', icon: 'palette' });
W('groups', 'atarah-community', 'community', 1600, 600, { palette: 'violet', icon: 'users' });
W('groups', 'nairobi-creatives', 'city', 1600, 600, { palette: 'ember', icon: 'building-2' });
W('groups', 'animators-of-kenya', 'animation', 1600, 600, { palette: 'teal', icon: 'clapperboard' });
W('groups', 'music-makers', 'music', 1600, 600, { palette: 'dusk', icon: 'headphones' });
W('groups', 'atarah-fellows', 'learning', 1600, 600, { palette: 'sunset', icon: 'award' });
const LEARN = [
  ['build-a-portfolio-that-gets-you-hired', 'design', 'violet', 'layers'],
  ['pricing-your-creative-work', 'business', 'ember', 'briefcase'],
  ['grant-writing-for-creatives', 'learning', 'teal', 'book-open'],
  ['creative-business-starter-kit', 'business', 'night', 'lightbulb'],
  ['branding-for-one-person-studios', 'design', 'berry', 'shapes'],
  ['know-your-rights-copyright-basics', 'rights', 'dusk', 'scale'],
  ['sound-design-for-short-films', 'music', 'night', 'audio-waveform'],
  ['colour-grading-quick-start', 'film', 'sunset', 'aperture'],
];
for (const [s, th, pal, ic] of LEARN) W('learning', s, th, 1600, 900, { palette: pal, icon: ic });
W('learning', 'generic-1', 'learning', 1600, 900, { palette: 'ocean' });
W('learning', 'generic-2', 'learning', 1600, 900, { palette: 'berry' });
W('learning', 'generic-3', 'learning', 1600, 900, { palette: 'violet' });
W('posts', 'animated-short', 'animation', 1600, 1200, { palette: 'sunset', icon: 'clapperboard' });
W('posts', 'meetup', 'community', 1600, 1200, { palette: 'ember', icon: 'calendar-heart' });
W('posts', 'documentary', 'film', 1600, 1200, { palette: 'night', icon: 'film' });
W('posts', 'shoot-1', 'photo', 1600, 1200, { palette: 'ocean', icon: 'camera' });
W('posts', 'shoot-2', 'photo', 1600, 1200, { palette: 'teal', icon: 'mountain' });
W('posts', 'shoot-3', 'photo', 1600, 1200, { palette: 'sunset', icon: 'sun' });
W('posts', 'link-preview', 'music', 1600, 900, { palette: 'berry', icon: 'disc-3' });

// Opportunity provider logos (600 x 600).
const PROVIDERS = [
  ['nairobi-creative-fund', 'Nairobi Creative Fund', 'violet', 'circle'],
  ['kilifi-arts-residency', 'Kilifi Arts Residency', 'ocean', 'wave'],
  ['lakeside-film-collective', 'Lakeside Film Collective', 'night', 'arc'],
  ['savannah-sound-festival', 'Savannah Sound Festival', 'sunset', 'wave'],
  ['east-africa-design-week', 'East Africa Design Week', 'berry', 'diamond'],
  ['kenya-creative-economy-council', 'Kenya Creative Economy Council', 'dusk', 'arc'],
  ['mombasa-stories-studio', 'Mombasa Stories Studio', 'teal', 'circle'],
  ['rift-valley-college-of-the-arts', 'Rift Valley College of the Arts', 'ember', 'diamond'],
];
for (const [s, n, pal, sh] of PROVIDERS) jobs.push([`providers/${s}.jpg`, logo(n, pal, sh), 600, 600]);
// Generic marks (no letters) for providers added later without a logo.
[['violet', 'briefcase'], ['teal', 'award'], ['sunset', 'sparkles'], ['dusk', 'building-2']].forEach(([pal, ic], i) => {
  const [c1, c2, c3] = PALETTES[pal];
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="600" height="600" viewBox="0 0 600 600"><defs><linearGradient id="b" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="${c1}"/><stop offset="1" stop-color="${c2}"/></linearGradient></defs><rect width="600" height="600" fill="url(#b)"/><circle cx="300" cy="300" r="190" fill="none" stroke="${c3}" stroke-width="14" opacity=".9"/><g transform="translate(180 180) scale(10)" fill="none" stroke="#fff" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">${icon(ic)}</g></svg>`;
  jobs.push([`providers/generic-${i + 1}.jpg`, svg, 600, 600]);
});

(async () => {
  const b = await chromium.launch();
  const pg = await b.newPage();
  for (const [rel, svg, w, h] of jobs) {
    const out = path.join(OUT, rel);
    fs.mkdirSync(path.dirname(out), { recursive: true });
    await pg.setViewportSize({ width: w, height: h });
    await pg.setContent(`<html><head><style>html,body{margin:0}svg{display:block;width:${w}px;height:${h}px}</style></head><body>${svg}</body></html>`);
    await pg.evaluate(() => document.fonts.ready);
    await pg.screenshot({ path: out, type: 'jpeg', quality: 82, clip: { x: 0, y: 0, width: w, height: h } });
  }
  await b.close();
  console.log('wrote', jobs.length);
})();
