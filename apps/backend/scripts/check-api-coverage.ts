/**
 * P1-M12 audit: compares the OpenAPI document with the Phase 1 endpoint inventory of Master Prompt Appendix A.2 and
 * fails on gaps. Re-run it at the end of every milestone:
 *
 *   pnpm gen:api                                   # regenerate packages/api-contracts/openapi.json first
 *   cd apps/backend && npx ts-node --transpile-only scripts/check-api-coverage.ts          # report
 *   cd apps/backend && npx ts-node --transpile-only scripts/check-api-coverage.ts --final  # the gate: pending is a failure too
 *
 * Every Appendix entry ends in one of four states, never hidden:
 *   PRESENT    the method and path are in OpenAPI exactly as the Appendix names them
 *   DEVIATION  built under a different but recorded path (the actual path must exist: the reason is printed)
 *   PENDING    owned by a milestone that is not finished yet (`--pending=P1-M10,P1-M11`; default: none pending)
 *   MISSING    not in OpenAPI and not explained: the script exits 1
 * It also checks that the generated Dart client knows every OpenAPI operation, and prints how many operations
 * document error responses and examples (quality, reported but not a failure).
 */
import { existsSync, readFileSync, readdirSync, statSync } from 'node:fs';
import { join, resolve } from 'node:path';

type Method = 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE';
interface Item {
  /** Appendix family, for the report. */
  family: string;
  method: Method | '*';
  /** Path under /api/v1. `{}` matches any parameter name; a trailing `/*` matches any path below. */
  path: string;
  milestone: string;
  /** Built under a different path: `actual` is "METHOD /path" that must exist, `why` is the recorded reason. */
  deviation?: { actual: string; why: string };
  /** Deliberately not in OpenAPI (internal): `source` is a file that must contain `needle`. */
  hidden?: { source: string; needle: string; why: string };
}

const I = (
  family: string,
  method: Item['method'],
  path: string,
  milestone: string,
  extra: Partial<Item> = {},
): Item => ({
  family,
  method,
  path,
  milestone,
  ...extra,
});

