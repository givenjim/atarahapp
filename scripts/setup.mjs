// Atarah workspace setup. Cross-platform (Windows, macOS, Linux).
// Installs TypeScript dependencies and, when present, Flutter dependencies.
// It never starts containers or touches git.
import { spawnSync } from 'node:child_process';
import { existsSync, copyFileSync } from 'node:fs';
import { join } from 'node:path';

const root = new URL('..', import.meta.url).pathname.replace(/^\/([A-Za-z]:)/, '$1');
const isWin = process.platform === 'win32';

function run(cmd, args, cwd = root) {
  console.log(`\n> ${cmd} ${args.join(' ')}  (${cwd})`);
  // On Windows pnpm/flutter are .cmd shims and need a shell; pass one string to avoid arg-escaping warnings.
  const r = isWin
    ? spawnSync([cmd, ...args].join(' '), { cwd, stdio: 'inherit', shell: true })
    : spawnSync(cmd, args, { cwd, stdio: 'inherit' });
  if (r.status !== 0) {
    console.error(`FAILED: ${cmd} ${args.join(' ')}`);
    process.exit(r.status ?? 1);
  }
}

function has(cmd) {
  return spawnSync(isWin ? 'where' : 'which', [cmd], { stdio: 'ignore' }).status === 0;
}

if (!has('pnpm')) {
  console.error('pnpm is required: npm i -g pnpm');
  process.exit(1);
}
run('pnpm', ['install']);

// Create local env files from templates without overwriting existing ones.
// Next.js apps read .env.local; the backend reads .env. Mobile uses --dart-define-from-file (see its template).
const envTargets = { 'apps/backend': '.env', 'apps/web': '.env.local', 'apps/admin': '.env.local' };
for (const [app, envName] of Object.entries(envTargets)) {
  const example = join(root, app, '.env.example');
  const target = join(root, app, envName);
  if (existsSync(example) && !existsSync(target)) {
    copyFileSync(example, target);
    console.log(`created ${app}/${envName} from .env.example`);
  }
}

if (existsSync(join(root, 'apps/mobile/pubspec.yaml'))) {
  if (has('flutter')) run('flutter', ['pub', 'get'], join(root, 'apps/mobile'));
  else console.warn('flutter not found on PATH; skipping apps/mobile dependencies');
}

console.log('\nSetup complete. Next: `just dev` (needs Docker running) or see docs/DEVELOPMENT.md');
