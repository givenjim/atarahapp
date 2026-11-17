// Generates platform token files from tokens.json (single source of truth):
//   apps/mobile/lib/core/design_system/tokens.g.dart   Flutter (AtColors light + dark, radii, type ...)
//   packages/design-tokens/dist/tokens.css             CSS custom properties for web and admin: light in :root,
//                                                      dark under prefers-color-scheme and [data-theme="dark"]
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

const ALIGN = {
  90: ['Alignment.centerLeft', 'Alignment.centerRight'],
  135: ['Alignment.topLeft', 'Alignment.bottomRight'],
  180: ['Alignment.topCenter', 'Alignment.bottomCenter'],
};

const light = tokens.color.light;
const dark = tokens.color.dark;
const roles = Object.keys(light);
const statics = Object.entries(tokens.static);
const themedGradients = Object.keys(tokens.gradientThemed);
const shadowNames = Object.keys(tokens.shadow);
for (const r of roles)
  if (!(r in dark)) throw new Error(`Colour role "${r}" is missing from the dark set`);

const shadowField = (n) => `shadow${upperFirst(n)}`;
const gradField = (n) => `${n}Gradient`;
const cssGradient = (g) =>
  `linear-gradient(${g.angle}deg, ${g.stops.map(([c, p]) => `${c} ${Math.round(p * 100)}%`).join(', ')})`;

// ---- Dart -----------------------------------------------------------------------------------

function gradLiteral(g) {
  const [begin, end] = ALIGN[g.angle];
  return `LinearGradient(begin: ${begin}, end: ${end}, colors: <Color>[${g.stops.map(([c]) => dartColor(c)).join(', ')}], stops: <double>[${g.stops.map(([, p]) => dartNum(p)).join(', ')}])`;
}

function shadowLiteral(appearance, name) {
  if (appearance === 'dark') {
    const c = dartColor(dark[tokens.shadowDark.role]);
    return `<BoxShadow>[BoxShadow(color: ${c}, spreadRadius: ${dartNum(tokens.shadowDark.spread)})]`;
  }
  const s = tokens.shadow[name];
  return `<BoxShadow>[BoxShadow(color: ${dartColor(s.color)}, offset: Offset(${dartNum(s.x)}, ${dartNum(s.y)}), blurRadius: ${dartNum(s.blur)})]`;
}