export const INVENTORY: Item[] = [
  // Auth
  I('Auth', 'GET', '/auth/sessions', 'P1-M6'),
  I('Auth', 'DELETE', '/auth/sessions/{}', 'P1-M6'),
  I('Auth', 'POST', '/auth/hooks/send-sms', 'P1-M6', {
    hidden: {
      source: 'src/identity/identity.controllers.ts',
      needle: 'send-sms',
      why: 'Supabase hook: signature-verified, kept out of the public contract',
    },
  }),
  I('Auth', 'GET', '/me/security', 'P1-M11'),
  // Me
  I('Me', 'GET', '/users/me', 'P1-M6'),
  I('Me', 'PATCH', '/me/account', 'P1-M11'),
  I('Me', 'GET', '/me/preferences', 'P1-M7'),
  I('Me', 'PATCH', '/me/preferences', 'P1-M7'),
  I('Me', 'GET', '/me/privacy', 'P1-M11'),
  I('Me', 'PATCH', '/me/privacy', 'P1-M11'),
  I('Me', 'GET', '/me/notification-preferences', 'P1-M11', {
    deviation: {
      actual: 'GET /notifications/preferences',
      why: 'Built in P0-M9 under /notifications; PUT replaces PATCH',
    },
  }),
  I('Me', 'PATCH', '/me/notification-preferences', 'P1-M11', {
    deviation: {
      actual: 'PUT /notifications/preferences',
      why: 'Built in P0-M9 under /notifications; PUT replaces PATCH',
    },
  }),
  I('Me', 'POST', '/me/export', 'P1-M11'),
  I('Me', 'POST', '/me/delete', 'P1-M11'),
  I('Me', 'POST', '/me/restore', 'P1-M11'),
  // Taxonomy and locations
  I('Taxonomy', 'GET', '/taxonomy/*', 'P1-M2'),
  I('Taxonomy', 'GET', '/locations/*', 'P1-M2'),
  I('Taxonomy', 'POST', '/taxonomy/specialisations/suggestions', 'P1-M2'),
  // Onboarding and profile
  I('Profile', 'PATCH', '/me/onboarding', 'P1-M2'),
  I('Profile', 'POST', '/me/onboarding/complete', 'P1-M2'),
  I('Profile', 'GET', '/handles/{}/availability', 'P1-M2'),
  I('Profile', 'GET', '/me/profile', 'P1-M3'),
  I('Profile', 'PATCH', '/me/profile', 'P1-M3'),
  I('Profile', 'GET', '/me/passport', 'P1-M3'),
  I('Profile', 'PATCH', '/me/passport/visibility', 'P1-M3'),
  I('Profile', 'GET', '/me/growth', 'P1-M3'),
  I('Profile', 'GET', '/creatives', 'P1-M5'),
  I('Profile', 'GET', '/creatives/{}', 'P1-M3'),
  // Portfolio and identity
  I('Portfolio', 'GET', '/me/projects', 'P1-M4'),
  I('Portfolio', 'POST', '/me/projects', 'P1-M4'),
  I('Portfolio', 'PATCH', '/me/projects/{}', 'P1-M4'),
  I('Portfolio', 'DELETE', '/me/projects/{}', 'P1-M4'),
  I('Portfolio', 'POST', '/me/projects/{}/publish', 'P1-M4'),
  I('Portfolio', 'POST', '/me/projects/{}/media', 'P1-M4', {
    deviation: {
      actual: 'PATCH /me/projects/{}',
      why: 'Project pictures are set with `mediaIds` on the project; uploads use /media',
    },
  }),
  I('Portfolio', 'GET', '/me/skills', 'P1-M4'),
  I('Portfolio', 'GET', '/me/experiences', 'P1-M4', {
    deviation: { actual: 'GET /me/experience', why: 'Singular resource name chosen in P1-M4' },
  }),
  I('Portfolio', 'GET', '/me/achievements', 'P1-M4'),
  I('Portfolio', 'GET', '/me/services', 'P1-M4'),
  I('Portfolio', 'GET', '/creatives/{}/projects', 'P1-M4'),
  // Connections
  I('Connections', 'POST', '/connections', 'P1-M3', {
    deviation: {
      actual: 'POST /creatives/{}/connect',
      why: 'A request is made to a person by handle',
    },
  }),
  I('Connections', 'POST', '/connections/{}/accept', 'P1-M3'),
  I('Connections', 'POST', '/connections/{}/decline', 'P1-M3'),
  I('Connections', 'DELETE', '/connections/{}', 'P1-M3'),
  I('Connections', 'GET', '/me/connections', 'P1-M3'),
  I('Connections', 'GET', '/me/connection-requests', 'P1-M3', {
    deviation: {
      actual: 'GET /me/connections',
      why: 'Incoming and sent requests are `?listState=PENDING_RECEIVED|PENDING_SENT` on the same list',
    },
  }),
  I('Connections', 'GET', '/creatives/suggestions', 'P1-M8'),
  // Home, search, articles
  I('Home', 'GET', '/home', 'P1-M5'),
  I('Home', 'GET', '/search', 'P1-M5'),
  I('Home', 'GET', '/me/recent-searches', 'P1-M5'),
  I('Home', 'DELETE', '/me/recent-searches', 'P1-M5'),
  I('Home', 'GET', '/articles', 'P1-M5'),
  I('Home', 'GET', '/articles/{}', 'P1-M5'),
  // Community
  I('Community', 'GET', '/community/feed', 'P1-M8'),
  I('Community', 'POST', '/posts', 'P1-M8'),
  I('Community', 'GET', '/posts/{}', 'P1-M8'),
  I('Community', 'PATCH', '/posts/{}', 'P1-M8'),
  I('Community', 'DELETE', '/posts/{}', 'P1-M8'),
  I('Community', 'GET', '/posts/{}/comments', 'P1-M8'),
  I('Community', 'POST', '/posts/{}/comments', 'P1-M8'),
  I('Community', 'PUT', '/posts/{}/reactions', 'P1-M8'),
  I('Community', 'GET', '/groups', 'P1-M8'),
  I('Community', 'POST', '/groups/{}/join', 'P1-M8'),
  I('Community', 'POST', '/groups/{}/leave', 'P1-M8'),
  I('Community', 'GET', '/groups/{}/posts', 'P1-M8'),
  I('Community', 'POST', '/blocks', 'P1-M8'),
  I('Community', 'POST', '/mutes', 'P1-M8'),
  I('Community', 'POST', '/reports', 'P1-M8'),
  I('Community', 'GET', '/me/reports', 'P1-M8'),
  // Opportunities
  I('Opportunities', 'GET', '/opportunities', 'P1-M9'),
  I('Opportunities', 'GET', '/opportunities/{}', 'P1-M9'),
  I('Opportunities', 'POST', '/opportunities/{}/track', 'P1-M9'),
  I('Opportunities', 'GET', '/me/opportunities', 'P1-M9'),
  I('Opportunities', 'GET', '/me/applications', 'P1-M11'),
  I('Opportunities', 'GET', '/provider/opportunities', 'P1-M9'),
  // Learning
  I('Learning', 'GET', '/learning', 'P1-M10'),
  I('Learning', 'GET', '/learning/categories/{}', 'P1-M10'),
  I('Learning', 'GET', '/learning/{}', 'P1-M10'),
  I('Learning', 'POST', '/learning/{}/enrol', 'P1-M10'),
  I('Learning', 'PUT', '/learning/lessons/{}/progress', 'P1-M10'),
  I('Learning', 'PUT', '/learning/{}/progress', 'P1-M10', {
    deviation: {
      actual: 'PUT /learning/lessons/{}/progress',
      why: 'Course progress is recorded per lesson; a course is begun with POST /learning/{}/start and finished with POST /learning/{}/complete (built in P1-M10; owner to confirm)',
    },
  }),
  I('Learning', 'GET', '/me/learning', 'P1-M10'),
  I('Learning', 'GET', '/me/learning/stats', 'P1-M10'),
  I('Learning', 'GET', '/learning/lessons/{}/playback', 'P1-M10', {
    deviation: {
      actual: 'GET /learning/lessons/{}/video',
      why: 'Playback is GET /learning/lessons/{}/video (built in P1-M10; owner to confirm)',
    },
  }),
  // Saved and activity
  I('Saved', 'GET', '/me/saved', 'P1-M11'),
  I('Saved', 'POST', '/me/saved', 'P1-M11', {
    deviation: {
      actual: 'PUT /me/saved/{}/{}',
      why: 'Saving is an idempotent PUT of (type, id); each module also has its own save route',
    },
  }),
  I('Saved', 'DELETE', '/me/saved/{}', 'P1-M11', {
    deviation: {
      actual: 'DELETE /me/saved/{}/{}',
      why: 'Removal is by (type, id), not by a saved-row id',
    },
  }),
  I('Saved', 'GET', '/me/activity', 'P1-M11'),
  // Notifications
  I('Notifications', 'GET', '/notifications', 'P1-M11'),
  I('Notifications', 'GET', '/notifications/unread-count', 'P1-M11'),
  I('Notifications', 'POST', '/notifications/{}/read', 'P1-M11'),
  I('Notifications', 'POST', '/notifications/read-all', 'P1-M11'),
  I('Notifications', 'POST', '/devices', 'P0-M9'),
  // Help and legal
  I('Help', 'GET', '/help/articles', 'P1-M11', {
    deviation: {
      actual: 'GET /help',
      why: 'The list of help articles is GET /help, one article is GET /help/articles/{slug} (built in P1-M11; owner to confirm)',
    },
  }),
  I('Help', 'GET', '/help/faq', 'P1-M11'),
  I('Help', 'GET', '/legal/{}', 'P1-M5'),
  // Media
  I('Media', 'POST', '/media/uploads', 'P0-M9'),
  I('Media', 'POST', '/media/uploads/{}/complete', 'P0-M9', {
    deviation: { actual: 'POST /media/{}/complete', why: 'The upload id is the media id' },
  }),
  I('Media', 'GET', '/media/{}/url', 'P0-M9', {
    deviation: {
      actual: 'GET /media/{}',
      why: 'The media view carries the signed `url` and `variants`',
    },
  }),
  // Admin
  I('Admin', 'GET', '/admin/users', 'P0-M8'),
  I('Admin', 'GET', '/admin/roles', 'P1-M12'),
  I('Admin', 'GET', '/admin/taxonomy/*', 'P1-M2'),
  I('Admin', 'GET', '/admin/articles', 'P1-M5'),
  I('Admin', 'GET', '/admin/home-curation', 'P1-M5', {
    deviation: { actual: 'GET /admin/home', why: 'Named /admin/home in P1-M5' },
  }),
  I('Admin', 'GET', '/admin/reports', 'P1-M8'),
  I('Admin', 'GET', '/admin/moderation-cases', 'P1-M8'),
  I('Admin', 'GET', '/admin/groups', 'P1-M8'),
  I('Admin', 'GET', '/admin/announcements', 'P1-M8'),
  I('Admin', 'GET', '/admin/opportunities', 'P1-M9'),
  I('Admin', 'GET', '/admin/opportunity-providers', 'P1-M9'),
  I('Admin', 'GET', '/admin/learning/*', 'P1-M10'),
  I('Admin', 'GET', '/admin/courses/*', 'P1-M10', {
    deviation: {
      actual: 'GET /admin/learning/contents/{}',
      why: 'Courses are managed through /admin/learning/contents; /admin/courses/{id}/lessons holds only lesson changes (built in P1-M10; owner to confirm)',
    },
  }),
  I('Admin', 'GET', '/admin/notifications/broadcasts', 'P1-M11'),
  I('Admin', 'GET', '/admin/help-articles', 'P1-M11'),
  I('Admin', 'GET', '/admin/faq', 'P1-M11'),
  I('Admin', 'GET', '/admin/legal-documents', 'P1-M11'),
  I('Admin', 'GET', '/admin/privacy-requests', 'P1-M11'),
  I('Admin', 'GET', '/admin/analytics/*', 'P1-M12'),
  I('Admin', 'GET', '/admin/jobs', 'P1-M12'),
  I('Admin', 'GET', '/admin/audit-logs', 'P0-M8'),
  I('Admin', 'GET', '/admin/settings', 'P1-M12'),
  I('Admin', 'GET', '/admin/feature-flags', 'P1-M12'),
  I('Admin', 'GET', '/admin/dashboard', 'P1-M12'),
  // Ops
  I('Ops', 'GET', '/health/live', 'P0-M3', {
    hidden: {
      source: 'src/health/health.controller.ts',
      needle: "'live'",
      why: 'Outside /api/v1 and the public contract',
    },
  }),
  I('Ops', 'GET', '/health/ready', 'P0-M3', {
    hidden: {
      source: 'src/health/health.controller.ts',
      needle: "'ready'",
      why: 'Outside /api/v1 and the public contract',
    },
  }),
  I('Ops', 'GET', '/metrics', 'P0-M3', {
    hidden: {
      source: 'src/metrics/metrics.controller.ts',
      needle: "@Controller('metrics')",
      why: 'Internal, token-protected',
    },
  }),
];

