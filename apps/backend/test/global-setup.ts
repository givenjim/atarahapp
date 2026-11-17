import { execSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import path from 'node:path';
import pg from 'pg';
import { Redis } from 'ioredis';

const BACKEND_DIR = path.resolve(__dirname, '..');
const REPO_ROOT = path.resolve(BACKEND_DIR, '..', '..');
/**
 * The backend role's password. Locally it is the developer's own (apps/backend/.env), so running the tests does not
 * change it under a running backend; in CI there is no .env and a fixed test password is used.
 */
function backendRolePassword(): string {
  try {
    const env = readFileSync(path.join(BACKEND_DIR, '.env'), 'utf8');
    const found = /^ATARAH_BACKEND_DB_PASSWORD=(.{12,})$/m.exec(env)?.[1]?.trim();
    if (found) return found;
  } catch {
    // no .env: CI
  }
  return 'atarah-test-backend-role-password';
}
export const TEST_BACKEND_DB_PASSWORD = backendRolePassword();

interface SupabaseStatus {
  DB_URL: string;
  API_URL: string;
  PUBLISHABLE_KEY?: string;
  ANON_KEY: string;
  SECRET_KEY?: string;
  SERVICE_ROLE_KEY: string;
}

function localStatus(): SupabaseStatus {
  const out = execSync('npx supabase status -o json', { cwd: REPO_ROOT, encoding: 'utf8' });
  return JSON.parse(out.slice(out.indexOf('{'))) as SupabaseStatus;
}

/**
 * Integration tests run against the **local Supabase stack** (real Auth, Postgres, Storage and Realtime) plus
 * Redis (Master Prompt 7.7). Start both first: `just infra-up`.
 *
 * This resets the local database: it deletes every Auth user and truncates every application table so each run
 * starts empty. It refuses to run against anything that is not on this machine.
 */
export default async function globalSetup(): Promise<void> {
  const status = localStatus();
  const admin = new URL(status.DB_URL);
  if (!['127.0.0.1', 'localhost'].includes(admin.hostname)) {
    throw new Error(`Refusing to reset a database that is not local: ${admin.hostname}`);
  }

  const apiKey = status.PUBLISHABLE_KEY ?? status.ANON_KEY;
  const secretKey = status.SECRET_KEY ?? status.SERVICE_ROLE_KEY;
  const backendUrl = new URL(status.DB_URL);
  backendUrl.username = 'atarah_backend';
  backendUrl.password = TEST_BACKEND_DB_PASSWORD;

  // The Send SMS hook secret is the one the local Auth service was started with (supabase/.env).
  const hookSecret = /^SEND_SMS_HOOK_SECRET=(.+)$/m
    .exec(readFileSync(path.join(REPO_ROOT, 'supabase', '.env'), 'utf8'))?.[1]
    ?.trim();
  if (!hookSecret) throw new Error('supabase/.env has no SEND_SMS_HOOK_SECRET');

  Object.assign(process.env, {
    ATARAH_SEND_SMS_HOOK_SECRET: hookSecret,
    ATARAH_DIRECT_URL: status.DB_URL,
    ATARAH_DATABASE_URL: backendUrl.toString(),
    ATARAH_SUPABASE_URL: status.API_URL,
    ATARAH_SUPABASE_SECRET_KEY: secretKey,
    ATARAH_TEST_SUPABASE_PUBLISHABLE_KEY: apiKey,
    ATARAH_REDIS_URL: process.env.ATARAH_TEST_REDIS_URL ?? 'redis://localhost:56379/15',
  });

  execSync('npx prisma migrate deploy', { cwd: BACKEND_DIR, stdio: 'inherit', env: process.env });

  const client = new pg.Client({ connectionString: status.DB_URL });
  await client.connect();
  try {
    await client.query(
      `ALTER ROLE atarah_backend WITH LOGIN PASSWORD ${client.escapeLiteral(TEST_BACKEND_DB_PASSWORD)}`,
    );
    // audit_logs and moderation_actions refuse TRUNCATE by design; lift that for the reset only.
    await client.query('ALTER TABLE audit_logs DISABLE TRIGGER USER');
    await client.query('ALTER TABLE moderation_actions DISABLE TRIGGER USER');
    const { rows } = await client.query<{ tablename: string }>(
      `SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND tablename <> '_prisma_migrations'`,
    );
    if (rows.length > 0) {
      const list = rows.map((r) => `public."${r.tablename}"`).join(', ');
      await client.query(`TRUNCATE ${list} RESTART IDENTITY CASCADE`);
    }
    await client.query('ALTER TABLE audit_logs ENABLE TRIGGER USER');
    await client.query('ALTER TABLE moderation_actions ENABLE TRIGGER USER');
    await client.query('DELETE FROM auth.users');
  } finally {
    await client.end();
  }

  const redis = new Redis(process.env.ATARAH_REDIS_URL!, { maxRetriesPerRequest: 1 });
  try {
    await redis.flushdb();
  } finally {
    redis.disconnect();
  }
}
