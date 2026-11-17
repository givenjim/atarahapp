# Atarah — Architecture

Initial version (P0-M1). Source: Master Prompt §5. Updated as modules land. **Updated for Supabase in P1-M6** (v2.3 §5.5 and §5.7): sections that say "replaced" describe what P0 built and what P1-M6 changed.

## Shape

Modular monolith. One NestJS API (`apps/backend`) plus a BullMQ worker entry point, on **Supabase** (managed PostgreSQL, Auth, Storage, Realtime) with Prisma, and Redis for cache, rate limits and queues. Clients: Flutter mobile (`apps/mobile`), Next.js public/member web (`apps/web`), Next.js admin console (`apps/admin`, talks only to `/api/v1/admin/*`).

```text
Flutter app ──┐  sign-up, OTP, sign-in, refresh, recovery, MFA
Next.js web ──┼────────────────────────────────────────────────► Supabase Auth (JWT, sessions, MFA)
Admin ────────┘                                                         │ trigger: auth.users → public.users
   │
   └─► REST /api/v1 (OpenAPI 3, Bearer = Supabase JWT) ─► NestJS modules ─┬─► Supabase Postgres (RLS deny-all; backend role bypasses)
                                                                          ├─► Supabase Storage (signed URLs issued by NestJS)
Flutter app ── Realtime: its own notifications only (RLS) ◄───────────────┤
                                                                          └─► Redis / BullMQ workers ─► email / SMS / FCM / payments / AI
```

**Who does what.** The apps talk to Supabase **only for authentication**, plus one Realtime subscription to the member's own `notifications`; every data request goes to NestJS. NestJS verifies the Supabase JWT (JWKS, issuer, audience, expiry), checks the Supabase session still exists, loads `public.users` by `sub` and applies Atarah's own authorisation (status, roles, entitlements, ownership, visibility, flags). It never reads `user_metadata` for decisions.

## Rules

- Modules own their tables and talk through exported services or domain events, never each other's tables.
- Authorisation = account status + roles + entitlements + verification + ownership + visibility + feature flags, evaluated on the backend on every request. Never a single `user.role`.
- OpenAPI is generated from the backend and is the contract for the generated Dart and TypeScript clients in `packages/api-contracts`.
- Mobile request path: Widget → Riverpod notifier → repository → generated API client → REST. Widgets never call HTTP; local cache is never the source of truth.
- Providers (email, SMS, payments, AI) sit behind interfaces; production adapters are owner decisions (Master Prompt §12).

Sections for provider interfaces, queues and storage are added in P0-M3, P0-M5 and P0-M9.

## Backend foundations (P0-M3)

```text
apps/backend/src
  config/         zod-validated env -> AppConfigService (the only place that reads process.env)
  common/         ApiException, error filter, response envelope, validation pipe, pagination, sorting, request id, logger config
  prisma/         PrismaService (+ transaction helper)
  redis/          shared ioredis client (REDIS token)
  supabase/       SupabaseJwtService (JWKS verification), SupabaseAdminService (service-role client: Auth admin API and Storage)
  storage/        StorageService on Supabase Storage (signed upload/download URLs, head/read/write/remove); ensures buckets outside production
  metrics/        GET /metrics (Prometheus text: request latency by route pattern, queue depth, process metrics)
  audit/          AuditService.record(entry, tx?) -> append-only audit_logs
  feature-flags/  FeatureFlagService (Redis-cached 30 s), PlatformSettingsService (cached 60 s), flag registry
  queues/         BullMQ: queue registry, QueueAdminService (failed-jobs view), SystemProcessor
  health/         /health/live, /health/ready (PostgreSQL, Redis, storage)
  main.ts         API entry point          worker.ts   worker entry point (no HTTP)
  configure-app.ts  the pipeline (prefix, CORS, helmet, pipes, filter, interceptor) shared by main.ts and tests
```

Queues: `system`, `notifications`, `media`, `payments`, `analytics`, `maintenance` (prefix `atarah:<env>`). Default retry policy: 5 attempts, exponential backoff from 2 s; failures are retained 14 days for the admin view. Modules add processors for the queues they own; the worker process loads them.