const BACKEND = resolve(__dirname, '..');
const ROOT = resolve(BACKEND, '..', '..');
const args = process.argv.slice(2);
const FINAL = args.includes('--final');
const pending = new Set(
  (args.find((a) => a.startsWith('--pending='))?.slice('--pending='.length) ?? '')
    .split(',')
    .filter(Boolean),
);

type Ops = Map<string, Set<string>>; // normalised path -> methods

const norm = (p: string) => p.replace(/^\/api\/v1/, '').replace(/\{[^}]+\}/g, '{}');

function loadOps(): Ops {
  const doc = JSON.parse(
    readFileSync(join(ROOT, 'packages/api-contracts/openapi.json'), 'utf8'),
  ) as {
    paths: Record<string, Record<string, unknown>>;
  };
  const ops: Ops = new Map();
  for (const [path, methods] of Object.entries(doc.paths)) {
    const set = ops.get(norm(path)) ?? new Set<string>();
    for (const m of Object.keys(methods)) set.add(m.toUpperCase());
    ops.set(norm(path), set);
  }
  return ops;
}

function has(ops: Ops, method: string, path: string): boolean {
  if (path.endsWith('/*')) {
    const prefix = path.slice(0, -1);
    for (const [p, ms] of ops)
      if (p.startsWith(prefix) && (method === '*' || ms.has(method))) return true;
    return false;
  }
  const wanted = norm(path);
  for (const [p, ms] of ops) {
    // Parameters match by position: `/groups/{ref}` satisfies `/groups/{}`; a literal `unread-count` is not a parameter.
    if (p === wanted && (method === '*' || ms.has(method))) return true;
  }
  return false;
}

