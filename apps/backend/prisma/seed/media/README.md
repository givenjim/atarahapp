# Placeholder pictures (development only)

Used by `../demo-media.ts` (DEC-088) to fill every picture slot of a development database: profile photos,
portfolio projects, article heroes and inline images, group covers, Skill Labs covers, opportunity provider logos,
community post photos and the link-preview image. Never ship these as real content.

| Folder       | Contents                                                        | Source and licence                                                                                     |
| ------------ | --------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| `avatars/`   | 8 demo-account portraits and a pool of 12 for other profiles    | Open Peeps by Pablo Stanley, CC0 1.0, rendered with DiceBear 9 (MIT) `open-peeps` style               |
| `portfolio/` | 2 pictures for each of 3 projects per demo creative             | Generated artwork in the Atarah palette; motifs are Lucide icons (ISC)                                 |
| `articles/`, `groups/`, `learning/`, `posts/` | Heroes, covers and post photos | Same generated artwork                                                                                 |
| `providers/` | Logos for the 8 demo providers and 4 generic marks              | Generated (initials in Plus Jakarta Sans, SIL OFL 1.1; generic marks use Lucide icons)                 |

All names are fictional demo data. `generate-placeholders.js` is the script that drew them (run outside the repo
with `@dicebear/core`, `@dicebear/collection`, `lucide-static` and Playwright installed); it is kept for reference.

Run against a database that is already seeded (for example the hosted dev project):

```
cd apps/backend
node --env-file=.env.cloud -r ts-node/register/transpile-only prisma/seed/media-cli.ts
```

or `pnpm db:seed:media` for the local stack. A fresh `pnpm db:seed` adds them for demo records automatically.
