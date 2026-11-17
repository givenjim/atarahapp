/**
 * Creates (or tops up) one verified showcase member with a finished, realistic profile, so a tester can open the app
 * and try every Phase 1 feature without setting anything up. It drives the REAL API as that member, the way the app
 * does (onboarding, portfolio, community, opportunities), so everything is consistent with what the backend enforces.
 *
 * Everything here is invented dummy data. The account's email, password and name come from the environment and are
 * never stored in the repository:
 *
 *   SHOWCASE_EMAIL      the account (created already verified when it does not exist)
 *   SHOWCASE_PASSWORD   its password
 *   SHOWCASE_NAME       the member's name, e.g. "Melvin Derrick"
 *   ATARAH_API_URL      the running API (default http://localhost:3000)
 *   ATARAH_SUPABASE_URL, ATARAH_SUPABASE_PUBLISHABLE_KEY, ATARAH_SUPABASE_SECRET_KEY
 *                       the Supabase project the API uses (the secret key creates the Auth user)
 *
 * Needs the API and the worker running (the worker validates the uploaded pictures) and the demo seed already applied
 * to that database (it connects the member with the demo members and saves demo opportunities). Safe to run again:
 * steps that are already done are skipped.
 *
 *   node --env-file=.env.cloud -r ts-node/register/transpile-only scripts/seed-showcase-account.ts
 */
import { createClient } from '@supabase/supabase-js';
import sharp from 'sharp';

const need = (k: string): string => {
  const v = process.env[k];
  if (!v) throw new Error(`${k} is required`);
  return v;
};

const EMAIL = need('SHOWCASE_EMAIL').toLowerCase();
const PASSWORD = need('SHOWCASE_PASSWORD');
const NAME = need('SHOWCASE_NAME');
const API = (process.env.ATARAH_API_URL ?? 'http://localhost:3000').replace(/\/$/, '') + '/api/v1';
const SUPABASE_URL = need('ATARAH_SUPABASE_URL');
const PUBLISHABLE = need('ATARAH_SUPABASE_PUBLISHABLE_KEY');
const SECRET = need('ATARAH_SUPABASE_SECRET_KEY');
const DEMO_PASSWORD = 'Atarah-demo-1';

const log = (m: string) => console.log(`• ${m}`);

// ---- tiny API client ------------------------------------------------------------------------------------------

interface Envelope<T> {
  data: T;
  meta?: Record<string, unknown>;
}

async function call<T = unknown>(
  token: string | null,
  method: string,
  path: string,
  body?: unknown,
  query: Record<string, string | number | boolean | undefined> = {},
  allow: number[] = [],
): Promise<Envelope<T> | null> {
  const qs = Object.entries(query)
    .filter(([, v]) => v !== undefined)
    .map(([k, v]) => `${k}=${encodeURIComponent(String(v))}`)
    .join('&');
  const res = await fetch(`${API}${path}${qs ? `?${qs}` : ''}`, {
    method,
    headers: {
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...(body !== undefined ? { 'Content-Type': 'application/json' } : {}),
    },
    ...(body !== undefined ? { body: JSON.stringify(body) } : {}),
  });
  if (allow.includes(res.status)) return null;
  const text = await res.text();
  if (!res.ok) throw new Error(`${method} ${path} -> ${res.status} ${text.slice(0, 400)}`);
  return text ? (JSON.parse(text) as Envelope<T>) : ({ data: null } as Envelope<T>);
}

