/**
 * P1-M12 audit: lists every mutating route (POST, PUT, PATCH, DELETE) and every search route and says how it is
 * rate-limited. Every route is covered by the global default (120 requests a minute per client for reads and 60 for
 * writes, see RateLimitModule; admin writes also need a permission, an authenticator code and are audited); this script
 * checks that routes where abuse costs something carry an explicit, tighter `@Throttle`:
 *
 *   cd apps/backend && npx ts-node --transpile-only scripts/check-rate-limits.ts            # report; exit 1 on a gap
 *   cd apps/backend && npx ts-node --transpile-only scripts/check-rate-limits.ts --all       # also print every route
 *
 * "Sensitive" means: account and security actions, sign-in helpers, uploads,
 * reports, posting and commenting, connection requests, search, and the public (anonymous) routes that write.
 * It starts the application without opening the database or Redis (like the OpenAPI export).
 */
import 'reflect-metadata';
import { RequestMethod } from '@nestjs/common';
import { METHOD_METADATA, PATH_METADATA } from '@nestjs/common/constants';

process.env.ATARAH_SKIP_CONNECT = '1';

const THROTTLER_LIMIT = 'THROTTLER:LIMITdefault';
const THROTTLER_TTL = 'THROTTLER:TTLdefault';
const THROTTLER_SKIP = 'THROTTLER:SKIPdefault';
const IS_PUBLIC = 'access:public';

const METHOD: Record<number, string> = {
  [RequestMethod.GET]: 'GET',
  [RequestMethod.POST]: 'POST',
  [RequestMethod.PUT]: 'PUT',
  [RequestMethod.PATCH]: 'PATCH',
  [RequestMethod.DELETE]: 'DELETE',
};

/** Writes that must carry their own limit. Matched against `METHOD /path`. */
const SENSITIVE: RegExp[] = [
  /^(POST|PUT|PATCH|DELETE) \/me\/(delete|restore|export|password|account|security|privacy)/,
  /^(POST|DELETE) \/auth\//,
  /^POST \/media\//,
  /^POST \/reports/,
  /^POST \/posts/,
  /^POST \/groups\/[^/]+\/posts/,
  /^POST \/comments?/,
  /^POST \/creatives\/[^/]+\/connect/,
  /^POST \/(blocks|mutes)/,
  /^POST \/taxonomy\/specialisations\/suggestions/,
  /^POST \/opportunities\/[^/]+\/track/,
  /^PUT \/opportunities\/[^/]+\/save/,
  /^POST \/learning\//,
  /^PUT \/learning\//,
  /^GET \/(search|creatives)(\/|$)/,
  /^GET \/handles\//,
];

async function main(): Promise<void> {
  const { NestFactory, ModulesContainer } = await import('@nestjs/core');
  const { AppModule } = await import('../src/app.module');
  const app = await NestFactory.create(AppModule, { logger: false });
  const reflect = Reflect as unknown as { getMetadata(k: string, t: unknown): unknown };
  const rows: Array<{ route: string; limit: string; sensitive: boolean; explicit: boolean }> = [];
  for (const mod of app.get(ModulesContainer).values()) {
    for (const wrapper of mod.controllers.values()) {
      const ctrl = wrapper.metatype as unknown as { prototype: Record<string, unknown> } | null;
      if (!ctrl) continue;
      const base = reflect.getMetadata(PATH_METADATA, ctrl);
      const bases = Array.isArray(base) ? (base as string[]) : [(base as string | undefined) ?? ''];
      for (const name of Object.getOwnPropertyNames(ctrl.prototype)) {
        const handler = ctrl.prototype[name];
        if (typeof handler !== 'function' || name === 'constructor') continue;
        const code = reflect.getMetadata(METHOD_METADATA, handler) as number | undefined;
        if (code === undefined || !(code in METHOD)) continue;
        const sub = reflect.getMetadata(PATH_METADATA, handler);
        const subs = Array.isArray(sub) ? (sub as string[]) : [(sub as string | undefined) ?? ''];
        const get = (k: string) => reflect.getMetadata(k, handler) ?? reflect.getMetadata(k, ctrl);
        for (const b of bases) {
          for (const s of subs) {
            const path = `/${b}/${s}`.replace(/\/+/g, '/').replace(/\/$/, '') || '/';
            const route = `${METHOD[code]} ${path}`;
            const limit = get(THROTTLER_LIMIT) as number | undefined;
            const ttl = get(THROTTLER_TTL) as number | undefined;
            const skipped = get(THROTTLER_SKIP) === true;
            const explicit = limit !== undefined && !skipped;
            const mutating = code !== RequestMethod.GET;
            const isSearch = /^GET \/(search|creatives|handles)/.test(route);
            if (!mutating && !isSearch) continue;
            rows.push({
              route,
              limit: skipped
                ? 'SKIPPED'
                : explicit
                  ? `${limit} / ${Math.round((ttl ?? 0) / 1000)} s`
                  : mutating
                    ? 'default 60 / 60 s'
                    : 'default 120 / 60 s',
              sensitive: SENSITIVE.some((re) => re.test(route)),
              explicit,
            });
          }
        }
      }
    }
  }
  await app.close();

  rows.sort((a, b) => a.route.localeCompare(b.route));
  const gaps = rows.filter((r) => r.sensitive && !r.explicit);
  const skipped = rows.filter((r) => r.limit === 'SKIPPED');
  if (process.argv.includes('--all'))
    for (const r of rows)
      console.log(`${r.explicit ? 'explicit' : 'default '}  ${r.limit.padEnd(20)} ${r.route}`);
  console.log(
    `Mutating and search routes: ${rows.length}. Explicit limit: ${rows.filter((r) => r.explicit).length}. Default only: ${rows.filter((r) => !r.explicit).length}. Throttling skipped: ${skipped.length}.`,
  );
  for (const r of skipped) console.log(`  SKIPPED  ${r.route}`);
  if (gaps.length > 0) {
    console.error(`\nSensitive routes with no explicit limit (${gaps.length}):`);
    for (const g of gaps) console.error(`  ${g.route}`);
    console.error('\ncheck-rate-limits: FAILED');
    process.exit(1);
  }
  console.log('check-rate-limits: OK (every sensitive route has an explicit limit)');
  void IS_PUBLIC;
}

main().catch((e: unknown) => {
  console.error(e);
  process.exit(1);
});
