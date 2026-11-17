// Measures the hot endpoints against the volume seed in the scratch database `atarah_perf` (setup-perf-db.mjs and
// load-volume.mjs first) and writes docs/PERFORMANCE.md. Budgets (Master Prompt P1-M12): p95 < 300 ms for reads and
// < 600 ms for writes. The script exits 1 when a budget is missed or a request fails.
//
//   node apps/backend/scripts/perf/run-perf.mjs [--reads=150] [--writes=60] [--only=feed] [--keep-api]
//   (--only measures just the endpoints whose label contains the text, for quick iteration; it still rewrites the report,
//   so do a full run before committing docs/PERFORMANCE.md)
//
// What it does: starts the API (ts-node, transpile-only) on port 3057 against atarah_perf with throttling off
// (ATARAH_ENV=test) and Redis database 14; creates three throw-away members in the LOCAL Supabase Auth (so tokens are real),
// mirrors them into the scratch database with realistic data (connections, notifications, trackings), measures
// each endpoint one request at a time, counts the SQL statements one request issues (pg_stat_statements; more than
// 40 statements for one request is flagged as a likely N+1), captures auto_explain plans for statements slower than
// 80 ms, and deletes the throw-away members again. Local only.
import { execFileSync, spawn } from 'node:child_process';
import { readFileSync, writeFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const backend = join(here, '..', '..');
const root = join(backend, '..', '..');
const require = createRequire(join(backend, 'package.json'));
const pg = require('pg');
const { createClient } = require('@supabase/supabase-js');

const arg = (name, dflt) => {
  const hit = process.argv.find((a) => a.startsWith(`--${name}=`));
  return hit ? Number(hit.split('=')[1]) : dflt;
};
const READS = arg('reads', 150);
const WRITES = arg('writes', 60);
const KEEP = process.argv.includes('--keep-api');
const ONLY =
  process.argv
    .find((a) => a.startsWith('--only='))
    ?.slice(7)
    .toLowerCase() ?? null;
const PORT = 3057;
const API = `http://127.0.0.1:${PORT}`;
const READ_BUDGET = 300;
const WRITE_BUDGET = 600;
const QUERY_FLAG = 40;

const env = Object.fromEntries(
  readFileSync(join(backend, '.env'), 'utf8')
    .split(/\r?\n/)
    .filter((l) => /^[A-Z_]+=/.test(l))
    .map((l) => [
      l.slice(0, l.indexOf('=')),
      l
        .slice(l.indexOf('=') + 1)
        .trim()
        .replace(/^"|"$/g, ''),
    ]),
);
const status = JSON.parse(
  (() => {
    const out = execFileSync('npx', ['supabase', 'status', '-o', 'json'], {
      cwd: root,
      encoding: 'utf8',
      shell: true,
    });
    return out.slice(out.indexOf('{'));
  })(),
);
const perfUrl = 'postgresql://supabase_admin:postgres@127.0.0.1:55322/atarah_perf';
const backendUrl = `postgresql://atarah_backend:${encodeURIComponent(env.ATARAH_BACKEND_DB_PASSWORD)}@127.0.0.1:55322/atarah_perf`;

// A connection that reconnects: Docker Desktop on Windows now and then resets a long-lived localhost TCP connection, and
// one reset must not end a ten-minute measurement. Each query is retried once on a fresh connection.
let client = null;
async function connect() {
  client = new pg.Client({ connectionString: perfUrl });
  client.on('error', () => {
    client = null;
  });
  await client.connect();
}
await connect();
const db = {
  async query(...args) {
    for (let attempt = 0; ; attempt += 1) {
      try {
        if (!client) await connect();
        return await client.query(...args);
      } catch (e) {
        if (
          attempt >= 2 ||
          !/ECONNRESET|terminated|ECONNREFUSED|EPIPE/i.test(
            String(e?.message ?? e) + String(e?.code ?? ''),
          )
        )
          throw e;
        client = null;
        await new Promise((r) => setTimeout(r, 1000));
      }
    }
  },
  async end() {
    await client?.end().catch(() => undefined);
  },
};
// Leftovers of an interrupted earlier run (members this script created in the scratch database).
await db.query("DELETE FROM creative_profiles WHERE handle LIKE 'perf_run_%'");
await db.query("DELETE FROM users WHERE email LIKE '%@perf-run.atarah.test'");
await db.query("DELETE FROM auth.users WHERE email LIKE '%@perf-run.atarah.test'");
const admin = createClient(status.API_URL, status.SECRET_KEY ?? status.SERVICE_ROLE_KEY, {
  auth: { persistSession: false, autoRefreshToken: false },
});
const publicKey = status.PUBLISHABLE_KEY ?? status.ANON_KEY;

// ---- personas ---------------------------------------------------------------------------------------------------
const created = [];
async function persona(label, heavy) {
  const email = `perf.${label}.${Date.now().toString(36)}@perf-run.atarah.test`;
  const password = 'Perf-run-pass-1';
  const c = await admin.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
    user_metadata: { full_name: `Perf ${label}` },
  });
  if (c.error) throw c.error;
  created.push(c.data.user.id);
  const anon = createClient(status.API_URL, publicKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const s = await anon.auth.signInWithPassword({ email, password });
  if (s.error) throw s.error;
  const token = s.data.session.access_token;
  const claims = JSON.parse(Buffer.from(token.split('.')[1], 'base64url').toString());
  const id = c.data.user.id;
  await db.query('SET session_replication_role = replica');
  await db.query(
    "INSERT INTO auth.users (id, aud, role, email, email_confirmed_at, created_at, updated_at) VALUES ($1,'authenticated','authenticated',$2,now(),now(),now()) ON CONFLICT DO NOTHING",
    [id, email],
  );
  await db.query(
    'INSERT INTO auth.sessions (id, user_id, created_at, updated_at) VALUES ($1,$2,now(),now()) ON CONFLICT DO NOTHING',
    [claims.session_id, id],
  );
  await db.query(
    `INSERT INTO users (id, email, "emailVerifiedAt", "fullName", status, "isDemo", "createdAt", "updatedAt") VALUES ($1,$2,now(),$3,'ACTIVE',true,now(),now()) ON CONFLICT DO NOTHING`,
    [id, email, `Perf ${label}`],
  );
  const [d] = (await db.query('SELECT id FROM disciplines ORDER BY "sortOrder" LIMIT 1')).rows;
  const [cty] = (
    await db.query('SELECT id, "countryId" FROM counties ORDER BY "sortOrder" LIMIT 1')
  ).rows;
  const profile = (
    await db.query(
      `INSERT INTO creative_profiles (id, "userId", handle, "displayName", headline, bio, "primaryDisciplineId", "countryId", "countyId", "onboardingStep", "onboardingCompletedAt", "completionPercent", "createdAt", "updatedAt")
    VALUES (gen_random_uuid(), $1, $2, $3, 'Perf headline', 'Perf bio', $4, $5, $6, 'DONE', now(), 70, now(), now()) RETURNING id`,
      [id, `perf_run_${label}`, `Perf ${label}`, d.id, cty.countryId, cty.id],
    )
  ).rows[0].id;
  await db.query(
    'INSERT INTO creative_disciplines ("profileId","disciplineId","isPrimary") VALUES ($1,$2,true)',
    [profile, d.id],
  );
  await db.query(
    `INSERT INTO creative_skills ("profileId","skillId",level,source) SELECT $1, id, 'INTERMEDIATE', 'SELF_DECLARED' FROM skills ORDER BY "sortOrder" LIMIT 4 ON CONFLICT DO NOTHING`,
    [profile],
  );
  const links = heavy ? 150 : 15;
  await db.query(
    `INSERT INTO connections (id, "requesterId", "addresseeId", status, "createdAt", "updatedAt")
    SELECT gen_random_uuid(), $1, u.id, 'ACCEPTED', now(), now() FROM users u WHERE u.email LIKE 'perf.%@perf.atarah.test' ORDER BY u.email LIMIT $2`,
    [id, links],
  );
  await db.query(
    `INSERT INTO group_memberships (id, "groupId", "userId", role, "createdAt", "updatedAt") SELECT gen_random_uuid(), g.id, $1, 'MEMBER', now(), now() FROM groups g WHERE g.slug LIKE 'perf-group-%' ORDER BY g.slug LIMIT 4 ON CONFLICT DO NOTHING`,
    [id],
  );
  await db.query(
    `INSERT INTO notifications (id, "userId", category, title, body, "deepLink", "readAt", "createdAt", "updatedAt")
    SELECT gen_random_uuid(), $1, 'COMMUNITY', 'Perf notification ' || k, 'Body', '/home', CASE WHEN k % 4 = 0 THEN NULL ELSE now() END, now() - k * interval '5 minute', now()
    FROM generate_series(1, $2::int) k`,
    [id, heavy ? 5000 : 200],
  );
  await db.query(
    `INSERT INTO opportunity_trackings (id, "userId", "opportunityId", status, "savedAt", "createdAt", "updatedAt")
    SELECT gen_random_uuid(), $1, o.id, 'SAVED', now(), now(), now() FROM opportunities o WHERE o.slug LIKE 'perf-opp-%' AND o.status = 'PUBLISHED' ORDER BY o.slug LIMIT $2 ON CONFLICT DO NOTHING`,
    [id, heavy ? 300 : 20],
  );
  await db.query('SET session_replication_role = DEFAULT');
  return { id, token, label };
}

