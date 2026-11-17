/**
 * One-off, DEV ONLY: copies the data of the pre-Supabase local database (plain PostgreSQL, NestJS-issued auth) into
 * the Supabase stack (P1-M6, Master Prompt 5.7 and P1-M6 item 2). There are no production users yet; this script
 * refuses to run against anything that is not on this machine.
 *
 *   SOURCE_DATABASE_URL=postgresql://atarah:atarah_dev_password@localhost:55432/atarah \
 *   ATARAH_SOURCE_S3_ENDPOINT=http://localhost:59000 ATARAH_SOURCE_S3_ACCESS_KEY=... ATARAH_SOURCE_S3_SECRET_KEY=... \
 *   pnpm --filter @atarah/backend exec ts-node --transpile-only scripts/migrate-dev-data.ts
 *
 * Run it on a freshly migrated target that has NOT been seeded yet (reference data keeps its source ids), then run
 * `pnpm db:seed` afterwards (idempotent).
 *
 * Target values come from apps/backend/.env (ATARAH_DIRECT_URL, ATARAH_SUPABASE_URL, ATARAH_SUPABASE_SECRET_KEY).
 *
 * 1. Every source user is recreated in Supabase Auth with the SAME id (admin API), so the `auth.users` trigger
 *    creates the `users` row. The old Argon2id password hash is imported when Supabase accepts it; otherwise the
 *    account gets a one-time random password that is printed (dev accounts only) and must be reset.
 * 2. Every other application table is copied in foreign-key order, by shared column name, skipping the tables
 *    Supabase Auth replaced (credentials, sessions, verification_codes, admin_totp).
 * 3. Objects in the three source buckets are copied to Supabase Storage under the same keys.
 */
import 'dotenv/config';
import { randomBytes } from 'node:crypto';
import { GetObjectCommand, ListObjectsV2Command, S3Client } from '@aws-sdk/client-s3';
import { createClient } from '@supabase/supabase-js';
import pg from 'pg';

const REPLACED_TABLES = new Set([
  'credentials',
  'sessions',
  'verification_codes',
  'admin_totp',
  '_prisma_migrations',
]);
const BUCKETS = ['public-media', 'private-media', 'verification-evidence'];

const need = (name: string): string => {
  const v = process.env[name];
  if (!v) throw new Error(`${name} is required`);
  return v;
};
const assertLocal = (label: string, url: string): void => {
  const host = new URL(url).hostname;
  if (!['localhost', '127.0.0.1'].includes(host))
    throw new Error(`Refusing to run: ${label} is not a local address (${host})`);
};

