// One command from a fresh checkout to a working local environment:
//   install dependencies -> create env files -> start Supabase and Redis -> write the Supabase env values ->
//   generate the Prisma client -> migrate -> set the backend role password -> seed -> check Row Level Security.
// Needs Docker running. Safe to run again: every step is idempotent. It never touches git.
import { spawnSync } from 'node:child_process';

const root = new URL('..', import.meta.url).pathname.replace(/^\/([A-Za-z]:)/, '$1');
const isWin = process.platform === 'win32';

function run(cmd, args, cwd = root) {
  console.log(`\n> ${cmd} ${args.join(' ')}`);
  const r = isWin
    ? spawnSync([cmd, ...args].join(' '), { cwd, stdio: 'inherit', shell: true })
    : spawnSync(cmd, args, { cwd, stdio: 'inherit' });
  if (r.status !== 0) {
    console.error(`\nFAILED: ${cmd} ${args.join(' ')}`);
    process.exit(r.status ?? 1);
  }
}

const docker = spawnSync(isWin ? 'docker info' : 'docker', isWin ? [] : ['info'], {
  stdio: 'ignore',
  shell: isWin,
});
if (docker.status !== 0) {
  console.error(
    'Docker is not running. Start Docker Desktop (or the Docker daemon) and run this again.',
  );
  process.exit(1);
}

run('node', ['scripts/setup.mjs']);
run('docker', ['compose', '-f', 'infrastructure/docker-compose.yml', 'up', '-d', '--wait']);
// The Supabase CLI (a dev dependency) starts PostgreSQL, Auth, Storage, Realtime and the mail catcher.
run('npx', ['supabase', 'start']);
run('node', ['scripts/supabase-env.mjs']);
run('pnpm', ['--filter', '@atarah/backend', 'db:generate']);
run('pnpm', ['--filter', '@atarah/backend', 'db:migrate:deploy']);
run('pnpm', ['--filter', '@atarah/backend', 'db:provision']);
run('pnpm', ['--filter', '@atarah/backend', 'db:seed']);
run('node', ['scripts/check-rls.mjs']);

console.log(`
Environment ready.
  API + worker:  pnpm --filter @atarah/backend dev          (then: pnpm --filter @atarah/backend dev:worker)
  Admin console: pnpm --filter @atarah/admin dev            http://localhost:3200
  Public site:   pnpm --filter @atarah/web dev              http://localhost:3100
  Mail inbox:    http://127.0.0.1:55324  (Supabase local mail catcher)
  Supabase Studio: http://127.0.0.1:55323
  Demo accounts: docs/DEVELOPMENT.md`);