function walk(dir: string, out: string[] = []): string[] {
  for (const f of readdirSync(dir)) {
    const p = join(dir, f);
    if (statSync(p).isDirectory()) walk(p, out);
    else if (p.endsWith('.dart')) out.push(p);
  }
  return out;
}

/** Operations the generated Dart client does not contain (the client is stale or generation failed). */
function staleClientOperations(): string[] {
  const dir = join(ROOT, 'apps/mobile/lib/core/api/generated');
  if (!existsSync(dir)) return ['(no generated Dart client found)'];
  const dart = walk(dir)
    .filter((f) => f.endsWith('_client.dart'))
    .map((f) => readFileSync(f, 'utf8'))
    .join('\n');
  const doc = JSON.parse(
    readFileSync(join(ROOT, 'packages/api-contracts/openapi.json'), 'utf8'),
  ) as {
    paths: Record<string, Record<string, unknown>>;
  };
  const stale: string[] = [];
  for (const [path, methods] of Object.entries(doc.paths)) {
    for (const m of Object.keys(methods)) {
      if (!dart.includes(`@${m.toUpperCase()}('${path}'`))
        stale.push(`${m.toUpperCase()} ${path.replace('/api/v1', '')}`);
    }
  }
  return stale;
}

function quality(): { total: number; withErrors: number; withExamples: number } {
  const doc = JSON.parse(
    readFileSync(join(ROOT, 'packages/api-contracts/openapi.json'), 'utf8'),
  ) as {
    paths: Record<string, Record<string, { responses?: Record<string, unknown> }>>;
  };
  let total = 0;
  let withErrors = 0;
  let withExamples = 0;
  for (const methods of Object.values(doc.paths)) {
    for (const op of Object.values(methods)) {
      total += 1;
      if (Object.keys(op.responses ?? {}).some((c) => /^[45]/.test(c))) withErrors += 1;
      if (JSON.stringify(op).includes('"example')) withExamples += 1;
    }
  }
  return { total, withErrors, withExamples };
}

