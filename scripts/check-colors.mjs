// Fails if a colour from the pre-v2.3 palette appears in app, web, admin or package SOURCE.
// Master Prompt v2.3 P1-M7. Matches "#rrggbb" and Dart "0xFFrrggbb" forms, case-insensitive.
// Skips dependencies, build output, docs/ and design/ (they may describe the old palette).
// NOTE: #1c1a4a is an old value AND the new dark "Mist" (section 8.3), so that one value is
// exempt in packages/design-tokens/tokens.json and the files generated from it only.
import { readdirSync, readFileSync, statSync } from 'node:fs';
import { join, relative, sep } from 'node:path';

const root = new URL('..', import.meta.url).pathname.replace(/^\/([A-Za-z]:)/, '$1');

const OLD = [
  '5b45f0',
  '15133d',
  '4330d6',
  '7b6cf6',
  '5a46ee',
  'e8457a',
  'c62f63',
  'f08a24',
  'c76a10',
  '2f6fe0',
  '8b5cf6',
  'c78a10',
  'f5a524',
  '4a36e0',
  '3b2bc4',
  '1c1a4a',
  '25206a',
  '2f2783',
  'fde7c4',
  'fbd38d',
];
const DARK_MIST = '1c1a4a';
const DARK_MIST_EXEMPT = new Set([
  'packages/design-tokens/tokens.json',
  'packages/design-tokens/dist/tokens.css',
  'packages/design-tokens/dist/tokens.ts',
  'apps/mobile/lib/core/design_system/tokens.g.dart',
]);
const PATTERN = new RegExp(`(?:#|0xFF)(${OLD.join('|')})(?![0-9a-f])`, 'gi');

const SCAN_ROOTS = ['apps', 'packages'];
const SKIP_DIRS = new Set([
  'node_modules',
  '.git',
  'build',
  '.next',
  'coverage',
  '.dart_tool',
  '.pub-cache',
  '.gradle',
  'Pods',
  'generated',
  'test-results',
  'playwright-report',
  '.turbo',
]);
const SOURCE_EXT =
  /\.(dart|ts|tsx|js|jsx|mjs|cjs|css|scss|json|html|svg|xml|kt|java|swift|plist|yaml|yml|md)$/i;

const hits = [];

function walk(dir) {
  for (const name of readdirSync(dir)) {
    const full = join(dir, name);
    const st = statSync(full);
    if (st.isDirectory()) {
      const buildOutput =
        name === 'dist' &&
        !relative(root, full).split(sep).join('/').startsWith('packages/design-tokens/');
      if (!SKIP_DIRS.has(name) && !buildOutput) walk(full);
      continue;
    }
    if (!SOURCE_EXT.test(name) || st.size > 2_000_000 || name === 'pubspec.lock') continue;
    const rel = relative(root, full).split(sep).join('/');
    const text = readFileSync(full, 'utf8');
    text.split(/\r?\n/).forEach((line, i) => {
      for (const m of line.matchAll(PATTERN)) {
        if (m[1].toLowerCase() === DARK_MIST && DARK_MIST_EXEMPT.has(rel)) continue;
        hits.push(`${rel}:${i + 1}: ${m[0]}`);
      }
    });
  }
}

for (const r of SCAN_ROOTS) walk(join(root, r));

if (hits.length) {
  console.error(`Colour check FAILED: ${hits.length} old palette value(s) found:`);
  for (const h of hits) console.error('  ' + h);
  process.exit(1);
}
console.log('Colour check passed: no pre-v2.3 palette values in source.');
