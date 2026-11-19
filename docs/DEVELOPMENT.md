# Atarah — Development guide

How to set up, run, test and regenerate everything in this repository. Commands were run on the primary dev host (Windows 11); Linux and macOS use the same commands. Decisions behind the setup are in `DECISIONS.md`.

## 1. Prerequisites

| Tool           | Version seen                              | Notes                                                              |
| -------------- | ----------------------------------------- | ------------------------------------------------------------------ |
| Node.js        | 26.5.0 (target 22 LTS, see `.nvmrc`)      | `engines` requires 22 or newer                                     |
| pnpm           | 12.14.0                                   | `npm i -g pnpm`. Dependency build scripts are allow-listed (below) |
| Docker         | Docker Desktop, Compose v2                | **The daemon must be running** for local services and the tests    |
| Flutter / Dart | 3.47.0 stable                             | `C:\flutter` on the primary host                                   |
| Java           | JDK 17                                    | Android builds                                                     |
| Android SDK    | API 36 system image, AVD `Tether_Pixel_6` | `ANDROID_HOME` set; first Gradle build downloads a lot             |
| just           | `winget install Casey.Just`               | Optional. Every recipe has a `pnpm` or `node` equivalent           |
| Python         | 3.13                                      | Optional, utility scripts only                                     |

iOS builds need macOS and Xcode. They are **not** configured or verified on the Windows host (see DEC-025).

pnpm 12 blocks dependency install scripts unless they are listed under `allowBuilds` in `pnpm-workspace.yaml`. If `pnpm install` reports "Ignored build scripts", decide whether the package needs its script, then add it as `true` or `false` there.

## 2. One-command setup

```bash
git clone <repo> && cd atarah     # or unzip the repository
pnpm bootstrap                    # or: just bootstrap
```

`pnpm bootstrap` (`scripts/bootstrap.mjs`) installs dependencies, creates the local env files from the templates, starts Redis and the **local Supabase stack** (PostgreSQL, Auth, Storage, Realtime and a mail catcher, through the Supabase CLI, a dev dependency) and waits until they are healthy, writes the Supabase URL and keys into `apps/backend/.env`, `apps/web/.env.local` and `apps/admin/.env.local` (`scripts/supabase-env.mjs`, read from `supabase status`; nothing secret is committed), generates the Prisma client, applies the migrations, sets the `atarah_backend` role password, seeds reference and (dev only) demo data, and runs the Row Level Security check. Every step is safe to repeat. Docker must be running. The first start downloads the Supabase images (several minutes).

Then start what you need (each in its own terminal):

```bash
pnpm --filter @atarah/backend dev          # API on http://localhost:3000   (Swagger UI: /api/docs)
pnpm --filter @atarah/backend dev:worker   # BullMQ worker: media validation, notification delivery
pnpm --filter @atarah/admin dev            # admin console on http://localhost:3200
pnpm --filter @atarah/web dev              # public site on http://localhost:3100
```

Check the API: `curl localhost:3000/health/ready` reports `postgres`, `redis` and `storage` as `up`.

## 3. Services and ports

Host ports are offset so Atarah runs beside other local projects, including another Supabase stack on the default ports (DEC-010, DEC-062).

| Service                                              | Container                  | Host port                | Use                                                                               |
| ---------------------------------------------------- | -------------------------- | ------------------------ | --------------------------------------------------------------------------------- |
| Supabase API gateway (Auth, Storage, Realtime, REST) | `supabase_kong_atarah`     | 55321                    | `ATARAH_SUPABASE_URL`; the apps talk to it only for Auth and one Realtime channel |
| PostgreSQL 17 (Supabase)                             | `supabase_db_atarah`       | 55322                    | Direct connection (`ATARAH_DIRECT_URL`): migrations and the test setup            |
| Supavisor pooler                                     | `supabase_pooler_atarah`   | 55329                    | Runtime connection (`ATARAH_DATABASE_URL`, user `atarah_backend.pooler-dev`)      |
| Studio                                               | `supabase_studio_atarah`   | 55323                    | Browse data (never edit it there)                                                 |
| Mail catcher                                         | `supabase_inbucket_atarah` | 55324 (UI), 55325 (SMTP) | Auth codes and application email: http://127.0.0.1:55324                          |
| Redis 7                                              | `atarah-redis`             | 56379                    | Queues, rate limits, caches                                                       |