// ---- the API ----------------------------------------------------------------------------------------------------
let api = null;
async function startApi() {
  const apiEnv = {
    ...process.env,
    ...env,
    ATARAH_ENV: 'test',
    ATARAH_PORT: String(PORT),
    ATARAH_PUBLIC_URL: API,
    ATARAH_DATABASE_URL: backendUrl,
    ATARAH_DIRECT_URL: perfUrl,
    ATARAH_REDIS_URL: 'redis://localhost:56379/14',
    ATARAH_SUPABASE_URL: status.API_URL,
    ATARAH_SUPABASE_SECRET_KEY: status.SECRET_KEY ?? status.SERVICE_ROLE_KEY,
  };
  api = spawn('node', ['node_modules/ts-node/dist/bin.js', '--transpile-only', 'src/main.ts'], {
    cwd: backend,
    env: apiEnv,
    stdio: ['ignore', 'pipe', 'pipe'],
  });
  let log = '';
  api.stdout.on('data', (d) => (log += d));
  api.stderr.on('data', (d) => (log += d));
  for (let i = 0; i < 120; i += 1) {
    await new Promise((r) => setTimeout(r, 1500));
    try {
      const r = await fetch(`${API}/health/ready`);
      if (r.ok) return;
    } catch {
      /* not yet */
    }
    if (api.exitCode !== null) throw new Error(`API exited early:\n${log.slice(-1500)}`);
  }
  throw new Error(`API did not become ready:\n${log.slice(-1500)}`);
}