Local service ports (DEC-010, offset so Atarah runs beside other projects; DEC-062): Supabase API 55321, PostgreSQL 55322 (direct) and 55329 (pooler), Studio 55323, mail catcher 55324 (UI) and 55325 (SMTP), Redis 56379.

## Identity, access and messaging (P0-M5; authentication replaced by Supabase Auth in P1-M6)

```text
apps/backend/src
  access/      AccessModule (global): guards (SupabaseAuth -> Permissions -> Entitlements -> RecentAuth), decorators,
               AccessService (effective permissions, live-membership entitlements), visibility.policy
  identity/    SessionService (Active sessions = auth.sessions, through security-definer functions), SecurityService (MFA
               factors, device registry), SmsHookService (Send SMS hook, Standard Webhooks signature), UserViewService, controllers
  supabase/    JWT verification and the service-role client
  messaging/   EmailProvider / SmsProvider interfaces, dev implementations (SMTP to the mail catcher, SMS log sink), DevOutbox
  common/      RateLimitModule (Redis throttler, runs before authentication)
```

**What moved to Supabase Auth (P1-M6):** passwords and hashes, sign-up, the 6-digit codes (email and SMS), sign-in, refresh-token rotation with reuse detection, recovery, MFA (TOTP and phone) and Google OAuth. The NestJS tables `credentials`, `sessions`, `verification_codes` and `admin_totp` were dropped (dev and staging only; no production users existed, DEC-061).

**Request authentication.** `SupabaseAuthGuard`: verify the JWT, check the `auth.sessions` row still exists (so sign-out and revocation work at once, not after the 1-hour token), load `public.users` and apply the account-status rules; on `/admin/*` also require a staff role, **AAL2** (a verified MFA factor) and the 30-minute idle timeout (a Redis activity key). "Recent re-authentication" for sensitive admin actions means the TOTP factor was verified within the last 5 minutes (the `amr` claim of the token).

**Database trigger.** An `auth.users` INSERT creates `public.users` (same UUID; `PENDING_VERIFICATION`, or `ACTIVE` when already confirmed) and the consent records from the sign-up metadata; an UPDATE keeps email, phone, verification flags and first activation in step. `users.id` has a foreign key to `auth.users(id)` with `ON DELETE CASCADE`.

**Database roles.** Migrations run as `postgres` (`ATARAH_DIRECT_URL`). The app and worker connect as `atarah_backend` (BYPASSRLS, `ATARAH_DATABASE_URL`, through the transaction pooler). `anon` and `authenticated` hold no privileges on application tables; Row Level Security is on for every table and the only policy is `notifications_select_own` (Realtime). The backend has no direct grant on the `auth` schema: the few reads it needs go through `SECURITY DEFINER` functions (`atarah_auth_*`) executable only by `atarah_backend`.

**Provider interfaces** (so no feature is tied to one vendor):

| Interface                                         | Token            | Dev implementation                                                            | Production        |
| ------------------------------------------------- | ---------------- | ----------------------------------------------------------------------------- | ----------------- |
| `EmailProvider.send({ to, subject, text, html })` | `EMAIL_PROVIDER` | `SmtpEmailProvider` (local mail catcher)                                      | Owner decision #2 |
| `SmsProvider.send({ to, text })`                  | `SMS_PROVIDER`   | `LogSmsProvider` (dev only; rejected in staging/production by the env schema) | Owner decision #3 |

Modules add `@RequiresPermission`, `@RequiresEntitlement` and `@RequiresRecentAuth` to their routes; they never re-implement checks. Domain services still enforce ownership and field-level visibility with `visibility.policy`.

## Mobile app architecture (P0-M7)

Request path (never skipped): **Widget → Riverpod notifier/provider → repository → generated API client → REST.** Widgets never call HTTP and the local store is never the source of truth.

