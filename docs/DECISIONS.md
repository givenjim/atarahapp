# Atarah — Decisions Log

Dated, numbered entries (Master Prompt §9.2). Format: decision, context, options, choice, reason, impact.

## DEC-001 — Start from an empty workspace; no repository assessment

- **Date:** 2026-10-17
- **Context:** P0-M1 asks for `docs/REPO_ASSESSMENT.md` only when a CREA-8 repository already exists. The working directory contained only the design zip.
- **Options:** (a) write an empty assessment; (b) skip it and say why.
- **Choice:** Skip; this entry is the record.
- **Impact:** None. No existing code to reuse or migrate.

## DEC-002 — `just` instead of `make` on the Windows host

- **Date:** 2026-10-17
- **Context:** P0-M1 asks for a root `Makefile` or `justfile`. The development machine is Windows 11 without `make`.
- **Options:** Install GNU make (via Chocolatey/Scoop), or use `just`.
- **Choice:** `justfile` (installed with `winget install Casey.Just`). Recipe names use hyphens (`db-migrate`, `gen-api`) because `just` does not allow `:` in recipe names. The `pnpm` root scripts (`pnpm db:migrate`, `pnpm gen:api`) keep the colon names from the Master Prompt.
- **Impact:** Anywhere the prompt says `make setup` read `just setup`.

## DEC-003 — Brand check implemented in Node, with a shell wrapper

- **Date:** 2026-10-17
- **Context:** §P0-M2 names `scripts/check-brand.sh`. The host is Windows PowerShell.
- **Choice:** Implementation in `scripts/check-brand.mjs` (runs everywhere); `scripts/check-brand.sh` is a two-line wrapper for Linux CI.
- **Impact:** CI calls `scripts/check-brand.sh` on Linux; developers can run `pnpm check:brand`.

## DEC-004 — Dart workspace tooling: no Melos until a second Dart package exists

- **Date:** 2026-10-17
- **Context:** P0-M1 says "Melos (or a documented script) for Dart". At P0-M1 there is exactly one Dart package (`apps/mobile`); the generated Dart API client arrives with P0-M3/P0-M7.
- **Choice:** Use documented `just` recipes that run `flutter` commands in `apps/mobile`. Revisit adding Melos when `packages/api-contracts` ships a Dart client package.
- **Impact:** None functionally.

## DEC-005 — Package manager version

- **Date:** 2026-10-17
- **Context:** `npm i -g pnpm` installed pnpm 12.14.0 on this machine (Node 26.5.0).
- **Choice:** Pin `packageManager: pnpm@12.14.0` and `engines.node >= 22` in the root `package.json`; `.nvmrc` says 22 (the LTS line the backend will target). Record any incompatibility found with Node 26 here.
- **Impact:** Contributors need pnpm 12 and Node 22 or newer.

## DEC-006 — Master Prompt stored verbatim

- **Date:** 2026-10-17
- **Choice:** `docs/MASTER_PROMPT.md` is a byte-for-byte copy of `ATARAH_MASTER_PROMPT.md` supplied by the product owner. It is excluded from Prettier and from the brand check (it names "CREA-8" as history).

## DEC-007 — Product identifiers assumed (owner decisions #1 in Master Prompt §12)

- **Date:** 2026-10-17
- **Context:** Production domain and app IDs are owner decision #1; the prompt names defaults.
- **Choice:** Domain `atarah.app`; Android `applicationId` `app.atarah.mobile` (flavours `.dev`, `.staging`); iOS bundle ID `app.atarah.mobile`; Dart package `atarah`; npm scope `@atarah`. Applied when each project is scaffolded (mobile in P0-M7).
- **Impact:** Flagged in every gate report until the owner confirms.

## DEC-008 — P0-M2 rename scope

- **Date:** 2026-10-17
- **Context:** No legacy code exists (DEC-001), so there is nothing to rename in source. The retired working name survives only in the owner-supplied specification documents under `design/prototype/uploads/` and in this log's history notes.
- **Choice:** Enforce the new name from the first file: every identifier is created as Atarah, and `scripts/check-brand.mjs` guards against regressions. P0-M2 is therefore "convention + guard", not a bulk rename.

## DEC-009 — Dev object storage: S3-compatible server instead of MinIO

- **Date:** 2026-10-17
- **Context:** §5.1 and P0-M9 name MinIO for local storage. On the dev host, `minio/minio` and `minio/mc` are not pullable from Docker Hub, and `quay.io/minio/*` returned 401 / no manifest.
- **Options:** Keep trying MinIO tags; use another S3-compatible server; skip local storage.
- **Choice:** `zenko/cloudserver` (Scality, S3-compatible) in `infrastructure/docker-compose.yml`. Bucket creation moves from a compose init container to the backend storage module (idempotent `ensureBuckets` on startup in non-production).
- **Impact:** The backend only uses the S3 API (path-style addressing, signed URLs), so MinIO or any S3 service remains a valid drop-in for staging and production. Revisit if the owner wants MinIO specifically.

## DEC-010 — Offset host ports for local services

- **Date:** 2026-10-17
- **Context:** Other local projects on the dev host (including earlier-named containers) already bind 5432 and 6379.
- **Choice:** Atarah uses PostgreSQL 55432, Redis 56379, S3 59000, Mailpit SMTP 51025 / UI 58025. Existing containers are left untouched.
- **Impact:** `.env.example` and the compose file use these ports; Testcontainers (P0-M3) picks random ports and is unaffected.

## DEC-011 — Health probes live outside `/api/v1`

