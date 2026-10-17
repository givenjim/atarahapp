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

`pnpm bootstrap` (`scripts/bootstrap.mjs`) installs dependencies, creates the local env files from the templates, starts PostgreSQL, Redis, S3-compatible storage and Mailpit (waiting until they are healthy), generates the Prisma client, applies the migrations and seeds the reference and demo data. It stops with a clear message if Docker is not running, and it is safe to run again.

Then start what you need (each in its own terminal):

```bash
pnpm --filter @atarah/backend dev          # API on http://localhost:3000   (Swagger UI: /api/docs)
pnpm --filter @atarah/backend dev:worker   # BullMQ worker: media validation, notification delivery
pnpm --filter @atarah/admin dev            # admin console on http://localhost:3200
pnpm --filter @atarah/web dev              # public site on http://localhost:3100
```

Check the API: `curl localhost:3000/health/ready` reports `postgres`, `redis` and `storage` as `up`.

## 3. Services and ports

Host ports are offset so Atarah runs beside other local projects (DEC-010).

| Service          | Container         | Host port    | Use                                                                  |
| ---------------- | ----------------- | ------------ | -------------------------------------------------------------------- |
| PostgreSQL 16    | `atarah-postgres` | 55432        | Application database (`atarah`)                                      |
| Redis 7          | `atarah-redis`    | 56379        | Queues, rate limits, caches                                          |
| S3 (CloudServer) | `atarah-s3`       | 59000        | Object storage. MinIO is not pullable, any S3 server works (DEC-009) |
| Mailpit          | `atarah-mailpit`  | 51025, 58025 | SMTP and inbox UI at http://localhost:58025                          |

The API creates the three buckets (`public-media`, `private-media`, `verification-evidence`) on start outside production. Start and stop services with `just infra-up` / `just infra-down` (`docker compose -f infrastructure/docker-compose.yml …`).

## 4. Environment files

| App     | Template                    | Local file (git-ignored)                                                |
| ------- | --------------------------- | ----------------------------------------------------------------------- |
| backend | `apps/backend/.env.example` | `apps/backend/.env`                                                     |
| web     | `apps/web/.env.example`     | `apps/web/.env.local`                                                   |
| admin   | `apps/admin/.env.example`   | `apps/admin/.env.local`                                                 |
| mobile  | `apps/mobile/.env.example`  | `apps/mobile/env.<flavor>.json` (passed with `--dart-define-from-file`) |

`pnpm setup` copies the templates without overwriting existing files. Only `NEXT_PUBLIC_*` values reach a browser. Never commit real values; signing keys and keystores live outside the repository. The backend validates its environment at start and lists every problem at once; staging and production refuse placeholder secrets.

## 5. Demo data (development only)

`pnpm db:seed` always loads reference data (roles, permissions, plans, taxonomy, counties, settings). With `ATARAH_ENV=dev` it also loads flagged demo accounts. Shared password `Atarah-demo-1`; emails end in `@demo.atarah.test`.

| Account           | Notes                                          |
| ----------------- | ---------------------------------------------- |
| `nia@`, `kiptoo@` | Free members                                   |
| `amani@`          | Pro member (admin grant) and MENTOR            |
| `zuri@`           | SELLER                                         |
| `wanjiku@`        | Pro member (admin grant)                       |
| `moderator@`      | MODERATOR (admin console, limited permissions) |
| `admin@`          | PLATFORM_ADMIN                                 |
| `superadmin@`     | SUPER_ADMIN                                    |

Staff accounts enrol their own authenticator on first admin sign-in; no TOTP secret is seeded. Verification emails land in Mailpit; SMS codes print to the API console in dev. Demo data never appears in production and is never hard-coded in UI code.

## 6. Running each app

### Backend and worker

```bash
cd apps/backend
pnpm build && node dist/main.js     # API (or: pnpm dev)
node dist/worker.js                 # worker (or: pnpm dev:worker)
pnpm lint && pnpm typecheck
pnpm test                           # unit + integration (integration starts PostgreSQL, Redis and, for media, S3 itself)
pnpm test:unit
pnpm test:integration
pnpm db:migrate                     # create a new migration while developing (prisma migrate dev)
pnpm db:migrate:deploy              # apply existing migrations (what bootstrap and CI use)
```

Jest runs with `--experimental-vm-modules` (DEC-017). Integration tests need Docker; they never touch the local development database.

Development stand-ins, all refused in staging and production: the SMS "log" sink, the push "dev" sink and the SMTP inbox (Mailpit). Push to a phone needs a real Firebase service account in `ATARAH_FCM_SERVICE_ACCOUNT_JSON`; without it a deployed environment fails push jobs loudly instead of pretending.

### Web and admin

```bash
pnpm --filter @atarah/web test       # component tests (vitest + Testing Library)
pnpm --filter @atarah/admin test
```

First admin sign-in: open http://localhost:3200, sign in as `admin@demo.atarah.test` (password above), add the shown key to an authenticator app, enter a code, and save the recovery codes.

**Playwright flow** (admin sign-in with TOTP, suspend a member, see the audit entry, reactivate):

