// Writes the local Supabase connection values into the apps' git-ignored .env files, by asking the running
// local stack (`supabase status`). Nothing secret is committed: the keys come from the CLI at run time.
//
//   node scripts/supabase-env.mjs        (Supabase must be running: `just infra-up`)
//
// Creates apps/backend/.env from .env.example when missing, then sets only the Supabase and database keys.
import { spawnSync } from 'node:child_process';
import { existsSync, readFileSync, writeFileSync, copyFileSync } from 'node:fs';
import { randomBytes } from 'node:crypto';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const isWin = process.platform === 'win32';

function status() {
  const r = spawnSync('npx supabase status -o json', {
    cwd: root,
    shell: true,
    encoding: 'utf8',
    stdio: ['ignore', 'pipe', 'pipe'],
  });
  if (r.status !== 0) {
    console.error(
      'Could not read `supabase status`. Is the local stack running? (just infra-up)\n' + r.stderr,
    );
    process.exit(1);
  }
  const json = r.stdout.slice(r.stdout.indexOf('{'));
  return JSON.parse(json);
}

function readEnv(path) {
  const out = new Map();
  if (!existsSync(path)) return out;
  for (const line of readFileSync(path, 'utf8').split(/\r?\n/)) {
    const m = /^([A-Z0-9_]+)=(.*)$/.exec(line);
    if (m) out.set(m[1], m[2]);
  }
  return out;
}

export function setEnvValues(path, values) {
  let text = existsSync(path) ? readFileSync(path, 'utf8') : '';
  for (const [key, value] of Object.entries(values)) {
    const re = new RegExp(`^${key}=.*$`, 'm');
    if (re.test(text)) text = text.replace(re, `${key}=${value}`);
    else text += (text.endsWith('\n') || text === '' ? '' : '\n') + `${key}=${value}\n`;
  }
  writeFileSync(path, text);
}

const s = status();
const hookSecret = readEnv(join(root, 'supabase', '.env')).get('SEND_SMS_HOOK_SECRET');
if (!hookSecret) {
  console.error(
    'supabase/.env has no SEND_SMS_HOOK_SECRET. Copy supabase/.env.example and set a real value.',
  );
  process.exit(1);
}

const backendEnv = join(root, 'apps', 'backend', '.env');
if (!existsSync(backendEnv))
  copyFileSync(join(root, 'apps', 'backend', '.env.example'), backendEnv);
const current = readEnv(backendEnv);
const dbPassword =
  current.get('ATARAH_BACKEND_DB_PASSWORD') || randomBytes(18).toString('base64url');

const direct = new URL(s.DB_URL);
const poolerPort = new URL(s.DB_URL).port === '55322' ? '55329' : '6543';
setEnvValues(backendEnv, {
  ATARAH_SUPABASE_URL: s.API_URL,
  ATARAH_SUPABASE_SECRET_KEY: s.SECRET_KEY ?? s.SERVICE_ROLE_KEY,
  ATARAH_SEND_SMS_HOOK_SECRET: hookSecret,
  ATARAH_BACKEND_DB_PASSWORD: dbPassword,
  // Runtime: the transaction pooler, as the backend role (Supavisor wants role.tenant-id; the local tenant is pooler-dev, in the cloud it is the project ref).
  ATARAH_DATABASE_URL: `postgresql://atarah_backend.pooler-dev:${encodeURIComponent(dbPassword)}@${direct.hostname}:${poolerPort}/postgres?pgbouncer=true&connection_limit=10`,
  // Migrations and long-running jobs: the direct connection, as the database owner.
  ATARAH_DIRECT_URL: s.DB_URL,
});
// Web and admin: only the URL and the PUBLISHABLE key reach the browser (never the secret key).
for (const app of ['web', 'admin']) {
  const target = join(root, 'apps', app, '.env.local');
  if (!existsSync(join(root, 'apps', app))) continue;
  setEnvValues(target, {
    NEXT_PUBLIC_SUPABASE_URL: s.API_URL,
    NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY: s.PUBLISHABLE_KEY ?? s.ANON_KEY,
  });
  console.log(`Updated ${target}`);
}
console.log(`Updated ${backendEnv} from the local Supabase stack (${s.API_URL}).`);
void isWin;
