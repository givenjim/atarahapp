# Atarah — Architecture

Initial version (P0-M1). Source: Master Prompt §5. Updated as modules land.

## Shape

Modular monolith. One NestJS API (`apps/backend`) plus a BullMQ worker entry point, PostgreSQL 16 (Prisma), Redis, S3-compatible storage. Clients: Flutter mobile (`apps/mobile`), Next.js public/member web (`apps/web`), Next.js admin console (`apps/admin`, talks only to `/api/v1/admin/*`).

```text
Flutter app ─┐
Next.js web ─┼─► REST /api/v1 (OpenAPI 3) ─► NestJS modules ─► PostgreSQL / Redis / Object storage
Admin ───────┘                                      └─► BullMQ workers ─► email / SMS / FCM / payments / AI
```

## Rules

- Modules own their tables and talk through exported services or domain events, never each other's tables.
- Authorisation = account status + roles + entitlements + verification + ownership + visibility + feature flags, evaluated on the backend on every request. Never a single `user.role`.
- OpenAPI is generated from the backend and is the contract for the generated Dart and TypeScript clients in `packages/api-contracts`.
- Mobile request path: Widget → Riverpod notifier → repository → generated API client → REST. Widgets never call HTTP; local cache is never the source of truth.
- Providers (email, SMS, payments, AI, auth) sit behind interfaces; production adapters are owner decisions (Master Prompt §12).

Sections for provider interfaces, queues and storage are added in P0-M3, P0-M5 and P0-M9.

## Backend foundations (P0-M3)

```text
apps/backend/src
  config/         zod-validated env -> AppConfigService (the only place that reads process.env)
  common/         ApiException, error filter, response envelope, validation pipe, pagination, sorting, request id, logger config
  prisma/         PrismaService (+ transaction helper)
  redis/          shared ioredis client (REDIS token)
  storage/        S3 abstraction (path-style, signed URLs from P0-M9); ensures buckets in non-production
  audit/          AuditService.record(entry, tx?) -> append-only audit_logs
  feature-flags/  FeatureFlagService (Redis-cached 30 s), PlatformSettingsService (cached 60 s), flag registry
  queues/         BullMQ: queue registry, QueueAdminService (failed-jobs view), SystemProcessor
  health/         /health/live, /health/ready (PostgreSQL, Redis, storage)
  main.ts         API entry point          worker.ts   worker entry point (no HTTP)
  configure-app.ts  the pipeline (prefix, CORS, helmet, pipes, filter, interceptor) shared by main.ts and tests
```

Queues: `system`, `notifications`, `media`, `payments`, `analytics`, `maintenance` (prefix `atarah:<env>`). Default retry policy: 5 attempts, exponential backoff from 2 s; failures are retained 14 days for the admin view. Modules add processors for the queues they own; the worker process loads them.

Local service ports (DEC-010): PostgreSQL 55432, Redis 56379, S3 59000, Mailpit 51025 (SMTP) / 58025 (UI).

## Identity, access and messaging (P0-M5)

```text
apps/backend/src
  access/      AccessModule (global): guards (Jwt -> Permissions -> Entitlements -> RecentAuth), decorators,
               TokenService (JWT), AccessService (effective permissions, live-membership entitlements),
               visibility.policy (canView, assertOwner, assertNotSelf)
  identity/    AuthService, AdminAuthService, CodeService, SessionService, PasswordService, UserViewService,
               GoogleAuthProvider (interface + unconfigured placeholder), controllers (auth, users, admin/auth)
  messaging/   EmailProvider / SmsProvider interfaces, dev implementations (SMTP to Mailpit, SMS log sink),
               DevOutbox (dev/test only), branded code-message templates
  common/      RateLimitModule (Redis throttler, runs before authentication)
```

**Provider interfaces** (so no feature is tied to one vendor):

| Interface                                         | Token                  | Dev implementation                                                            | Production        |
| ------------------------------------------------- | ---------------------- | ----------------------------------------------------------------------------- | ----------------- |
| `EmailProvider.send({ to, subject, text, html })` | `EMAIL_PROVIDER`       | `SmtpEmailProvider` (Mailpit)                                                 | Owner decision #2 |
| `SmsProvider.send({ to, text })`                  | `SMS_PROVIDER`         | `LogSmsProvider` (dev only; rejected in staging/production by the env schema) | Owner decision #3 |
| `GoogleAuthProvider.verifyIdToken(idToken)`       | `GOOGLE_AUTH_PROVIDER` | `UnconfiguredGoogleAuthProvider`                                              | Owner decision #4 |

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

Session lifecycle: launch → `/splash` (checking stored tokens via `GET /users/me`) → signed out: `/welcome`; signed in: remembered deep link or `/home`. A server-ended session (refresh rejected, token reuse, idle) calls `SessionController.expire()` and the router returns to welcome.

## Web and admin (P0-M8)

`apps/web` (public site, port 3100) and `apps/admin` (console, port 3200) are Next.js App Router apps that read design tokens from `@atarah/design-tokens` (CSS variables) and load Plus Jakarta Sans through `next/font/local` (self-hosted, OFL). Both call the API through the generated client in `@atarah/api-contracts` from the server only. The admin console is a backend-for-frontend (DEC-027): tokens stay in `httpOnly` cookies, mutations are Server Actions, and a proxy rotates the session. Shared admin UI kit (`components/ui`): `DataTable` with server-side `Pagination`, `StatusPill`, `ConfirmDialog` (reason capture), `ReauthDialog`, `SoonPanel`. Backend: the `admin` module (`apps/backend/src/admin`) holds the users and audit-log endpoints.

## Media and notifications (P0-M9)

```text
client ── POST /media/uploads ──▶ API ── signed PUT URL ──▶ client ── PUT bytes ──▶ S3
client ── POST /media/{id}/complete ──▶ API ── job ──▶ [media queue] ──▶ worker: sniff, strip EXIF, variants ──▶ READY

feature module ── notify() ──▶ in-app row + jobs ──▶ [notifications queue] ──▶ worker ──▶ FCM / SMTP / SMS provider
```

`apps/backend/src/media` holds the rules (`media.rules.ts`: allow-list, limits, type sniffing), `MediaService`, the controller and `MediaProcessor`. `apps/backend/src/notifications` holds `NotificationsService` (fan-out and preferences), `NotificationDeliveryService` (per-channel delivery inside the worker), the push providers and the Atarah-branded email template. Processors are registered only in the worker process (`worker.module.ts`); the API only enqueues. Providers are swapped through the `PUSH_PROVIDER`, `EMAIL_PROVIDER` and `SMS_PROVIDER` tokens. See DEC-029 and DEC-030.
