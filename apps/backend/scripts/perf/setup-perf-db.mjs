// Builds the scratch database `atarah_perf` on the LOCAL Supabase Postgres (never the shared `postgres` database used by
// dev and the integration tests): copies the current schema (public and auth) with pg_dump, adds the extensions,
// and loads the reference seed (roles, permissions, taxonomy, counties, settings). Safe to repeat: it drops and rebuilds.
//
//   node apps/backend/scripts/perf/setup-perf-db.mjs
//
// Needs Docker with the local Supabase stack running (`just infra-up`). Nothing here touches any cloud system.
import { execFileSync, spawnSync } from 'node:child_process';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const container = process.env.ATARAH_DB_CONTAINER ?? 'supabase_db_atarah';
const backend = join(dirname(fileURLToPath(import.meta.url)), '..', '..');
const db = 'atarah_perf';
const psql = (database, sql, input) =>
  execFileSync(
    'docker',
    [
      'exec',
      '-i',
      container,
      'psql',
      '-U',
      'supabase_admin',
      '-d',
      database,
      '-v',
      'ON_ERROR_STOP=1',
      '-Atq',
      ...(sql ? ['-c', sql] : []),
    ],
    { input, encoding: 'utf8', maxBuffer: 1 << 28 },
  );

console.log('Rebuilding scratch database', db);
psql('postgres', `SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '${db}'`);
psql('postgres', `DROP DATABASE IF EXISTS ${db}`);
psql('postgres', `CREATE DATABASE ${db}`);
psql(
  db,
  'CREATE SCHEMA IF NOT EXISTS extensions; CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA extensions; CREATE EXTENSION IF NOT EXISTS pgcrypto SCHEMA extensions; CREATE EXTENSION IF NOT EXISTS pg_stat_statements SCHEMA extensions; CREATE EXTENSION IF NOT EXISTS citext SCHEMA public; CREATE EXTENSION IF NOT EXISTS pg_trgm SCHEMA public; CREATE EXTENSION IF NOT EXISTS unaccent SCHEMA public',
);

const dump = execFileSync(
  'docker',
  [
    'exec',
    container,
    'pg_dump',
    '-U',
    'supabase_admin',
    '-d',
    'postgres',
    '-s',
    '-n',
    'public',
    '-n',
    'auth',
    '--no-owner',
    '--no-privileges',
  ],
  { encoding: 'utf8', maxBuffer: 1 << 29 },
);
const r = spawnSync(
  'docker',
  ['exec', '-i', container, 'psql', '-U', 'supabase_admin', '-d', db, '-q'],
  { input: dump, encoding: 'utf8', maxBuffer: 1 << 28 },
);
const errors = (r.stderr ?? '')
  .split('\n')
  .filter((l) => /ERROR/.test(l) && !/already exists/.test(l));
if (errors.length)
  console.log('Schema restore notes (first 8):\n  ' + errors.slice(0, 8).join('\n  '));

// The backend role needs the same access it has in the shared database.
psql(
  db,
  'GRANT USAGE ON SCHEMA public, auth TO atarah_backend; GRANT ALL ON ALL TABLES IN SCHEMA public TO atarah_backend; GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO atarah_backend; GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO atarah_backend',
);
console.log(
  'Tables in public:',
  psql(db, "SELECT count(*) FROM pg_tables WHERE schemaname='public'").trim(),
);

const url = `postgresql://supabase_admin:postgres@127.0.0.1:55322/${db}`;
const seed = spawnSync(
  'node',
  ['node_modules/ts-node/dist/bin.js', '--transpile-only', 'prisma/seed/index.ts'],
  {
    cwd: backend,
    env: {
      ...process.env,
      ATARAH_SEED_REFERENCE_ONLY: '1',
      ATARAH_DATABASE_URL: url,
      ATARAH_DIRECT_URL: url,
    },
    encoding: 'utf8',
  },
);
console.log(
  'Reference seed exit code:',
  seed.status,
  (seed.stderr || '').split('\n').slice(0, 3).join(' '),
);
console.log('Done. Next: node scripts/perf/load-volume.mjs');
