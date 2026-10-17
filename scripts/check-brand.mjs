// Fails if a legacy brand name ("CREA-8", "CREA8", "crea8") appears anywhere it should not.
// Allowed: docs/ history notes (docs/DECISIONS.md, docs/MASTER_PROMPT.md, docs/REPO_ASSESSMENT.md,
// docs/PROJECT_PROGRESS.md) and design/prototype/uploads/. Also skips dependencies and build output.
import { readdirSync, readFileSync, statSync } from 'node:fs';
import { join, relative, sep } from 'node:path';

const root = new URL('..', import.meta.url).pathname.replace(/^\/([A-Za-z]:)/, '$1');
const PATTERN = /crea[-_ ]?8/i;

const SKIP_DIRS = new Set([
  'node_modules',
  '.git',
  'dist',
  'build',
  '.next',
  'coverage',
  '.dart_tool',
  '.pub-cache',
  '.gradle',
  'Pods',
]);
const ALLOWED_PREFIXES = ['design/prototype/uploads/'];
const ALLOWED_FILES = new Set([
  'docs/DECISIONS.md',
  'docs/MASTER_PROMPT.md',
  'docs/REPO_ASSESSMENT.md',
  'docs/PROJECT_PROGRESS.md',
  'scripts/check-brand.mjs',
  'scripts/check-brand.sh',
]);
const BINARY_EXT = /\.(png|jpe?g|gif|webp|ico|pdf|docx|zip|woff2?|ttf|otf|mp4|mp3|keystore|jks)$/i;

const hits = [];

function walk(dir) {
  for (const name of readdirSync(dir)) {
    const full = join(dir, name);
    const rel = relative(root, full).split(sep).join('/');
    const st = statSync(full);
    if (st.isDirectory()) {
      if (!SKIP_DIRS.has(name)) walk(full);
      continue;
    }
    if (BINARY_EXT.test(name) || st.size > 2_000_000) continue;
    if (ALLOWED_FILES.has(rel) || ALLOWED_PREFIXES.some((p) => rel.startsWith(p))) continue;
    // The path itself must not carry the old brand either.
    if (PATTERN.test(rel)) hits.push(`${rel} (file name)`);
    const text = readFileSync(full, 'utf8');
    text.split(/\r?\n/).forEach((line, i) => {
      if (PATTERN.test(line)) hits.push(`${rel}:${i + 1}: ${line.trim().slice(0, 120)}`);
    });
  }
}

walk(root);

if (hits.length) {
  console.error(`Brand check FAILED — legacy name found in ${hits.length} place(s):`);
  for (const h of hits) console.error('  ' + h);
  process.exit(1);
}
console.log('Brand check passed: no legacy brand names found outside allowed history notes.');