The three storage buckets (`public-media`, `private-media`, `verification-evidence`) are created by the migrations and `supabase/config.toml`. Start and stop everything with `just infra-up` / `just infra-down` (`npx supabase start|stop` plus `docker compose -f infrastructure/docker-compose.yml …`). `just supabase-env` refreshes the env values; `just check-rls` runs the RLS guard.

**Android emulator.** The emulator reaches the host API at `10.0.2.2:3000`, but signed storage URLs carry `127.0.0.1:55321`, so run `adb reverse tcp:55321 tcp:55321` (and optionally `adb reverse tcp:3000 tcp:3000`) once per emulator start.

### Hosted dev project (Supabase cloud)

`apps/backend/.env.cloud` (git-ignored) holds the hosted dev project's values (DEC-070). Apply migrations with `set -a; . ./.env.cloud; set +a; ATARAH_DATABASE_URL=$ATARAH_DIRECT_URL npx prisma migrate deploy`, set the role password with `scripts/provision-backend-role.mjs`, push Auth settings with `node scripts/push-auth-config.mjs apps/backend/.env.cloud`, and run the API with `node --env-file=.env.cloud dist/main.js`. Never run the integration tests against it (they refuse non-local databases).

## 4. Environment files

| App     | Template                    | Local file (git-ignored)                                                |
| ------- | --------------------------- | ----------------------------------------------------------------------- |
| backend | `apps/backend/.env.example` | `apps/backend/.env`                                                     |
| web     | `apps/web/.env.example`     | `apps/web/.env.local`                                                   |
| admin   | `apps/admin/.env.example`   | `apps/admin/.env.local`                                                 |
| mobile  | `apps/mobile/.env.example`  | `apps/mobile/env.<flavor>.json` (passed with `--dart-define-from-file`) |

`pnpm setup` copies the templates without overwriting existing files. Only `NEXT_PUBLIC_*` values reach a browser. Web and admin need `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` (the publishable key is printed by `npx supabase status -o json` as `PUBLISHABLE_KEY`); the service-role/secret key belongs to the backend only and must never be set in an app. Never commit real values; signing keys and keystores live outside the repository. The backend validates its environment at start and lists every problem at once; staging and production refuse placeholder secrets.

## 5. Demo data (development only)

`pnpm db:seed` always loads reference data (roles, permissions, plans, taxonomy, counties, settings). With `ATARAH_ENV=dev` it also loads flagged demo accounts, articles, community and (P1-M9) eight invented opportunity providers with twelve listings of every type. Shared password `Atarah-demo-1`; emails end in `@demo.atarah.test`.

**Placeholder pictures (DEC-088).** `pnpm db:seed` gives demo records pictures. To fill every empty picture slot of a database that is already seeded, run from `apps/backend`: `node --env-file=.env.cloud -r ts-node/register/transpile-only prisma/seed/media-cli.ts` (hosted dev) or `pnpm db:seed:media` (local). Dev databases only; safe to repeat.

**A showcase member for testers (P1-M9).** `apps/backend/scripts/seed-showcase-account.ts` creates one verified member with a finished, realistic profile (portfolio with pictures, skills, experience, achievements, services, connections, posts, tracked opportunities) by driving the real API as that member. It needs the API and worker running and the demo seed applied, and reads the account from the environment, so no credentials are committed: `SHOWCASE_EMAIL`, `SHOWCASE_PASSWORD`, `SHOWCASE_NAME`, `ATARAH_API_URL` and the three `ATARAH_SUPABASE_*` values. Run it from `apps/backend` with `node --env-file=.env.cloud -r ts-node/register/transpile-only scripts/seed-showcase-account.ts` (or your local env file). Safe to repeat.

| Account           | Notes                                          |
| ----------------- | ---------------------------------------------- |
| `nia@`, `kiptoo@` | Free members                                   |
| `amani@`          | Pro member (admin grant) and MENTOR            |
| `zuri@`           | SELLER                                         |
| `wanjiku@`        | Pro member (admin grant)                       |
| `moderator@`      | MODERATOR (admin console, limited permissions) |
| `admin@`          | PLATFORM_ADMIN                                 |
| `superadmin@`     | SUPER_ADMIN                                    |

