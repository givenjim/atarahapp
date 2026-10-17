import { execSync } from 'node:child_process';
import { PostgreSqlContainer } from '@testcontainers/postgresql';
import { RedisContainer } from '@testcontainers/redis';

/**
 * Starts a real PostgreSQL 16 and Redis 7 once for the whole integration run, applies every
 * migration, and exports connection strings to the test workers through process.env.
 */
export default async function globalSetup(): Promise<void> {
  const pg = await new PostgreSqlContainer('postgres:16-alpine')
    .withDatabase('atarah_test')
    .withUsername('atarah')
    .withPassword('atarah_test_password')
    .start();
  const redis = await new RedisContainer('redis:7-alpine').start();

  const databaseUrl = pg.getConnectionUri();
  process.env.ATARAH_DATABASE_URL = databaseUrl;
  process.env.ATARAH_REDIS_URL = `redis://${redis.getHost()}:${redis.getMappedPort(6379)}`;

  execSync('npx prisma migrate deploy', {
    stdio: 'inherit',
    env: { ...process.env, ATARAH_DATABASE_URL: databaseUrl },
  });

  (globalThis as Record<string, unknown>).__ATARAH_CONTAINERS__ = [pg, redis];
}