- **Date:** 2026-10-17
- **Context:** P0-M3 lists `/health/live` and `/health/ready` and separately says the API is under `/api/v1`.
- **Choice:** Probes are served at `/health/live` and `/health/ready` (excluded from the global prefix, hidden from Swagger, exempt from throttling) so orchestrators and uptime checks do not depend on the API version. Responses still use the `{ data }` envelope; a failed readiness check returns 503 with an `EXTERNAL_SERVICE_ERROR` envelope whose `details.checks` names the failing dependency.

## DEC-012 — Backend lint: `consistent-type-imports` disabled for the NestJS app

- **Date:** 2026-10-17
- **Context:** The shared ESLint base enforces `import type` for type-only imports. In NestJS, constructor-injected classes are only used as types in source but are read at runtime through decorator metadata; converting them to `import type` silently breaks dependency injection.
- **Choice:** Rule stays on in the shared base (web and admin), turned off in `apps/backend/eslint.config.mjs`.

## DEC-013 — Build and tooling notes (backend)

- **Date:** 2026-10-17
- `tsconfig.build.json` sets `incremental: false`. With `deleteOutDir`, a stale `.tsbuildinfo` made `nest build` skip emitting files, producing a broken `dist/` (found when the worker failed to start).
- Prisma is pinned to 6.x and configured through `prisma.config.ts` (the `package.json#prisma` key is deprecated). Multi-file schema in `prisma/schema/`.
- pnpm 12 blocks dependency install scripts; the allow-list is `allowBuilds` in `pnpm-workspace.yaml`.
- BullMQ connection options are cast (`as unknown as ConnectionOptions`) because BullMQ bundles its own ioredis typings; the object is structurally identical.
- Integration tests stub only the S3 storage adapter (PostgreSQL and Redis are real Testcontainers). The real S3 adapter is exercised against a real S3 server in P0-M9.

## DEC-014 — Enum names that collide with entity names get a `Key` suffix

- **Date:** 2026-10-17
- **Context:** Master Prompt §6.1 names enums `Role`, `MembershipPlan` and `Entitlement`, while P0-M4 also lists entities `Role`, `MembershipPlan` and `Entitlement`. Prisma cannot have an enum and a model with the same name.
- **Choice:** Models keep the entity names; enums are `RoleKey`, `MembershipPlanKey`, `EntitlementKey`. Values are exactly the prompt's. API and UI vocabulary is unaffected.

## DEC-015 — Permissions seed: member defaults, role grants, and where `payment.manage` sits

- **Date:** 2026-10-17
- **Context:** The Roles & Permissions Matrix (specification document) and §6.1 differ: the matrix lets content admins manage opportunities and treats "Admin" as one column; §6.1 says content admins do not manage opportunities or decide verification, platform admins need a separate `payment.manage`, and members are implicit rather than a stored role. §6.1 wins (precedence order).
- **Choice:** `Permission.isMemberDefault` marks what every ACTIVE account holds without a role. Roles carry only additional capabilities. `PLATFORM_ADMIN` has `payment.view` but not `payment.manage`; `SUPER_ADMIN` holds every permission including `payment.manage`. Seeded permission keys are `resource.action`; the exact set is in `prisma/seed/data/access.ts` and is asserted by tests.
- **Impact:** A way to grant `payment.manage` to a specific non-super admin (per-user permission grants) is not modelled yet; revisit in P2-M1 when payments land and the owner confirms who handles finance.

## DEC-016 — Taxonomy seed scope

