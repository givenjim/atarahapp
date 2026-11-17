// Runs scripts/check-rls.sql against ATARAH_DIRECT_URL (the owner connection) and exits non-zero on a violation.
//   ATARAH_DIRECT_URL=postgresql://postgres:postgres@127.0.0.1:55322/postgres node scripts/check-rls.mjs
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const require = createRequire(join(root, 'apps', 'backend', 'package.json'));
const pg = require('pg');

const url =
  process.env.ATARAH_DIRECT_URL ?? 'postgresql://postgres:postgres@127.0.0.1:55322/postgres';
const client = new pg.Client({ connectionString: url });
await client.connect();
try {
  await client.query(readFileSync(join(root, 'scripts', 'check-rls.sql'), 'utf8'));
  console.log(
    'check-rls: OK (RLS on every public table; only the notifications SELECT policy; anon has no access).',
  );
} catch (err) {
  console.error(`check-rls: FAILED - ${err.message}`);
  process.exitCode = 1;
} finally {
  await client.end();
}
