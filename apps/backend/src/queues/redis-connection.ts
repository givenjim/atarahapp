import type { RedisOptions } from 'ioredis';

/** BullMQ needs connection options rather than a URL string. */
export function redisConnectionFromUrl(url: string, lazy = false): RedisOptions {
  const u = new URL(url);
  const db = u.pathname && u.pathname !== '/' ? Number(u.pathname.slice(1)) : 0;
  return {
    host: u.hostname,
    port: u.port ? Number(u.port) : 6379,
    username: u.username ? decodeURIComponent(u.username) : undefined,
    password: u.password ? decodeURIComponent(u.password) : undefined,
    db: Number.isInteger(db) ? db : 0,
    ...(u.protocol === 'rediss:' ? { tls: {} } : {}),
    // Required by BullMQ for blocking worker connections.
    maxRetriesPerRequest: null,
    lazyConnect: lazy,
  };
}