async function main(): Promise<void> {
  if ((process.env.ATARAH_ENV ?? 'dev') !== 'dev') throw new Error('Dev only (ATARAH_ENV=dev)');
  const sourceUrl = need('SOURCE_DATABASE_URL');
  const targetUrl = need('ATARAH_DIRECT_URL');
  const apiUrl = need('ATARAH_SUPABASE_URL');
  assertLocal('source database', sourceUrl);
  assertLocal('target database', targetUrl);
  assertLocal('Supabase API', apiUrl);

  const source = new pg.Client({ connectionString: sourceUrl });
  const target = new pg.Client({ connectionString: targetUrl });
  await source.connect();
  await target.connect();
  const supabase = createClient(apiUrl, need('ATARAH_SUPABASE_SECRET_KEY'), {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  try {
    const seeded = await target.query('SELECT count(*)::int AS n FROM disciplines');
    if (seeded.rows[0].n > 0 && process.env.ATARAH_MIGRATE_FORCE !== '1')
      throw new Error(
        'The target already has reference data. Reset it first (supabase db reset + migrate), or set ATARAH_MIGRATE_FORCE=1.',
      );

    // ---- 1. users through the Auth admin API -------------------------------------------------------
    const users = (
      await source.query(
        `SELECT u.*, c."passwordHash" FROM users u LEFT JOIN credentials c ON c."userId" = u.id ORDER BY u."createdAt"`,
      )
    ).rows;
    let imported = 0;
    let reset = 0;
    for (const u of users) {
      const exists = await target.query('SELECT 1 FROM auth.users WHERE id = $1', [u.id]);
      if (exists.rowCount) continue;
      const base = {
        id: u.id,
        email: u.email ?? undefined,
        phone: u.phone ?? undefined,
        email_confirm: Boolean(u.emailVerifiedAt),
        phone_confirm: Boolean(u.phoneVerifiedAt),
        user_metadata: { full_name: u.fullName },
      };
      let created = await supabase.auth.admin.createUser({
        ...base,
        ...(u.passwordHash ? { password_hash: u.passwordHash } : {}),
      } as Parameters<typeof supabase.auth.admin.createUser>[0]);
      if (created.error && u.passwordHash) {
        const temporary = randomBytes(12).toString('base64url') + '9';
        created = await supabase.auth.admin.createUser({ ...base, password: temporary });
        if (!created.error) {
          reset += 1;
          console.log(`  temporary password for ${u.email ?? u.phone}: ${temporary}`);
        }
      } else if (!created.error) imported += 1;
      if (created.error) throw new Error(`createUser ${u.id}: ${created.error.message}`);
    }
    console.log(
      `Auth users: ${users.length} in source, ${imported} with their password hash, ${reset} with a temporary password.`,
    );

    // ---- 2. application tables in foreign-key order -----------------------------------------------
    const tables = (
      await target.query<{ tablename: string }>(
        `SELECT tablename FROM pg_tables WHERE schemaname = 'public'`,
      )
    ).rows
      .map((r) => r.tablename)
      .filter((t) => !REPLACED_TABLES.has(t));
    const srcTables = new Set(
      (
        await source.query<{ tablename: string }>(
          `SELECT tablename FROM pg_tables WHERE schemaname = 'public'`,
        )
      ).rows.map((r) => r.tablename),
    );
    const pending = tables.filter((t) => srcTables.has(t));

    for (let pass = 1; pending.length > 0 && pass <= 8; pass++) {
      const failed: string[] = [];
      for (const table of [...pending]) {
        try {
          const copied = await copyTable(source, target, table);
          console.log(`  ${table}: ${copied} rows`);
          pending.splice(pending.indexOf(table), 1);
        } catch (err) {
          if (!/foreign key|violates/i.test((err as Error).message)) throw err;
          failed.push(table);
        }
      }
      if (failed.length === pending.length && failed.length > 0 && pass === 8)
        throw new Error(`Could not copy: ${failed.join(', ')}`);
    }

    // ---- 3. storage objects -----------------------------------------------------------------------
    const s3Endpoint = process.env.ATARAH_SOURCE_S3_ENDPOINT;
    if (s3Endpoint) {
      assertLocal('source S3', s3Endpoint);
      const s3 = new S3Client({
        endpoint: s3Endpoint,
        region: 'us-east-1',
        forcePathStyle: true,
        credentials: {
          accessKeyId: need('ATARAH_SOURCE_S3_ACCESS_KEY'),
          secretAccessKey: need('ATARAH_SOURCE_S3_SECRET_KEY'),
        },
      });
      let objects = 0;
      for (const bucket of BUCKETS) {
        let token: string | undefined;
        do {
          const page = await s3.send(
            new ListObjectsV2Command({ Bucket: bucket, ContinuationToken: token }),
          );
          for (const o of page.Contents ?? []) {
            const got = await s3.send(new GetObjectCommand({ Bucket: bucket, Key: o.Key! }));
            const body = Buffer.from(await got.Body!.transformToByteArray());
            const up = await supabase.storage
              .from(bucket)
              .upload(o.Key!, body, { contentType: got.ContentType, upsert: true });
            if (up.error) throw new Error(`upload ${bucket}/${o.Key}: ${up.error.message}`);
            objects += 1;
          }
          token = page.NextContinuationToken;
        } while (token);
      }
      console.log(`Storage objects copied: ${objects}`);
    } else {
      console.log('Storage: ATARAH_SOURCE_S3_ENDPOINT not set, no objects copied.');
    }

    // ---- report -----------------------------------------------------------------------------------
    for (const t of ['users', 'creative_profiles', 'projects', 'media_assets', 'notifications']) {
      const a = (await source.query(`SELECT count(*)::int n FROM ${t}`)).rows[0].n;
      const b = (await target.query(`SELECT count(*)::int n FROM ${t}`)).rows[0].n;
      console.log(`${t}: source ${a}, target ${b}${a === b ? '' : '  <-- differs'}`);
    }
  } finally {
    await source.end();
    await target.end();
  }
}

/** Copies the columns the two tables share. Existing target rows (same primary key) are updated in place. */
async function copyTable(source: pg.Client, target: pg.Client, table: string): Promise<number> {
  const cols = async (c: pg.Client): Promise<Array<{ name: string; type: string }>> =>
    (
      await c.query<{ column_name: string; data_type: string }>(
        `SELECT column_name, data_type FROM information_schema.columns WHERE table_schema = 'public' AND table_name = $1`,
        [table],
      )
    ).rows.map((r) => ({ name: r.column_name, type: r.data_type }));
  const targetCols = new Map((await cols(target)).map((c) => [c.name, c.type]));
  const columns = (await cols(source)).map((c) => c.name).filter((c) => targetCols.has(c));
  if (columns.length === 0) return 0;
  const isJson = (c: string): boolean => ['json', 'jsonb'].includes(targetCols.get(c) ?? '');
  const pk = (
    await target.query<{ attname: string }>(
      `SELECT a.attname FROM pg_index i JOIN pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey)
       WHERE i.indrelid = ('public."' || $1 || '"')::regclass AND i.indisprimary`,
      [table],
    )
  ).rows.map((r) => r.attname);
  const rows = (
    await source.query(`SELECT ${columns.map((c) => `"${c}"`).join(', ')} FROM "${table}"`)
  ).rows;
  const quoted = columns.map((c) => `"${c}"`).join(', ');
  const placeholders = columns.map((_, i) => `$${i + 1}`).join(', ');
  const conflict =
    pk.length > 0
      ? `ON CONFLICT (${pk.map((c) => `"${c}"`).join(', ')}) DO ${
          columns.every((c) => pk.includes(c))
            ? 'NOTHING'
            : `UPDATE SET ${columns
                .filter((c) => !pk.includes(c))
                .map((c) => `"${c}" = EXCLUDED."${c}"`)
                .join(', ')}`
        }`
      : '';
  await target.query('BEGIN');
  try {
    for (const row of rows) {
      await target.query(
        `INSERT INTO "${table}" (${quoted}) VALUES (${placeholders}) ${conflict}`,
        columns.map((c) => (isJson(c) && row[c] !== null ? JSON.stringify(row[c]) : row[c])),
      );
    }
    await target.query('COMMIT');
  } catch (err) {
    await target.query('ROLLBACK');
    throw err;
  }
  return rows.length;
}

main().catch((err: unknown) => {
  console.error(err instanceof Error ? err.message : err);
  process.exit(1);
});