async function signIn(email: string, password: string): Promise<{ token: string; id: string }> {
  const client = createClient(SUPABASE_URL, PUBLISHABLE, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
  const { data, error } = await client.auth.signInWithPassword({ email, password });
  if (error || !data.session) throw new Error(`Sign-in as ${email} failed: ${error?.message}`);
  return { token: data.session.access_token, id: data.user.id };
}

// ---- generated pictures ---------------------------------------------------------------------------------------

const esc = (s: string) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;');

async function picture(
  w: number,
  h: number,
  from: string,
  to: string,
  title: string,
  subtitle = '',
): Promise<Buffer> {
  const size = Math.round(Math.min(w, h) / (title.length > 3 ? 9 : 2.6));
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}">
    <defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="${from}"/><stop offset="1" stop-color="${to}"/></linearGradient>
      <radialGradient id="r" cx="0.75" cy="0.2" r="0.6"><stop offset="0" stop-color="#fff" stop-opacity="0.35"/>
      <stop offset="1" stop-color="#fff" stop-opacity="0"/></radialGradient></defs>
    <rect width="100%" height="100%" fill="url(#g)"/><rect width="100%" height="100%" fill="url(#r)"/>
    <text x="50%" y="${subtitle ? '48%' : '54%'}" text-anchor="middle" font-family="Helvetica, Arial, sans-serif"
      font-weight="700" font-size="${size}" fill="#fff">${esc(title)}</text>
    ${subtitle ? `<text x="50%" y="62%" text-anchor="middle" font-family="Helvetica, Arial, sans-serif" font-size="${Math.round(size / 2.4)}" fill="#fff" fill-opacity="0.85">${esc(subtitle)}</text>` : ''}
  </svg>`;
  return sharp(Buffer.from(svg)).jpeg({ quality: 86 }).toBuffer();
}

async function upload(token: string, bytes: Buffer): Promise<string> {
  const ticket = (
    await call<{ id: string; uploadUrl: string; headers: Record<string, string> }>(
      token,
      'POST',
      '/media/uploads',
      { kind: 'IMAGE', mimeType: 'image/jpeg', sizeBytes: bytes.length, visibility: 'PUBLIC' },
    )
  )!.data;
  const put = await fetch(ticket.uploadUrl, {
    method: 'PUT',
    headers: ticket.headers,
    body: new Uint8Array(bytes),
  });
  if (!put.ok) throw new Error(`Upload failed: ${put.status} ${await put.text()}`);
  await call(token, 'POST', `/media/${ticket.id}/complete`);
  for (let i = 0; i < 45; i += 1) {
    const m = (await call<{ status: string; rejectionReason: string | null }>(token, 'GET', `/media/${ticket.id}`))!.data;
    if (m.status === 'READY') return ticket.id;
    if (m.status === 'REJECTED') throw new Error(`Picture refused: ${m.rejectionReason}`);
    await new Promise((r) => setTimeout(r, 2000));
  }
  throw new Error('The picture never became READY. Is the worker running?');
}

// ---- steps ----------------------------------------------------------------------------------------------------

async function ensureAccount(): Promise<{ token: string; id: string }> {
  const admin = createClient(SUPABASE_URL, SECRET, { auth: { autoRefreshToken: false, persistSession: false } });
  const created = await admin.auth.admin.createUser({
    email: EMAIL,
    password: PASSWORD,
    email_confirm: true,
    user_metadata: { full_name: NAME },
  });
  if (created.error) {
    if (!/already|registered|exists/i.test(created.error.message)) throw created.error;
    // The account exists: make sure it is verified and has the expected password.
    const list = await admin.auth.admin.listUsers({ page: 1, perPage: 1000 });
    const found = list.data.users.find((u) => u.email?.toLowerCase() === EMAIL);
    if (!found) throw new Error('The account exists but could not be found.');
    await admin.auth.admin.updateUserById(found.id, { password: PASSWORD, email_confirm: true });
    log(`Account ${EMAIL} already existed: password and verification refreshed`);
  } else {
    log(`Created verified account ${EMAIL}`);
  }
  return signIn(EMAIL, PASSWORD);
}

interface Named {
  id: string;
  name: string;
  slug?: string;
}

async function onboard(token: string): Promise<void> {
  const state = (await call<{ completed: boolean }>(token, 'GET', '/me/onboarding'))!.data;
  if (state.completed) return log('Onboarding already finished');

  const disciplines = (await call<Array<Named & { specialisations: Named[] }>>(token, 'GET', '/taxonomy/disciplines'))!.data;
  const film = disciplines.find((d) => d.name === 'Film / Video') ?? disciplines[0]!;
  await call(token, 'PATCH', '/me/onboarding', { step: 'DISCIPLINE', disciplineId: film.id });
  await call(token, 'PATCH', '/me/onboarding', {
    step: 'SPECIALISATION',
    specialisationIds: film.specialisations.slice(0, 2).map((s) => s.id),
  });

  const skills = (await call<Named[]>(token, 'GET', '/taxonomy/skills', undefined, { discipline: film.id }))!.data;
  const wanted = ['After Effects', 'Storyboarding', 'Colour', 'Blender', 'Client management'];
  const picked = wanted.flatMap((n) => skills.filter((s) => s.name === n));
  const interests = (await call<Named[]>(token, 'GET', '/taxonomy/interests'))!.data;
  const growth = (await call<Named[]>(token, 'GET', '/taxonomy/development-areas'))!.data;
  await call(token, 'PATCH', '/me/onboarding', {
    step: 'SKILLS',
    skillIds: (picked.length > 0 ? picked : skills.slice(0, 5)).map((s) => s.id),
    interestIds: interests.slice(0, 3).map((i) => i.id),
    developmentAreaIds: growth.slice(0, 2).map((g) => g.id),
  });

  const countries = (await call<Named[]>(token, 'GET', '/locations/countries'))!.data;
  const counties = (await call<Array<Named & { code: string }>>(token, 'GET', '/locations/counties'))!.data;
  const nairobi = counties.find((c) => c.code === 'NBI') ?? counties[0]!;
  await call(token, 'PATCH', '/me/onboarding', {
    step: 'LOCATION',
    countryId: countries[0]!.id,
    countyId: nairobi.id,
    town: 'Kilimani',
    locationVisibility: 'MEMBERS',
  });
  const handle = NAME.toLowerCase().replace(/[^a-z0-9]+/g, '_').replace(/^_|_$/g, '');
  await call(token, 'PATCH', '/me/onboarding', {
    step: 'BASICS',
    displayName: NAME,
    handle,
    bio: 'Nairobi filmmaker and motion designer telling East African stories through short film, music videos and titles.',
  });
  const initials = NAME.split(/\s+/).map((p) => p[0]!.toUpperCase()).slice(0, 2).join('');
  const avatar = await upload(token, await picture(800, 800, '#5B3FD6', '#E4457E', initials));
  await call(token, 'POST', '/me/avatar', { mediaId: avatar });
  await call(token, 'POST', '/me/onboarding/complete');
  log(`Finished onboarding as @${handle}`);
}

async function profile(token: string): Promise<void> {
  await call(token, 'PATCH', '/me/profile', {
    headline: 'Filmmaker and motion designer in Nairobi',
    openToCommissions: true,
    contactShowEmail: true,
    contactForConnections: true,
    links: [
      { label: 'Showreel', url: 'https://example.com/showreel' },
      { label: 'Instagram', url: 'https://example.com/instagram' },
      { label: 'YouTube', url: 'https://example.com/youtube' },
    ],
  });
  log('Profile headline, availability and links set');
}

async function portfolio(token: string): Promise<void> {
  const existing = (await call<Array<{ title: string }>>(token, 'GET', '/me/projects'))!.data;
  const skills = (await call<Array<{ id: string; name: string; level: string | null }>>(token, 'GET', '/me/skills'))!.data;
  const ids = skills.map((s) => s.id);
  const levels = ['EXPERT', 'ADVANCED', 'ADVANCED', 'INTERMEDIATE', 'INTERMEDIATE'] as const;
  for (const [i, s] of skills.slice(0, 5).entries()) {
    if (s.level) continue;
    await call(token, 'PUT', `/me/skills/${s.id}`, { level: levels[i] });
  }

  const projects = [
    {
      title: 'Kibera Rising',
      role: 'Director and editor',
      client: 'Self-initiated',
      projectDate: '2025-03-14',
      category: 'PROJECT',
      description:
        'A 22-minute documentary following three young entrepreneurs in Kibera as they turn a shared compound into a market. Shot over five months on a two-person crew and edited in Nairobi.',
      outcome: 'Screened at three community cinema nights and won Best Short Documentary at the Nairobi Youth Film Night.',
      colours: ['#7A3FD8', '#E4457E'],
      cover: 'Kibera Rising',
      sub: 'Documentary · 22 min',
      featured: true,
      links: [{ label: 'Watch the trailer', url: 'https://example.com/kibera-rising' }],
    },
    {
      title: 'Nairobi Nights: Music Video',
      role: 'Director and colourist',
      client: 'Zawadi Amani',
      projectDate: '2024-11-02',
      category: 'MEDIA',
      description:
        'A single-take style music video shot across five Nairobi locations in one night for an afro-soul single. Graded for a warm, neon-lit look.',
      outcome: 'Over 180,000 views in the first two months and a feature on a local music channel.',
      colours: ['#0F9D8A', '#2B2D7E'],
      cover: 'Nairobi Nights',
      sub: 'Music video',
      featured: true,
      links: [],
    },
    {
      title: 'Mombasa Road: Title Sequence',
      role: 'Motion designer',
      client: 'Pamoja Studios',
      projectDate: '2024-06-20',
      category: 'MEDIA',
      description:
        'Opening titles for a six-part television drama. Hand-cut paper textures animated in After Effects with a custom score from a Nairobi composer.',
      outcome: 'Used for the full series broadcast and nominated for a regional design award.',
      colours: ['#8E5BD9', '#C4245A'],
      cover: 'Mombasa Road',
      sub: 'Title design',
      featured: false,
      links: [],
    },
    {
      title: 'Lake Victoria Stories',
      role: 'Director',
      client: '',
      projectDate: '',
      category: 'PROJECT',
      description: '',
      outcome: '',
      colours: ['#2E86DE', '#1B1464'],
      cover: 'Lake Victoria',
      sub: 'In development',
      featured: false,
      links: [],
      draft: true,
    },
  ];

  for (const p of projects) {
    if (existing.some((e) => e.title === p.title)) continue;
    const draft = (await call<{ id: string }>(token, 'POST', '/me/projects', { title: p.title }))!.data;
    const cover = await upload(token, await picture(1600, 1000, p.colours[0]!, p.colours[1]!, p.cover, p.sub));
    const frame = await upload(token, await picture(1600, 1000, p.colours[1]!, p.colours[0]!, p.sub));
    await call(token, 'PATCH', `/me/projects/${draft.id}`, {
      role: p.role,
      ...(p.client ? { client: p.client } : {}),
      ...(p.projectDate ? { projectDate: p.projectDate } : {}),
      category: p.category,
      ...(p.description ? { description: p.description } : {}),
      ...(p.outcome ? { outcome: p.outcome } : {}),
      mediaIds: [cover, frame],
      skillIds: ids.slice(0, 3),
      links: p.links,
      visibility: 'PUBLIC',
    });
    if (!('draft' in p)) {
      await call(token, 'POST', `/me/projects/${draft.id}/publish`);
      if (p.featured) await call(token, 'PATCH', `/me/projects/${draft.id}`, { featured: true });
    }
    log(`Project: ${p.title}${'draft' in p ? ' (draft)' : ''}`);
  }
}

async function experienceAndMore(token: string): Promise<void> {
  const have = (await call<unknown[]>(token, 'GET', '/me/experience'))!.data;
  if (have.length === 0) {
    await call(token, 'POST', '/me/experience', {
      title: 'Freelance filmmaker',
      organisation: 'Self-employed',
      location: 'Nairobi',
      startDate: '2022-01-10',
      current: true,
      description: 'Documentary, music video and brand film commissions for East African clients.',
    });
    await call(token, 'POST', '/me/experience', {
      title: 'Video editor and motion designer',
      organisation: 'Pamoja Studios',
      location: 'Nairobi',
      startDate: '2020-02-03',
      endDate: '2021-12-17',
      current: false,
      description: 'Cut promos and broadcast titles for a production house with a team of eight.',
    });
    await call(token, 'POST', '/me/experience', {
      title: 'Production assistant',
      organisation: 'Lakeview Pictures',
      location: 'Kisumu',
      startDate: '2018-06-01',
      endDate: '2020-01-31',
      current: false,
      description: 'Set logistics and footage logging on two feature documentaries.',
    });
    log('Experience added');
  }
  const ach = (await call<unknown[]>(token, 'GET', '/me/achievements'))!.data;
  if (ach.length === 0) {
    await call(token, 'POST', '/me/achievements', {
      type: 'AWARD',
      title: 'Best Short Documentary',
      issuer: 'Nairobi Youth Film Night',
      achievedOn: '2025-05-24',
      description: 'For Kibera Rising.',
    });
    await call(token, 'POST', '/me/achievements', {
      type: 'CERTIFICATE',
      title: 'Certificate in Digital Cinematography',
      issuer: 'Rift Valley College of the Arts',
      achievedOn: '2019-11-15',
    });
    await call(token, 'POST', '/me/achievements', {
      type: 'SELECTION',
      title: 'Selected for the Coast Film Lab',
      issuer: 'Coast Film Lab',
      achievedOn: '2024-08-30',
    });
    log('Achievements added');
  }
  const services = (await call<unknown[]>(token, 'GET', '/me/services'))!.data;
  if (services.length === 0) {
    await call(token, 'POST', '/me/services', {
      title: 'Short film and documentary production',
      description: 'From treatment to final grade, with a small crew.',
      priceType: 'RANGE',
      priceMin: 150000,
      priceMax: 400000,
    });
    await call(token, 'POST', '/me/services', {
      title: 'Logo and title animation',
      description: 'Two concepts and two rounds of changes.',
      priceType: 'FIXED',
      priceMin: 45000,
    });
    await call(token, 'POST', '/me/services', {
      title: 'Video editing (per day)',
      priceType: 'FIXED',
      priceMin: 12000,
    });
    log('Services added');
  }
}

async function people(token: string, myId: string): Promise<void> {
  const demo = {
    nia: await signIn('nia@demo.atarah.test', DEMO_PASSWORD).catch(() => null),
    amani: await signIn('amani@demo.atarah.test', DEMO_PASSWORD).catch(() => null),
    wanjiku: await signIn('wanjiku@demo.atarah.test', DEMO_PASSWORD).catch(() => null),
    kiptoo: await signIn('kiptoo@demo.atarah.test', DEMO_PASSWORD).catch(() => null),
  };
  if (!demo.nia || !demo.amani) return log('Demo members not found: run the demo seed first. People step skipped');

  const mine = NAME.toLowerCase().replace(/[^a-z0-9]+/g, '_').replace(/^_|_$/g, '');
  const connected = (await call<unknown[]>(token, 'GET', '/me/connections'))!.data;
  if (connected.length === 0) {
    // Melvin asks Nia and Amani, who accept; Kiptoo asks Melvin (an incoming request); Melvin asks Wanjiku (pending).
    for (const [key, who] of [
      ['nia', 'nia_wairimu'],
      ['amani', 'amani_otieno'],
    ] as const) {
      const sent = (await call<{ id: string }>(token, 'POST', `/creatives/${who}/connect`))!.data;
      await call(demo[key]!.token, 'POST', `/connections/${sent.id}/accept`, undefined, {}, [404, 409]);
    }
    if (demo.kiptoo) await call(demo.kiptoo.token, 'POST', `/creatives/${mine}/connect`, undefined, {}, [409]);
    await call(token, 'POST', '/creatives/wanjiku_njeri/connect', undefined, {}, [409, 404]);
    log('Connections: 2 connected, 1 incoming request, 1 sent');
  }

  const groups = (await call<Array<{ id: string; slug: string; name: string; joined: boolean }>>(token, 'GET', '/groups'))!.data;
  for (const g of groups.filter((x) => !x.joined).slice(0, 2)) {
    await call(token, 'POST', `/groups/${g.id}/join`, undefined, {}, [409]);
  }

  const mineFeed = (await call<Array<{ author: { id?: string } }>>(token, 'GET', '/community/feed', undefined, { limit: 50 }))!.data;
  if (!mineFeed.some((p) => p.author?.id === myId)) {
    const p1 = (await call<{ id: string }>(token, 'POST', '/posts', {
      type: 'UPDATE',
      body: 'Just wrapped the colour grade on Kibera Rising. Five months of shooting, one very long weekend of grading. Thank you to everyone who lent us a roof, a generator or a cup of chai.',
      audience: 'MEMBERS',
    }))!.data;
    await call(token, 'POST', '/posts', {
      type: 'QUESTION',
      body: 'Anyone have a favourite affordable sound recordist in Nairobi for a two-day shoot in March? Budget is tight but the project is a good one.',
      audience: 'MEMBERS',
    });
    await call(demo.nia!.token, 'PUT', `/posts/${p1.id}/reactions`, undefined, {}, [409]);
    await call(demo.amani!.token, 'PUT', `/posts/${p1.id}/reactions`, undefined, {}, [409]);
    await call(demo.nia!.token, 'POST', `/posts/${p1.id}/comments`, { body: 'Cannot wait to see it. Will you screen it in Nairobi?' });
    log('Community: 2 posts with a reaction and a comment');
  }
  // React to someone else's post as the member.
  const others = (await call<Array<{ id: string; author: { id?: string } }>>(token, 'GET', '/community/feed', undefined, { limit: 5 }))!.data;
  for (const p of others.filter((x) => x.author?.id !== myId).slice(0, 2)) {
    await call(token, 'PUT', `/posts/${p.id}/reactions`, undefined, {}, [409]);
  }
}

async function opportunities(token: string): Promise<void> {
  const mine = (await call<unknown[]>(token, 'GET', '/me/opportunities'))!.data;
  if (mine.length > 0) return log('Opportunities already tracked');
  const all = (await call<Array<{ id: string; title: string }>>(token, 'GET', '/opportunities', undefined, { limit: 50, sort: 'deadline' }))!.data;
  const find = (needle: string) => all.find((o) => o.title.includes(needle));
  const save = async (needle: string) => {
    const o = find(needle);
    if (o) await call(token, 'PUT', `/opportunities/${o.id}/save`);
    return o;
  };
  await save('Emerging Creatives Grant');
  await save('Short Film Development Fund');
  await save('Sound Engineer');
  const motion = find('Junior Motion Designer');
  if (motion) await call(token, 'POST', `/opportunities/${motion.id}/track`, { status: 'IN_PROGRESS' });
  const intern = find('Production Assistant');
  if (intern) await call(token, 'POST', `/opportunities/${intern.id}/track`, { status: 'APPLIED', notes: 'Sent my showreel and CV.' });
  const comp = find('Young Storytellers');
  if (comp) {
    await call(token, 'POST', `/opportunities/${comp.id}/track`, { status: 'APPLIED' });
    await call(token, 'POST', `/opportunities/${comp.id}/track`, { status: 'COMPLETED', outcome: 'NOT_SELECTED' });
  }
  log('Opportunities: 3 saved, 1 in progress, 1 applied, 1 completed');
}

async function main(): Promise<void> {
  const health = await fetch(`${API.replace('/api/v1', '')}/health/ready`).catch(() => null);
  if (!health?.ok) throw new Error(`The API is not ready at ${API}. Start it (and the worker) first.`);

  const { token, id } = await ensureAccount();
  await onboard(token);
  await profile(token);
  await portfolio(token);
  await experienceAndMore(token);
  await people(token, id);
  await opportunities(token);
  const me = (await call<{ completion: { percent: number } }>(token, 'GET', '/me/profile'))!.data;
  log(`Done. Profile completion ${me.completion.percent}%. Sign in as ${EMAIL}.`);
}

main().catch((e) => {
  console.error(e instanceof Error ? e.message : e);
  process.exit(1);
});