- **Date:** 2026-10-17
- **Choice:** Skills, interests and development areas are seeded exactly as the prototype lists them (general skills, `disciplineId` null); per-discipline skill lists are left to admins, as the prompt says. Towns are not seeded. County codes are Atarah-assigned three-letter identifiers (e.g. NBI, MSA, KSM, NKR) and are permanent once used in a Passport number.
- Learning and marketplace category tables, and `LegalDocument`, are created in the baseline (earlier than the milestones that use them) so the reference seed can include them as P0-M4 requires. Help-article placeholders are seeded in P1-M9 with `HelpArticle`.
- Settings values for owner decisions (#7 commission 0 %, #8 marketplace fee 0 %, #9 Pro price, #10 scholarship 6 months, #11 SLA 5 days, #15 support email) are the prompt's stated defaults and remain flagged for the owner.

## DEC-017 — Backend tests run Jest with `--experimental-vm-modules`

- **Date:** 2026-10-17
- **Context:** `otplib` v13 depends on ESM-only crypto packages. Jest's CommonJS module system cannot load them without ESM support. `ts-jest` still compiles our TypeScript to CommonJS.
- **Choice:** `pnpm test`, `test:unit` and `test:integration` invoke `node --experimental-vm-modules node_modules/jest/bin/jest.js`. Running plain `npx jest` fails on suites that import `otplib`.
- **Alternative rejected:** a hand-written TOTP implementation (more code to get wrong in a security path).

## DEC-018 — API is bearer-token only; cookies live in the Next.js servers

- **Date:** 2026-10-17
- **Context:** §5.5 says web and admin use `httpOnly`/`Secure`/`SameSite=Lax` cookies with CSRF protection.
- **Choice:** The NestJS API never sets cookies. The web and admin Next.js servers (BFF) call the API with the bearer token and keep the access and refresh tokens in `httpOnly` cookies themselves, adding CSRF protection on their own mutating routes (P0-M8). This keeps one authentication mechanism in the API for mobile, web and admin.

## DEC-019 — Auth behaviour details the prompt leaves open

- **Date:** 2026-10-17
- Sign-up returns `409 CONFLICT` with `details.reason = ACCOUNT_EXISTS` and a per-field message (the prototype shows "An account with this email already exists. Sign in instead?"). This is the one place existence is revealed; sign-in, resend, verify and forgot-password never reveal it.
- Signing in to an unverified account with the right password sends a fresh code (cooldown permitting) and returns `403 VERIFICATION_REQUIRED` (`details.reason = ACCOUNT_NOT_VERIFIED`) so the app can open the verify screen.
- Refresh tokens get a 10 second reuse grace window so a client retrying a refresh does not destroy its own session (DEC-020 describes the attack path).
- `Session.approxLocation` stays empty until a GeoIP source is chosen (P1-M9, Security screen). IP and user agent are stored.
- Admin refresh tokens live 12 hours; the 30 minute idle timeout applies on top.
- Access tokens carry a unique `jti`.
- Registration records consent against the latest `LegalDocument` version for Terms and Privacy (`0.0-draft` until the owner supplies legal text).
- `FORBIDDEN` for a suspended/deactivated account and `VERIFICATION_REQUIRED` for a pending one are returned on every authenticated route, including mid-session.

## DEC-020 — Findings from the first auth test run (fixed)

- `@ValidateNested()` accepts `undefined`, so omitting `consent` created an account without consent. Fixed with `@IsDefined()`; covered by a test.
- Access tokens issued in the same second were byte-identical. Fixed with a `jti`.

## DEC-021 — Text colours darkened to meet 4.5:1 (accessibility over exact prototype hex)

- **Date:** 2026-10-17
- **Context:** §8.1 lists the prototype's exact colours; §7.5 requires 4.5:1 contrast for body text. Several prototype text colours measure below 4.5:1 on their backgrounds (muted `#77758f` on white is 4.44; warning `#c76a10` on its tint is about 3.5; amber `#c78a10` about 2.8; info and purple about 4.1 and 3.9; the Pro pill text 4.18).
- **Choice:** Fills, borders and icon colours keep the prototype hex values. Only **text** colours change, by the smallest amount that passes: `muted` `#77758f`→`#6f6d85`; warning strong `#c76a10`→`#a95a0e`; amber strong `#c78a10`→`#97690c`; info strong `#2f6fe0`→`#2d69d5`; purple strong `#8b5cf6`→`#7c52db`; Pro text `#8a5a00`→`#805400`. Placeholder text now uses `muted` (the prototype's `faint` is 2.5:1). `faint` is used only for icons and disabled states.
- **Impact:** Visible difference is slight (a few percent darker). `contrast_test.dart` asserts every text/background pair the components use, so a future token edit that breaks contrast fails CI. Revisit with the product owner if exact prototype colours are preferred over AA compliance.

## DEC-022 — Fonts, icons and test fidelity

- **Date:** 2026-10-17
- Plus Jakarta Sans 400/500/600/700/800 (SIL OFL 1.1, from the font's official repository) is bundled in `apps/mobile/assets/fonts/` with its licence file. Icons use the `lucide_icons_flutter` package (same names as the prototype).
- Flutter tests replace all fonts with block glyphs unless real fonts are loaded, which made the first goldens meaningless. `test/flutter_test_config.dart` now loads both fonts for every test.
- Flutter's pixel-sampling `textContrastGuideline` is unreliable on anti-aliased small text with real fonts (reported 1.3:1 for dark text on white). Contrast is verified from the token pairs instead (`contrast_test.dart`). Tap-target and label guidelines still run against every gallery entry, plus a 200 % text-scale overflow check.
- Goldens use a comparator that tolerates 0.5 % differing pixels (`tolerant_golden_comparator.dart`) because text anti-aliasing differs slightly between machines. They were generated on the Windows dev host; if CI runs on Linux, regenerate them there once with `flutter test --update-goldens`.

## DEC-023 — Scope of the P0-M6 component set

- **Date:** 2026-10-17
- All 32 `At*` components in §8.2 and the 12 domain widgets (`CreativeCard` … `SavedItemRow`) are built now as **presentational** widgets: every string, number and image is a parameter; they embed no sample data and never fetch. Domain-specific view models are introduced by the feature milestones that supply the data.
- Strings that belong to components are in `lib/core/l10n/app_en.arb` (generated `AppLocalizations`). A handful of labels in domain widgets that carry data (for example the type label on a card) are passed in by the caller.
- The gallery (`ComponentGalleryScreen`) uses neutral "Sample …" placeholders and is not routed yet; it is added to the dev-flavour router in P0-M7. `lib/main.dart` temporarily opens it.
- Findings the tests forced into the components: text fields were 57px high instead of 52, prefix text could overflow at 200 % text, a segmented control's tap area was 40px, a media tile's remove button was clipped to a 36px tap area, and two cards overflowed at large text. All fixed.

## DEC-024 — Typed API contract end to end (OpenAPI → Dart client)

- **Date:** 2026-10-17
- **Context:** §7.2 makes OpenAPI the contract for generated Dart and TypeScript clients. The first export had request schema names with no properties and no response shapes, so a generated client would have been untyped.
- **Choice:** Every request and response model carries explicit `@ApiProperty` decorators (the Nest Swagger CLI plugin is not used because the export script and Jest run through ts-node, where the plugin does not apply). `ApiEnvelope(Model)` documents the `{ data, meta }` wrapper. Operation ids are plain method names, so the client reads `auth.login(...)`. The user-agent header is read by a param decorator so it is not listed as an API parameter.
- **Mobile:** `swagger_parser` (config `apps/mobile/swagger_parser.yaml`) generates Retrofit clients and `json_serializable` models into `lib/core/api/generated/`. Regenerate with `pnpm gen:api` then `dart run swagger_parser && dart run build_runner build`.

## DEC-025 — Mobile architecture choices for the shell

- **Date:** 2026-10-17
- **Router:** `go_router` with a `StatefulShellRoute.indexedStack` for the five tabs. Detail, placeholder and auth screens are top-level routes, so the tab bar hides on them (the prototype's `NO_TABS` behaviour). Redirect rules are a pure function (`computeRedirect`) with its own tests. A deep link that arrives before the session check finishes, or while signed out, is remembered in `?from=` and honoured after sign-in. Only in-app absolute paths are accepted as a destination (no open redirects).
- **Deep links:** `https://atarah.app/<path>` (verified App Links once `assetlinks.json` is published, P3-M4) and `atarah://app/<path>` (the host is fixed to `app` so the URI path maps straight onto routes).
- **Riverpod 3 retries failed providers automatically.** The session check opts out (`noAutomaticRetry`) so an offline launch shows "Can't reach Atarah" with a Try again button instead of an endless splash.
- **Token storage:** `flutter_secure_storage` (Android Keystore / iOS Keychain). The access token is short-lived; the refresh token is rotated on every use by the backend. Concurrent 401s share **one** refresh (`SessionRefresher`), otherwise parallel refreshes would replay a rotated token and the backend would end the session. A terminal reason (`TOKEN_REUSED`, `SESSION_IDLE`) ends the session without trying to refresh. Safe GETs retry twice on connection errors; writes are never retried automatically.
- **Developer sign-in** (dev flavour only) signs in to the real API with an existing account. It exists so the app shell can be reached and tested until the real sign-in screens ship in P1-M1. It is compiled out of the route table in staging and production.
- **Welcome buttons:** "Create account" and "Sign in" open their labelled Phase 1 placeholder until P1-M1 (no dead buttons).
- **Firebase:** not initialised yet. Real Firebase configs are not committed (§1) and push is wired with the notifications module (P0-M9, P1-M9). Sentry initialises only when `ATARAH_SENTRY_DSN` is provided.
- **iOS:** the bundle id is `app.atarah.mobile`. iOS flavours (schemes and xcconfig) are not configured and no iOS build was produced: this host is Windows. Reported as not verifiable here.
- **Android signing:** release builds use the debug key locally. Release keystores live outside the repository and are supplied by CI (P3-M8).
- **Staging and production API hosts** (`api.staging.atarah.app`, `api.atarah.app`) are assumptions until the owner confirms the domain (DEC-007); override with `--dart-define ATARAH_API_BASE_URL`.

## DEC-026 — Android minSdk 26 and sentry_flutter 10

- **Date:** 2026-10-17
- **Context:** `sentry_flutter` 8.x pins Kotlin language version 1.6, which the Kotlin 2.4 toolchain rejects, so the Android build failed. Version 10 builds but declares `minSdk 26`.
- **Choice:** Upgrade to `sentry_flutter ^10.1.0` and set the app `minSdk` to 26 (Android 8.0). Devices below Android 8.0 are a very small share and are not supported. Owner can revisit if a wider reach is required (it would mean dropping or swapping the crash-reporting SDK).

## DEC-027 — Admin console session handling (BFF) and navigation phases

- **Date:** 2026-10-17
- **Context:** DEC-018 puts cookies and CSRF in the Next server. P0-M8 needed the concrete design and a phase label for every unbuilt section.
- **Choice:** The admin app is a backend-for-frontend. Tokens live only in `httpOnly`, `SameSite=Lax`, `Secure` (production) cookies set by the Next server; the browser never sees a token. All mutations are Server Actions, which Next protects with an Origin check, so no separate CSRF token is needed. `src/proxy.ts` rotates an expired access token with the refresh cookie and forwards the new cookies to the page being rendered; no session means a redirect to `/login`. The password step stores the challenge token in a five-minute cookie. First-time recovery codes travel to their own page in a two-minute `httpOnly` cookie (a Server Action that sets cookies re-renders its own route, which would otherwise wipe them).
- **Sidebar:** all 18 sections of the Admin Platform spec, each tied to the permission that grants it (`apps/admin/src/lib/nav.ts`); hiding is a convenience, the backend enforces the same permission. Phases shown on unbuilt sections: Dashboard, Roles & Permissions, Content, Learning, Opportunities, Community & Reports, Notifications, Analytics, Settings = **P1** (P1-M10 and the module milestones); Memberships, Verification, Mentorship, Marketplace, Payments = **P2**; Creative Economy, AI = **P3**. Users and Audit Logs are live. The phase mapping is my reading of the milestone list, flagged for the owner to confirm.
- **Account actions:** an administrator cannot suspend or reactivate their own account; only a super admin can change a PLATFORM_ADMIN or SUPER_ADMIN account. Suspension ends every live session immediately. Both actions need recent re-authentication and are audited with before/after state and the reason.

## DEC-028 — Generated TypeScript client and e2e fixtures

- **Date:** 2026-10-17
- **Choice:** `@atarah/api-contracts` ships `src/schema.d.ts` (generated with `openapi-typescript` from `openapi.json`) and a small typed `openapi-fetch` client (`createApiClient`). `pnpm gen:api` exports the contract and regenerates the types. Web and admin import it; paths include the `/api/v1` prefix because that is how the contract names them.
- **E2E:** the Playwright flow runs against the real backend and creates a fresh administrator and member through `apps/backend/scripts/e2e-fixtures.ts` (dev only, refuses any other `ATARAH_ENV`, records flagged `isDemo`). The test enrols TOTP through the real UI and reads the secret from the page, so no secret is seeded or shared between runs. A code from the next 30-second step is used for re-authentication to avoid the replay guard.

## DEC-029 — Media pipeline rules

- **Date:** 2026-10-17
- **Context:** §5.5/§7.4 require signed uploads, MIME sniffing, size limits, EXIF stripping and private-by-default buckets.
- **Choice:** Clients upload straight to storage with a signed `PUT` whose content type and exact length are signed, then confirm. A queue job (`media`) reads the first 4 KB, identifies the real type from the bytes (JPEG, PNG, WebP, WAV, PDF, MP4/MOV/M4A, WebM, Ogg, MP3), and rejects anything that is not on the allow-list or does not match the declared type. Images are decoded and re-encoded, which removes all metadata (EXIF, GPS), with a 50-megapixel decode limit against decompression bombs, and get 200/600/1200 px WebP renditions. Other kinds are marked ready after sniffing. Rejected objects are deleted and audited as `media.reject`. Allowed types: images JPEG/PNG/WebP, video MP4/MOV/WebM, audio MP3/M4A/WAV/Ogg, documents PDF only (a CV in Word format is an owner question, not assumed). The member endpoint offers only `PUBLIC` and `PRIVATE`; the `EVIDENCE` bucket is reserved for the verification module (P2-M6). Every download is a short-lived signed URL (private 15 min, public 1 h), so a bare object key never works. The lookup answers "not found" for another member's file. A member may hold at most 50 unfinished uploads per day.
- **Not built yet:** clean-up of abandoned `PENDING_UPLOAD` rows and orphan objects; scheduled with the maintenance jobs in P3-M5.

## DEC-030 — Notification fan-out, push provider and preferences

- **Date:** 2026-10-17
- **Choice:** `NotificationsService.notify()` is the only way a module messages a member. It always stores the in-app notification, then queues delivery per channel: push when the member has push on for the category and an active device token, email when email is on and the address is verified, SMS only when the caller asks and the phone is verified. Missing preference rows mean "on". Notices marked `critical` (password changed, suspension, payment failure) ignore push and email preferences. Deep links must be in-app paths (`/...`), never URLs, to rule out open redirects; email links are built from `ATARAH_APP_LINK_BASE_URL` (assumed `https://atarah.app`, DEC-007). Delivery re-checks the member's state (suspended or deleted members get nothing) and revokes device tokens that FCM reports as invalid. Failed jobs are retried by BullMQ with exponential backoff. A member keeps at most ten active device tokens; a token that appears under another member's sign-in is reassigned, never shared.
- **Providers:** push goes through `PushProvider`. With Firebase credentials it uses FCM (`firebase-admin`); without them, development and test use a recording sink and any deployed environment fails the job loudly. **FCM delivery is not verified:** request building, batching and invalid-token handling are tested against a fake client only, because no Firebase project credentials exist yet (owner decision). Email uses the SMTP provider (Mailpit locally); the production email and SMS providers are owner decisions (§12 #2 and #3).
- **Not built yet:** notification list, mark-read and unread count (P1-M9); broadcast to audiences (P1-M9).

## DEC-031 — Secret scanning with gitleaks

- **Date:** 2026-10-17
- **Choice:** `.gitleaks.toml` extends the default ruleset and skips dependencies and build output. The gate runs `gitleaks dir . --config .gitleaks.toml` over the working tree (this workspace is not a git repository). CI downloads the pinned release binary instead of using the licensed GitHub Action. The one finding during M9 was the Playwright fixture file holding a random throwaway password; the test now deletes it on teardown.

## DEC-032 — P1-M1 entry and authentication screens

- **Date:** 2026-10-17
- **Developer sign-in removed.** The real sign-in screen replaces it, so the dev-only screen and its route are gone. The dev flavour keeps only the component gallery.
- **Onboarding entry.** A new member who verifies is sent to `/onboarding`, which is a labelled "Soon · P1" placeholder (Creative profile setup) whose back button goes Home, until P1-M2 builds the real steps. Splash routing for "signed in but onboarding incomplete" needs the profile model from P1-M2, so Phase 1 splash currently sends every signed-in member Home. Nothing else is hidden behind this.
- **Verify screen:** the Verify button is the only way to submit (no auto-submit on the sixth digit), because the milestone says the button is disabled until six digits and an accidental auto-submit would burn one of the limited attempts. The countdown is driven by the server's `resendAvailableAt`; the app never invents its own cooldown. A sign-in with the right password on an unverified account opens the verify screen, because the API has already sent a fresh code.
- **Forgot and reset:** requesting a code opens the reset screen with the "Code sent. It expires in 15 minutes." banner. A successful reset signs the member in with the new password and shows a dismissible banner at the top of the app: "Password updated. You were signed out of your other devices." (a snackbar covered the tab bar and blocked taps on a real screen).
- **Server messages are shown as the server wrote them** (wrong password, lock-out, unverified, code invalid), so the wording lives in one place. The lock-out message gets one extra line pointing at resetting the password.
- **Continue with Google:** shown only when `GET /config/public` says `googleSignIn` is on (default off; an unreachable server counts as off). The Google SDK and OAuth credentials are an owner decision (Master Prompt section 12); with the flag on but no SDK wired, the button opens a labelled "Soon · Later" screen instead of doing nothing.
- **New public endpoints:** `GET /config/public` and `GET /legal/{TERMS|PRIVACY}`. Until the owner publishes reviewed text, the seeded draft is returned with `isDraft: true` and shown under a "draft, not reviewed" banner. Legal text is never written by me.
- **Phone numbers** are normalised on the device the same way the API does it (Kenyan local formats to +254, E.164), so the form can show the right error first; the server stays the authority.
- **Artwork:** the splash ribbon and welcome collage use the design prototype's images as placeholders (`apps/mobile/assets/images`). The prototype's "1,280 creatives" counter was left out because it is sample data; a real count comes with the community features.
- **Analytics:** `user_registered`, `verification_completed` and `sign_in` are emitted through the analytics interface. The sink is still the no-op one until an analytics provider is chosen, so no event leaves the device yet.

## DEC-033 — Emulator runs at the end of each phase

- **Date:** 2026-10-17 (owner instruction, replaces "emulator at P1-M5")
- The Android emulator and on-device integration tests run **only at the end of each phase**, or when the owner asks for them in between. Anything not implemented or wrong is fixed from that pass.
- Until then every milestone is verified with `flutter analyze`, widget and golden tests, backend tests and (admin) Playwright. `integration_test` journeys are still written and analysed, but not executed. Milestone reports say "emulator not run (deferred to the end of the phase by the owner)" and never claim device evidence.
- The phase-end emulator pass becomes part of the phase gate checklist.

## DEC-034 — P1-M2 profile model, completion engine and Passport

- **Date:** 2026-10-17
- **One profile row per member** (`CreativeProfile`), created on first use with the sign-up name as display name. Skipped steps stay null; nothing is invented.
- **Discipline** is stored twice on purpose: `primaryDisciplineId` on the profile (fast joins, foreign key) and `CreativeDiscipline` (all disciplines, `isPrimary`, one primary per member by a partial unique index) for when members can add more later. Both are written in one transaction. Changing the primary discipline clears specialisations and discipline-specific skills.
- **Resume point:** `onboardingStep` (INTRO ... PHOTO, DONE) is the step to show next. Saving an earlier step again never moves it back. Skip saves nothing and still advances it.
- **Caps** (abuse guards, not product rules): 20 skills, 10 specialisations, 10 interests, 10 areas to develop. Bio 160 characters (the prototype's counter). Display name 2 to 60.
- **Completion engine** (`apps/backend/src/creative/completion.ts`, weights in `docs/DOMAIN.md`): one pure function, cached in `CreativeProfile.completionPercent` on every write. Projects and experience are counted from P1-M4; until then they are 0, so the highest reachable score today is 75%. That is honest rather than hiding the items; the next-items list tells the member what is missing.
- **Passport number** `ATR-{COUNTY CODE}-{sequence}` is issued once at completion from a per-county atomic counter (`passport_counters`, INSERT ... ON CONFLICT ... RETURNING inside the completion transaction). Concurrent completions never share a number, and a double tap on Finish wastes none (the losing transaction rolls back its increment). **A member who never set a county gets the code `GEN`** (not a county code, so it cannot collide). The number never changes, so such a member keeps `GEN` even if they add a county later. **Owner to confirm** this fallback, or to require a county.
- **Completion without a handle:** a member who skipped the basics step gets a handle made from their name (first free of `name`, `name2`, ...), so a profile link always exists once setup is finished.
- **Setup is closed once finished** (`PATCH /me/onboarding` then answers 409). Editing the profile arrives in P1-M3.

## DEC-035 — Profile links (handles)

- **Date:** 2026-10-17
- 3 to 30 lower-case letters, digits and underscores, stored in a `citext` unique column with a CHECK constraint. Input is trimmed, lower-cased and a leading `@` dropped. A reserved list (admin, atarah, support, route names ...) is refused. Uniqueness is decided by the database: two simultaneous claims give one winner and one 409 with up to three free alternatives.
- `GET /handles/{handle}/availability` needs a signed-in member and is throttled (40 per minute). A member's own handle counts as available. The app checks 400 ms after typing and ignores outdated answers; if the check cannot run (offline, throttled) typing is not blocked, because the save validates again.
- Handles are not changeable in setup after finishing; the change flow (with limits) belongs to P1-M3.

## DEC-036 — Profile photo

- **Date:** 2026-10-17
- Picker: `image_picker` (gallery or camera, bounded to 1600 px before cropping). Crop: `crop_your_image` (pure Dart, square result with a circular guide, because photos are shown in circles). Upload: the existing media pipeline (signed PUT to the PUBLIC bucket, confirm, wait for the validation and resize job, then `POST /me/avatar`). The server accepts only a READY image the member owns in the PUBLIC bucket, and replacing a photo deletes the old file.
- The app polls the media record for up to 45 seconds. If the worker is not running the upload times out with a clear message (the API alone does not process media).
- **PARTIAL until the phase-end device pass:** the picker, camera permission prompt and crop gestures have not run on a device. The cropper and picker sit behind small seams, so widget tests cover everything around them.

## DEC-037 — Location

- **Date:** 2026-10-17
- Country and county come from the database (Kenya seeded, 47 counties). "Use my current location" asks for **coarse location only**, once, on tap; the phone's own geocoder (no third party, no API key) turns it into place names, and the server matches the name to a county (`GET /locations/counties/match`: "Nairobi City County" matches Nairobi; no clear match returns null and the member chooses). Coordinates never leave the device.
- If the geocoder is missing on a device (some phones without Google services) the member sees "We couldn't get your location. Choose your county from the list." **PARTIAL until the phase-end device pass** (permission prompt and real geocoding untested).
- Town is free text for now (the `towns` table is admin-managed and empty). Visibility defaults to Members only, as in the Master Prompt, and is stored on the profile; enforcement in profile responses comes with P1-M3.

## DEC-038 — Setup routing and the profile-setup gate

- **Date:** 2026-10-17
- After sign-in (splash, welcome, verify, sign-in) a member with unfinished setup is sent to `/onboarding`, which resumes at the saved step; a finished member goes Home or to the remembered destination. While the setup state loads, the splash keeps showing. If the state cannot be loaded the member is **not** trapped: they go Home, and `/onboarding` still works from a link.
- Setup does not block other routes, so a member can leave it (Back on the first step goes Home) and return. Home will offer to finish it when P1-M5 builds Home.
- Taxonomy lists, locations and handle checks need a signed-in member; none of them are public.

## DEC-039 — Specialisation suggestions and admin taxonomy

- **Date:** 2026-10-17
- A member can have 5 pending suggestions, asking again for the same name returns the open one, and a name already in the list is refused with a pointer to it.
- Admin approve creates the specialisation (optionally under a corrected name), merge points the suggestion at an existing one of the **same discipline**, reject keeps an optional note. Decisions are atomic (two admins at once: one wins, the other gets 409), audited, and the suggester gets a PROFILE notification. If the suggester still practises that discipline, the approved or merged specialisation is also added to their profile (a small courtesy; easy to remove).
- Taxonomy admin: create, rename, archive and restore, reorder, with usage counts. Slugs never change. Archived entries leave new selections but stay on profiles that already have them. Nothing is deleted. Permission `taxonomy.manage` (CONTENT_ADMIN, PLATFORM_ADMIN, SUPER_ADMIN). The admin e2e signs in as the existing PLATFORM_ADMIN fixture, so a CONTENT_ADMIN-only login is covered by the backend integration tests but not by Playwright.
- **API naming:** controller method names become OpenAPI operation ids, which must be unique or the generated clients break. `list` and `complete` collided, so the admin list is `listTaxonomy` and onboarding completion is `completeOnboarding`.
- Swagger tag names must be plain ASCII ("Admin Taxonomy"): a "·" in a tag produced a directory name that broke the Dart generator.

## DEC-040 — Profile visibility model (P1-M3)

- **Date:** 2026-10-18
- **Always shown** on a profile that can be seen: name, photo, headline, discipline and specialisations, handle, "open to commissions", member-since. A member cannot hide their identity card (that is what makes them findable and connectable).
- **Sections with their own audience** (`ProfileSection`): bio, location, portfolio, skills, experience, services, links, contact. Defaults follow Master Prompt 6.2 (bio, portfolio, skills, services, links public; experience and location members; contact private). One row per changed section (`profile_section_visibility`); no row means the default. **Location keeps living on the profile** (`locationVisibility`, chosen in onboarding) so there is a single source of truth; the Passport reads and writes that column for the LOCATION row.
- **Viewer relations:** owner, connection, member, anonymous. The three visibility levels give connections the same view as members, with one real difference: **contact details**. A member can tick "My connections can see my contact details", which shows email and phone (as chosen by the show-email and show-phone preferences) to accepted connections even while the section is private. Nobody else ever sees a private section.
- **A profile that cannot be seen does not exist:** unknown handle, setup unfinished, suspended or deleted account all answer 404 (the owner still sees their own). Blocking arrives with the community milestone and will hide profiles the same way.
- **The connection count** is shown to signed-in members, not to anonymous visitors.
- **Owner preview** (`previewAs=PUBLIC|MEMBERS`) lets the owner see exactly what the server would send to the public or to other members. Only the owner may use it (403 otherwise).
- **Passport and "Public view" share the same server filter**, so what the owner previews is what others get; there is no second code path in the app.
- Links must be `https://`, at most 8, duplicates collapse. The handle cannot be changed here.

## DEC-041 — Connections

- **Date:** 2026-10-18
- One `connections` row per pair of members (unique index on the unordered pair, CHECK against self). Status PENDING, ACCEPTED, DECLINED, REMOVED; declining, removing and asking again reuse the row, so a pair never has two.
- Asking someone who already asked you accepts their request. Two members pressing Connect at the same moment end up connected (the unique index decides, the loser answers the winner's request).
- **Declined requests cool down for 30 days** for the requester (anti-harassment; constant `DECLINE_COOLDOWN_DAYS`, easy to move to settings). Removing a connection has no cooldown. A member can switch off "Accept connection requests" (`acceptConnections`), which disables Connect for everyone.
- Notifications (COMMUNITY): request received, request accepted. A notification failure never undoes the connection.
- Only accepted connections between active members who finished setup count and are listed. The list and incoming-requests endpoints exist now (`GET /me/connections?listState=`); the screens arrive with P1-M6.
- **Message opens "Soon · Later":** member-to-member messaging is out of scope (Master Prompt decision 14); enquiry threads come with the marketplace in P2-M3.

## DEC-042 — Growth is computed live

- **Date:** 2026-10-18
- The six growth bars (formulas in `docs/DOMAIN.md`) are computed from real data on every request. The optional `GrowthSnapshot` cache was not built: the inputs are a handful of indexed counts, so there is nothing to cache yet. Revisit if the Passport becomes slow.
- Inputs that belong to later milestones (projects, experience, achievements, services, courses, verification) are 0 until those features exist. The bars stay low rather than being hidden or invented.

## DEC-043 — Optional authentication on public reads

- **Date:** 2026-10-18
- `@OptionalAuth()` marks a route that works signed out and signed in. No token means anonymous; a token is verified exactly as everywhere else, and a bad or expired token is a **401** (so the app can refresh it) rather than silently downgrading the caller to anonymous. `@Viewer()` reads the caller. `GET /creatives/{handle}` is the first user. The anonymous web profile page is not built in this milestone.

## DEC-044 — Sharing and external links

- **Date:** 2026-10-18
- The share link is `ATARAH_APP_LINK_BASE_URL` (default `https://atarah.app`) plus the handle, pending the domain decision (DEC-007). The app shares text and link through the system share sheet (`share_plus`) and copies the link from the Passport.
- Links on a profile open through the existing "You're leaving Atarah" modal, then the browser (`url_launcher`). **The modal's body copy says Atarah "doesn't receive or process this application"**, which is written for opportunity applications and reads oddly for a profile link. Owner: please supply copy for the general case.
- Every profile has a public share link. There is no profile-level "private profile" switch in Phase 1; sections are the control.

## DEC-045 — Query parameter names that generate safe Dart enums

- **Date:** 2026-10-18
- The Dart generator names an enum after the query parameter. `state` and `preview` produced types called `State` and `Preview`, which clash with Flutter's `State`. The parameters are `listState` and `previewAs`, and the same rule applies to future endpoints (avoid `state`, `status`, `connectionState`, `key`, `size` and other Flutter names).

## DEC-046 — Profile tab next steps

- **Date:** 2026-10-18
- The profile tab's "next best step" comes from the completion engine. Bio and headline open the edit sheet; contact opens the Passport; everything else (photo, discipline, specialisation, skills, location, project, experience) opens its labelled "Soon" screen, because editing those arrives with P1-M4. The edit sheet covers exactly what the Master Prompt lists: name, headline, bio, links and contact preferences, plus "open to commissions" and "accept connection requests".

## DEC-047 — Progress file and chat summaries replace milestone reports

- **Date:** 2026-10-19
- **Decision (owner):** no `MILESTONE_REPORT_*.md` files. `docs/PROGRESS.md` (phase and milestone tracker, with a "Where we are" block, evidence, suggested commit message and notes per milestone) replaces `docs/PROJECT_PROGRESS.md`. After every milestone it is updated and a summary is given in chat. This supersedes the report and register wording in Master Prompt §9.1 and §9.3. `GATE_REPORT_P0.md` stays as the phase gate record.

## DEC-048 — Who can see a project

- **Date:** 2026-10-19
- A project is visible to a viewer only when **both** the member's Portfolio section and the project's own audience allow it, it is published, and a moderator has not hidden it. Drafts are never visible to anyone but the owner. The owner always sees their own, including hidden ones (with the reason).
- A hidden section or project answers 404, the same as one that does not exist, so a closed door cannot be told from a missing one. The profile payload still lists `lockedSections`, so the app can say "hidden" instead of trying.
- Experience and achievements share the **Experience** section's audience; there is no separate achievements section.

## DEC-049 — Project files

- **Date:** 2026-10-19
- Up to 10 files per project: images, video and audio. Documents are refused. A file must be the member's own, in the public bucket, and not refused by the validation job. A draft may hold a file that is still processing; publishing waits until every file is ready.
- Video and audio play with the platform player from signed addresses. Only YouTube and Vimeo links play inside the page (YouTube through the no-cookie host); the page cannot navigate anywhere else. Every other link goes through the "You're leaving Atarah" modal.
- Uploading a 200 MB video streams from disk, never through memory.

## DEC-050 — Collaborators

- **Date:** 2026-10-19
- Tagging a member sends them an in-app notification and the tag stays **pending** (not shown on the public project) until they accept. They can accept, decline, or take themselves off later. A person who is not on Atarah is typed in by name and shows at once.
- A member can be tagged once per project; re-tagging after removal starts a new request. Up to 10 collaborators per project.
- Finding members to tag uses a small search (`GET /members/search`). Explore (P1-M5) will bring real discovery; this stays minimal.

## DEC-051 — Services and prices

- **Date:** 2026-10-19
- Prices are stored in **minor units** (cents) and travel on the API as **whole Kenya shillings**. `FIXED` needs a price, `RANGE` a lowest and a highest at least as high, `ON_REQUEST` none. A service stays "Profile only"; "Publish to marketplace" and "View listing" open their Phase 2 screen until the marketplace exists (P2-M3).

## DEC-052 — Unset fields are left out of requests

- **Date:** 2026-10-19
- The generated models write every unset field as `null`. For a partial update that reads as "set it to nothing". The app's network layer now drops top-level `null` fields from request bodies, so the server leaves them alone. Clearing a text field is done by sending an empty string; the API documents that per field.

## DEC-053 — Drafts save as the member types

- **Date:** 2026-10-19
- Opening "Add a project" creates nothing. The draft is created on the first change (typing or a file) and then saved about a second after each change, and when the member leaves. A save that cannot reach the server says so and keeps the form. "Save draft" saves and leaves. "Help me describe this" opens its labelled Phase 3 screen.
- Sharing a project shares its title and the member's profile link, because projects have no public address yet. **Owner: confirm, or tell me the address you want for a project.**

## DEC-054 — Portfolio moderation

- **Date:** 2026-10-19
- Moderators (permission `moderation.act`) can see any **published** project, hide it with a reason of 5 to 300 characters, and restore it. Each action is audited (`portfolio.project.hide`, `.restore`, entity type `project`), the owner is notified, and profile completion is recalculated (a hidden project does not count). Drafts are not shown to moderators.
- There is no appeal flow yet: the owner is told to edit the project and contact support. **Owner: say if you want an in-app appeal.**
