// Generates platform token files from tokens.json (single source of truth):
//   apps/mobile/lib/core/design_system/tokens.g.dart   Flutter
//   packages/design-tokens/dist/tokens.css             CSS custom properties for web and admin
//   packages/design-tokens/dist/tokens.ts              typed constants for TypeScript
// Run: pnpm gen:tokens
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const root = join(here, '..', '..');
const tokens = JSON.parse(readFileSync(join(here, 'tokens.json'), 'utf8'));

const HEADER =
  'GENERATED FILE. Do not edit: change packages/design-tokens/tokens.json and run `pnpm gen:tokens`.';

// ---- helpers --------------------------------------------------------------------------------

const isLeafColor = (v) => typeof v === 'string';
const kebab = (s) => s.replace(/([a-z0-9])([A-Z])/g, '$1-$2').toLowerCase();
const upperFirst = (s) => s[0].toUpperCase() + s.slice(1);

function parseColor(value) {
  const hex = /^#([0-9a-f]{6})$/i.exec(value);
  if (hex)
    return {
      r: parseInt(hex[1].slice(0, 2), 16),
      g: parseInt(hex[1].slice(2, 4), 16),
      b: parseInt(hex[1].slice(4, 6), 16),
      a: 1,
    };
  const rgba = /^rgba\((\d+),\s*(\d+),\s*(\d+),\s*([\d.]+)\)$/.exec(value);
  if (rgba) return { r: +rgba[1], g: +rgba[2], b: +rgba[3], a: +rgba[4] };
  throw new Error(`Unsupported colour "${value}"`);
}

function dartColor(value) {
  const c = parseColor(value);
  if (c.a === 1) {
    const h = (n) => n.toString(16).padStart(2, '0');
    return `Color(0xFF${(h(c.r) + h(c.g) + h(c.b)).toUpperCase()})`;
  }
  return `Color.fromRGBO(${c.r}, ${c.g}, ${c.b}, ${c.a})`;
}

const dartNum = (n) => (Number.isInteger(n) ? `${n}.0` : `${n}`);

/** Flatten nested colour groups: { success: {bg} } -> success + 'Bg'. */
function flattenColors(obj, prefix = '') {
  const out = [];
  for (const [k, v] of Object.entries(obj)) {
    if (k.startsWith('$')) continue;
    const name = prefix ? prefix + upperFirst(k) : k;
    if (isLeafColor(v)) out.push([name, v]);
    else out.push(...flattenColors(v, name));
  }
  return out;
}

const ALIGN = {
  90: ['Alignment.centerLeft', 'Alignment.centerRight'],
  135: ['Alignment.topLeft', 'Alignment.bottomRight'],
  180: ['Alignment.topCenter', 'Alignment.bottomCenter'],
};

// ---- Dart -----------------------------------------------------------------------------------

