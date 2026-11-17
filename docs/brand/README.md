# Atarah brand assets

Source of truth (Master Prompt v2.3, section 8):

- `logo-pack/` (`SVG/`, `PNG/`, `App_Icons/`): the **Ascent** logo (adopted 2026-11-16, DEC-087). App copies are made from here; do not edit the pack.
- The previous ribbon logo pack and its guidelines PDF are kept for reference in `archive/2026-ribbon/`. Do not ship them.

## The Ascent logo

- Symbol: a gradient "A" (violet-to-indigo left leg, plum-to-magenta right leg) wrapped by a ribbon that runs purple, pink, orange to gold and loops behind the right leg.
- Wordmark: "Atarah" outlined from Plus Jakarta Sans ExtraBold (800), ink `#0A082A`. Brand line "CREATE · CONNECT · GROW" in Plus Jakarta Sans Bold (700), wide tracking, with magenta `#D20E8C` and orange `#FC6727` dots. The type is outlined artwork; no font file is needed.
- Lockups:
  - `atarah-logo-primary-*`: stacked (symbol over wordmark over brand line), as supplied.
  - `atarah-logo-notagline-*`: horizontal (symbol left of the wordmark), for headers.
  - `atarah-symbol-*`: the symbol alone, square.
- Variants: `color` (light surfaces), `reversed` (white type, colour symbol; dark surfaces), `mono-dark` (`#0A082A`) and `mono-white`. The one-colour symbol separates the overlaps with real gaps in the geometry, not SVG masks, so it renders in `flutter_svg`. `atarah-symbol-reversed` is identical to `atarah-symbol-color`.
- App icon: colour symbol on white (light) or `#0D0A2E` (dark). Native splash: colour symbol on Midnight `#17153F`.

## Logo usage rules (section 8.4)

- Ship the pack SVGs. **Never redraw, retype, recolour or reshape** the logo. The wordmark is outlined artwork; Montserrat is not an app font.
- Versions and minimum widths:
  - `atarah-logo-primary-{color|reversed}` (stacked, with the brand line): **200 px** or wider (the app splash uses 300 px).
  - `atarah-logo-notagline-{color|reversed}`: **120 px** or wider.
  - `atarah-symbol-{color|mono-white|mono-dark}`: **20 px** or wider.
- Clear space: the width of the left leg of the "A" on every side.
- Appearance: use the full-colour logo on light surfaces and the **reversed** logo on dark ones (dark appearance, Midnight splash). The symbol keeps its gradients in both appearances.
- Placements (as in the prototype):
  - Web header and admin sidebar: no-brand-line colour logo, about 130 px.
  - `splash`: reversed primary logo, 300 px, centred on the Midnight gradient with the brand ring.
  - `welcome`: no-brand-line colour logo, 140 px, no separate tagline text.
  - `home` header: no-brand-line colour logo, 126 px.
  - `ob_done` Passport preview: 20 px colour symbol before "CREATIVE PASSPORT".
  - `passport` card: 20 px white symbol plus "CREATIVE PASSPORT".
  - "Atarah Team" posts and other system authors: 26 px colour symbol on a Mist circle (`AtAvatar.system`).
- The old `ribbon.png` artwork is removed. The ring motif is drawn in code (`AtBrandRing`).

## Where the assets live

| Use                                | Location                                                                                          |
| ---------------------------------- | ------------------------------------------------------------------------------------------------- |
| Mobile logos (`AtLogo`)            | `apps/mobile/assets/brand/*.svg` (C2PA metadata block stripped; artwork untouched)                |
| Launcher icon, adaptive foreground | `apps/mobile/assets/launcher/` (generated into `android/` and `ios/` by `flutter_launcher_icons`) |
| Native splash                      | `apps/mobile/assets/launcher/atarah-splash-symbol.png` (`flutter_native_splash`)                  |
| Web and admin logos and favicons   | `apps/web/public/brand/`, `apps/admin/public/brand/` (SVGs and `favicon-16/32/64.png`)            |

Regenerate icons and splash: see `docs/DEVELOPMENT.md` (section 7, tokens, icons and splash).
