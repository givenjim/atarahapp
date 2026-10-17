# @atarah/design-tokens

`tokens.json` is the single source for colours, gradients, shadows, radii, spacing, type and motion.
`pnpm gen:tokens` writes:

- `apps/mobile/lib/core/design_system/tokens.g.dart` (Flutter)
- `dist/tokens.css` (CSS custom properties, `--at-*`, for web and admin)
- `dist/tokens.ts` (typed constants)

Generated files are committed. Never hard-code a colour, radius, shadow or size in a screen. Text colours are tuned for 4.5:1 contrast (DEC-021).