function main(): void {
  const ops = loadOps();
  const rows: Array<{ state: string; item: Item; note: string }> = [];
  for (const item of INVENTORY) {
    const label = `${item.method} ${item.path}`;
    if (has(ops, item.method, item.path)) {
      rows.push({ state: 'PRESENT', item, note: '' });
    } else if (item.hidden) {
      const file = join(BACKEND, item.hidden.source);
      const ok = existsSync(file) && readFileSync(file, 'utf8').includes(item.hidden.needle);
      rows.push({
        state: ok ? 'PRESENT' : 'MISSING',
        item,
        note: ok ? `hidden on purpose: ${item.hidden.why}` : `expected in ${item.hidden.source}`,
      });
    } else if (item.deviation) {
      const [m, p] = item.deviation.actual.split(' ') as [string, string];
      const ok = has(ops, m, p);
      rows.push({
        state: ok ? 'DEVIATION' : pending.has(item.milestone) ? 'PENDING' : 'MISSING',
        item,
        note: `${item.deviation.actual}: ${item.deviation.why}`,
      });
    } else if (pending.has(item.milestone)) {
      rows.push({ state: 'PENDING', item, note: `owned by ${item.milestone}` });
    } else {
      rows.push({ state: 'MISSING', item, note: label });
    }
  }

  const count = (s: string) => rows.filter((r) => r.state === s).length;
  for (const state of ['MISSING', 'PENDING', 'DEVIATION']) {
    const list = rows.filter((r) => r.state === state);
    if (list.length === 0) continue;
    console.log(`\n${state} (${list.length})`);
    for (const r of list)
      console.log(
        `  ${r.item.method.padEnd(6)} ${r.item.path.padEnd(48)} ${r.item.milestone.padEnd(7)} ${r.note}`,
      );
  }
  const stale = staleClientOperations();
  const q = quality();
  console.log(
    `\nInventory: ${rows.length} entries: ${count('PRESENT')} present, ${count('DEVIATION')} recorded deviations, ${count('PENDING')} pending, ${count('MISSING')} missing.`,
  );
  console.log(
    `Dart client: ${stale.length === 0 ? 'knows every OpenAPI operation' : `${stale.length} operation(s) missing from the generated client (regenerate it)`}`,
  );
  for (const s of stale.slice(0, 15)) console.log(`  ${s}`);
  console.log(
    `OpenAPI quality: ${q.total} operations, ${q.withErrors} document error responses, ${q.withExamples} carry examples.`,
  );

  const failures =
    count('MISSING') +
    (FINAL ? count('PENDING') : 0) +
    (stale.length > 0 ? 1 : 0) +
    (FINAL && q.withErrors < q.total ? 1 : 0);
  if (failures > 0) {
    console.error(`\ncheck-api-coverage: FAILED${FINAL ? ' (--final)' : ''}`);
    process.exit(1);
  }
  console.log('\ncheck-api-coverage: OK');
}

main();