```text
lib/core
  config/        Flavor, AppConfig (API base URL, Sentry DSN; dev tools only in dev)
  storage/       TokenStore (SecureTokenStore = Android Keystore / iOS Keychain; MemoryTokenStore for tests)
  networking/    dio_factory (X-Request-Id, bearer, single-flight refresh on 401, GET retry),
                 SessionRefresher, failures (ApiFailure / NetworkFailure / UnexpectedFailure from the error envelope)
  api/generated/ Retrofit clients + models generated from packages/api-contracts/openapi.json
  auth/          AuthRepository, SessionController (AsyncNotifier<MeDto?>), SessionStatus
  routing/       Routes, computeRedirect (pure), appRouter (GoRouter + StatefulShellRoute)
  connectivity/  isOnline stream -> global AtOfflineBanner
  analytics/     AnalyticsSink interface (no-op in dev)
  design_system/ tokens.g.dart, AtTheme, At* components, dev gallery
lib/features     auth (splash, welcome, signup, verify, signin, forgot, reset, legal), profile, shell (tab shell, notices, placeholder route)
```

Session lifecycle (P1-M6: the Supabase SDK holds and refreshes the session; `supabase_flutter` is used for authentication only): launch → `/splash` (restoring the SDK session, then `GET /users/me`) → signed out: `/welcome`; signed in: remembered deep link or `/home`. A server-ended session (refresh rejected, token reuse, idle) calls `SessionController.expire()` and the router returns to welcome.

## Web and admin (P0-M8)

`apps/web` (public site, port 3100) and `apps/admin` (console, port 3200) are Next.js App Router apps that read design tokens from `@atarah/design-tokens` (CSS variables) and load Plus Jakarta Sans through `next/font/local` (self-hosted, OFL). Both call the API through the generated client in `@atarah/api-contracts` from the server only. The admin console is a backend-for-frontend (DEC-027; from P1-M6 on Supabase Auth with `@supabase/ssr`): the session stays in `httpOnly` cookies, TOTP MFA lifts it to AAL2, mutations are Server Actions, and a proxy refreshes the session. Shared admin UI kit (`components/ui`): `DataTable` with server-side `Pagination`, `StatusPill`, `ConfirmDialog` (reason capture), `ReauthDialog`, `SoonPanel`. Backend: the `admin` module (`apps/backend/src/admin`) holds the users and audit-log endpoints.

## Media and notifications (P0-M9)

```text
client ── POST /media/uploads ──▶ API ── signed PUT URL ──▶ client ── PUT bytes ──▶ Supabase Storage
client ── POST /media/{id}/complete ──▶ API ── job ──▶ [media queue] ──▶ worker: sniff, strip EXIF, variants ──▶ READY

feature module ── notify() ──▶ in-app row + jobs ──▶ [notifications queue] ──▶ worker ──▶ FCM / SMTP / SMS provider
```

`apps/backend/src/media` holds the rules (`media.rules.ts`: allow-list, limits, type sniffing), `MediaService`, the controller and `MediaProcessor`. `apps/backend/src/notifications` holds `NotificationsService` (fan-out and preferences), `NotificationDeliveryService` (per-channel delivery inside the worker), the push providers and the Atarah-branded email template. Processors are registered only in the worker process (`worker.module.ts`); the API only enqueues. Providers are swapped through the `PUSH_PROVIDER`, `EMAIL_PROVIDER` and `SMS_PROVIDER` tokens. See DEC-029 and DEC-030.

## Supabase platform (P1-M6)

Rules in force (Master Prompt 5.7): NestJS is the only data API; RLS on every table with no policies except the notifications SELECT; the anon (publishable) key may ship in apps, the service-role (secret) key and the database password exist only in the backend's secret store; Prisma owns `public`, and raw SQL for `auth`, `realtime` and `storage` lives in Prisma migrations; migrations apply through `ATARAH_DIRECT_URL` and runtime uses the pooler; local development is the Supabase CLI stack (`supabase/config.toml`, ports 553xx) plus Redis. Environments: local, then separate dev, staging and production Supabase projects created by the owner (owner decision 18; cloud checks are BLOCKED until supplied).

**Storage.** Buckets `public-media` (public), `private-media` and `verification-evidence` (private) are created by a migration, and by `config.toml` locally. Uploads use signed upload URLs from NestJS. Supabase signs them for two hours and cannot bind the type or length, so `MediaService.complete` checks the size and the validation job sniffs the real type. Storage RLS has no policies, so the anon key cannot list or write anything (tested).

