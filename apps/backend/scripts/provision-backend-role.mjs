// Sets the password of the `atarah_backend` database role (created, without a password, by the
// 20261022090000_supabase_platform migration). The password comes from the secret store, never from a migration.
//
//   ATARAH_DIRECT_URL=<postgres admin url> ATARAH_BACKEND_DB_PASSWORD=<secret> node scripts/provision-backend-role.mjs
//
// Run after `prisma migrate deploy` in every environment (the local bootstrap, CI and the deploy pipeline).
import pg from 'pg';

export async function provisionBackendRole(adminUrl, password) {
  if (!adminUrl) throw new Error('ATARAH_DIRECT_URL is required');
  if (!password || password.length < 12) {
    throw new Error('ATARAH_BACKEND_DB_PASSWORD is required (at least 12 characters)');
  }
  const client = new pg.Client({ connectionString: adminUrl });
  await client.connect();
  try {
    const literal = client.escapeLiteral(password);
    await client.query(`ALTER ROLE atarah_backend WITH LOGIN PASSWORD ${literal}`);
  } finally {
    await client.end();
  }
}

if (import.meta.url === `file:///${process.argv[1].replace(/\\/g, '/')}`) {
  provisionBackendRole(process.env.ATARAH_DIRECT_URL, process.env.ATARAH_BACKEND_DB_PASSWORD)
    .then(() => console.log('atarah_backend role password set.'))
    .catch((err) => {
      console.error(err.message);
      process.exit(1);
    });
}
