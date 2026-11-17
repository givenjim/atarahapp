// P1-M7 codemod: moves Dart code from the old static colour API to the theme extension.
//   AtColors.x      -> context.at.x      (renamed roles are mapped, see RENAMES)
//   AtShadows.x     -> context.at.shadowX
//   AtGradients.darkCard -> context.at.darkCardGradient
//   AtTone.pink|info|purple -> AtTone.coral|indigo|violet
//   wash.color -> wash.colorOf(context) is NOT automatic; tone.colors -> tone.colorsOf(context) is NOT automatic.
// Usage: node scripts/migrate-at-colors.mjs <file.dart|dir> ...   (rewrites in place, prints a summary)
// Afterwards run `dart analyze`: fix `const` contexts (drop `const`), places without a BuildContext
// (pass `AtColors c` or a BuildContext in), and the manual items listed above.
import { readdirSync, readFileSync, statSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';

const RENAMES = {
  pinkBg: 'coralSurface',
  pinkFg: 'coral',
  pinkStrong: 'coralStrong',
  successBg: 'successSurface',
  successFg: 'successIcon',
  warningBg: 'tangerineSurface',
  warningFg: 'tangerine',
  warningStrong: 'tangerineStrong',
  amberBg: 'amberSurface',
  amberFg: 'tangerine',
  infoBg: 'indigoSurface',
  infoFg: 'primary',
  infoStrong: 'primary',
  purpleBg: 'violetSurface',
  purpleFg: 'primary',
  purpleStrong: 'primary',
  neutralBg: 'neutralSurface',
  neutralFg: 'neutralText',
  neutralStrong: 'neutralText',
  tint1: 'primaryTint',
  tint2: 'primaryTintStrong',
  tint3: 'primaryTintFaint',
  tint4: 'primaryTintFaint',
  violet1: 'violetTint1',
  violet2: 'violetTint1',
  violet3: 'violetTint2',
};
const TONES = { pink: 'coral', info: 'indigo', purple: 'violet' };

function migrate(text) {
  let n = 0;
  const bump = (s) => (n++, s);
  let out = text
    .replace(/\bAtColors\.([a-zA-Z0-9]+)\b/g, (_, name) => {
      if (name === 'light' || name === 'dark') return `AtColors.${name}`;
      return bump(`context.at.${RENAMES[name] ?? name}`);
    })
    .replace(/\bAtShadows\.([a-zA-Z0-9]+)\b/g, (_, name) =>
      bump(`context.at.shadow${name[0].toUpperCase()}${name.slice(1)}`),
    )
    .replace(/\bAtGradients\.darkCard\b/g, () => bump('context.at.darkCardGradient'))
    .replace(/\bAtTone\.(pink|info|purple)\b/g, (_, t) => bump(`AtTone.${TONES[t]}`));
  return [out, n];
}

function* files(p) {
  const st = statSync(p);
  if (st.isDirectory()) {
    for (const f of readdirSync(p)) yield* files(join(p, f));
  } else if (p.endsWith('.dart') && !p.endsWith('.g.dart')) yield p;
}

let total = 0;
for (const arg of process.argv.slice(2)) {
  for (const f of files(arg)) {
    const [out, n] = migrate(readFileSync(f, 'utf8'));
    if (n) {
      writeFileSync(f, out);
      total += n;
      console.log(`${n}\t${f}`);
    }
  }
}
console.log(`${total} replacement(s)`);