Staff accounts enrol their own authenticator on first admin sign-in; no TOTP secret is seeded. Demo accounts are created in Supabase Auth (all with the dev password `Atarah-demo-1`). Verification and recovery emails land in the local mail catcher (http://127.0.0.1:55324); SMS codes go through the Send SMS hook and print to the API console in dev (start the API first, since Supabase calls it). Demo data never appears in production and is never hard-coded in UI code.

## 6. Running each app

### Backend and worker

```bash
cd apps/backend
pnpm build && node dist/main.js     # API (or: pnpm dev)
node dist/worker.js                 # worker (or: pnpm dev:worker)
pnpm lint && pnpm typecheck
pnpm test                           # unit + integration (integration runs against the local Supabase stack and Redis: `just infra-up` first)
pnpm test:unit
pnpm test:integration
pnpm db:migrate:deploy              # apply migrations (direct connection; what bootstrap and CI use)
pnpm db:provision                   # set the atarah_backend role password from ATARAH_BACKEND_DB_PASSWORD
pnpm db:erd                         # regenerate docs/DATABASE-ERD.md
# New migration: write the SQL by hand (or from `prisma migrate diff --script`); `prisma migrate dev` does not work
# with the auth.users foreign key (DEC-061). Enable RLS on every new table in the same migration.
```

Jest runs with `--experimental-vm-modules` (DEC-017). Integration tests need Docker and the running Supabase stack, and **they reset the local database** (all Auth users and application tables are emptied and Redis database 15 is flushed; the setup refuses a non-local database). Run `pnpm db:seed` afterwards to get the demo accounts back.

Development stand-ins, all refused in staging and production: the SMS "log" sink, the push "dev" sink and the local mail catcher. Push to a phone needs a real Firebase service account in `ATARAH_FCM_SERVICE_ACCOUNT_JSON`; without it a deployed environment fails push jobs loudly instead of pretending.

### Web and admin

```bash
pnpm --filter @atarah/web test       # component tests (vitest + Testing Library)
pnpm --filter @atarah/admin test
```

First admin sign-in: open http://localhost:3200 and sign in as `admin@demo.atarah.test` (password above). The console uses Supabase Auth with TOTP: an account without an authenticator is taken to the enrolment screen (scan the QR code or enter the key, then enter a code); afterwards each sign-in is password, then a 6-digit code. Supabase TOTP has **no recovery codes**: a lost authenticator must be reset by a super administrator (removing the factor), which the Users page does not offer yet. The session lives in httpOnly cookies set by the Next server (`@supabase/ssr`); the browser never sees a token and the Supabase client is used for Auth only, all data goes through the API. Sensitive actions (suspend, reactivate) need a code verified within the last 5 minutes; otherwise the console asks for the code again. The API signs a session out after 30 minutes idle.

**Playwright flows** (admin sign-in with TOTP, suspend a member, see the audit entry, reactivate; sign-in with an existing authenticator; taxonomy management):

```bash
cd apps/admin
npx playwright install chromium     # once
pnpm build                          # needs NEXT_PUBLIC_SUPABASE_* in apps/admin/.env.local
pnpm e2e                            # needs the local Supabase stack and the backend running on :3000
E2E_REAUTH=1 pnpm e2e e2e/admin-reauth.spec.ts   # optional, ~6 minutes: lets the 5-minute window lapse
```

The flows create their own throwaway administrator and member through the Supabase Auth admin API (`apps/backend/scripts/e2e-fixtures.ts`, dev only, using the service-role key from `apps/backend/.env`; roles are assigned with Prisma, so the database must be seeded) and delete the fixture file afterwards. Playwright loads `apps/admin/.env.local`, so the same Supabase values apply.

The store buttons on the holding page stay hidden ("launching soon") until `NEXT_PUBLIC_STORE_LINKS_ENABLED=true` and a store URL is set.

### Mobile

```bash
cd apps/mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Riverpod providers + API client json
flutter gen-l10n                                           # strings from lib/core/l10n/app_en.arb

# Android emulator against the local stack. One-time: copy .env.example to env.dev.json (git-ignored) and paste the
# publishable key from `npx supabase status -o json` (run in the repo root; `supabase start` must be running).
adb reverse tcp:55321 tcp:55321     # local Supabase (Auth + Realtime), reached as 127.0.0.1 from the emulator
adb reverse tcp:3000 tcp:3000       # optional: the API is also reachable as 10.0.2.2:3000 (the dev default)
flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env.dev.json

flutter analyze && dart format --set-exit-if-changed lib test && flutter test

# Emulator runs happen at the end of each phase, or when the owner asks (DEC-033). The onboarding journey
# (integration_test/onboarding_journey_test.dart) also needs the worker running: node apps/backend/dist/worker.js
# On-device journeys against the real backend (register, sign in, reset). Codes are read from the local mail catcher, so
# `just infra-up` must be running (override with --dart-define=ATARAH_MAILPIT_URL=...).
flutter test integration_test/auth_journeys_test.dart --flavor dev -d emulator-5554 \
  --dart-define-from-file=env.dev.json
```

Flavours: `dev` (`app.atarah.mobile.dev`, "Atarah Dev"), `staging` (`.staging`), `prod` (`app.atarah.mobile`, "Atarah"). Entry points `lib/main_dev.dart`, `main_staging.dart`, `main_prod.dart` (and `main.dart` = prod). Config comes from `--dart-define` / `--dart-define-from-file` (`ATARAH_API_BASE_URL`, `ATARAH_SUPABASE_URL`, `ATARAH_SUPABASE_PUBLISHABLE_KEY`, `ATARAH_SENTRY_DSN`); see `apps/mobile/.env.example`. The app signs in with Supabase Auth (`supabase_flutter`, Auth and the notifications Realtime channel only; every data request goes to the API) and starts only when the Supabase URL and publishable key are set. The dev URL defaults to `http://127.0.0.1:55321` through `adb reverse`, not `10.0.2.2`, because the signed storage URLs returned by the API contain `127.0.0.1:55321`; one host keeps both working. Staging and prod have no default URL. The Supabase session is kept in `flutter_secure_storage`; the verification and recovery codes arrive in Mailpit (http://127.0.0.1:55324), and the app answers Google OAuth on `atarah://auth-callback` (hidden while the `googleSignIn` flag is off). The `minSdk` is 26 (DEC-026). The dev flavour allows cleartext HTTP (a dev-only manifest overlay) for the API at `10.0.2.2` and the local Supabase at `127.0.0.1`.

**Emulator setup:** create or reuse an AVD (`Tether_Pixel_6`, API 36), then `"$ANDROID_HOME/emulator/emulator.exe" -avd Tether_Pixel_6 -no-snapshot`. Confirm with `adb devices`. The first Gradle build downloads dependencies and can take many minutes; later builds are fast.

Layout: `lib/core/{config,storage,networking,auth,routing,connectivity,analytics,design_system,l10n,app}`, `lib/features/{auth,dev,profile,shell}`, `lib/shared/widgets`.

## 7. Generating code

| What                                  | Command (repo root unless noted)                                                                                                                     |
| ------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| OpenAPI contract + TypeScript types   | `pnpm gen:api` → `packages/api-contracts/openapi.json` and `src/schema.d.ts` (commit both)                                                           |
| Dart API client                       | `pnpm gen:api`, then `cd apps/mobile && dart run swagger_parser && dart run build_runner build --delete-conflicting-outputs`                         |
| Design tokens (Dart, CSS, TypeScript) | `pnpm gen:tokens` after editing `packages/design-tokens/tokens.json`                                                                                 |
| Prisma client                         | `pnpm --filter @atarah/backend db:generate` (`pnpm install` alone does not generate it, because the schema lives in `prisma/schema`; bootstrap does) |
| Riverpod / json code                  | `dart run build_runner build --delete-conflicting-outputs` in `apps/mobile`                                                                          |

CI fails if `pnpm gen:api` changes anything, so regenerate after every API change. Generated Dart is committed: after any Dart code generation run `dart format lib test integration_test` in `apps/mobile`, because the generators do not format their output and CI checks that regenerating produces no diff.

### Tokens, icons, splash and the `context.at` migration (P1-M7)

- **Tokens:** edit `packages/design-tokens/tokens.json`, run `pnpm gen:tokens`, commit the generated `tokens.g.dart` and `dist/*`. Run `node scripts/check-colors.mjs` (also `pnpm check:colors`, `just check-colors`) to prove no old-palette colour remains.
- **Launcher icons and native splash** (config in `apps/mobile/pubspec.yaml`, sources in `apps/mobile/assets/launcher/`): `cd apps/mobile && dart run flutter_launcher_icons && dart run flutter_native_splash:create`. The adaptive foreground and the splash symbol were made from the logo pack PNGs (`atarah-symbol-color-512px.png` at 240 px on a 432 px canvas; `atarah-symbol-reversed-512px.png` on a 1152 px canvas). Android's display name comes from `resValue` in `android/app/build.gradle.kts` ("Atarah"; "Atarah Dev" and "Atarah Staging" for those flavours); iOS `CFBundleDisplayName` and `CFBundleName` are "Atarah".
- **Logos:** the source of truth is `docs/brand/logo-pack/`; the app copies are in `apps/mobile/assets/brand/` (the C2PA `<metadata>` block removed so flutter_svg does not log it) and `apps/{web,admin}/public/brand/`. Usage rules: `docs/brand/README.md`.
- **Migrating feature code from the old static API** (mechanical): `node scripts/migrate-at-colors.mjs <files or dirs>` rewrites `AtColors.x` to `context.at.x` (renamed roles mapped), `AtShadows.x` to `context.at.shadowX`, `AtGradients.darkCard` to `context.at.darkCardGradient`, and `AtTone.pink|info|purple` to `coral|indigo|violet`; then `dart analyze` and fix by hand:
  - **const contexts:** `const Foo(color: context.at.x)` is not constant. Remove `const` from the enclosing widget (the analyzer points at it).
  - **no `BuildContext`** (helpers, static fields, default parameter values): pass `BuildContext` or an `AtColors` into the helper; make a `Color color = AtColors.x` default parameter nullable (`Color? color`) and resolve `color ?? context.at.x` in `build`.
  - **`tone.colors`** becomes `tone.colorsOf(context)`; **`wash.color`** becomes `wash.colorOf(context)`; **`AtWordmark`** becomes `AtLogo` (width, not font size).
  - **Renamed roles:** `pinkBg/pinkFg/pinkStrong` -> `coralSurface/coral/coralStrong`; `successBg/successFg` -> `successSurface/successIcon`; `warningBg/warningFg/warningStrong` -> `tangerineSurface/tangerine/tangerineStrong`; `amberBg/amberFg` -> `amberSurface/tangerine`; `infoX` -> `indigoSurface/primary`; `purpleX` -> `violetSurface/primary`; `neutralBg/neutralFg/neutralStrong` -> `neutralSurface/neutralText`; `tint1/tint2/tint3/tint4` -> `primaryTint/primaryTintStrong/primaryTintFaint`; `violet1/violet2/violet3` -> `violetTint1/violetTint1/violetTint2`; `proText` is gone (the Pro pill is white on the Coral to Tangerine gradient).
  - **Judgement calls the codemod cannot make:** `AtColors.white` used as a background must become `surface` (cards, sheets, tab bars) or `background` (pages); a fill that carries white text (selected chip, toggle, badge, progress) uses `primaryFill`, not `primary`. Check each screen in light and dark in the gallery or with a golden.
  - In tests, pump with `tester.pumpAt(widget, appearance: AtAppearance.dark)` (`test/support/pump_app.dart`); after switching appearance on a mounted tree use `pumpAndSettle` because `MaterialApp` animates theme changes.

### Web and admin appearance (P1-M7)

Both apps import `@atarah/design-tokens/tokens.css`; use only the `--at-color-*` names in that file (no hex values). Dark is in the same file: it follows `prefers-color-scheme` unless `<html data-theme="light">` pins light, and `data-theme="dark"` forces dark. The public web page pins light. The admin shell has a System / Light / Dark toggle (`components/appearance-toggle.tsx`) whose choice is kept in `localStorage` and applied by an inline script in the root layout before first paint (`lib/appearance.ts`). Logos are the SVGs in `public/brand` (admin swaps colour/reversed in CSS); favicons come from `favicon-16/32/64.png` through Next metadata `icons`.

## 8. Quality gates

```bash
pnpm format:check      # prettier (pnpm format to fix)
pnpm lint              # every workspace package
pnpm typecheck
pnpm test              # backend (unit + integration), web, admin
pnpm build             # backend, web, admin
pnpm check:brand       # legacy-brand guard
gitleaks dir . --config .gitleaks.toml --no-banner --redact   # secret scan of the working tree
just test              # TypeScript tests plus flutter test
```

`.github/workflows/ci.yml` runs the same steps: brand check and secret scan; format, lint, typecheck, contract freshness, tests and builds; the admin Playwright flow against a real backend; Flutter analyze, tests and an Android debug build. The workflow has not been executed on GitHub yet; the owner pushes it.

## 9. Media and notifications (P0-M9)

- **Uploads** never pass through the API. `POST /media/uploads` returns a signed `PUT` URL (type and exact length are part of the signature); the client uploads to storage, then calls `POST /media/{id}/complete`. A worker job sniffs the real file type from the bytes, rejects anything that does not match, strips EXIF from images and writes 200/600/1200 px WebP variants. Limits: images 10 MB, video 200 MB, audio 50 MB, documents 10 MB.
- **Notifications:** feature modules call `NotificationsService.notify()`. It stores the in-app notification, then queues push and email (and SMS when asked) according to the member's preferences. Only `critical` notices ignore preferences.

## 9b. Creative CV / EPK PDFs (P2-M7)

- The worker prints the CV HTML to an A4 PDF with a headless Chromium-family browser started as a child process (`apps/backend/src/cv/pdf-renderer.ts`). Set `ATARAH_PDF_BROWSER_PATH` to its executable, or leave it empty to use the first Chrome, Edge or chromium found in a common install path. With none, a build fails with "PDF creation is not available" and nothing is stored. The production image must install Chromium.
- Share links are served by the API at `GET /{handle}/cv/{token}` (not under `/api/v1`) until the web app takes over in P3-M4. The member API is `/api/v1/me/creative-cv/...`.

## 10. Troubleshooting

| Symptom                                                                   | Cause and fix                                                                                                                                                                                                 |
| ------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `pnpm bootstrap` says Docker is not running                               | Start Docker Desktop, wait for the engine, run it again.                                                                                                                                                      |
| Port already allocated                                                    | Another project holds the port. Atarah already uses offset ports (section 3); stop the other container or change the mapping in `infrastructure/docker-compose.yml` and the matching `.env`.                  |
| `prisma generate` fails with `EPERM … query_engine-windows.dll.node`      | A running API, worker or Jest process holds the engine file (Windows). Stop them, run `pnpm --filter @atarah/backend db:generate`, start them again.                                                          |
| `pnpm install` reports "Ignored build scripts"                            | See the `allowBuilds` note in section 1.                                                                                                                                                                      |
| Integration tests hang at start                                           | Docker is slow or out of resources, and a container did not start. Stop stray `testcontainers-ryuk` containers, free resources, and run again. Running other heavy jobs in parallel causes 5 s test timeouts. |
| Jest "Cannot use import statement" or ESM errors                          | Run through `pnpm test` (it passes `--experimental-vm-modules`), not bare `jest`.                                                                                                                             |
| Admin console redirects to `/login` in a loop                             | The API is not reachable at `ATARAH_API_BASE_URL`, `NEXT_PUBLIC_SUPABASE_*` is missing in `apps/admin/.env.local`, or the session ended (idle timeout, suspension). Check `curl localhost:3000/health/ready`. |
| Mobile app shows "Can't reach Atarah"                                     | Wrong `ATARAH_API_BASE_URL` (on the emulator use `http://10.0.2.2:3000`, not `localhost`), or `adb reverse tcp:55321 tcp:55321` was not run so Supabase is unreachable.                                       |
| Android build fails on `sentry_flutter` Kotlin errors                     | Use `sentry_flutter` 10 and `minSdk` 26 (DEC-026).                                                                                                                                                            |
| First Android build takes 20+ minutes                                     | Gradle is downloading the toolchain and dependencies. Do not interrupt; later builds take about two minutes.                                                                                                  |
| Long-running process disappears in an agent shell                         | Run the API and worker in their own terminals; a backgrounded process is killed when the shell call ends.                                                                                                     |
| Next build creates `src/.next` or a stray `tsconfig.json` in `apps/*/src` | The command was run from the wrong directory. Run it from `apps/web` or `apps/admin` and delete the strays.                                                                                                   |
| `check:brand` fails                                                       | The retired working name appears outside `docs/` history notes and `design/prototype/uploads/`. Replace it with "Atarah".                                                                                     |

## 11. Naming conventions

| Thing               | Convention                                                                                             | Example                                    |
| ------------------- | ------------------------------------------------------------------------------------------------------ | ------------------------------------------ |
| Product / app name  | "Atarah" (display), `atarah` (identifiers)                                                             | Dart package `atarah`                      |
| npm packages        | `@atarah/<name>`                                                                                       | `@atarah/backend`, `@atarah/design-tokens` |
| Android / iOS ID    | `app.atarah.mobile` (+ `.dev`, `.staging` suffixes on Android flavours)                                | DEC-007                                    |
| Env vars            | `ATARAH_` prefix (`NEXT_PUBLIC_` for browser-exposed values in web)                                    | `ATARAH_DATABASE_URL`                      |
| TS files            | kebab-case; Nest suffixes `.module.ts`, `.controller.ts`, `.service.ts`, `.policy.ts`, `.dto.ts`       | `membership.service.ts`                    |
| Dart files          | snake_case; widgets/classes PascalCase; design-system classes prefixed `At`                            | `at_button.dart`, `AtButton`               |
| Riverpod providers  | `camelCase` + `Provider` (generated)                                                                   | `currentUserProvider`                      |
| Routes (mobile/web) | kebab-case paths, ids as params                                                                        | `/opportunities/:id`                       |
| REST endpoints      | plural nouns, kebab-case, under `/api/v1`; admin under `/api/v1/admin`                                 | `GET /api/v1/learning/categories/{slug}`   |
| DB tables           | snake_case plural via Prisma `@@map`; camelCase columns in Prisma                                      | `@@map("mentorship_bookings")`             |
| Enums               | PascalCase type, UPPER_SNAKE values exactly as in Master Prompt §6                                     | `BookingStatus.PENDING_PAYMENT`            |
| Domain events       | PascalCase past tense                                                                                  | `PaymentSucceeded`                         |
| Feature flags       | kebab-case                                                                                             | `google-sign-in`, `card-payments`          |
| Permissions         | `resource.action`                                                                                      | `payment.manage`                           |
| Docker services     | `atarah-<service>`                                                                                     | `atarah-postgres`                          |
| Brand strings in UI | "Atarah", "Verified by Atarah", "You're leaving Atarah"; "Luxaion" only as company / payment processor | "Secure payment processed by Luxaion"      |

The brand guard (`pnpm check:brand`) fails on the retired working name anywhere except `docs/` history notes and `design/prototype/uploads/`.

## 12. Dependencies added

| Date       | Dependency                                                                                                                                                                                                                                                                                                                                    | Why                                            |
| ---------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------- |
| 2026-10-17 | pnpm 12.14.0 (global)                                                                                                                                                                                                                                                                                                                         | Workspace package manager                      |
| 2026-10-17 | just (global, winget)                                                                                                                                                                                                                                                                                                                         | Task runner (DEC-002)                          |
| 2026-10-17 | prettier (root dev dep)                                                                                                                                                                                                                                                                                                                       | Formatting                                     |
| 2026-10-22 | `supabase` CLI (dev dependency, root), `@supabase/supabase-js`, `jose`, `prom-client` (backend); removed `argon2`, `jsonwebtoken`, `@aws-sdk/client-s3` (kept as a dev dependency for the one-off dev data migration), Testcontainers; `supabase_flutter`, `device_info_plus` (mobile); `@supabase/ssr`, `@supabase/supabase-js` (web, admin) | P1-M6 (DEC-061, DEC-068, DEC-069)              |
| 2026-10-22 | `flutter_svg` (mobile dependency); `flutter_launcher_icons`, `flutter_native_splash` (mobile dev dependencies)                                                                                                                                                                                                                                | P1-M7 brand assets, app icon and native splash |
| 2026-10-17 | NestJS 11 (config, swagger, throttler, bullmq), Prisma 6, ioredis, BullMQ, nestjs-pino, helmet, zod, class-validator, @aws-sdk/client-s3, argon2, jsonwebtoken, otplib, nodemailer                                                                                                                                                            | Backend                                        |
| 2026-10-17 | jest 30, ts-jest, supertest, testcontainers (+ postgresql, redis modules)                                                                                                                                                                                                                                                                     | Backend tests                                  |
| 2026-10-17 | Flutter packages (Riverpod 3, go_router, dio, retrofit, json_serializable, swagger_parser, flutter_secure_storage, connectivity_plus, sentry_flutter 10)                                                                                                                                                                                      | Mobile app (DEC-024, DEC-025, DEC-026)         |
| 2026-10-17 | Next.js 16, React 19, vitest 5, Testing Library, jsdom, @playwright/test (+ Chromium), openapi-typescript, openapi-fetch, otplib (admin e2e only), server-only                                                                                                                                                                                | Web and admin (DEC-027, DEC-028)               |
| 2026-10-17 | sharp, firebase-admin, @aws-sdk/s3-request-presigner                                                                                                                                                                                                                                                                                          | Media pipeline, FCM push (DEC-029)             |
| 2026-10-17 | gitleaks 8.30.1 (winget)                                                                                                                                                                                                                                                                                                                      | Secret scan (`.gitleaks.toml`)                 |

### Performance, backup and audit tools (P1-M12)

- **Volume seed and perf run** (local only, in the scratch database `atarah_perf`, never the shared dev database): `node apps/backend/scripts/perf/setup-perf-db.mjs` (copies the current schema and loads reference data; run it again after new migrations), `node apps/backend/scripts/perf/load-volume.mjs` (10,000 members, 50,000 posts, 200,000 comments, 2,000 opportunities, 500 learning items, 100,000 notifications; counts are `--members=` and so on), `node apps/backend/scripts/perf/run-perf.mjs` (starts the API against the scratch database on port 3057, creates two throw-away members in the local Auth and removes them, measures, writes `docs/PERFORMANCE.md`; `--only=feed --reads=60 --statements` for quick iteration). Needs Docker and the local stack. The scratch database is mirrored from the dev schema with `pg_dump`, so it needs no migration step of its own.
- **Backup:** `bash scripts/db-backup.sh [dir]`, `bash scripts/db-restore.sh <dump> [scratch-db]` (refuses `postgres`), `bash scripts/db-backup-test.sh [db]`. Dumps go to `backups/` (git-ignored).
- **Audits:** `scripts/check-api-coverage.ts`, `scripts/check-rate-limits.ts` (in `apps/backend`), `scripts/check-auth-config.mjs`, `scripts/check-rls.mjs`: commands in TESTING.md.
- **Parallel work:** `apps/backend/scripts/with-lock.sh int|gen <command>` serialises integration test runs (they reset the one local database) and API client generation across people or agents working at once.


## 13. Payments sandbox (P2-M1)

M-Pesa is off until it is configured and switched on. To run a real sandbox payment (needs Safaricom Daraja sandbox credentials from https://developer.safaricom.co.ke; none are in the repository, so this walkthrough has **not been run**):

1. In `apps/backend/.env` set `ATARAH_MPESA_ENV=sandbox`, `ATARAH_MPESA_CONSUMER_KEY`, `ATARAH_MPESA_CONSUMER_SECRET`, `ATARAH_MPESA_SHORTCODE` (the sandbox shortcode, usually `174379`), `ATARAH_MPESA_PASSKEY` (the sandbox passkey from the portal) and `ATARAH_MPESA_CALLBACK_TOKEN` (`openssl rand -hex 24`).
2. Safaricom must reach the callback: expose the API over https (any tunnel) and set `ATARAH_MPESA_CALLBACK_BASE_URL` to that origin. The URL it calls is `<origin>/api/v1/webhooks/payments/mpesa/<token>`. Without a tunnel the app still settles: `GET /payments/{id}` asks Safaricom for the status after a few seconds.
3. Switch the `payments-mpesa` flag on (admin console, Settings), start the API and the worker.
4. Pay: the development "sandbox check" is `POST /payments` with `{"purpose":"OTHER","method":"MPESA","phone":"<Safaricom test number>","sandboxAmountMinor":100}` and an `Idempotency-Key` header. The real purchases (membership, booking) arrive in P2-M2 and P2-M5.
5. Look at the result in the console under Payments: the event history shows the prompt, the callback, the status query that confirmed it, and the ledger row.

Tests never call Safaricom: the integration suite (`test/payments.int-spec.ts`) runs the real Daraja adapter against a mocked Safaricom. `ATARAH_MPESA_ENV=production` is refused unless `ATARAH_ENV=production`.