const call = async (token, method, path, body) => {
  const t = process.hrtime.bigint();
  const res = await fetch(`${API}/api/v1${path}`, {
    method,
    headers: {
      Authorization: `Bearer ${token}`,
      ...(body ? { 'Content-Type': 'application/json' } : {}),
    },
    ...(body ? { body: JSON.stringify(body) } : {}),
  });
  const text = await res.text();
  return {
    status: res.status,
    ms: Number(process.hrtime.bigint() - t) / 1e6,
    json: text ? JSON.parse(text) : null,
  };
};
const pct = (a, p) => {
  const s = [...a].sort((x, y) => x - y);
  return s[Math.min(s.length - 1, Math.floor((p / 100) * s.length))];
};
const stmtCount = async () =>
  Number(
    (
      await db.query(
        `SELECT coalesce(sum(calls),0) n FROM extensions.pg_stat_statements s JOIN pg_roles r ON r.oid = s.userid WHERE r.rolname = 'atarah_backend'`,
      )
    ).rows[0].n,
  );

try {
  console.log(
    'Creating throw-away members in the local Supabase Auth and mirroring them into atarah_perf',
  );
  const heavy = await persona('heavy', true);
  const light = await persona('light', false);
  await db.query(
    `ALTER ROLE atarah_backend IN DATABASE atarah_perf SET auto_explain.log_min_duration = '80ms'`,
  );
  await db.query(
    `ALTER ROLE atarah_backend IN DATABASE atarah_perf SET auto_explain.log_analyze = on`,
  );
  await db.query(
    `ALTER ROLE atarah_backend IN DATABASE atarah_perf SET auto_explain.log_buffers = on`,
  );
  await db.query(
    `ALTER ROLE atarah_backend IN DATABASE atarah_perf SET auto_explain.log_format = 'text'`,
  );
  console.log('Starting the API against atarah_perf (this takes a minute)...');
  await startApi();

  const oppIds = (
    await db.query(
      `SELECT id FROM opportunities WHERE slug LIKE 'perf-opp-%' AND status = 'PUBLISHED' ORDER BY slug LIMIT 400`,
    )
  ).rows.map((r) => r.id);
  const postIds = (
    await db.query(
      `SELECT id FROM posts WHERE body LIKE 'Perf post%' AND audience IN ('MEMBERS','PUBLIC') ORDER BY "createdAt" DESC LIMIT 500`,
    )
  ).rows.map((r) => r.id);
  const pick = (a, i) => a[i % a.length];
  const words = ['animation', 'music', 'film', 'grant', 'portfolio', 'design', 'photography'];

  // A feed cursor needs the previous page; the harness walks pages like the app does.
  let feedCursor = null;
  const reads = [
    ['GET /home', (i) => ['GET', '/home']],
    ['GET /community/feed (first page)', () => ['GET', '/community/feed?limit=20']],
    [
      'GET /community/feed (next page)',
      async (i, t) => {
        if (!feedCursor || i % 5 === 0) {
          const r = await call(t, 'GET', '/community/feed?limit=20');
          feedCursor = r.json?.meta?.nextCursor ?? null;
        }
        const r = await call(
          t,
          'GET',
          `/community/feed?limit=20${feedCursor ? `&cursor=${encodeURIComponent(feedCursor)}` : ''}`,
        );
        feedCursor = r.json?.meta?.nextCursor ?? null;
        return r;
      },
    ],
    ['GET /search (all kinds)', (i) => ['GET', `/search?q=${pick(words, i)}`]],
    // Informational: "perf" is in every seeded post body and member name, so this matches every row (like searching a
    // word that is in everything). Reported, not held to the budget.
    ['GET /search (worst case: a word in every post)', () => ['GET', '/search?q=perf']],
    [
      'GET /search (opportunities)',
      (i) => ['GET', `/search?type=opportunities&q=${pick(words, i)}`],
    ],
    ['GET /creatives (people)', (i) => ['GET', `/creatives?q=${pick(words, i)}&limit=20`]],
    ['GET /opportunities/home', () => ['GET', '/opportunities/home']],
    [
      'GET /opportunities (list, deadline)',
      (i) => ['GET', `/opportunities?limit=20&page=${1 + (i % 20)}`],
    ],
    [
      'GET /opportunities (filtered, relevance)',
      (i) => ['GET', `/opportunities?type=GRANT&sort=relevance&deadline=30d&page=${1 + (i % 3)}`],
    ],
    ['GET /opportunities/{id}', (i) => ['GET', `/opportunities/${pick(oppIds, i)}`]],
    [
      'GET /me/opportunities',
      (i) => ['GET', `/me/opportunities?tab=${pick(['all', 'saved', 'closing'], i)}`],
    ],
    ['GET /learning (hub)', () => ['GET', '/learning']],
    ['GET /me/learning', () => ['GET', '/me/learning?tab=active']],
    ['GET /notifications', () => ['GET', '/notifications']],
    ['GET /notifications/unread-count', () => ['GET', '/notifications/unread-count']],
    ['GET /me/profile', () => ['GET', '/me/profile']],
    ['GET /articles', (i) => ['GET', `/articles?page=${1 + (i % 10)}`]],
  ];
  let n = 0;
  const writes = [
    [
      'POST /posts',
      (i) => [
        'POST',
        '/posts',
        { type: 'UPDATE', body: `Perf write ${Date.now()} ${i}`, audience: 'MEMBERS' },
      ],
    ],
    [
      'POST /posts/{id}/comments',
      (i) => ['POST', `/posts/${pick(postIds, i)}/comments`, { body: `Perf reply ${i}` }],
    ],
    ['PUT /posts/{id}/reactions', (i) => ['PUT', `/posts/${pick(postIds, 200 + i)}/reactions`]],
    [
      'PUT /opportunities/{id}/save',
      (i) => ['PUT', `/opportunities/${pick(oppIds, 399 - i)}/save`],
    ],
    [
      'POST /opportunities/{id}/track',
      (i) => ['POST', `/opportunities/${pick(oppIds, 150 + i)}/track`, { status: 'IN_PROGRESS' }],
    ],
  ];

  const results = [];
  const slowAll = [];
  async function measure(kind, [label, make], count, token) {
    // Warm up, then one counted request, then the timed series.
    const one = async (i) => {
      const spec = await make(i, token);
      if (spec && 'ms' in spec) return spec;
      const [m, p, b] = spec;
      return call(token, m, p, b);
    };
    const first = await one(0);
    if (first.status === 404 && /^GET \/(learning|notifications|me\/learning)/.test(label)) {
      results.push({ kind, label, absent: true });
      console.log(`  ${label.padEnd(44)} not present in this build (404)`);
      return;
    }
    for (let i = 1; i <= 8; i += 1) await one(i);
    await db.query('SELECT extensions.pg_stat_statements_reset()');
    const before = await stmtCount();
    const probe = await one(9);
    if (process.argv.includes('--statements')) {
      const st = await db.query(
        `SELECT calls, round(mean_exec_time::numeric,1) AS ms, left(query, 150) AS q FROM extensions.pg_stat_statements s JOIN pg_roles r ON r.oid = s.userid WHERE r.rolname = 'atarah_backend' AND query NOT ILIKE '%pg_stat_statements%' ORDER BY calls DESC, mean_exec_time DESC LIMIT 30`,
      );
      console.log(
        st.rows
          .map((r) => `    ${String(r.calls).padStart(3)}x ${String(r.ms).padStart(7)} ms  ${r.q}`)
          .join('\n'),
      );
    }
    const statements = (await stmtCount()) - before - 0;
    const ms = [];
    let failures = 0;
    let bad = null;
    for (let i = 10; i < 10 + count; i += 1) {
      const r = await one(i);
      if (r.status >= 500 || r.status === 401 || r.status === 403) {
        failures += 1;
        bad = `${r.status} ${JSON.stringify(r.json)?.slice(0, 160)}`;
      } else ms.push(r.ms);
    }
    const row = {
      kind,
      label,
      p50: pct(ms, 50),
      p95: pct(ms, 95),
      p99: pct(ms, 99),
      max: Math.max(...ms),
      n: ms.length,
      failures,
      statements,
      bad,
      probeStatus: probe.status,
    };
    results.push(row);
    const top = (
      await db.query(
        `SELECT calls, round(mean_exec_time::numeric, 2) AS mean_ms, round(max_exec_time::numeric, 1) AS max_ms, left(query, 400) AS query FROM extensions.pg_stat_statements s JOIN pg_roles r ON r.oid = s.userid WHERE r.rolname = 'atarah_backend' AND query NOT LIKE '%pg_stat_statements%' ORDER BY mean_exec_time DESC LIMIT 2`,
      )
    ).rows;
    for (const t of top) slowAll.push({ label, ...t });
    const budget = kind === 'read' ? READ_BUDGET : WRITE_BUDGET;
    console.log(
      `  ${label.padEnd(44)} p50 ${row.p50.toFixed(0).padStart(4)}  p95 ${row.p95.toFixed(0).padStart(4)}  p99 ${row.p99.toFixed(0).padStart(4)} ms  ${String(statements).padStart(3)} stmts ${row.p95 > budget ? ' OVER BUDGET' : ''}${failures ? ` FAILURES ${failures}: ${bad}` : ''}`,
    );
  }
  console.log(`\nReads (${READS} requests each, budget p95 < ${READ_BUDGET} ms)`);
  for (const r of reads)
    if (!ONLY || r[0].toLowerCase().includes(ONLY)) await measure('read', r, READS, heavy.token);
  console.log(`\nWrites (${WRITES} requests each, budget p95 < ${WRITE_BUDGET} ms)`);
  for (const w of writes)
    if (!ONLY || w[0].toLowerCase().includes(ONLY)) await measure('write', w, WRITES, light.token);

  // Slowest statements and the plans auto_explain captured.
  const slow = slowAll.sort((x, y) => Number(y.mean_ms) - Number(x.mean_ms)).slice(0, 14);
  let plans = '';
  try {
    const logs = execFileSync(
      'docker',
      ['logs', '--since', '40m', process.env.ATARAH_DB_CONTAINER ?? 'supabase_db_atarah'],
      { encoding: 'utf8', maxBuffer: 1 << 28, stdio: ['ignore', 'pipe', 'pipe'] },
    );
    const blocks = logs
      .split(/\n(?=\d{4}-\d\d-\d\d )/)
      .filter((b) => /auto_explain/.test(b) && /atarah_perf/.test(b));
    const seen = new Set();
    for (const b of blocks) {
      const key = (b.match(/Query Text: ([^\n]{0,80})/)?.[1] ?? b.slice(0, 80)).replace(
        /\d+/g,
        '#',
      );
      if (seen.has(key) || seen.size >= 8) continue;
      seen.add(key);
      plans += b.replace(/^.*?auto_explain\]?\s*/s, '').slice(0, 2600) + '\n\n';
    }
  } catch (e) {
    plans = `(could not read the database log: ${e.message})`;
  }

  const over = results.filter(
    (r) =>
      !r.absent &&
      !r.label.includes('worst case') &&
      (r.p95 > (r.kind === 'read' ? READ_BUDGET : WRITE_BUDGET) || r.failures > 0),
  );
  const nplus = results.filter((r) => !r.absent && r.statements > QUERY_FLAG);
  const totals = (
    await db.query(
      `SELECT (SELECT count(*) FROM users) users, (SELECT count(*) FROM posts) posts, (SELECT count(*) FROM comments) comments, (SELECT count(*) FROM opportunities) opportunities, (SELECT count(*) FROM notifications) notifications`,
    )
  ).rows[0];
  const fmt = (v) => (v === undefined ? '' : v.toFixed(0));
  const table = results
    .map((r) =>
      r.absent
        ? `| ${r.label} | ${r.kind} | not in this build | | | | |`
        : `| ${r.label} | ${r.kind} | ${fmt(r.p50)} | ${fmt(r.p95)} | ${fmt(r.p99)} | ${r.statements} | ${r.label.includes('worst case') ? 'info only' : r.p95 > (r.kind === 'read' ? READ_BUDGET : WRITE_BUDGET) || r.failures ? 'OVER' : 'ok'} |`,
    )
    .join('\n');
  const md = `# Atarah: performance on the volume seed (P1-M12)

Generated by \`apps/backend/scripts/perf/run-perf.mjs\` on ${new Date().toISOString().slice(0, 10)}. Reproduce: \`node apps/backend/scripts/perf/setup-perf-db.mjs && node apps/backend/scripts/perf/load-volume.mjs && node apps/backend/scripts/perf/run-perf.mjs\`.

**Environment.** One developer machine (Windows 11, Docker Desktop): the API under ts-node, local Supabase Postgres 17 with the default small settings (shared_buffers 128 MB, work_mem 4 MB), Redis, one request at a time over loopback, throttling off. These are local numbers; they show what the queries and plans cost, not production latency.

**Data** (scratch database \`atarah_perf\`): ${totals.users} members, ${totals.posts} posts, ${totals.comments} comments, ${totals.opportunities} opportunities, ${totals.notifications} notifications (plus profiles, projects, connections, reactions, trackings, learning items where the schema has them). The "heavy" member has 150 connections, 5,000 notifications and 300 saved opportunities.

**Budgets.** p95 under ${READ_BUDGET} ms for reads and under ${WRITE_BUDGET} ms for writes. Statements = SQL statements one request issues (a count above ${QUERY_FLAG} would be flagged as a likely N+1).

| Endpoint | Kind | p50 ms | p95 ms | p99 ms | SQL statements | Budget |
| --- | --- | ---: | ---: | ---: | ---: | --- |
${table}

**Result:** ${over.length === 0 ? 'every measured endpoint is within budget' : `${over.length} endpoint(s) over budget: ${over.map((r) => r.label).join('; ')}`}. ${nplus.length === 0 ? 'No endpoint issues more than 40 statements.' : `Likely N+1: ${nplus.map((r) => `${r.label} (${r.statements})`).join('; ')}.`}

## Slowest statements (pg_stat_statements, after the run)

| Mean ms | Max ms | Calls | Endpoint | Statement |
| ---: | ---: | ---: | ---: | --- |
${slow.map((s) => `| ${s.mean_ms} | ${s.max_ms} | ${s.calls} | ${s.label} | \`${s.query.replace(/\s+/g, ' ').replace(/\|/g, '\\|').slice(0, 220)}\` |`).join('\n')}

## EXPLAIN ANALYZE of statements slower than 80 ms (auto_explain)

${plans.trim() ? '```\n' + plans.trim() + '\n```' : 'No statement ran longer than 80 ms during this run.'}
`;
  if (!ONLY) {
    writeFileSync(join(root, 'docs', 'PERFORMANCE.md'), md);
    console.log('\nWrote docs/PERFORMANCE.md');
  } else console.log('\n(--only: report not written)');
  if (over.length || nplus.length) {
    process.exitCode = 1;
    console.log(`FAILED: ${over.length} over budget, ${nplus.length} possible N+1`);
  } else console.log('PASSED: all budgets met');
} finally {
  if (api && !KEEP) api.kill();
  for (const id of created) await admin.auth.admin.deleteUser(id).catch(() => undefined);
  await db
    .query(`ALTER ROLE atarah_backend IN DATABASE atarah_perf RESET ALL`)
    .catch(() => undefined);
  await db.end();
}