function genDart() {
  const lines = [];
  lines.push(`// ${HEADER}`);
  lines.push('// ignore_for_file: public_member_api_docs, constant_identifier_names');
  lines.push("import 'package:flutter/material.dart' show ThemeExtension;");
  lines.push("import 'package:flutter/painting.dart';");
  lines.push('');

  lines.push('/// The six brand colours (Master Prompt 8.1). Identical in both appearances.');
  lines.push('abstract final class AtBrand {');
  for (const [name, v] of Object.entries(tokens.brand))
    lines.push(`  static const Color ${name} = ${dartColor(v)};`);
  lines.push('}');
  lines.push('');

  const all = [
    ...roles.map((r) => [r, 'Color']),
    ...statics.map(([n]) => [n, 'Color']),
    ...themedGradients.map((g) => [gradField(g), 'LinearGradient']),
    ...shadowNames.map((n) => [shadowField(n), 'List<BoxShadow>']),
  ];

  lines.push(
    '/// Every colour role, gradient and shadow that depends on the appearance, as a [ThemeExtension].',
  );
  lines.push(
    '/// Read it with `context.at` (theme.dart). [light] and [dark] are the two const sets.',
  );
  lines.push('class AtColors extends ThemeExtension<AtColors> {');
  lines.push('  const AtColors({');
  for (const [n] of all) lines.push(`    required this.${n},`);
  lines.push('  });');
  lines.push('');
  for (const [n, ty] of all) lines.push(`  final ${ty} ${n};`);
  lines.push('');
  for (const app of ['light', 'dark']) {
    const set = app === 'light' ? light : dark;
    lines.push(`  static const AtColors ${app} = AtColors(`);
    for (const r of roles) lines.push(`    ${r}: ${dartColor(set[r])},`);
    for (const [n, v] of statics) lines.push(`    ${n}: ${dartColor(v)},`);
    for (const g of themedGradients)
      lines.push(`    ${gradField(g)}: ${gradLiteral(tokens.gradientThemed[g][app])},`);
    for (const n of shadowNames) lines.push(`    ${shadowField(n)}: ${shadowLiteral(app, n)},`);
    lines.push('  );');
    lines.push('');
  }
  lines.push('  @override');
  lines.push('  AtColors copyWith({');
  for (const [n, ty] of all) lines.push(`    ${ty}? ${n},`);
  lines.push('  }) {');
  lines.push('    return AtColors(');
  for (const [n] of all) lines.push(`      ${n}: ${n} ?? this.${n},`);
  lines.push('    );');
  lines.push('  }');
  lines.push('');
  lines.push('  @override');
  lines.push('  AtColors lerp(covariant ThemeExtension<AtColors>? other, double t) {');
  lines.push('    if (other is! AtColors) return this;');
  lines.push('    return AtColors(');
  for (const [n, ty] of all) {
    if (ty === 'Color') lines.push(`      ${n}: Color.lerp(${n}, other.${n}, t)!,`);
    else if (ty === 'LinearGradient')
      lines.push(`      ${n}: LinearGradient.lerp(${n}, other.${n}, t)!,`);
    else lines.push(`      ${n}: BoxShadow.lerpList(${n}, other.${n}, t)!,`);
  }
  lines.push('    );');
  lines.push('  }');
  lines.push('}');
  lines.push('');

  lines.push('/// Gradients that look the same in both appearances.');
  lines.push('abstract final class AtGradients {');
  for (const [name, g] of Object.entries(tokens.gradient))
    lines.push(`  static const LinearGradient ${name} = ${gradLiteral(g)};`);
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
  const colorVars = (set, indent) => {
    const out = [];
    for (const r of roles) out.push(`${indent}--at-color-${kebab(r)}: ${set[r]};`);
    return out;
  };
  const themedVars = (app, indent) => {
    const out = [];
    for (const g of themedGradients)
      out.push(
        `${indent}--at-gradient-${kebab(g)}: ${cssGradient(tokens.gradientThemed[g][app])};`,
      );
    for (const n of shadowNames) {
      if (app === 'dark')
        out.push(
          `${indent}--at-shadow-${kebab(n)}: 0 0 0 ${tokens.shadowDark.spread}px ${dark[tokens.shadowDark.role]};`,
        );
      else {
        const s = tokens.shadow[n];
        out.push(`${indent}--at-shadow-${kebab(n)}: ${s.x}px ${s.y}px ${s.blur}px ${s.color};`);
      }
    }
    return out;
  };

  const out = [`/* ${HEADER} */`, ':root {', '  color-scheme: light;'];
  out.push(`  --at-font-family: '${tokens.font.family}', system-ui, sans-serif;`);
  for (const [name, v] of Object.entries(tokens.brand)) out.push(`  --at-brand-${name}: ${v};`);
  out.push(...colorVars(light, '  '));
  for (const [name, v] of statics) out.push(`  --at-color-${kebab(name)}: ${v};`);
  for (const [name, g] of Object.entries(tokens.gradient))
    out.push(`  --at-gradient-${kebab(name)}: ${cssGradient(g)};`);
  out.push(...themedVars('light', '  '));
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

  const darkBody = (indent) => [
    `${indent}color-scheme: dark;`,
    ...colorVars(dark, indent),
    ...themedVars('dark', indent),
  ];
  out.push('/* Dark appearance: follows the system unless the page pins data-theme="light". */');
  out.push('@media (prefers-color-scheme: dark) {');
  out.push('  :root:not([data-theme="light"]) {', ...darkBody('    '), '  }');
  out.push('}', '');
  out.push('/* Manual override. */');
  out.push(':root[data-theme="dark"] {', ...darkBody('  '), '}', '');
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