function genDart() {
  const colors = flattenColors(tokens.color);
  const lines = [];
  lines.push(`// ${HEADER}`);
  lines.push('// ignore_for_file: public_member_api_docs, constant_identifier_names');
  lines.push("import 'package:flutter/painting.dart';");
  lines.push('');

  lines.push('/// Colour tokens.');
  lines.push('abstract final class AtColors {');
  for (const [name, v] of colors) lines.push(`  static const Color ${name} = ${dartColor(v)};`);
  lines.push('}');
  lines.push('');

  lines.push('/// Gradient tokens.');
  lines.push('abstract final class AtGradients {');
  for (const [name, g] of Object.entries(tokens.gradient)) {
    const [begin, end] = ALIGN[g.angle];
    lines.push(`  static const LinearGradient ${name} = LinearGradient(`);
    lines.push(`    begin: ${begin},`);
    lines.push(`    end: ${end},`);
    lines.push(`    colors: <Color>[${g.stops.map(([c]) => dartColor(c)).join(', ')}],`);
    lines.push(`    stops: <double>[${g.stops.map(([, s]) => dartNum(s)).join(', ')}],`);
    lines.push('  );');
  }
  lines.push('}');
  lines.push('');

  lines.push(
    '/// Shadow tokens (each is a list so it can be passed straight to BoxDecoration.boxShadow).',
  );
  lines.push('abstract final class AtShadows {');
  for (const [name, s] of Object.entries(tokens.shadow)) {
    lines.push(`  static const List<BoxShadow> ${name} = <BoxShadow>[`);
    lines.push(
      `    BoxShadow(color: ${dartColor(s.color)}, offset: Offset(${dartNum(s.x)}, ${dartNum(s.y)}), blurRadius: ${dartNum(s.blur)}),`,
    );
    lines.push('  ];');
  }
  lines.push('}');
  lines.push('');

  lines.push('/// Corner radius tokens.');
  lines.push('abstract final class AtRadii {');
  for (const [name, r] of Object.entries(tokens.radius)) {
    lines.push(`  static const double ${name}Value = ${dartNum(r)};`);
    lines.push(
      `  static const BorderRadius ${name} = BorderRadius.all(Radius.circular(${dartNum(r)}));`,
    );
  }
  lines.push('  static const BorderRadius sheetTop = BorderRadius.only(');
  lines.push(`    topLeft: Radius.circular(${dartNum(tokens.radius.sheet)}),`);
  lines.push(`    topRight: Radius.circular(${dartNum(tokens.radius.sheet)}),`);
  lines.push('  );');
  lines.push('}');
  lines.push('');

  lines.push('/// Spacing and size tokens.');
  lines.push('abstract final class AtSpacing {');
  for (const [name, n] of Object.entries(tokens.spacing))
    lines.push(`  static const double ${name} = ${dartNum(n)};`);
  lines.push('}');
  lines.push('');
  lines.push('abstract final class AtSizes {');
  for (const [name, n] of Object.entries(tokens.size))
    lines.push(`  static const double ${name} = ${dartNum(n)};`);
  lines.push('}');
  lines.push('');

  lines.push('/// Motion durations.');
  lines.push('abstract final class AtMotion {');
  for (const [name, ms] of Object.entries(tokens.motion))
    lines.push(`  static const Duration ${name} = Duration(milliseconds: ${ms});`);
  lines.push('}');
  lines.push('');

  lines.push(
    '/// Text styles. Plus Jakarta Sans is bundled as an asset (never fetched at runtime).',
  );
  lines.push('abstract final class AtTextStyles {');
  lines.push(`  static const String fontFamily = '${tokens.font.family}';`);
  for (const [name, t] of Object.entries(tokens.type)) {
    const ls = t.letterSpacingEm
      ? `, letterSpacing: ${dartNum(+(t.letterSpacingEm * t.size).toFixed(3))}`
      : '';
    lines.push(`  static const TextStyle ${name} = TextStyle(`);
    lines.push(
      `    fontFamily: fontFamily, fontSize: ${dartNum(t.size)}, fontWeight: FontWeight.w${t.weight}, height: ${dartNum(t.height ?? 1.3)}${ls},`,
    );
    lines.push('  );');
  }
  lines.push('}');
  lines.push('');
  return lines.join('\n');
}

// ---- CSS ------------------------------------------------------------------------------------

function genCss() {
  const out = [`/* ${HEADER} */`, ':root {'];
  out.push(`  --at-font-family: '${tokens.font.family}', system-ui, sans-serif;`);
  for (const [name, v] of flattenColors(tokens.color))
    out.push(`  --at-color-${kebab(name)}: ${v};`);
  for (const [name, g] of Object.entries(tokens.gradient)) {
    const stops = g.stops.map(([c, p]) => `${c} ${Math.round(p * 100)}%`).join(', ');
    out.push(`  --at-gradient-${kebab(name)}: linear-gradient(${g.angle}deg, ${stops});`);
  }
  for (const [name, s] of Object.entries(tokens.shadow))
    out.push(`  --at-shadow-${kebab(name)}: ${s.x}px ${s.y}px ${s.blur}px ${s.color};`);
  for (const [name, r] of Object.entries(tokens.radius))
    out.push(`  --at-radius-${kebab(name)}: ${r}px;`);
  for (const [name, n] of Object.entries(tokens.spacing))
    out.push(`  --at-space-${kebab(name)}: ${n}px;`);
  for (const [name, n] of Object.entries(tokens.size))
    out.push(`  --at-size-${kebab(name)}: ${n}px;`);
  for (const [name, t] of Object.entries(tokens.type)) {
    out.push(`  --at-type-${kebab(name)}-size: ${t.size}px;`);
    out.push(`  --at-type-${kebab(name)}-weight: ${t.weight};`);
    out.push(`  --at-type-${kebab(name)}-height: ${t.height ?? 1.3};`);
    if (t.letterSpacingEm) out.push(`  --at-type-${kebab(name)}-tracking: ${t.letterSpacingEm}em;`);
  }
  for (const [name, ms] of Object.entries(tokens.motion))
    out.push(`  --at-motion-${name}: ${ms}ms;`);
  out.push('}', '');
  return out.join('\n');
}

// ---- TypeScript -----------------------------------------------------------------------------

function genTs() {
  const body = JSON.stringify(tokens, null, 2).replace(/"\$description": ".*",\n\s*/, '');
  return `// ${HEADER}\nexport const tokens = ${body} as const;\n\nexport type Tokens = typeof tokens;\n`;
}

function write(path, content) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, content, 'utf8');
  console.log(`wrote ${path.replace(root, '.')}`);
}

write(join(root, 'apps/mobile/lib/core/design_system/tokens.g.dart'), genDart());
write(join(here, 'dist/tokens.css'), genCss());
write(join(here, 'dist/tokens.ts'), genTs());