```bash
cd apps/admin
npx playwright install chromium     # once
pnpm build
pnpm e2e                            # needs the backend running on :3000 with the migrated dev database
```

The flow creates its own throwaway administrator and member (`apps/backend/scripts/e2e-fixtures.ts`, dev only) and deletes its fixture file afterwards.

The store buttons on the holding page stay hidden ("launching soon") until `NEXT_PUBLIC_STORE_LINKS_ENABLED=true` and a store URL is set.

### Mobile

```bash
cd apps/mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Riverpod providers + API client json
flutter gen-l10n                                           # strings from lib/core/l10n/app_en.arb

# Android emulator against the local API (the emulator reaches the host as 10.0.2.2)
flutter run --flavor dev -t lib/main_dev.dart --dart-define=ATARAH_API_BASE_URL=http://10.0.2.2:3000

flutter analyze && dart format --set-exit-if-changed lib test && flutter test

# On-device journey against the real backend (needs the demo seed)
flutter test integration_test/app_journey_test.dart --flavor dev -d emulator-5554 \
  --dart-define=ATARAH_API_BASE_URL=http://10.0.2.2:3000
```

Flavours: `dev` (`app.atarah.mobile.dev`, "Atarah Dev"), `staging` (`.staging`), `prod` (`app.atarah.mobile`, "Atarah"). Entry points `lib/main_dev.dart`, `main_staging.dart`, `main_prod.dart` (and `main.dart` = prod). Config comes from `--dart-define` / `--dart-define-from-file` (`ATARAH_API_BASE_URL`, `ATARAH_SENTRY_DSN`); see `apps/mobile/.env.example`. The `minSdk` is 26 (DEC-026). The dev flavour allows cleartext HTTP to `10.0.2.2` only (a dev-only manifest overlay).

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

## 10. Troubleshooting

| Symptom                                                                   | Cause and fix                                                                                                                                                                                                 |
| ------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `pnpm bootstrap` says Docker is not running                               | Start Docker Desktop, wait for the engine, run it again.                                                                                                                                                      |
| Port already allocated                                                    | Another project holds the port. Atarah already uses offset ports (section 3); stop the other container or change the mapping in `infrastructure/docker-compose.yml` and the matching `.env`.                  |
| `prisma generate` fails with `EPERM … query_engine-windows.dll.node`      | A running API, worker or Jest process holds the engine file (Windows). Stop them, run `pnpm --filter @atarah/backend db:generate`, start them again.                                                          |
| `pnpm install` reports "Ignored build scripts"                            | See the `allowBuilds` note in section 1.                                                                                                                                                                      |
| Integration tests hang at start                                           | Docker is slow or out of resources, and a container did not start. Stop stray `testcontainers-ryuk` containers, free resources, and run again. Running other heavy jobs in parallel causes 5 s test timeouts. |
| Jest "Cannot use import statement" or ESM errors                          | Run through `pnpm test` (it passes `--experimental-vm-modules`), not bare `jest`.                                                                                                                             |
| Admin console redirects to `/login` in a loop                             | The API is not reachable at `ATARAH_API_BASE_URL`, or the session ended (idle timeout, suspension). Check `curl localhost:3000/health/ready`.                                                                 |
| Mobile app shows "Can't reach Atarah"                                     | Wrong `ATARAH_API_BASE_URL`. On the emulator use `http://10.0.2.2:3000`, not `localhost`.                                                                                                                     |
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

| Date       | Dependency                                                                                                                                                                         | Why                                    |
| ---------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------- |
| 2026-10-17 | pnpm 12.14.0 (global)                                                                                                                                                              | Workspace package manager              |
| 2026-10-17 | just (global, winget)                                                                                                                                                              | Task runner (DEC-002)                  |
| 2026-10-17 | prettier (root dev dep)                                                                                                                                                            | Formatting                             |
| 2026-10-17 | NestJS 11 (config, swagger, throttler, bullmq), Prisma 6, ioredis, BullMQ, nestjs-pino, helmet, zod, class-validator, @aws-sdk/client-s3, argon2, jsonwebtoken, otplib, nodemailer | Backend                                |
| 2026-10-17 | jest 30, ts-jest, supertest, testcontainers (+ postgresql, redis modules)                                                                                                          | Backend tests                          |
| 2026-10-17 | Flutter packages (Riverpod 3, go_router, dio, retrofit, json_serializable, swagger_parser, flutter_secure_storage, connectivity_plus, sentry_flutter 10)                           | Mobile app (DEC-024, DEC-025, DEC-026) |
| 2026-10-17 | Next.js 16, React 19, vitest 5, Testing Library, jsdom, @playwright/test (+ Chromium), openapi-typescript, openapi-fetch, otplib (admin e2e only), server-only                     | Web and admin (DEC-027, DEC-028)       |
| 2026-10-17 | sharp, firebase-admin, @aws-sdk/s3-request-presigner                                                                                                                               | Media pipeline, FCM push (DEC-029)     |
| 2026-10-17 | gitleaks 8.30.1 (winget)                                                                                                                                                           | Secret scan (`.gitleaks.toml`)         |