## Theming and brand (P1-M7)

**Source of truth.** `packages/design-tokens/tokens.json` holds the six brand colours, a light and a dark colour set with identical role names (Master Prompt 8.1 to 8.3), gradients, shadows, radii, spacing and type. `pnpm gen:tokens` writes `tokens.g.dart` (Flutter), `dist/tokens.css` (light in `:root`; dark under `@media (prefers-color-scheme: dark)` on `:root:not([data-theme="light"])` and under `:root[data-theme="dark"]`) and `dist/tokens.ts`. `scripts/check-colors.mjs` (CI) fails if a pre-v2.3 colour appears in source.

**Flutter API.** `AtColors` is a `ThemeExtension` _instance_ with one field per colour role, the themed gradient (`darkCardGradient`) and the themed shadows (`shadowCard`, `shadowCta`, ...). `AtColors.light` and `AtColors.dark` are the two const sets. `AtTheme.light` and `AtTheme.dark` are Material 3 `ThemeData` that both carry the extension. Widgets read colours only through the context:

```dart
final c = context.at;            // AtColors for the active appearance
Container(color: c.surface, ...) // c.background, c.surface, c.raised, c.mist
Text('x', style: AtTextStyles.body.copyWith(color: c.ink))
BoxDecoration(gradient: c.darkCardGradient, boxShadow: c.shadowDarkCard)
```

- Tones and washes resolve per appearance: `tone.colorsOf(context)` returns `AtToneColors(bg, fg, strong)`; `wash.colorOf(context)`; with an `AtColors` in hand use `c.tone(tone)` and `c.wash(wash)`. Tones: `primary, violet, indigo, success, warning, coral, amber, neutral`.
- `context.at` falls back to the set matching `Theme.brightness` if a test uses a plain `ThemeData`, so it never throws.
- Appearance-independent values stay static: `AtBrand.*` (the six brand colours), `AtGradients.{cta, ctaSquare, splash, ai, pro, brandRing}`, `AtRadii`, `AtSpacing`, `AtSizes`, `AtTextStyles`, `AtMotion`. Const contexts (theme definitions, `const` constructors) use `AtColors.light.x` only for values that really are identical in both appearances, otherwise they take the colour from `context.at` at build time.
- Role guide: text `ink`, `longForm`, `body`, `muted`, `faint`; links, icons and active states `primary` (Indigo in light, light violet in dark); **fills that carry white text** (selected chip, toggle, badge, progress fill) use `primaryFill` (Indigo in both); page `background`; cards and sheets `surface`; raised `raised`; soft tiles `mist`. `white` is always white (text on gradients); never use it as a card or page background.
- Dark shadows are a 1 px ring in the card border colour (spec 8.5), so always take shadows from `context.at.shadowX`.
- Appearance state: `AtAppearance { light, dark }` (matches the backend `LIGHT | DARK`), `MaterialApp(theme: AtTheme.light, darkTheme: AtTheme.dark, themeMode: ...)`. The controller (local storage, account sync, first-frame application) lives in the app layer, not in the design system. `AtTheme.overlayStyle(brightness)` gives the status and navigation bar style; dark brand screens (splash) wrap their subtree in `AnnotatedRegion<SystemUiOverlayStyle>` with the dark style.

**Brand components** (`lib/core/design_system/components/brand.dart`, `appearance_toggle.dart`): `AtLogo` (variant `primary | noBrandLine | symbol`; style `automatic` = colour in light and reversed in dark, or `reversed | monoWhite | monoDark`; asserts the minimum widths 300, 120 and 20 in debug builds), `AtBrandRing` (self-positioning `Positioned`, put it in a clipped `Stack`), `AtProPill`, `AtAppearanceToggle(value, onChanged)`, `AtAvatar.system()`, and `AtDarkCard(ring: true)`. Logos are the pack SVGs in `assets/brand/` (metadata stripped); never redraw or recolour them.

**Gallery and goldens.** The dev gallery shows every entry in a light and a dark `GalleryPanel`; goldens exist per entry, appearance and text scale (`goldens/<id>.<light|dark>.<1x|2x>.png`).
