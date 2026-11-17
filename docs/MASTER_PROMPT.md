---
title: 'ATARAH — MASTER PROMPT FOR CLAUDE CODE'
subtitle: 'Version 2.3 · Supabase backend platform · Brand refresh (new logo, palette and dark appearance) · Complete backend and database scope for Phase 1 · Continues from P1-M5 · Supersedes v2.0–v2.2, the CREA-8 Space Master Prompt and the CREA-8 Frontend Completion & Vertical Slice Correction Prompt'
---

# 0. How to use this document

This is the single implementation contract for building **Atarah** (formerly _CREA-8 Space_), a product of **Luxaion Creatives**. Read it fully before doing anything. Re-read the section for the active milestone before starting that milestone.

The build runs in **four phases** — **Phase 0 (Foundation)**, **Phase 1 (Core Member Experience)**, **Phase 2 (Premium, Economy & Trust)** and **Phase 3 (Intelligence, Ecosystem & Production Launch)**. Milestone numbering **restarts at M1 in every phase**. A milestone is always referred to by phase and number, for example **P0-M3**, **P1-M9**, **P2-M1**.

Within a phase you move from one milestone to the next on your own. At the **end of every phase you stop**, write the phase gate report, announce the phase by name and wait for the product owner.

## 0.1 Resuming the build (read this first — v2.3)

This is **version 2.3** of the Master Prompt. It replaces v2.0, v2.1 and v2.2 **without restarting the project**. Work completed under v2.0 stays completed.

**Where the project stands:**

| Milestones              | Status                          |
| ----------------------- | ------------------------------- |
| P0-M1 … P0-M9 (Phase 0) | COMPLETED (Phase 0 gate passed) |
| P1-M1 … P1-M5           | COMPLETED                       |
| **P1-M6 onward**        | **Start here**                  |

**What changed since v2.0:**

1. **Supabase is the backend platform.** The product owner chose **Supabase** together with the existing **NestJS** API:
   - Supabase provides the managed **PostgreSQL** database, **Auth**, **Storage** and **Realtime**.
   - NestJS remains the API and the security and business-logic boundary.
   - Prisma, Redis and BullMQ stay.
   - Sections 5 and 7 are updated, and a new milestone, **P1-M6 — Supabase platform adoption**, moves what is already built onto Supabase.
2. **New brand identity approved.** A new logo (logo pack + _Logo & Brand Identity Guidelines_ PDF) and a new six-colour brand palette (Midnight, Indigo, Violet, Coral, Tangerine, Mist) replace the old wordmark, the old violet palette and the `ribbon.png` artwork.
3. **Updated design prototype.** Every screen now uses the new logo and colours, and the prototype adds a **dark appearance** (Light / Dark toggle in Settings). It still has the same 85 screens, layouts, copy and flows. A second new milestone, **P1-M7 — Brand refresh and dark appearance**, retrofits this into everything already built.
4. **Backend and database are specified to completion for Phase 1:**
   - section **7.9** (backend and database definition of done)
   - a **"Backend & database (complete)"** block in every remaining Phase 1 milestone
   - a **backend completion audit** in the last Phase 1 milestone
   - **Appendix A**, the full Phase 1 table, endpoint and job inventory
5. **Phase 1 now has 12 milestones.** The two new milestones go first because later work depends on them. Phases 2 and 3 keep their numbering.
6. Updated sections: 3.1, 4.3, **5 (Supabase)**, 6.3, 7.3, 7.4, 7.7, **7.9 (new)**, **8 (rewritten)**, 10 (Phase 1 and P3-M8), 12, 13 and **Appendix A (new)**.

**Phase 1 milestone numbering:**

| v2.0 ID | v2.3 ID    | Milestone                                                        |
| ------- | ---------- | ---------------------------------------------------------------- |
| —       | **P1-M6**  | Supabase platform adoption (new)                                 |
| —       | **P1-M7**  | Brand refresh and dark appearance (new)                          |
| P1-M6   | **P1-M8**  | Community                                                        |
| P1-M7   | **P1-M9**  | Opportunities                                                    |
| P1-M8   | **P1-M10** | Skill Labs                                                       |
| P1-M9   | **P1-M11** | Activity, notifications, saved items, settings and system states |
| P1-M10  | **P1-M12** | Admin operations, analytics and Phase 1 hardening                |

If you already adopted v2.1 or v2.2, the brand refresh was numbered P1-M6 there. It is **P1-M7** now, and everything after it moves up by one more.

**How to resume (before writing any code):**

1. Read this document fully, then `docs/PROJECT_PROGRESS.md`, `docs/DECISIONS.md` and the code as it stands. Do **not** redo completed milestones.
2. Replace `docs/MASTER_PROMPT.md` with this version (v2.3) and update `CLAUDE.md` if it quotes anything that changed.
3. **Reconcile the register.**
   - Keep P0-M1 … P1-M5 as COMPLETED with their evidence.
   - Add P1-M6 (Supabase) and P1-M7 (Brand refresh) as NOT STARTED.
   - Renumber the later Phase 1 milestones as in the table above, keeping any partial status or notes.
   - Add a dated note: "Master Prompt v2.3 adopted — Supabase + brand refresh inserted; backend scope completed".
   - Record the change in `DECISIONS.md`.
4. If any work for a later milestone (for example Community) was already started, keep it and file it under its new ID.
5. **Backend platform report.** Before anything else, inspect the repo and write `docs/SUPABASE_ADOPTION.md`. It must state, with file references, what the code currently uses for:
   - the database (Supabase or plain PostgreSQL; how Prisma connects)
   - authentication (Supabase Auth or the NestJS Argon2/JWT implementation)
   - file storage (Supabase Storage, MinIO or S3)
   - local development services

   Then list exactly what P1-M6 must change. If the code is already on Supabase, P1-M6 becomes an alignment pass against section 5.7.

6. Run the full test suite and the existing journeys from P1-M1 … P1-M5 on the emulator to confirm a green baseline. Fix anything already broken and record it.
7. **Backend and database baseline audit.** Compare the existing schema, endpoints and jobs for Phase 0 and P1-M1 … P1-M5 with Appendix A and section 7.9. List every gap in the register under P1-M6 and close the gaps in P1-M6.
8. Start **P1-M6**, then continue through P1-M12 milestone by milestone, and stop at the Phase 1 gate.

# 1. Hard rules

These rules override everything else in this document and in every other source.

- **Never run git write commands** (`init`, `add`, `commit`, `push`, `branch`, `checkout -b`, `merge`, `rebase`, `tag`, `stash`, `remote`, `gh repo create`, `gh pr create`, or anything else that changes git state). The product owner does all version control. Read-only git commands (`status`, `diff`, `log`, `show`) are allowed. At the end of each milestone, **report the changed files instead of committing**.
- Work on **one phase at a time**, in small increments. **Stop at every phase gate** and write the gate report (section 9). When a phase ends, announce it by name, exactly in this form, followed by a short summary:
  - `PHASE 0 FOUNDATION REQUIREMENTS COMPLETE`
  - `PHASE 1 CORE MEMBER EXPERIENCE REQUIREMENTS COMPLETE`
  - `PHASE 2 PREMIUM, ECONOMY & TRUST REQUIREMENTS COMPLETE`
  - `PHASE 3 INTELLIGENCE, ECOSYSTEM & PRODUCTION LAUNCH REQUIREMENTS COMPLETE`
- **Never fabricate** opportunity listings presented as real, verification outcomes, payment confirmations, legal or policy text, licences, API or provider behaviour, test results or build success. Report only what you actually ran and observed. Seed and demo data must be clearly marked as such (section 7.6).
- **No secrets in the client or the repo.** Use `.env` files that are git-ignored, with committed `.env.example` templates. Android/iOS signing keys and keystores live **outside the repo**.
- **No dead UI.** Every tappable element does something real. Entry points to features scheduled for a later phase open **`AtFutureScreen`**, labelled **"Soon · P#"** (for example "Soon · P2"). Features beyond Phase 3 use **"Soon · Later"**. A button that does nothing, a fake success toast or a screen of hard-coded sample data counts as dead UI.
- **Ask only when blocked.** Otherwise make a reasonable assumption, record it in `docs/DECISIONS.md` and continue. **If two important sources conflict, stop and ask** (section 3 says what counts as a conflict and what is already resolved).
- The product owner has allowed you to **install any missing tool or package without asking**. Record new dependencies in `docs/DEVELOPMENT.md`.
- **Do not deploy** to any shared or production environment, publish store builds, change production infrastructure or touch production data without explicit written authorisation from the product owner.

# 2. Your role

You are the principal engineer building Atarah end to end: the database, backend, mobile app, public web app, admin console, infrastructure, tests and documentation. You are **not** the product owner. You implement the approved product faithfully. You do not silently change scope, business rules, permissions, user journeys or the visual design.

Your priorities, in order: **understand → verify → plan → implement → test → document → verify acceptance criteria → report**. Optimise for verified progress, never for the appearance of progress.

# 3. Sources of truth and precedence

## 3.1 Inputs you have been given

| Source                                                                                                                                                                                                                                            | What it governs                                                                                                           |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| **This Master Prompt (v2.0)**                                                                                                                                                                                                                     | Process, phases, milestones, stack, canonical vocabulary, rules                                                           |
| **Atarah design prototype — updated with the new brand** (`Atarah mobile app design.zip`, v2.1)                                                                                                                                                   | All mobile screens, layouts, components, visual tokens (light and dark), logo placement, microcopy, navigation and states |
| **Atarah Logo & Brand Identity Guidelines** (PDF) and the **logo pack** (SVG, PNG, app icons)                                                                                                                                                     | The logo, its versions, clear space, minimum sizes, brand colours and gradients                                           |
| **Final PRD (v1.0)**                                                                                                                                                                                                                              | Product scope, MVP boundary, premium boundary, deferred items                                                             |
| Mobile IA & Screen Spec · Mobile Functional Requirements · User Roles & Permissions Matrix · Domain & Data Model · API & Backend Requirements · Technical Architecture · UX/UI Specification · Admin Platform Specification · Development Backlog | Detailed behaviour, rules, entities, permissions, admin operations                                                        |
| PRD Notes, PRD Notes Responses, Product Expansion Strategic Options, Luxaion Concept Note                                                                                                                                                         | Background and founder decisions                                                                                          |

All of the documents above still say "CREA-8". Read every occurrence as **Atarah**.

## 3.2 Order of precedence

When sources disagree, follow the higher one:

1. The hard rules (section 1).
2. This Master Prompt, including the canonical vocabulary in section 6.
3. The Atarah design prototype — for anything visible to the user (layout, copy, labels, states, flow order).
4. The Final PRD — for scope.
5. The remaining specifications, in this order: Roles & Permissions, Domain & Data Model, API & Backend, Technical Architecture, Functional Requirements, Admin Platform, UX/UI, Mobile IA, Backlog.

## 3.3 What counts as a conflict that requires you to stop

Stop and ask only when **both** are true:

- two of the important sources above disagree, **and** the precedence order or section 6 does not settle it; and
- the disagreement affects money, security, privacy, legal exposure, permissions or committed scope.

Everything else: choose the option most consistent with the design prototype and this document, record it in `docs/DECISIONS.md`, and continue.

## 3.4 Known differences already resolved

The specification documents disagree with each other on role names, status values, membership tiers and module names. **Section 6 is the resolution.** Do not reopen these questions. If you find a new difference that section 6 does not cover, apply section 3.3.

# 4. The product

## 4.1 What Atarah is

Atarah is a **Creative Operating Layer**: the infrastructure around a creative person's career. It connects **identity, skills, learning, community, opportunities, mentorship, marketplace and professional growth** into one continuous journey for Kenyan creatives first, and is built to expand to East Africa and beyond.

Tagline: **Create · Connect · Grow.**

Product loop: **Discover → Identify → Learn → Connect → Collaborate → Opportunity → Earn → Grow → Thrive → Give back.**

UX north star: **One creative identity, many connected possibilities.** The same profile, skills, disciplines, projects and location power learning, discovery, opportunities, mentorship, the marketplace and AI help. Never make a user re-enter what Atarah already knows.

Atarah must never collapse into a generic social network, job board, course platform, marketplace, portfolio site or chatbot. Its value is the connection between those parts.

## 4.2 Confirmed product decisions

- **Six MVP pillars:** Identity, Community, Learning, Opportunities, Marketplace foundation, Administration.
- **Premium (Atarah Pro):** Mentorship booking, Verified Creative, Skill Verification, reduced marketplace fees. Premium is enforced by the backend, never by hiding UI alone.
- **Mentorship** is premium. Payments are processed through Luxaion's payment infrastructure (M-Pesa and card).
- **Opportunities** are mainly external references at first: Discover → Classify → Verify → Present → link out. Atarah never pretends to process an external application.
- **Learning** uses a hybrid content model: Atarah-owned content, permitted embedded content (e.g. YouTube) and external references. Do not build a large self-hosted video library.
- **AI** is an intelligence layer inside existing screens, not a standalone chatbot.
- **Public web** is the acquisition layer; the mobile app and member web are the retention layer.
- **Deferred beyond Phase 3** (use "Soon · Later" if an entry point is ever needed): advanced marketplace transactions (checkout, escrow, payouts, disputes), Gig Board, corporate procurement, project rooms and AI collaboration matching, Wellness Zone, physical hubs, equipment and studio booking, institutional programme management, international expansion infrastructure, the Creative Business Toolkit and Work Governance.

## 4.3 The design prototype

The prototype contains **85 screens** in 12 groups. It is the **visual and behavioural source of truth** for the mobile app.

| Group (prototype file)               | Screens                                                                                                                  |
| ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------ |
| Entry (`AtarahEntry`)                | splash, welcome, signup, signin, verify, forgot, reset                                                                   |
| Onboarding (`AtarahEntry`)           | ob_intro, ob_disc, ob_spec, ob_skills, ob_loc, ob_basics, ob_photo, ob_done                                              |
| Home & Explore (`AtarahDiscover`)    | home, explore, search, filters, economy, county, article                                                                 |
| Community (`AtarahCommunity`)        | community, post, compose, groups, group, creatives, creative                                                             |
| Opportunities (`AtarahOpps`)         | opps, opp_list, opp, opp_ai, opp_leave, opp_saved                                                                        |
| Learning (`AtarahLearn`)             | labs, lab_cat, course, lesson, my_learning                                                                               |
| Marketplace (`AtarahMarket`)         | market, market_browse, listing, seller, listing_new, my_listings                                                         |
| Mentorship (`AtarahMentor`)          | mentorship, mentors, mentor, book, pay_summary, pay, pay_done, my_mentorship, mentor_tools                               |
| Creative identity (`AtarahIdentity`) | profile, passport, portfolio, project, project_new, skills, experience, achievements, services, cv, verification, ai_bio |
| Activity (`AtarahAccount`)           | activity, notifications, saved, applications                                                                             |
| Settings (`AtarahAccount`)           | settings, membership, account, privacy, notif_settings, security, help, legal, delete                                    |
| System states (`AtarahAccount`)      | st_loading, st_empty, st_error, st_offline, st_premium                                                                   |

How to use the prototype:

- In P0-M1, copy the unzipped prototype into `design/prototype/` (read-only reference; never ship it). The router file `Atarah Mobile App.dc.html` lists every screen with a one-line purpose. Each `Atarah*.dc.html` file holds the markup for its screens plus a `<script type="text/x-dc">` block with sample data that shows the **data shape** each screen needs.
- `support.js` is the prototype's runtime and `icons.js` renders Lucide icons; neither is app code. `theme-dark.js` is a mock-up colour remap for the dark appearance — use its colour map as reference only (section 8.3); do not port it.
- `assets/logo/` holds the logo files used by the prototype. They are identical to the logo pack; always take production assets from the logo pack in `docs/brand/`.
- **Ignore the `_ds/modernist-…` folder.** It is an unused design-system bundle (red, square corners, Archivo font) and contradicts the actual design. The real tokens are the inline styles in the screen files and are listed in section 8.
- The prototype's "Viewer" switches (appearance light/dark; membership free/premium; roles creative, mentor, seller; offline) show the **appearance, premium, role and offline variants** every screen must support.
- Sample people (Nia Wairimu, Amani Otieno, Zuri Mwangi, Kiptoo Langat, Wanjiku Njeri) and organisations are **illustrative**. They may appear only in clearly labelled demo seed data, never as hard-coded UI.
- Where the prototype leaves a control unwired (for example Share, Save draft, Add to calendar, Join call, Download PDF, Reply), you still implement the obvious real behaviour. Section 10 states it for each milestone.

## 4.4 Primary mobile navigation

Five bottom tabs, exactly as in the prototype: **Home · Explore · Community · Opportunities · Profile** (Lucide `house`, `compass`, `users`, `briefcase`, `user`). Skill Labs, Marketplace, Mentorship, Articles and Creative Economy are reached from Home and Explore and highlight the **Explore** tab. Identity, Activity and Settings highlight **Profile**. Detail, creation, payment and settings sub-screens hide the tab bar — follow the prototype router's `NO_TABS` list.

# 5. Technology stack and architecture (locked)

Do not change any of these without written approval from the product owner.

## 5.1 Stack

| Layer                    | Technology                                                                                                                                                                                                                                                                                                           |
| ------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Mobile                   | **Flutter** (stable channel) + **Dart**, **Riverpod** (with code generation) for state, **go_router** for navigation, **dio** for HTTP, **freezed** + **json_serializable** for models. Android first; iOS must build and must not be blocked. No React Native. No Flutter Web for the website or admin.             |
| Public / member web      | **Next.js** (App Router) + **TypeScript** + React.                                                                                                                                                                                                                                                                   |
| Admin console            | A **separate** Next.js + TypeScript app that talks only to `/api/v1/admin/*`.                                                                                                                                                                                                                                        |
| Backend                  | **NestJS** + **TypeScript**, a **modular monolith**, running on top of Supabase (section 5.7). NestJS is the only data API. No microservices.                                                                                                                                                                        |
| API                      | **REST** + **OpenAPI 3**, versioned under **`/api/v1`**. OpenAPI is the contract shared by the Dart and TypeScript clients.                                                                                                                                                                                          |
| Database                 | **Supabase PostgreSQL** (managed; local via the Supabase CLI) with **Prisma** as ORM and migration tool. Prisma connects through the Supabase connection pooler at runtime and directly for migrations. Extensions: `pg_trgm`, `unaccent`, `citext`. Row Level Security is **enabled on every table** (section 5.7). |
| Auth                     | **Supabase Auth**: email + password, phone OTP, email OTP verification, password recovery by code, Google OAuth (flagged), MFA (phone and TOTP). NestJS verifies Supabase-issued JWTs and owns roles, permissions and account status.                                                                                |
| Cache, rate limits, jobs | **Redis** + **BullMQ**.                                                                                                                                                                                                                                                                                              |
| Files                    | **Supabase Storage** behind the existing storage abstraction, with signed upload and download URLs issued by NestJS. Buckets: `public-media`, `private-media`, `verification-evidence`.                                                                                                                              |
| Realtime                 | **Supabase Realtime** for live in-app notification updates only (section 5.7).                                                                                                                                                                                                                                       |
| Push / messages          | **Firebase Cloud Messaging** for push; in-app notifications in the database; **email** and **SMS** behind provider abstractions.                                                                                                                                                                                     |
| Payments                 | A **payment-provider abstraction**. First adapter: **M-Pesa (Safaricom Daraja STK Push)**. Card adapter behind the same interface; the card provider is an owner decision (section 12).                                                                                                                              |
| AI                       | An **AI-provider abstraction**. No feature is tied to one model vendor.                                                                                                                                                                                                                                              |
| Search                   | PostgreSQL full-text search with `pg_trgm`. No separate search engine.                                                                                                                                                                                                                                               |
| Observability            | Structured JSON logs (pino), request IDs, Sentry (or equivalent) for mobile, web, admin and backend, Prometheus-style metrics endpoint.                                                                                                                                                                              |
| Testing                  | Flutter unit, widget, golden and integration tests; Jest + Supertest against the local Supabase stack and Redis for the backend; Vitest/Jest + Testing Library and Playwright for web and admin; k6 for load tests.                                                                                                  |

## 5.2 Repository layout

```text
atarah/
  apps/
    mobile/        Flutter app (package name: atarah)
    web/           Next.js public + member web
    admin/         Next.js admin console
    backend/       NestJS API + workers
  packages/
    api-contracts/ OpenAPI spec (generated from the backend) + generated Dart and TS clients
    design-tokens/ tokens.json (single source) + generators for Dart and CSS
    shared-config/ ESLint, Prettier, tsconfig bases
  supabase/        Supabase CLI config.toml, Auth email templates, seed hooks (no secrets)
  infrastructure/  docker-compose (Redis) for local services, IaC for staging/production (P3)
  design/
    prototype/     the Claude Design prototype (reference only)
  docs/
```

## 5.3 Backend modules

One NestJS module per domain. Each module owns its entities, DTOs, validation, authorisation policies, services, controllers, events and tests. Modules talk to each other through exported services or domain events, never through each other's tables.

`identity` (auth, accounts, sessions) · `access` (roles, permissions, policies) · `membership` (plans, subscriptions, entitlements, scholarships) · `creative` (profiles, passport, disciplines, skills, experience, achievements, services) · `portfolio` (projects, media links, documents/CV) · `community` (posts, comments, reactions, groups, connections, blocks, mutes) · `learning` (content, courses, lessons, enrolments, progress) · `opportunities` (opportunities, providers, verification, tracking) · `marketplace` (sellers, listings, enquiries) · `mentorship` (mentors, session types, availability, bookings, feedback) · `verification` (creative, skill, mentor, seller and provider verification cases) · `content` (articles, help articles, legal documents, categories) · `creative-economy` (counties, organisations, ecosystem stats, rising talent) · `search` · `saved` · `notifications` · `payments` · `intelligence` (AI) · `media` · `moderation` (reports, moderation actions, appeals) · `admin` (dashboards, settings, feature flags) · `audit` · `analytics` · `shared`.

## 5.4 Flutter app structure

```text
lib/
  core/     config, flavors, networking, auth, routing, storage, offline, errors,
            analytics, notifications, design_system, l10n
  features/ auth, onboarding, home, explore, search, creative_economy, articles,
            community, opportunities, learning, marketplace, mentorship,
            identity, activity, settings, membership, payments, verification, ai
  shared/   widgets, models, utils, extensions
```

Request path: **Widget → Riverpod provider/notifier → repository → generated API client → REST**. Widgets never call HTTP directly. The local cache is never the source of truth.

Flavours: `dev`, `staging`, `prod`, each with its own API base URL and Firebase config. Android `applicationId` **`app.atarah.mobile`** (with `.dev` and `.staging` suffixes) unless the product owner names another — record it in `DECISIONS.md`.

## 5.5 Authentication and sessions (Supabase Auth)

- **Supabase Auth is the identity provider.** The mobile app uses `supabase_flutter` **only for authentication**: sign-up, sign-in, OTP verification, password recovery, Google OAuth, MFA, and session refresh. Every data request goes to the NestJS API. Web and admin use `@supabase/ssr` with httpOnly cookies.
- **Passwords:** minimum 8 characters including a number (the prototype's strength rule: "Strong — 8+ characters with a number"). Enforce it in the app and in the Supabase Auth password policy. Supabase hashes and stores passwords; Atarah never handles password hashes.
- **Sign-up and verification:**
  - Sign-up uses **email or phone** (one is required; the other can be added later).
  - Verification is a **6-digit one-time code**. Configure the OTP length to 6 and expiry to **10 minutes** (600 s). Email templates use the token, not magic links, so the prototype's code screen works.
  - Resend cooldown is **60 seconds**.
- **Account recovery:** recovery codes expire after **15 minutes** (prototype copy). Recovery uses the OTP code flow; a password reset signs the user out of other devices (`signOut` with the "others" scope).
- **Email and SMS delivery:**
  - Configure **custom SMTP** for Auth emails, using Atarah-branded templates.
  - Route SMS through the **Supabase "Send SMS" Auth hook** to a NestJS endpoint (`POST /api/v1/auth/hooks/send-sms`, with signature verification). It sends through the SMS-provider adapter, so the Kenyan SMS provider (section 12) is swappable.
  - Locally, Supabase's built-in mail catcher receives emails, and SMS goes to a log sink.
- **Sessions:**
  - Access tokens are Supabase JWTs (1-hour expiry). Refresh tokens rotate, with reuse detection enabled in Auth settings.
  - The SDK stores sessions in `flutter_secure_storage` (custom storage adapter).
  - The Security screen's "Active sessions" reads `auth.sessions` through NestJS with the service role, which also revokes a session on request.
  - Device name and platform are recorded in a `user_devices` table at sign-in.
- **NestJS guard:** `SupabaseAuthGuard` verifies each request's bearer JWT:
  - signature, through the project's JWKS endpoint (asymmetric signing keys; the JWT secret only on legacy projects), plus issuer, audience and expiry
  - it then loads `public.users` by `sub`, rejects `SUSPENDED`, `DEACTIVATED` and `DELETED` accounts, and attaches roles, permissions and entitlements.

  Atarah's authorisation never relies on Supabase `user_metadata`.

- **User records:**
  - A migration creates a `SECURITY DEFINER` trigger on `auth.users` insert. It creates the `public.users` row (same UUID) with status `PENDING_VERIFICATION` and the FREE membership, and records consent.
  - A second trigger keeps verification flags in sync when an email or phone is confirmed.
- **Two-step verification** (Settings → Security) uses **Supabase MFA with a phone factor**. Sign-in on a new device must reach AAL2.
- **Continue with Google:** Supabase OAuth provider, behind a feature flag (hidden, not dead) until credentials are supplied.
- **Admin accounts require Supabase MFA (TOTP).** Every `/api/v1/admin/*` request needs an **AAL2** token, and sensitive actions require recent re-authentication.
- **Rate limits:** configure Supabase Auth limits (sign-ups, OTP sends, verifications) and keep NestJS throttling on Atarah's own endpoints.

## 5.6 Authorisation model

Keep these concepts separate. **Never collapse them into a single `user.role` field.**

- **Account status** — can the person use Atarah at all.
- **Roles** — what the person may do (additive; a person can hold several).
- **Membership and entitlements** — what the person has paid for or been granted.
- **Verification** — what Atarah has confirmed about the person or a resource.
- **Ownership and visibility** — who owns a resource and who may see each part of it.

Effective access = account status + roles + entitlements + verification + ownership + visibility + platform policy (feature flags). It is evaluated **on the backend on every request**. Clients only decide whether to show a control; the server decides whether the action is allowed. Implement this as NestJS guards plus per-module policy classes, with a test for every allow and deny path that matters.

## 5.7 Supabase usage rules

1. **NestJS is the only data API.**
   - Clients never read or write application tables through the Supabase client (no PostgREST, no `supabase.from(...)` in the apps).
   - The Supabase client in the apps is used only for Auth, and for the single Realtime subscription in rule 4.
2. **Row Level Security on every table.**
   - Enable RLS on every table in the `public` schema, with **no policies** (deny all) for the `anon` and `authenticated` roles. The single exception is rule 4.
   - NestJS connects as a dedicated database role, separate from `anon`/`authenticated`, that bypasses RLS. Authorisation happens in NestJS (section 5.6).
   - A CI check (`scripts/check-rls.sql`) fails if any `public` table has RLS disabled or has a policy that is not on the allow-list.
3. **Keys.**
   - The **anon (publishable) key** may ship in the apps.
   - The **service-role (secret) key**, the database password and the JWT/JWKS settings exist **only** in the backend's secret store. They never go in a client, the repo or logs.
4. **Realtime.** Only `public.notifications` is published to Realtime, with one RLS `SELECT` policy: `user_id = auth.uid()`. The app subscribes to its own new notifications to update the bell badge and the list live. Everything else is pulled from the API.
5. **Storage.**
   - All buckets are private except `public-media`.
   - Uploads use **signed upload URLs created by NestJS** after an authorisation check. Downloads of private files use short-lived signed URLs.
   - Storage RLS denies direct client access.
   - Image variants are produced by Atarah's own media job (section 7.4), not by a plan-dependent feature.
6. **Schema ownership.**
   - Prisma owns the `public` schema. Never modify Supabase-managed schemas (`auth`, `storage`, `realtime`), except the documented triggers on `auth.users` and the Realtime publication, which are written as SQL inside Prisma migrations.
   - Reference `auth.users(id)` from `public.users.id` with a foreign key created in SQL.
7. **Connections.**
   - `DATABASE_URL` points to the Supabase **transaction pooler** (port 6543, `?pgbouncer=true&connection_limit=…`) for the app and worker.
   - `DIRECT_URL` points to the direct connection (port 5432) for Prisma migrations.
   - Long-running jobs use the session pooler or the direct URL.
8. **Environments.**
   - **Local:** `supabase start` (Supabase CLI, Docker), plus Redis in Docker. `supabase/config.toml` is committed without secrets.
   - **Dev, staging and production:** separate Supabase projects created by the product owner (section 12).
   - Prisma migrations are applied to each environment by the pipeline. Never edit data or schema in the Supabase dashboard; the dashboard is not the admin console.
9. **Backups.** Production uses Supabase point-in-time recovery (the plan is the owner's decision); restores are rehearsed in P3-M8.

# 6. Canonical vocabulary (resolves the specification conflicts)

Use these exact enum values in the database, API and code. The "UI label" column is what users see; it comes from the design prototype. Put the full list in `docs/DOMAIN.md` in P0-M4 and keep it current.

## 6.1 Accounts, roles, membership

| Concept                       | Values (UI label)                                                                                                                                                                                                                                              |
| ----------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `AccountStatus`               | `PENDING_VERIFICATION`, `ACTIVE`, `SUSPENDED`, `DEACTIVATED`, `DELETED`                                                                                                                                                                                        |
| `Role` (assignable, additive) | `MENTOR`, `SELLER`, `OPPORTUNITY_PROVIDER`, `INSTRUCTOR`, `MODERATOR`, `CONTENT_ADMIN`, `PLATFORM_ADMIN`, `SUPER_ADMIN`. Every active account is implicitly a **member** (a creative); that is not stored as a role. **Premium and Verified are never roles.** |
| `MembershipPlan`              | `FREE` ("Free"), `PRO` ("Atarah Pro")                                                                                                                                                                                                                          |
| `MembershipSource`            | `PAID`, `SCHOLARSHIP`, `ADMIN_GRANT`, `PARTNER`                                                                                                                                                                                                                |
| `MembershipStatus`            | `ACTIVE`, `PAST_DUE`, `CANCELLED` (active until period end), `EXPIRED`                                                                                                                                                                                         |
| `Entitlement`                 | `MENTORSHIP_BOOKING`, `CREATIVE_VERIFICATION`, `SKILL_VERIFICATION`, `REDUCED_MARKETPLACE_FEES`, `PREMIUM_CONTENT`                                                                                                                                             |

Pro price shown in the prototype: **KES 1,200 per month**, "Cancel anytime. No hidden fees." Keep the price in `PlatformSetting`, not in code.

Who may do what (summary; the Roles & Permissions Matrix gives the detail):

- Moderators handle reports and community content only — no payments, roles, memberships or private account data.
- Content admins manage articles, learning content, help and legal documents, categories and media. They **do not** manage opportunities or decide verification cases.
- Platform admins manage users, memberships, opportunities and their verification, mentors, sellers, verification cases, the marketplace and settings. Payment management needs the separate `payment.manage` permission.
- Super admins manage roles, permissions, admin accounts, security settings and emergency controls.
- Nobody can grant themselves a role, verify their own skill or verify their own opportunity.

## 6.2 Identity and visibility

| Concept                                                          | Values (UI label)                                                                                                                                                                                                                                   |
| ---------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Visibility` (per field and per section)                         | `PUBLIC` ("Public"), `MEMBERS` ("Members only"), `PRIVATE` ("Private")                                                                                                                                                                              |
| `PublicationStatus` (content)                                    | `DRAFT`, `IN_REVIEW`, `PUBLISHED`, `ARCHIVED`                                                                                                                                                                                                       |
| `SkillLevel`                                                     | `BEGINNER`, `INTERMEDIATE`, `ADVANCED`, `EXPERT` (shown as a 4-segment bar: 1–4)                                                                                                                                                                    |
| `SkillSource`                                                    | `SELF_DECLARED` ("Self-declared"), `LEARNING`, `VERIFIED` ("Verified")                                                                                                                                                                              |
| `VerificationStatus` (creative, skill, mentor, seller, provider) | `NOT_SUBMITTED`, `SUBMITTED` ("Application submitted"), `UNDER_REVIEW` ("Under review"), `VERIFIED` ("Verified"), `REJECTED`, `EXPIRED`, `REVOKED`. A skill with no case shows "Self-declared"; `SUBMITTED` and `UNDER_REVIEW` show "Under review". |
| `GrowthStrength` (Passport growth bars)                          | `EARLY`, `GROWING`, `ACTIVE`, `STRONG`                                                                                                                                                                                                              |
| `CreativeDocumentFormat`                                         | `CV` ("Creative CV"), `BIO` ("Artist biography"), `EPK` ("Electronic press kit"), `DECK` ("Portfolio presentation")                                                                                                                                 |

Privacy defaults for new accounts: identity, bio, portfolio and skills `PUBLIC`; experience and location `MEMBERS`; contact details `PRIVATE`; activity `PRIVATE`. (The prototype's Privacy screen and Passport screen show different sample values; these defaults resolve that.)

## 6.3 Opportunities

| Concept                         | Values (UI label)                                                                                                                |
| ------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| `OpportunityType`               | `GRANT`, `FUNDING`, `JOB`, `INTERNSHIP`, `GIG`, `COMPETITION`, `FESTIVAL`, `PARTNERSHIP`, `FELLOWSHIP`, `RESIDENCY`, `PROGRAMME` |
| `OpportunityTrust` (badge)      | `VERIFIED` ("Verified by Atarah"), `SOURCE_CONFIRMED` ("Source confirmed"), `EXTERNAL_SOURCE` ("External source")                |
| `OpportunityStatus` (lifecycle) | `DRAFT`, `PENDING_REVIEW`, `PUBLISHED`, `CLOSED`, `EXPIRED`, `ARCHIVED`, `REMOVED`                                               |
| `ApplicationMethod`             | `EXTERNAL_WEBSITE`, `EMAIL`, `IN_APP` (reserved; not built before Phase 3)                                                       |
| `OpportunityTrackingStatus`     | `SAVED` ("Saved"), `IN_PROGRESS` ("In progress"), `APPLIED` ("Applied"), `COMPLETED` ("Completed")                               |
| `OpportunityOutcome`            | `AWARDED`, `NOT_SELECTED`, `WITHDRAWN`, `UNKNOWN`                                                                                |

Display "Closing soon" when the deadline is within 14 days and the item is not applied or completed. Deadline urgency colours: ≤ 7 days Coral (`#FDE8EF`/`#C4245A`), 8–14 days Tangerine (`#FFF1E5`/`#B5530C`).

## 6.4 Learning and content

| Concept                 | Values (UI label)                                                                                                |
| ----------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `ContentSource`         | `ATARAH` ("Atarah Course" / "Atarah Editorial"), `PARTNER` ("Partner content"), `EXTERNAL` ("External resource") |
| `ContentDelivery`       | `NATIVE` ("In-app lessons"), `EMBEDDED` (permitted third-party player), `EXTERNAL_LINK` ("opens outside Atarah") |
| `LearningContentType`   | `COURSE`, `TUTORIAL`, `TOOLKIT`, `WEBINAR`, `MASTERCLASS`, `ARTICLE`                                             |
| `LearningCategoryGroup` | `CREATIVE`, `BUSINESS`, `PROFESSIONAL`                                                                           |
| `LessonProgressStatus`  | `NOT_STARTED`, `IN_PROGRESS`, `COMPLETED` ("locked" is computed, not stored)                                     |

## 6.5 Community

| Concept            | Values (UI label)                                                                                                                                                   |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `PostType`         | `UPDATE` ("Creative update"), `QUESTION` ("Question"), `DISCUSSION` ("Discussion"), `COLLABORATION` ("Collaboration"), `ANNOUNCEMENT` ("Announcement" — staff only) |
| `PostAudience`     | `PUBLIC`, `MEMBERS` ("Atarah members"), `CONNECTIONS`, `GROUP`                                                                                                      |
| `GroupType`        | `DISCIPLINE`, `LOCATION`, `INTEREST`, `PROGRAMME`                                                                                                                   |
| `ConnectionStatus` | `PENDING` ("Requested"), `ACCEPTED`, `DECLINED`, `REMOVED` (blocking is a separate `Block` record)                                                                  |
| `ReportReason`     | `INAPPROPRIATE`, `HARASSMENT`, `SCAM`, `MISLEADING`, `IMPERSONATION`, `IP_INFRINGEMENT`, `OTHER`                                                                    |
| `ReportStatus`     | `SUBMITTED`, `IN_REVIEW`, `RESOLVED`, `DISMISSED`, `ESCALATED`                                                                                                      |
| `ModerationAction` | `NO_ACTION`, `WARN_USER`, `HIDE_CONTENT`, `REMOVE_CONTENT`, `RESTORE_CONTENT`, `RESTRICT_ACCOUNT`, `SUSPEND_ACCOUNT`, `ESCALATE`                                    |

## 6.6 Marketplace and mentorship

| Concept                                              | Values (UI label)                                                                                                                            |
| ---------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `ListingType`                                        | `SERVICE`, `PRODUCT`                                                                                                                         |
| `PricingType`                                        | `FIXED`, `RANGE`, `ON_REQUEST` (price shown as "From KES x" for services)                                                                    |
| `ListingStatus`                                      | `DRAFT` ("Draft"), `UNDER_REVIEW` ("Under review"), `PUBLISHED` ("Published"), `REJECTED`, `SUSPENDED`, `ARCHIVED`                           |
| `ProfileServiceStatus`                               | `PROFILE_ONLY` ("Profile only"), `ON_MARKETPLACE` ("On Marketplace")                                                                         |
| `EnquiryStatus` ("Request booking" / buyer interest) | `NEW`, `REPLIED`, `CLOSED`                                                                                                                   |
| `MentorSessionFormat`                                | `VIDEO_CALL` (MVP), `IN_PERSON` (later)                                                                                                      |
| `BookingStatus`                                      | `PENDING_PAYMENT`, `CONFIRMED`, `COMPLETED`, `CANCELLED_BY_MENTEE`, `CANCELLED_BY_MENTOR`, `DECLINED_BY_MENTOR`, `NO_SHOW`, `PAYMENT_FAILED` |

**Booking rule (resolves a prototype ambiguity):** a session booked in one of the mentor's published availability slots is **confirmed automatically once the payment is verified** (the prototype's "Booking confirmed" screen). It then appears in the mentor's "Booking requests" list, where **Accept** acknowledges it and **Decline** cancels it with an automatic **full refund** and a notification to the mentee. Mentee cancellation: free up to 24 hours before the session; after that 50% is refunded (prototype copy). Keep these values in `PlatformSetting`.

## 6.7 Payments and notifications

| Concept                | Values                                                                                                                                                       |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `PaymentMethod`        | `MPESA`, `CARD`                                                                                                                                              |
| `PaymentPurpose`       | `MEMBERSHIP`, `MENTORSHIP`, `VERIFICATION`, `OTHER`                                                                                                          |
| `PaymentStatus`        | `INITIATED`, `PENDING`, `SUCCEEDED`, `FAILED`, `CANCELLED`, `REFUNDED`, `PARTIALLY_REFUNDED`                                                                 |
| `NotificationCategory` | `OPPORTUNITIES`, `MENTORSHIP`, `COMMUNITY`, `LEARNING`, `PROFILE`, `MARKETPLACE`, `SYSTEM` (payments, membership, security and account notices are `SYSTEM`) |

Money is stored as **integer minor units plus an ISO-4217 currency code** (KES by default; opportunities may show EUR or USD). Times are stored in **UTC** and displayed in the user's time zone (default `Africa/Nairobi`, labelled "EAT").

## 6.8 Taxonomies to seed (admin-managed afterwards)

- **Disciplines (12)** and their icons: Music `music`, Acting `drama`, Dance `person-standing`, Writing `pen-line`, Fashion `shirt`, Visual Art `palette`, Photography `camera`, Film / Video `clapperboard`, Design `pen-tool`, Animation `aperture`, Production `sliders-vertical`, Entrepreneur `lightbulb`.
- **Specialisations** per discipline: exactly the lists in `AtarahEntry.dc.html` (`ob_spec`), e.g. Animation → 2D animation, 3D animation, Motion graphics, Character design, Storyboarding. Members can suggest new ones (goes to an admin queue).
- **Skills, interests and "areas to develop"**: the `ob_skills` lists, extended per discipline by admins.
- **Learning categories**: Creative (Animation, Music, Acting, Writing, Fashion, Visual Arts, Production), Business (Financial Literacy, Entrepreneurship, Branding, Marketing), Professional (Portfolio Building, Client Management, Legal Awareness, Career Development).
- **Marketplace categories**: Photo, Animation, Music, Design, Film, Fashion, Writing, Events (icons and colours in `AtarahMarket.dc.html`).
- **Location hierarchy**: Country → County/Region → Town. Seed **Kenya and all 47 counties** with their three-letter codes (NBI, MSA, KSM, NKR, …). Never hard-code Kenya in logic.
- **Creative Passport ID** format: `ATR-{COUNTY CODE}-{zero-padded sequence}`, generated once at onboarding completion and never changed. Use the same county codes as the county list (NBI, MSA, KSM, NKR, …), so a Nairobi passport reads `ATR-NBI-0042`. The prototype's `ATR-NBO-0042` is a sample inconsistency.

# 7. Engineering standards (apply to every milestone)

## 7.1 Vertical slices

Build each feature as a complete slice: **database → domain service → API → generated client → Riverpod state → UI → authorisation → validation → tests → admin tooling → docs**. A feature is not done because its endpoint passes tests or its screen renders. It is done when a real user can complete the flow on the running app against the real backend.

## 7.2 API conventions

- Base path `/api/v1`. Admin endpoints under `/api/v1/admin/*`. Webhooks under `/api/v1/webhooks/{provider}`.
- Success envelope: `{ "data": …, "meta": { … } }`. Collections return `meta: { page, limit, total }` or `meta: { nextCursor }` for feeds. Default `limit` 20, maximum 100. No unbounded lists.
- Error envelope: `{ "error": { "code": "…", "message": "…", "details": { … }, "requestId": "…" } }`. Codes: `AUTHENTICATION_REQUIRED`, `INVALID_CREDENTIALS`, `FORBIDDEN`, `PREMIUM_REQUIRED`, `VERIFICATION_REQUIRED`, `APPROVAL_REQUIRED`, `RESOURCE_NOT_FOUND`, `VALIDATION_ERROR`, `CONFLICT`, `INVALID_STATE`, `RATE_LIMITED`, `PAYMENT_ERROR`, `EXTERNAL_SERVICE_ERROR`, `INTERNAL_ERROR`. Messages are human-readable and never expose stack traces or SQL.
- Filtering by explicit query parameters; sorting only by a whitelist per resource (`recent`, `deadline`, `relevance`, `popularity`, `rating`, `price`).
- **Idempotency-Key** header required on payment initiation, booking creation, membership upgrade, opportunity submission and enrolment. Store keys for 24 hours.
- Optimistic concurrency (`version` column) on resources edited by more than one actor (bookings, listings under review, verification cases). Database constraints prevent double-booking a mentor slot and duplicate entitlements from repeated payment callbacks.
- The OpenAPI document is generated from the NestJS code. After every API change, regenerate `packages/api-contracts` and the Dart and TypeScript clients, and list them in your changed-files report.
- Rate limits (Redis-backed) on sign-in, sign-up, code sending, password reset, search, posting, reporting, AI calls, payment initiation and webhooks. Start with sensible defaults and document them in `docs/SECURITY.md`.

## 7.3 Database conventions

- Prisma schema split by domain where the tooling allows; one migration per meaningful change, named descriptively. Never edit an applied migration.
- UUID primary keys; `createdAt`, `updatedAt` on every table; `deletedAt` soft delete where users can delete things they own.
- Lifecycles are explicit enums, never booleans such as `isVerified` or `isPremium`.
- Foreign keys, unique constraints, check constraints and indexes for every filter and sort the API exposes. Full-text `tsvector` columns with GIN indexes for searchable entities.
- Destructive changes (dropping or renaming columns with data) need written approval from the product owner.
- Supabase specifics (section 5.7): every new table gets RLS enabled in the same migration; SQL that touches `auth.users`, Realtime publications or storage policies lives in Prisma migrations as raw SQL; never change Supabase-managed schemas otherwise.
- `prisma/seed` has two layers: **reference seed** (taxonomies, counties, settings, roles, permissions, legal and help placeholders) that runs in every environment, and **demo seed** (sample creatives, opportunities, courses, listings, mentors) that runs **only** in `dev`, with every demo record flagged `isDemo = true` and never shown in production.

## 7.4 Security and privacy (every milestone)

- Validate all input on the server (class-validator DTOs or zod). Client validation is for feedback only.
- Check ownership and field-level visibility in the service layer. Visibility filtering happens before data leaves the API, including in search results, share links, notifications and AI context.
- Media: signed uploads only, MIME sniffing, size limits (images 10 MB, video 200 MB, audio 50 MB, documents 10 MB unless a milestone says otherwise), EXIF stripping on images, private-by-default buckets.
- Government ID and verification evidence are stored in a separate private bucket, encrypted, viewable only by authorised reviewers through short-lived URLs, and never returned to other users.
- Audit log (append-only) for every admin action, role or membership change, verification decision, moderation action, payment state change, refund and account deletion: actor, action, entity, before, after, IP, timestamp.
- Build to **Kenya's Data Protection Act, 2019** expectations: consent captured at sign-up with version and timestamp, purpose limitation, data export, deletion, and breach-response notes in `docs/SECURITY.md`. Legal text itself comes from the product owner (section 12).
- Log no passwords, tokens, codes, ID numbers or full phone numbers.

## 7.5 Mobile quality bar

- Match the prototype: layout, spacing, tokens, copy, icons and the order of sections. Compare each screen side by side with the prototype HTML (open it in a browser) before marking it done.
- Every screen supports the **light and dark appearances** (section 8.3).
- Every network screen has **loading** (skeletons preserving layout, never full-screen spinners), **empty** (with a next action), **error** (what happened, what to do), **offline** and, where relevant, **premium-gated** and **role-gated** states.
- Accessibility: semantic labels on icon buttons, minimum 48×48 touch targets, text scaling to 200% without clipping, contrast at least 4.5:1 for body text, colour never the only indicator, reduced-motion respected.
- Performance budgets: cold start under 2.5 s on a mid-range Android device in release mode; scrolling at 60 fps; images cached and resized server-side.
- Strings live in ARB files (`l10n`), English first, ready for Swahili later. No hard-coded currency, date format or country.

## 7.6 Data honesty

- No hard-coded people, prices, counts or listings in UI code. Everything comes from the API.
- Demo data is seeded only in `dev` and flagged.
- Never mark a payment, verification, booking or application as successful unless the system of record says so.

## 7.7 Testing expectations

| Layer         | Required                                                                                                                                                                                                                                                |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Backend       | Unit tests for domain services and policies; integration tests against the local Supabase stack for every endpoint (happy path, validation failure, unauthenticated, forbidden, not found, state conflict); webhook and idempotency tests for payments. |
| Mobile        | Widget tests for every screen state; provider/notifier tests; golden tests for design-system components and key screens; `integration_test` journeys per milestone run on the Android emulator.                                                         |
| Web / admin   | Component tests; Playwright tests for critical admin and public flows.                                                                                                                                                                                  |
| Cross-cutting | Authorisation matrix tests for every role and entitlement that a milestone touches.                                                                                                                                                                     |

Do not pad test counts. Every test must exercise real behaviour.

## 7.8 Verification surfaces

- **Android emulator** (Pixel 6 / API 35–36 image, or the closest available) is required for every mobile milestone. Run the app, walk the flow, check API calls in the backend logs, check persistence. If no emulator is available, report it as BLOCKED for that check; do not claim the flow was demonstrated.
- `flutter analyze`, `flutter test`, `dart format --set-exit-if-changed`, backend `lint`, `typecheck`, `test`, `build`, web/admin `lint`, `typecheck`, `test`, `build` must pass before a milestone closes.

## 7.9 Backend and database definition of done (every milestone)

A milestone's backend is complete only when **all** of these are true. Claude Code builds the backend and database **to completion inside the milestone that needs them** — never as "API exists, UI later" and never as "UI with mocked data".

**Database**

- Every table in the milestone's "Backend & database" block exists as a Prisma model with a named migration, explicit enums, foreign keys with deliberate `onDelete` behaviour, unique and check constraints, `createdAt`/`updatedAt`, `deletedAt` where users can delete, and an index for every filter, sort and join the API uses.
- Migrations apply cleanly to an empty database and on top of the previous milestone's database with data in it (test both). No destructive change without owner approval.
- Reference seed updated (taxonomies, settings, permissions); demo seed (dev only, `isDemo = true`) updated so every new screen has realistic data locally.
- Row Level Security is enabled on every new table (deny all; section 5.7) and `check-rls.sql` passes.
- `docs/DATABASE.md` updated: new tables, relationships, indexes, retention rules, and a regenerated ER diagram (e.g. `prisma-erd-generator`).

**Domain and API**

- One NestJS module per domain (section 5.3) with controller → service → repository layering; business rules live in services and policy classes, never in controllers.
- Every endpoint: DTO validation with size limits, the response and error envelopes (section 7.2), pagination and sort whitelists, authorisation through guards **and** policy checks (role, entitlement, ownership, visibility, account status), rate limits on every mutating or search endpoint, idempotency where section 7.2 requires it, and audit logging for every admin or sensitive action.
- State machines (statuses in section 6) are enforced in the service layer with tests for every allowed and forbidden transition; concurrent updates use transactions and optimistic locking where two actors can collide.
- Domain events emitted for the milestone's notable actions and consumed by notifications, search indexing and analytics through BullMQ — with retries, exponential backoff, a dead-letter queue and idempotent handlers.
- Search: new searchable entities get `tsvector` columns, GIN indexes and are included in `GET /search` with visibility filtering.
- OpenAPI documents every endpoint with request/response schemas, examples and possible error codes; `packages/api-contracts` and the Dart and TypeScript clients are regenerated and compile.
- Admin endpoints (`/api/v1/admin/*`) for everything operators must manage in that milestone, protected by the admin permissions, re-authentication for sensitive actions, and audit logs.

**Tests**

- Unit tests for services, policies, rule engines and state machines.
- Integration tests (local Supabase stack + Redis) for **every** endpoint: success, validation error, unauthenticated, forbidden (wrong role, wrong owner, suspended account), not found, invalid state, rate limited where applicable.
- Job tests: success, retry, idempotent re-run.
- Query-count assertions on list endpoints (no N+1).

**Integration**

- The mobile (and admin) screens of the milestone call the real endpoints through the generated clients; no mocked repositories remain in non-test code.

# 8. Design system (from the prototype and the brand guidelines)

The approved brand identity (logo, colours, gradients) is defined in **`docs/brand/Atarah - Logo & Brand Identity Guidelines.pdf`** and the **logo pack**. The updated prototype applies it to every screen and adds a **dark appearance**. Build the tokens once in `packages/design-tokens/tokens.json` (light **and** dark sets), then generate `apps/mobile/lib/core/design_system/tokens.g.dart` and a CSS variables file for web and admin. Never hard-code a colour, radius, shadow or font size in a screen.

## 8.1 Brand palette (the only base colours)

| Name          | HEX       | Main use                                                                                         |
| ------------- | --------- | ------------------------------------------------------------------------------------------------ |
| **Midnight**  | `#17153F` | Ink: headings and primary text; dark surfaces                                                    |
| **Indigo**    | `#5145D8` | Primary: links, active tab, selected chips, toggles, prices, progress, verified ticks and badges |
| **Violet**    | `#7968FF` | Primary light: gradient start, highlights, category accents                                      |
| **Coral**     | `#F04478` | Pink accent; error and destructive (as its dark shade for text)                                  |
| **Tangerine** | `#FF8A32` | Orange accent; warning, "Under review", deadlines (as its dark shade for text); star ratings     |
| **Mist**      | `#F6F5FC` | Soft surfaces and app background tiles                                                           |

Derived values (use exactly these; no others):

| Token                                                                          | Light value                                                                                                                                                           |
| ------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `primaryPressed`                                                               | `#3F34B8`                                                                                                                                                             |
| `violetTint1` / `violetTint2` (soft violets)                                   | `#9A8DFF` / `#B8AFFF`                                                                                                                                                 |
| `primaryTint` (chip/tile backgrounds)                                          | `#EFEDFF`                                                                                                                                                             |
| `primaryTintStrong` (active tab pill, selected row, borders of selected items) | `#E7E4FF`                                                                                                                                                             |
| `primaryTintFaint`                                                             | `#F8F7FF`                                                                                                                                                             |
| `violetSurface` (Violet accent background)                                     | `#F2F0FF`                                                                                                                                                             |
| `indigoSurface` (former blue accent background)                                | `#EEEDFB`                                                                                                                                                             |
| `coralSurface` / `coralStrong` (text, icons, destructive)                      | `#FDE8EF` / `#C4245A`                                                                                                                                                 |
| `tangerineSurface` / `tangerineStrong` (text on tints, warnings)               | `#FFF1E5` / `#B5530C`                                                                                                                                                 |
| `amberSurface` (achievements, info boxes)                                      | `#FFF6EC` (text `#B5530C`)                                                                                                                                            |
| `successSurface` / `successStrong` / `successIcon`                             | `#E9F8EE` / `#16784A` / `#1F9D55` — **success status only** (Published, Applied, Available, completed checks, "Payment received", success banners). Never decoration. |
| Neutral text                                                                   | body `#4A4868`, long-form `#2C2A50`, muted `#77758F`, faint `#A3A1B8`                                                                                                 |
| Neutral borders and dividers                                                   | card `#ECEBF4`, input `#E4E2EF`, divider `#F0EFF6` / `#F2F1F8`, toggle-off `#DCDBE6`, radio ring `#CFCCDF`, neutral pill `#F2F1F6`                                    |
| Cards, sheets                                                                  | `#FFFFFF`                                                                                                                                                             |
| Page corner washes                                                             | violet `#E7E4FF`, opportunities `#FFE8D6`, learning `#E7E4FF`, community/marketplace `#FDE3EC`, settings `#EFEDFF`                                                    |

Gradients:

| Gradient                                                                                 | Value                                                                                                                                                                                                                                                                                                                                                                 |
| ---------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Primary CTA                                                                              | linear 90°, Violet `#7968FF` → Indigo `#5145D8` (135° on square icon buttons)                                                                                                                                                                                                                                                                                         |
| Dark hero cards                                                                          | linear 135°, Midnight `#17153F` → `#1F1C55` → `#2A2478`                                                                                                                                                                                                                                                                                                               |
| Splash / dark brand screens (and their status and gesture bars)                          | Indigo `#5145D8` → `#3828C3`                                                                                                                                                                                                                                                                                                                                          |
| AI disc                                                                                  | Violet `#7968FF` → Indigo `#5145D8`                                                                                                                                                                                                                                                                                                                                   |
| **Atarah Pro / Premium pill**                                                            | Coral `#F04478` → Tangerine `#FF8A32`, white text, `crown` icon                                                                                                                                                                                                                                                                                                       |
| **Brand ring motif** (decoration on dark hero cards, splash, Passport card, course hero) | a 240 px circle positioned −70 px off the top-right corner, filled `linear 135°, #F04478 → #FF8A32` and masked to a ring (`radial-gradient(circle, transparent 57%, #000 58%)`), low emphasis, behind content, `aria-hidden`. In Flutter draw it with a `CustomPainter` (gradient stroke ring). The old `ribbon.png` artwork is **removed** — do not use it anywhere. |

Accessibility rules: never use Tangerine, Coral or Violet for small text on white — use `tangerineStrong`, `coralStrong` or Indigo. Body text stays Midnight or the neutral greys. White text on the CTA gradient is 15.5/700 minimum.

## 8.2 Semantic colour assignments (from the updated prototype)

| Element                                                               | Background / foreground                     |
| --------------------------------------------------------------------- | ------------------------------------------- |
| Verified badge (creative, skill, opportunity "Verified by Atarah")    | `#EFEDFF` / Indigo `#5145D8`, `badge-check` |
| Source confirmed                                                      | `#EFEDFF` / `#5145D8`, `shield-check`       |
| External source / Self-declared / Draft / Profile only                | `#F2F1F6` / `#4A4868`                       |
| Under review / In progress / Announcement / deadline 8–14 days        | `#FFF1E5` / `#B5530C`                       |
| Deadline ≤ 7 days / "Closing in n days" / Question post / destructive | `#FDE8EF` / `#C4245A`                       |
| Saved / Discussion post                                               | `#EFEDFF` / `#5145D8`                       |
| Creative update post                                                  | `#F2F0FF` / `#5145D8`                       |
| Published / Applied / Available / On Marketplace / success            | `#E9F8EE` / `#16784A`                       |

Opportunity types, learning sources, marketplace categories and other accent pairs: copy the exact pairs from the prototype files; every one now resolves to a brand-palette pair above.

## 8.3 Dark appearance

The prototype adds **Appearance: Light / Dark** (Settings → Account group, and the prototype's viewer panel). Default **Light**; the member's choice is saved per device (and to their account preferences so it follows them). `theme-dark.js` in the prototype is a runtime colour remap used only for the mock-up — **do not port it**. Implement a real dark `ThemeData` plus a `ThemeExtension` generated from the dark token set below.

| Role                                                           | Dark value                                                                              |
| -------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| Page background ("Night")                                      | `#0F0D2B`                                                                               |
| Cards and bordered or elevated surfaces ("Surface")            | `#17153F`                                                                               |
| Raised surfaces, dark hero start                               | `#1F1C55`                                                                               |
| Dark hero cards                                                | `#1F1C55` → `#2A2478` → `#3828C3`                                                       |
| Mist / soft tiles (`#F6F5FC`, `#F8F7FF`)                       | `#1C1A4A`                                                                               |
| Primary tint `#EFEDFF` / strong `#E7E4FF`                      | `#25215E` / `#2C2870`                                                                   |
| Violet surface `#F2F0FF` / indigo surface `#EEEDFB`            | `#231F5A` / `#221F55`                                                                   |
| Coral surface `#FDE8EF` / wash `#FDE3EC`                       | `#3A1838` / `#2E1533`                                                                   |
| Tangerine surface `#FFF1E5` / amber `#FFF6EC` / wash `#FFE8D6` | `#3A2420` / `#33221F` / `#2E1E22`                                                       |
| Success surface `#E9F8EE`                                      | `#0F3A2A`                                                                               |
| Neutral pill `#F2F1F6` / toggle-off `#DCDBE6` / ring `#CFCCDF` | `#24223F` / `#34325A` / `#4A4870`                                                       |
| Skeleton fills                                                 | `#1C1A4A`, shimmer `#25225E`                                                            |
| Borders: card `#ECEBF4` / input `#E4E2EF` / dividers           | `#2A2766` / `#322F6E` / `#221F4D`                                                       |
| Text: Midnight / long-form / body / muted / faint              | `#F6F5FC` / `#DCD9F2` / `#B9B6D6` / `#9592B8` / `#75729A`                               |
| Indigo and Violet text / pressed                               | `#9A8DFF` / `#B8AFFF`                                                                   |
| Coral strong / Tangerine strong text                           | `#F04478` / `#FF8A32`                                                                   |
| Success text / icon                                            | `#5FD39A` / `#3CC17A`                                                                   |
| Logos                                                          | swap every full-colour logo to its **reversed** version; the symbol keeps its gradients |
| White "glass" buttons over images                              | unchanged (keep dark text on them)                                                      |

Every screen, component and golden test must exist in both appearances.

## 8.4 Logo usage (from the brand guidelines)

- Ship the logo pack SVGs as assets (`flutter_svg` on mobile; `public/brand/` on web and admin) and **never redraw, retype, recolour or reshape** the logo. The wordmark is outlined artwork; Montserrat is not an app font.
- Versions: `atarah-logo-primary-{color|reversed}` (with brand line, only at ≥ 300 px wide), `atarah-logo-notagline-{color|reversed}` (≥ 120 px), `atarah-symbol-{color|mono-white|mono-dark}` (≥ 20 px). Clear space 2× the stroke width of the "A".
- Placements (exactly as the prototype): prototype/web header and admin sidebar → no-brand-line colour logo ~130 px; `splash` → reversed primary logo 300 px centred on the Indigo gradient with the brand ring; `welcome` → no-brand-line colour logo 140 px (no separate tagline text); `home` header → no-brand-line colour logo 126 px; `ob_done` Passport preview → 20 px colour symbol before "CREATIVE PASSPORT"; `passport` card → 20 px white symbol + "CREATIVE PASSPORT"; "Atarah Team" posts and other system authors → 26 px colour symbol on a Mist circle.
- App icons, favicon and native splash come from the logo pack (P1-M7).

## 8.5 Type, shape and spacing (unchanged)

- **Font:** Plus Jakarta Sans 400/500/600/700/800, bundled. Icons: Lucide (same names as the prototype).
- **Radii:** pills and buttons 999; cards 16–18; large panels 20–22; Passport card 24; inputs and back button 14; icon tiles 12–14; sheets and overlapping detail panels 28 (top corners); modals 26.
- **Shadows:** card `0 4 16 rgba(40,30,120,.04)`; floating button `0 6 18 rgba(60,40,160,.10)`; primary CTA `0 10 22 rgba(81,69,216,.28)`; selected tile `0 8 18 rgba(81,69,216,.30)`; dark card `0 14 30 rgba(23,21,63,.25)`; sheet `0 -10 40 rgba(23,21,63,.20)`; modal `0 30 60 rgba(23,21,63,.30)`. In dark mode, shadows use the border colours instead of light glows.
- **Type scale:** tab-root title 32/800 (−0.02em); sub-screen title 28–30/800; detail title 24–25/800; section title 20/700 (17–18 inside details); card title 14.5–16/700; body 14–15.5 (line-height 1.55–1.65); meta 12–12.5; chip 11–13/600; uppercase label 10.5–12/700 with 0.1–0.14em tracking.
- **Spacing:** page gutter 22; top bar padding 6/14; section gap 22–28; card padding 14–18; list gap 10–12.
- **Scrims:** sheets `rgba(23,21,63,.45)`; modals `.5`.

## 8.6 Components (Flutter, prefix `At`)

`AtButton` (primary gradient, secondary outline, tertiary text, destructive; heights 54/48/34; loading and disabled states) · `AtIconButton` (back 44×44 r14, floating, glass-over-image, filter) · `AtTextField` (52 high, focus ring Violet + 4px `#EFEDFF`, error state Coral, prefix such as "+254"/"KES"/"atarah.app/") · `AtCodeInput` (6 boxes) · `AtPasswordField` + strength meter · `AtChip` (selectable, removable, filter-dropdown) · `AtSegmented` · `AtToggle` (48×28) · `AtRadioCard` · `AtCheckbox` · `AtCard` / `AtDarkCard` (with optional `AtBrandRing`) · `AtTag` / `AtStatusPill` · `AtProPill` · `AtVerifiedTick` · `AtVerificationBadge` · `AtAvatar` (all prototype sizes, progress-ring variant, system-author variant with the symbol) · `AtProgressBar` / `AtProgressRing` / `AtStepper` · `AtSectionHeader` ("See all") · `AtTopBar` · `AtTabShell` (5-tab bar with pill indicator) · `AtBottomSheet` (grabber) · `AtModal` · `AtSkeleton` · `AtEmptyState` · `AtErrorState` (Atarah / external / invalid-link variants) · `AtOfflineBanner` · `AtPremiumGate` · **`AtFutureScreen`** ("Soon · P#") · `AtAiSheet` (AI header, disclaimer, accept/discard) · `AtLeavingAtarahModal` · `AtListRow` (settings row) · `AtTimeline` · `AtStatTile` · `AtMediaTile` / upload zone · **`AtLogo`** (variant: primary / no-brand-line / symbol; picks colour or reversed automatically from the active appearance; enforces minimum sizes in debug builds) · **`AtBrandRing`** · **`AtAppearanceToggle`**.

Domain widgets compose these: `CreativeCard`, `OpportunityCard`, `LearningCard`, `ListingCard`, `MentorCard`, `PostCard`, `ProjectCard`, `PassportCard`, `SkillCard`, `GroupCard`, `NotificationTile`, `SavedItemRow`.

Keep the **dev-only component gallery** (dev flavour) showing every component in every state **in light and dark**, covered by golden tests.

# 9. Progress tracking, reports and gates

## 9.1 `docs/PROJECT_PROGRESS.md` (the single authoritative register)

Keep it current after every milestone. It contains: overall status; current phase; current milestone; a table of **every milestone** (ID, name, status, backend, mobile, web, admin, tests, emulator-verified, notes); blocked items; known risks; deferred items; last verified date.

Milestone statuses: `NOT STARTED`, `IN PROGRESS`, `BLOCKED`, `IN REVIEW`, `COMPLETED`, `DEFERRED`, `CANCELLED`. Use `PARTIAL` in notes when only some layers exist. Progress percentage, if asked, is **completed milestones ÷ planned milestones** (excluding deferred and cancelled), never lines of code.

## 9.2 Other docs to maintain

`docs/ARCHITECTURE.md`, `docs/DOMAIN.md` (entities and the section 6 vocabulary), `docs/API.md` (how to use the OpenAPI document), `docs/DATABASE.md` (schema overview, migrations log), `docs/SECURITY.md`, `docs/DEVELOPMENT.md` (setup, commands, dependencies), `docs/DECISIONS.md` (dated, numbered entries: decision, context, options, choice, reason, impact), `docs/TESTING.md`, and from Phase 3 `docs/RUNBOOK.md` and `docs/RELEASE.md`. Also keep a short root `CLAUDE.md` that points to this Master Prompt (store a copy as `docs/MASTER_PROMPT.md`) and lists the hard rules.

## 9.3 Milestone procedure

**Before** each milestone: read its section; inspect the relevant code; confirm dependencies; set it `IN PROGRESS` in the register.

**During:** work in small increments; run the relevant tests often; record assumptions in `DECISIONS.md`.

**At the end of each milestone:** run formatters, linters, type checks, all tests and builds that the milestone touches; walk the flows on the emulator; tick every acceptance criterion with evidence; update the register and docs; then post a short **milestone report** and continue to the next milestone in the same phase:

```text
MILESTONE REPORT — P#-M# <name>
Status: COMPLETED | PARTIAL | BLOCKED
Built: …
Verified (commands run + results): …
Emulator walkthrough: …
Acceptance criteria: x/y met (list any unmet)
Decisions recorded: DEC-###, …
Files changed (for the owner to commit): …
Migrations: …
Known issues / deferred: …
```

If a milestone cannot be finished because of a blocker, mark it `BLOCKED`, describe the smallest decision or input needed, and continue with any later milestone in the same phase that does not depend on it.

## 9.4 Phase gate (stop here)

At the end of each phase, run the phase's **gate checks** (listed in section 10), then post:

```text
PHASE # <NAME> REQUIREMENTS COMPLETE

Summary: 3–6 sentences on what a real user can now do.
Milestones: P#-M1 … P#-Mn with final status.
Gate checks: each check, the command or walkthrough used, and the result.
Test totals: backend / mobile / web / admin (passed, failed, skipped).
Builds: Android debug + release (unsigned), iOS build status, web, admin, backend.
Open blockers and decisions needed from the product owner.
Risks.
Changed files since the last gate (grouped by app/package) — ready for the owner to commit.
Proposed next phase start: P#-M1.
```

Then **stop and wait**. Do not start the next phase until the product owner says so. If gate checks fail, do not announce completion: report what failed, fix it, and re-run the gate.

# 10. Phases and milestones

| Phase | Name                                        | Milestones     | Outcome                                                                                                                                                                                                                                                          |
| ----- | ------------------------------------------- | -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 0     | Foundation                                  | P0-M1 … P0-M9  | A secure, tested platform skeleton: repo, database, backend core, auth, design system, app shells, infrastructure and CI.                                                                                                                                        |
| 1     | Core Member Experience                      | P1-M1 … P1-M12 | The free MVP: sign-up to onboarding, identity and Passport, portfolio, home and discovery, the Supabase platform adoption, the brand refresh and dark appearance, community, opportunities, Skill Labs, activity and settings, with the admin tools to run them. |
| 2     | Premium, Economy & Trust                    | P2-M1 … P2-M8  | Payments, Atarah Pro, marketplace foundation, mentorship with paid booking, verification, Creative CV/EPK and the admin and finance operations behind them.                                                                                                      |
| 3     | Intelligence, Ecosystem & Production Launch | P3-M1 … P3-M8  | Contextual AI, the creative economy layer, the public web, offline and performance work, security and compliance hardening, full QA and production readiness.                                                                                                    |

Each milestone below says **what to build**, **how**, and **what "done" means**. Follow them in order.

**Status at v2.3:** Phase 0 and P1-M1 … P1-M5 are COMPLETED. Their descriptions below are kept as the record of what was built. Anything they say about NestJS-issued authentication, plain PostgreSQL, MinIO or Mailpit is superseded by sections 5.5 and 5.7 and moved to Supabase in P1-M6. Anything about the old wordmark, colours or ribbon artwork is superseded by section 8 and retrofitted in P1-M7. **Resume at P1-M6.**

---

## PHASE 0 — FOUNDATION

Goal: everything later phases rely on, built once and properly. No product screens beyond the auth shell, the tab shell and the component gallery.

### P0-M1 — Workspace audit, repository and design reference

**Build**

1. Inspect the working directory. **If a CREA-8 repository already exists** (earlier work produced a NestJS backend and Flutter/Next.js shells), do not restart: read `docs/`, `apps/*`, `packages/*`, the Prisma schema, tests and `git status`/`git log` (read-only). Write `docs/REPO_ASSESSMENT.md`: what exists, what works (run it), what conflicts with this prompt, and a mapping of existing work onto the new P0–P3 milestones. Reuse working code; adapt rather than replace.
2. If no repository exists, create the monorepo layout from section 5.2 (folders and files only — **no `git init`**).
3. Set up the workspace tooling: pnpm workspaces for the TypeScript apps, Melos (or a documented script) for Dart, root `Makefile` or `justfile` with `setup`, `dev`, `test`, `lint`, `build`, `db:migrate`, `db:seed`, `gen:api`, `gen:tokens`.
4. Copy the unzipped design prototype into `design/prototype/` and write `design/README.md` explaining how to open it and that `_ds/` must be ignored.
5. Create the docs set from section 9.2 (initial content), `CLAUDE.md`, `docs/MASTER_PROMPT.md` (this document) and `docs/PROJECT_PROGRESS.md` listing **all** milestones of all phases as `NOT STARTED` (or their assessed status if earlier work exists).
6. Add `.gitignore`, `.editorconfig`, `.env.example` for every app, and `shared-config` (ESLint, Prettier, tsconfig base, `analysis_options.yaml` with strict lints).

**Done when:** the structure exists; `make setup` runs on a clean machine; the register lists every milestone; the assessment (if applicable) is written; no secrets are present.

### P0-M2 — Brand migration and naming conventions

**Build**

1. Rename every CREA-8 / CREA8 / Crea8Space identifier to Atarah: package names (`@atarah/*`), the Dart package `atarah`, Android `applicationId` `app.atarah.mobile`, iOS bundle ID `app.atarah.mobile`, app display name "Atarah", NestJS app name, Docker service names, env-var prefixes (`ATARAH_`), API title "Atarah API", user-facing strings ("Verified by Atarah", "You're leaving Atarah", "Atarah members"), and the enum value previously called `CREA8_MANAGED` (now covered by `OpportunityTrust`/`ContentSource`, section 6).
2. Keep **"Luxaion"** only where it names the company or the payment processor ("Secure payment processed by Luxaion").
3. Add a CI check (`scripts/check-brand.sh`) that fails if "CREA-8", "CREA8" or "crea8" appears outside `docs/` history notes and `design/prototype/uploads/`.
4. Document naming conventions in `docs/DEVELOPMENT.md`: files, classes, providers, routes, endpoints, DB tables (snake_case plural via Prisma `@@map`), events (PascalCase past tense), feature flags (`kebab-case`).

**Done when:** the brand check passes, all apps still build and start, and the register shows the rename.

### P0-M3 — Backend core

**Build**

1. NestJS app in `apps/backend` with typed config (`@nestjs/config` + schema validation; the app refuses to start on missing or invalid env).
2. Global pieces: validation pipe (whitelist, forbid unknown), the error envelope filter (section 7.2), response envelope interceptor, request ID middleware, pino structured logging with redaction, Helmet, CORS allow-list per environment, Redis-backed throttler, graceful shutdown.
3. `/api/v1` prefix; Swagger UI at `/api/docs` in non-production; OpenAPI JSON export script feeding `packages/api-contracts`.
4. Health endpoints: `/health/live`, `/health/ready` (checks PostgreSQL, Redis, object storage).
5. Prisma client module, transaction helper, pagination helpers (offset and cursor), sorting whitelist helper.
6. `audit` module: `AuditLog` table and an `AuditService.record()` used by later modules; append-only at the database level (no update or delete grants for the app role on that table).
7. Feature-flag service (`PlatformSetting` + `FeatureFlag` tables, cached in Redis) with flags for every later-phase capability.
8. BullMQ setup with a worker process entry point (`apps/backend/src/worker.ts`), queues registry and a failed-jobs view for admin later.

**Tests:** unit tests for filters, interceptors and helpers; integration test proving the error envelope, validation errors, 404, rate limiting and health checks.

**Done when:** the backend and worker start against local PostgreSQL and Redis, `/api/docs` renders, and all tests pass.

### P0-M4 — Database baseline and domain vocabulary

**Build**

1. Write `docs/DOMAIN.md` from section 6 and the Domain & Data Model spec: every entity, its owner module, relationships, lifecycle enums, and visibility rules.
2. Create the baseline Prisma schema for the foundation entities: `User`, `Account` status, `Credential`, `Session`, `VerificationCode`, `ConsentRecord`, `Role`, `Permission`, `RolePermission`, `UserRole`, `MembershipPlan`, `Membership`, `Entitlement`, `MembershipEntitlement`, `Country`, `County`, `Town`, `Discipline`, `Specialisation`, `Skill`, `Interest`, `DevelopmentArea`, `MediaAsset`, `PlatformSetting`, `FeatureFlag`, `AuditLog`, `Notification`, `NotificationPreference`, `DeviceToken`. Later milestones add their own tables through new migrations.
3. Add all section 6 enums now so every module shares them.
4. Reference seed: roles and permissions (from the Roles & Permissions Matrix with section 6.1 applied), plans (FREE, PRO at KES 1,200/month), entitlements, Kenya + 47 counties with codes, the 12 disciplines with icons and specialisations, skills/interests/areas to develop, learning and marketplace categories, default settings (cancellation window 24 h, late refund 50%, verification SLA 5 working days, Pro price), and placeholder legal documents titled "DRAFT — pending legal review".
5. Demo seed (dev only, `isDemo = true`) for local testing.

**Tests:** migration up from empty; seed idempotency (running twice changes nothing); constraint tests for uniqueness and foreign keys.

**Done when:** `make db:migrate db:seed` works from scratch, `DOMAIN.md` and `DATABASE.md` are complete, and tests pass.

### P0-M5 — Identity, authentication and access control (backend)

_(COMPLETED under v2.0. Authentication moves to Supabase Auth in P1-M6; roles, permissions, entitlements and the access policies built here stay.)_

**Build**

1. `identity` module endpoints: `POST /auth/register`, `POST /auth/verify` (6-digit code), `POST /auth/resend-code`, `POST /auth/login`, `POST /auth/refresh`, `POST /auth/logout`, `POST /auth/logout-all`, `POST /auth/password/forgot`, `POST /auth/password/reset`, `GET /users/me`, `GET /auth/sessions`, `DELETE /auth/sessions/{id}`.
2. Implement the v2.0 authentication design (since replaced by Supabase Auth — section 5.5): Argon2id, JWT access + rotating refresh with reuse detection, hashed single-use codes, cooldowns, consent record at registration (terms and privacy version).
3. Email and SMS provider abstractions with a dev implementation (Mailpit for email, console/log sink for SMS) and a production adapter interface. Choose concrete production providers later (section 12); record the interface in `ARCHITECTURE.md`.
4. Google sign-in adapter behind the `google-sign-in` flag (disabled without credentials).
5. `access` module: guards for authentication, permission checks, entitlement checks (`@RequiresEntitlement`), account-status checks, and a policy helper for ownership and visibility. Denials map to `FORBIDDEN`, `PREMIUM_REQUIRED`, `VERIFICATION_REQUIRED` or `APPROVAL_REQUIRED`.
6. Admin authentication: separate login endpoint, TOTP enrolment and verification, admin session timeout (30 minutes idle), re-auth endpoint for sensitive actions.

**Tests:** full auth matrix — register (email and phone), duplicate identifiers, wrong code, expired code, cooldown, login success and failure, refresh rotation and reuse attack, logout, reset invalidating other sessions, suspended account denied, admin without TOTP denied.

**Done when:** every auth flow works through Swagger and the integration tests, and `SECURITY.md` documents tokens, codes and rate limits.

### P0-M6 — Design tokens and Flutter design system

_(COMPLETED under v2.0. Its tokens are replaced by the section 8 brand tokens in P1-M7.)_

**Build**

1. `packages/design-tokens/tokens.json` with everything in section 8.1, plus generators for Dart (`tokens.g.dart`, `AtColors`, `AtGradients`, `AtShadows`, `AtRadii`, `AtSpacing`, `AtTextStyles`) and CSS variables for web and admin.
2. `AtTheme` (Material 3 `ThemeData` built from the tokens; light theme only for now) with bundled Plus Jakarta Sans and Lucide icons.
3. Every component in section 8.2, each with its states (default, pressed, focused, disabled, loading, error) and semantics labels.
4. Dev-only component gallery route.

**Tests:** widget tests for interaction and states; golden tests for every component at 1× and with text scale 2.0.

**Done when:** the gallery matches the prototype's components side by side and the golden files are generated.

### P0-M7 — Mobile app shell

**Build**

1. Flavours (`dev`, `staging`, `prod`) with separate config and Firebase projects (dev config only for now; real keys are not committed).
2. `go_router` with: splash → session check → `welcome` / onboarding / `home` redirect logic; the five-tab `StatefulShellRoute` (Home, Explore, Community, Opportunities, Profile) with the prototype's tab styling; tab bar hidden on the `NO_TABS` screens; deep-link routes for profile, project, opportunity, course, lesson, listing, mentor, article, group and post (`https://atarah.app/...` and `atarah://...`), with "sign in, then return to the intended destination".
3. Networking: generated Dart client, dio interceptors (auth header, refresh-on-401 with a single-flight lock, request ID, error mapping to typed failures), retry for idempotent GETs.
4. Secure token storage, session restoration, global sign-out on refresh failure.
5. Connectivity provider and the global `AtOfflineBanner` ("You're offline. Saved content is still available.").
6. Every tab root and every entry point to unbuilt features routes to `AtFutureScreen` with the correct phase ("Soon · P1", "Soon · P2", "Soon · P3"). Replace each one as its milestone lands.
7. Crash and error reporting wired (Sentry or equivalent, DSN from env), analytics event interface (no-op sink in dev).

**Tests:** router redirect tests, interceptor tests (refresh single-flight), tab-shell widget test.

**Done when:** the app runs on the emulator, shows splash → welcome, the tab shell renders after a test login, deep links open the right placeholder, and nothing on screen is dead.

### P0-M8 — Web and admin shells

**Build**

1. `apps/web`: Next.js App Router, CSS variables from tokens, Plus Jakarta Sans via `next/font`, layout with the Atarah wordmark, a branded holding page ("Atarah — Create · Connect · Grow", join CTA linking to app-store placeholders behind a flag), `robots.txt` and sitemap scaffold, generated TS client.
2. `apps/admin`: Next.js app with admin login + TOTP, session handling, a permission-filtered sidebar matching the Admin Platform spec (Dashboard, Users, Memberships, Roles & Permissions, Verification, Content, Learning, Opportunities, Mentorship, Marketplace, Community & Reports, Creative Economy, Payments, Notifications, AI, Analytics, Audit Logs, Settings), unbuilt sections showing a "Soon · P#" panel, and two working pages: **Users** (search, view, suspend/reactivate with reason, audited) and **Audit Logs** (filterable, read-only).
3. Shared admin UI kit (table with server-side pagination, filters, status pill, confirm dialog, re-auth dialog).

**Tests:** component tests for the kit; Playwright: admin login with TOTP, suspend a user, see the audit entry.

**Done when:** both apps build and run locally against the backend and the Playwright flow passes.

### P0-M9 — Infrastructure, storage, notifications and CI

_(COMPLETED under v2.0. Local PostgreSQL, MinIO and Mailpit are replaced by the local Supabase stack, and storage by Supabase Storage, in P1-M6.)_

**Build**

1. `infrastructure/docker-compose.yml`: PostgreSQL 16, Redis 7, MinIO (with buckets `public-media`, `private-media`, `verification-evidence`), Mailpit. One command starts everything.
2. `media` module: request upload → signed URL → client uploads → confirm → validation job (MIME sniff, size, EXIF strip, image variants 200/600/1200 px) → `MediaAsset` ready. Signed download URLs for private assets.
3. `notifications` module: in-app notification store, preferences per category and channel (push, email), FCM sender, email sender (templated, Atarah-branded), SMS sender, all queued through BullMQ with retries; device-token registration endpoint.
4. CI pipeline definitions in `.github/workflows/` (files only; the owner pushes): install, brand check, lint, typecheck, test (with service containers), build for backend, web, admin; Flutter analyze, test and Android debug build. Cache dependencies.
5. `docs/DEVELOPMENT.md` complete: prerequisites, one-command setup, running each app, emulator setup, seeding, generating clients and tokens, troubleshooting.

**Tests:** media pipeline integration test (upload, validate, reject a disguised file); notification fan-out test respecting preferences.

**Phase 0 gate checks**

- Clean-machine setup following `DEVELOPMENT.md` works end to end.
- Backend, worker, web, admin and mobile all build and start; all tests pass; lint, typecheck and format pass; brand check passes.
- Auth matrix tests pass; admin TOTP flow passes in Playwright.
- The mobile shell runs on the Android emulator: splash, welcome, register via API (test tool or Swagger), sign in, tab shell, sign out; all later-phase entry points show "Soon · P#".
- No secrets in the repo (run a secret scanner such as gitleaks in no-git mode over the working tree).
- `PROJECT_PROGRESS.md`, `DECISIONS.md` and all docs are current.

Then announce **`PHASE 0 FOUNDATION REQUIREMENTS COMPLETE`**, write the gate report and stop.

---

## PHASE 1 — CORE MEMBER EXPERIENCE

Goal: a free member can join, build a credible creative identity, find people, take part in the community, discover and track opportunities, learn, and manage their account. Admins can run all of it. AI buttons, Marketplace, Mentorship, Verification, Membership upgrade, CV/EPK and Creative Economy entry points still open `AtFutureScreen` with their phase.

Every milestone delivers backend + database + mobile + admin (and web only where stated), with tests and an emulator walkthrough.

### P1-M1 — Entry and authentication screens

**Screens:** `splash`, `welcome`, `signup`, `signin`, `verify`, `forgot`, `reset`.

**Build**

1. **Splash:** Indigo brand gradient, brand ring motif, the reversed primary logo (300 px, with brand line), progress bar. Restores the session and routes: no session → `welcome`; signed in but onboarding incomplete → the next onboarding step; complete → `home`. No tap-to-continue in production.
2. **Welcome:** the colour logo without brand line (140 px), image collage (artwork from `design/prototype/assets`, replace with licensed brand imagery when supplied), headline "One creative identity. Many connected possibilities.", four pillar tiles, "Create account", "Sign in", Terms and Privacy links opening the legal documents (P1-M11 renders them; until then they open the seeded draft text read-only).
3. **Sign up:** full name, "Email or phone number" (detect which; phone normalised to E.164 with +254 default), password with show/hide and the 4-segment strength meter, consent checkbox (required; links to Terms and Privacy). "Continue with Google" shown only when the flag is on. Server errors mapped to field errors (e.g. "An account with this email already exists. Sign in instead?").
4. **Verify:** six-box code input with auto-advance and paste support; "Resend in 0:42" countdown driven by the server cooldown; "Why we verify" and "What's next" panel; CTA disabled until 6 digits.
5. **Sign in:** inline error banner exactly as the prototype ("That password doesn't match this account. Check it and try again, or reset it."), lockout message after repeated failures, "Forgot password?".
6. **Forgot / Reset:** request code (success banner "Code sent. It expires in 15 minutes."), then code + new password + confirm; on success, sign in and inform that other devices were signed out.
7. Analytics events: `user_registered`, `verification_completed`, `sign_in`.

**Tests:** widget tests for every state; integration test: register → verify → onboarding entry; sign-in failure then success; forgot → reset → sign-in.

**Done when:** all seven screens match the prototype and work on the emulator against the real backend, including the error and success banners.

### P1-M2 — Onboarding and creative profile creation

**Screens:** `ob_intro`, `ob_disc`, `ob_spec`, `ob_skills`, `ob_loc`, `ob_basics`, `ob_photo`, `ob_done`.

**Database:** `CreativeProfile` (handle, display name, headline, bio, primary discipline, county, town, location visibility, avatar media, onboarding step, completion %), `CreativeDiscipline`, `CreativeSpecialisation`, `CreativeSkill`, `CreativeInterest`, `CreativeDevelopmentArea`, `SpecialisationSuggestion`, `CreativePassport` (passport number, created at).

**API:** `GET /taxonomy/disciplines` (with specialisations), `GET /taxonomy/skills?discipline=`, `GET /taxonomy/interests`, `GET /taxonomy/development-areas`, `GET /locations/countries`, `GET /locations/counties?country=`, `PATCH /me/onboarding` (per step, resumable), `GET /handles/{handle}/availability`, `POST /me/avatar` (via media), `POST /me/onboarding/complete`, `POST /taxonomy/specialisations/suggestions`.

**Build**

1. The shell from the prototype: back, progress bar (step/8), "Skip", "Step n of 6", CTA ("Get started" / "Continue" / "Finish"). Each step saves to the server so onboarding resumes where it stopped. "Skip" saves nothing for that step and moves on; completion % reflects skipped steps.
2. Discipline (single choice, 3-column tiles; changing it clears specialisations); specialisation (multi-select rows, "+ Suggest a specialization" opens a small sheet and submits to the admin queue); skills / interests / areas to develop (chips with counters); location (country, county, optional town, "Use my current location" with permission prompt and reverse lookup to county, visibility segmented control with the three explanatory notes).
3. Profile basics: display name, profile link `atarah.app/{handle}` with live availability check and suggestions, short bio with 160-character counter. "✨ Help me write this" opens `AtFutureScreen` ("Soon · P3").
4. Profile photo: gallery or camera (image_picker), crop to circle, upload through the media pipeline, "Skip for now".
5. Completion: generate the Passport number (section 6.8), show the dark completion screen with the Passport preview and real completion percentage, "Go to Home".
6. **Profile completion engine** (backend, reused everywhere): weighted checklist (photo, bio, discipline, specialisation, ≥3 skills, location, ≥1 project, ≥1 experience, contact verified, …) returning percentage and the next missing items. Document the weights in `DOMAIN.md`.
7. Admin: taxonomy management (disciplines, specialisations, skills, interests, development areas: create, edit, reorder, archive) and the specialisation-suggestion queue (approve, merge, reject).

**Tests:** onboarding resume after app kill; handle uniqueness race; completion engine unit tests; admin taxonomy Playwright test.

**Done when:** a new account completes onboarding on the emulator, the data persists, and the Passport number and completion % are real.

### P1-M3 — My profile, Creative Passport and public creative profile

**Screens:** `profile`, `passport`, `creative` (another member's profile), plus Passport/profile parts of `privacy` (full privacy screen ships in P1-M11).

**Database:** `ProfileSectionVisibility` (section → visibility), `ProfileLink` (social links), contact preferences, `GrowthSnapshot` (optional cache).

**API:** `GET /me/profile`, `PATCH /me/profile`, `GET /me/passport`, `PATCH /me/passport/visibility`, `GET /creatives/{handle}` (visibility-filtered for the viewer: anonymous, member, connection, owner), `GET /me/growth`.

**Build**

1. **My profile:** avatar with the completion ring and % badge; name, verified tick (shown only when a real verification exists — none yet in Phase 1), headline and city; "Public view" (opens own `creative` page as others see it, with a viewer toggle: Public / Members); "Improve my bio" → `AtFutureScreen` ("Soon · P3"); Creative Passport card with the next best action from the completion engine; "Your tools" section shown only for mentor/seller roles (entries → "Soon · P2"); "My creative identity" list with live counts; second list (Activity, Saved, Membership showing Free/Pro, Settings). Edit profile sheet for name, headline, bio, links and contact preferences.
2. **Creative Passport:** the Passport card (number, discipline line, location, member since, trust pills only when real), **Growth** bars computed from real data (identity, portfolio, skills, learning, connections, professionalisation — document the formulas in `DOMAIN.md`), "Sections & visibility" rows that change visibility inline, "Copy link" (copies `https://atarah.app/{handle}`), "Create CV / EPK" → "Soon · P2".
3. **Creative profile (others):** cover, avatar, name, headline, location and availability ("Open to commissions"), **Connect** (build the `Connection` table and the request/accept/decline/remove endpoints in this milestone so the button works; P1-M8 adds suggestions and lists), Message → "Soon · Later" (messaging is not in scope; record in `DECISIONS.md`), segmented About / Portfolio / Services. Services tab shows profile services (P1-M4 data). All fields respect visibility.
4. Share: native share sheet with the public URL for public profiles.

**Tests:** visibility matrix tests (owner, connection, member, anonymous × each section); growth formula unit tests; widget tests for both profile variants.

**Done when:** changing a section's visibility immediately changes what another test account sees on the emulator.

### P1-M4 — Portfolio, projects, skills, experience, achievements and services

**Screens:** `portfolio`, `project`, `project_new`, `skills`, `experience`, `achievements`, `services`.

**Database:** `Project` (title, role, client, date, category/discipline, description, outcome, external links, featured, status DRAFT/PUBLISHED, visibility), `ProjectMedia` (image, video, audio; order), `ProjectSkill`, `ProjectCollaborator` (member link or free-text name + role), `Experience`, `Achievement` (type: award, certificate, feature, selection, nomination; source: manual or system), `ProfileService` (title, description, price type, price, status PROFILE_ONLY/ON_MARKETPLACE).

**API:** CRUD for each under `/me/...`, read endpoints under `/creatives/{handle}/...` (visibility-filtered), `POST /me/projects/{id}/publish`, collaborator invitations (a tagged member receives a notification and can accept or remove themselves).

**Build**

1. **Portfolio:** chips Featured / Projects / Media / Publications / Performances (filter by project category), featured hero, 2-column grid, dashed "+ Add project".
2. **Add project:** "Tell the story of your work" flow — upload zone (up to 10 files: images, video, audio, through the media pipeline with progress and retry), title, role, date, description, "✨ Help describe this" → "Soon · P3", skills chips, collaborators (search members or add by name), outcome and external links. **Autosaved drafts** ("Save draft" works), "Preview project" then Publish.
3. **Project detail:** media first (image gallery, video player, audio player; embedded YouTube/Vimeo links play through the embed), pills, title, role and client, description, skills used, collaborators (tap → their profile), outcome box, external link (opens via the leaving-Atarah pattern for external URLs), Edit and Share for the owner.
4. **Skills:** cards with level bar, status pill (Self-declared until P2-M6), "Improve this skill" → Skill Labs filtered by the skill (P1-M10; until then "Soon · P1"), "Find opportunities" → opportunities filtered by the skill (P1-M9), "Verify" → "Soon · P2". Add and edit skill sheet (taxonomy search, level).
5. **Experience:** timeline with add/edit/delete; **Achievements:** list with add/edit; certificates from Skill Labs are added automatically in P1-M10.
6. **Services:** profile services with "Profile only" status; "Publish" and "View listing" → "Soon · P2". "+" → add service form.
7. Admin: profile and portfolio moderation (view a member's public content, hide a project with reason, audited).

**Tests:** media upload failure and retry; draft autosave and resume; ownership tests (cannot edit another member's project); collaborator acceptance.

**Done when:** a member can build a full portfolio with real media on the emulator and see it on their public profile.

### P1-M5 — Home, Explore, search, filters and articles

**Screens:** `home`, `explore`, `search`, `filters`, `article`, plus the Explore tiles' routing.

**Database:** `Article` (slug, title, summary, body as structured blocks, hero media, author, source ATARAH/PARTNER/EXTERNAL, read time, published at, tags, related learning), `SearchDocument` materialised view or per-entity `tsvector` columns, `RecentSearch`.

**API:** `GET /home` (one aggregated, personalised payload with section-level fallbacks), `GET /creatives` (filters: discipline, specialisation, county, availability, verified; sort: relevance, recent), `GET /search?q=&type=` (grouped results with counts: creatives, opportunities, learning, marketplace, mentors, articles — types not yet built return no group), `GET /me/recent-searches`, `GET /articles`, `GET /articles/{slug}`.

**Build**

1. **Home** in the prototype order: header (wordmark, bell with unread dot → notifications, avatar → profile); hero "Welcome, {first name}" with the dark completion card; Quick Access tiles; Featured (an admin-pinned featured opportunity); "Continue learning" (hidden when nothing is in progress); "Recommended for you" with a **reason line** ("Because you selected Animation and Visual Art"); "Creatives to meet"; "From the community"; Marketplace and Mentorship tiles ("Soon · P2"); article card. Recommendations are **rule-based** in Phase 1 (discipline, skills, interests, county, deadlines) and always explain why. Sections with no data are hidden, not shown empty.
2. **Explore:** discipline tiles (from taxonomy), creative cards (96px image, name, tick, role, tags, location), the empty state "No creatives in this discipline yet nearby. Show all", "More to explore" tiles (Skill Labs, Opportunities, Marketplace → P2, Mentorship → P2, Articles, Creative economy → P3), "Want to be discovered?" card → Passport.
3. **Search:** focused field with clear button, type tabs with counts, recent searches (stored per user, deletable), grouped results with "See all {n}", debounced queries, `pg_trgm` typo tolerance. Results respect visibility.
4. **Filters sheet:** context-sensitive groups (discipline, location, availability), "Verified only" toggle (filters on real verification; returns nothing in Phase 1 unless seeded by admins — that is honest), "Reset", "Show {n} results" with a live count.
5. **Article:** source pill, title, byline, hero, body blocks (paragraph, heading, callout "Rule of thumb", image, quote), related Skill Lab card, save (P1-M11 saved items — wire the endpoint now) and share.
6. Admin: Articles CMS (draft → review → publish → archive, block editor, source label, hero upload, scheduling), Home curation (pin featured opportunity and featured article).

**Tests:** home aggregation with empty, new-user and established-user fixtures; search relevance and visibility tests; widget tests for every Home section's empty/hidden logic.

**Done when:** Home shows only real data, every tile goes somewhere real or to a labelled future screen, and search returns grouped, visibility-safe results on the emulator.

### P1-M6 — Supabase platform adoption

**Why:** the product owner chose Supabase as the backend platform after Phase 0. This milestone moves the database, authentication, storage and local development onto Supabase (sections 5.5 and 5.7). NestJS stays the API, and **every existing feature keeps working**. If the backend platform report (section 0.1, step 5) shows the code already uses Supabase, this milestone is an alignment pass: verify and fix each item below.

**Inputs:**

- The local Supabase stack (Supabase CLI).
- The dev and staging Supabase projects, plus their keys and database URLs, supplied by the product owner. If those are not supplied, do everything against the local stack and mark the cloud checks BLOCKED.

**Build**

1. **Local platform.**
   - Run `supabase init` (commit `supabase/config.toml`).
   - Configure the Auth settings in `config.toml`:
     - OTP length 6, expiry 600 s
     - password policy
     - refresh-token rotation and reuse detection
     - MFA phone and TOTP
     - SMS hook
     - custom SMTP placeholder
     - Atarah email templates using the 6-digit token
   - Reduce `infrastructure/docker-compose.yml` to Redis only; Supabase local replaces PostgreSQL, MinIO and Mailpit.
   - `make dev` starts Supabase, Redis, the backend, the worker, web and admin.
2. **Database.**
   - Point Prisma at Supabase: `DATABASE_URL` through the pooler, `DIRECT_URL` for migrations.
   - Apply all existing migrations to a fresh local Supabase database and check that they replay cleanly.
   - Add the SQL-in-migration pieces from section 5.7: the `auth.users` triggers and FK, the RLS-enable-all migration, the backend database role and grants, and the Realtime publication for `notifications` with its single policy.
   - Add `scripts/check-rls.sql` to CI.
   - Migrate existing dev data with a script (`scripts/migrate-dev-data.ts`), recreating dev users through the Auth admin API. There are no production users yet; confirm this in the report.
3. **Authentication.**
   - Replace the NestJS-issued credentials, tokens and codes with Supabase Auth, as in section 5.5.
   - Mobile: `supabase_flutter` for every P1-M1 flow (sign up, verify code, resend, sign in, forgot/reset by code, sign out). Keep the existing screens and copy unchanged. The dio interceptor attaches the Supabase access token; the SDK refreshes it.
   - Backend: `SupabaseAuthGuard`, user bootstrap through the triggers, `GET /users/me` unchanged, `GET/DELETE /auth/sessions` through the service role, and the `POST /auth/hooks/send-sms` hook with the SMS adapter.
   - Admin app: Supabase Auth with TOTP MFA; AAL2 required on `/admin/*`.
   - Remove the replaced NestJS auth endpoints and their tables (`credentials`, `sessions`, `verification_codes`, and similar) in a final migration, **dev and staging only**, and record it. They hold no production data.
4. **Storage.**
   - Implement the Supabase Storage adapter behind the existing storage interface. Create the three buckets with their policies.
   - Move existing dev media from MinIO to Supabase Storage with a script.
   - Signed upload and download URLs keep the same API shape, so the clients do not change.
   - The media validation and variant job reads from and writes to Supabase Storage.
5. **Realtime.** Subscribe to the member's own `notifications` inserts in the app, to update the unread badge live. The full notifications list ships in P1-M11.
6. **Tests and CI.**
   - Integration tests run against the **local Supabase stack** (started in CI with the Supabase CLI) plus Redis, replacing Testcontainers PostgreSQL.
   - Auth tests use real Supabase Auth flows (local).
   - The RLS check runs in CI.
   - Add a test that proves the anon key cannot read or write any application table.
7. **Environments and docs.**
   - Wire the dev and staging projects (migrations applied by a pipeline job when credentials exist).
   - Update `.env.example` for every app, `docs/ARCHITECTURE.md` (diagram: apps → Supabase Auth; apps → NestJS → Supabase Postgres/Storage; Redis/BullMQ), `docs/DEVELOPMENT.md`, `docs/SECURITY.md` (keys, RLS, hooks) and `docs/DATABASE.md`.
   - Record every decision.
8. **Backend and database gap-fill.** Close every gap found by the baseline audit (section 0.1, step 7) for Phase 0 and P1-M1 … P1-M5, so those milestones meet section 7.9 and Appendix A: missing tables, constraints, indexes, endpoints, admin endpoints, rate limits, events, jobs, OpenAPI entries and integration tests.

**Tests:**

- The full existing backend suite passes on Supabase.
- Auth matrix on Supabase:
  - register with email and with phone
  - wrong code, expired code, resend cooldown
  - sign-in failure and success
  - refresh
  - password reset signs out other devices
  - suspended account denied by the guard
  - admin without AAL2 denied
- Storage upload, download and authorisation tests.
- RLS and anon-key denial tests.
- Realtime notification delivery test.
- The P1-M1 … P1-M5 journeys pass on the emulator against local Supabase.

**Done when:**

- The app, web and admin run against Supabase (local, plus dev when credentials exist) with no feature regressions.
- No NestJS-issued auth tokens or MinIO remain.
- Every table has RLS enabled.
- All tests and checks pass.
- `docs/SUPABASE_ADOPTION.md` is marked complete with evidence.

### P1-M7 — Brand refresh and dark appearance (retrofit)

**Why:** the brand identity was approved after P1-M5. This milestone brings everything already built (Phase 0 and P1-M1 … P1-M5) onto the final logo, palette and dark appearance, so that every later milestone is built on the final design system. It changes **visual identity only** — no flows, copy, endpoints or data change, except the new appearance preference.

**Inputs:** the updated prototype (replace `design/prototype/` with the new version), the logo pack and `Atarah - Logo & Brand Identity Guidelines.pdf`.

**Build**

1. **Brand assets.**
   - Copy the guidelines PDF into `docs/brand/` and the full logo pack into `docs/brand/logo-pack/` (source of truth).
   - Mobile: add the SVGs used by the app to `apps/mobile/assets/brand/` (`flutter_svg`).
   - Web and admin: add the SVGs to `public/brand/` and set the favicon from `favicon-16/32/64.png`.
   - Delete `ribbon.png` and every reference to it.
2. **Tokens.**
   - Rewrite `packages/design-tokens/tokens.json` with the light **and** dark sets from section 8.
   - Regenerate the Dart and CSS outputs.
   - Remove every old colour value from the codebase.
   - Add `scripts/check-colors.sh` to CI. It fails if any of these old values appear in app, web or admin source: `#5b45f0`, `#15133d`, `#4330d6`, `#7b6cf6`, `#5a46ee`, `#e8457a`, `#c62f63`, `#f08a24`, `#c76a10`, `#2f6fe0`, `#8b5cf6`, `#c78a10`, `#f5a524`, `#4a36e0`, `#3b2bc4`, `#1c1a4a`, `#25206a`, `#2f2783`, `#fde7c4`, `#fbd38d`.
3. **Theme.**
   - Build `AtTheme.light` and `AtTheme.dark` (Material 3 `ThemeData` plus an `AtColors` `ThemeExtension`).
   - Every `At*` component reads colours only from the theme. No literal colours in widgets.
4. **New components.**
   - `AtLogo` (variants and automatic reversed version in dark mode; minimum-size assertion in debug).
   - `AtBrandRing` (the ring motif from section 8.1).
   - `AtProPill`.
   - `AtAppearanceToggle`.
   - Make the system-author variant of `AtAvatar`.
5. **Retrofit built screens** to match the updated prototype exactly, in light and dark:
   - `splash`: reversed primary logo at 300 px on the Indigo gradient, plus the brand ring.
   - `welcome`: 140 px logo, no tagline text.
   - Auth screens.
   - All onboarding steps, including the `ob_done` Passport preview with the symbol.
   - `home`: 126 px header logo and the ring on the dark completion card.
   - `explore`, `search`, `filters`, `article`.
   - `profile`, `passport` (symbol in the card header, ring motif), `creative`.
   - Portfolio, project, skills, experience, achievements and services screens.
   - Verified badges now use Indigo on `#EFEDFF`.
   - All semantic pills follow section 8.2.
6. **Appearance setting.**
   - Backend: add `appearance` (`LIGHT` | `DARK`; default `LIGHT`) to the member's preferences (`PATCH /me/preferences`, included in `GET /users/me`).
   - Mobile: store the choice locally, apply it before the first frame (no flash of the wrong theme), and sync it with the account when online.
   - Add the **Appearance** row (sun/moon icon, current value; tapping toggles) to the Settings → Account group in the position shown in the prototype. If the full Settings screen does not exist yet (it ships in P1-M11), add a minimal Settings entry so the toggle is reachable. P1-M11 then completes the screen around it.
   - Status bar and navigation bar styles follow the appearance and the dark brand screens.
7. **App identity.**
   - Generate launcher icons with `flutter_launcher_icons` from `atarah-app-icon-light-square-fullbleed-1024.png`. Android adaptive icon: foreground is the colour symbol in the safe zone; background is `#FBFAFB`.
   - Generate the native splash with `flutter_native_splash`: Indigo `#5145D8` background with the reversed symbol, handing over seamlessly to the Flutter `splash` screen.
   - Set the app display name "Atarah" on Android and iOS.
8. **Web and admin shells.**
   - Replace the logo and colours: CSS variables from the new tokens; admin sidebar logo 130 px.
   - Add a dark appearance to the admin (follows the system setting, with a manual override).
   - The public web holding page uses the light theme for now.
9. **Docs.** Update `docs/ARCHITECTURE.md` (theming), `docs/DEVELOPMENT.md` (how to regenerate tokens, icons and splash), and `DECISIONS.md`. Add `docs/brand/README.md` with the logo usage rules from section 8.4.
10. **Appearance preference storage.** Build the `member_preferences` table (RLS enabled) and `GET/PATCH /me/preferences`; the general backend gap-fill was done in P1-M6.

**Tests**

- Regenerate every golden test in light **and** dark.
- Widget tests for `AtLogo` (correct file per appearance; minimum-size assertion) and `AtAppearanceToggle`.
- Appearance persistence test: restart the app and the choice is kept; sign in on another device and the choice is synced.
- Contrast check on the token pairs listed in section 8.1 for both appearances (body text ≥ 4.5:1).
- `check-colors.sh` and `check-brand.sh` pass.
- Re-run the P1-M1 … P1-M5 journeys on the emulator in both appearances.

**Done when:**

- Every screen built so far matches the updated prototype side by side in light and dark.
- No old colour or ribbon artwork remains.
- The launcher icon and native splash show the new logo on the emulator.
- The appearance choice persists and syncs.
- All tests, lint, typecheck and builds pass.

### P1-M8 — Community: feed, posts, groups, connections and safety

**Screens:** `community`, `post`, `compose`, `groups`, `group`, `creatives` ("People to meet").

**Database:** `Post` (type, body, media, audience, group, status), `Comment` (threaded via parent), `Reaction`, `SavedPost` (via the saved-items table), `Group` (type, name, description, cover, location/discipline links, visibility), `GroupMembership` (role: member/moderator/owner), `GroupPin`, `Connection`, `Block`, `Mute` (user or thread), `Report`, `ModerationCase`, `ModerationActionLog`.

**API:** feed (`GET /community/feed`, cursor-paginated, ranked by recency with light relevance from discipline/county/group), post CRUD, comments, reactions, groups (list, discover by type, join/leave, pinned announcement, recent discussions), connections (request, accept, decline, remove, list, suggestions: "People to meet" with reason), block, mute, `POST /reports`.

**Backend & database (complete)**

_Tables_ (module `community`):

- `posts`: `author_id` → users, `type` (`PostType`), `body` (text, ≤ 5,000 chars), `audience` (`PostAudience`), `group_id` (nullable → groups), `status` (`VISIBLE`, `HIDDEN`, `REMOVED`), `reaction_count`, `reply_count`, `is_staff_announcement`, `search_vector`, timestamps, `deleted_at`.
- `post_media`: `post_id`, `media_asset_id`, `sort_order` (max 10 per post).
- `post_links`: `post_id`, `url`, `title`, `image`, `fetched_at`. Link previews are fetched server-side by a job with an SSRF-safe fetcher.
- `post_attachments`: `post_id`, `opportunity_id` (enabled in P1-M9).
- `comments`: `post_id`, `author_id`, `parent_comment_id` (one reply level), `body` (≤ 2,000), `status`, timestamps.
- `reactions`: unique (`post_id`, `user_id`).
- `groups`: unique `slug`, `type` (`GroupType`), `name`, `description`, `cover_media_id`, `discipline_id`, `county_id`, `is_official`, `visibility`, `member_count`.
- `group_memberships`: unique (`group_id`, `user_id`), `role` (`MEMBER`, `MODERATOR`, `OWNER`).
- `group_pins`: `group_id`, `post_id`, `pinned_by`.
- `connections`: exists since P1-M3. Add a unique index on the unordered pair (least/greatest user id) and a check that `requester_id <> recipient_id`.
- `blocks`: unique (`blocker_id`, `blocked_id`).
- `mutes`: `user_id`, `target_type` (`USER`, `POST`), `target_id`.
- `reports`: `reporter_id`, `target_type`, `target_id`, `reason` (`ReportReason`), `note`, `status` (`ReportStatus`).
- `moderation_cases`: one per reported target, with priority and assignee.
- `moderation_actions`: append-only; `action` (`ModerationAction`), `reason`, `actor_id`.

_Indexes:_

- `posts`: (`group_id`, `created_at desc`), (`author_id`, `created_at desc`), (`status`, `created_at desc`), GIN on `search_vector`.
- `comments`: (`post_id`, `created_at`).
- `reports`: (`status`, `created_at`).

_Services and rules:_

- `FeedService` applies audience, group membership, blocks (both directions), mutes and `status = VISIBLE` **in SQL**, with cursor pagination on (`created_at`, `id`).
- Counters change in the same transaction as the reaction or comment; a nightly job reconciles them.
- Announcements require the `community.announce` permission.
- Posting, commenting and connection requests require an `ACTIVE` account with a verified email or phone.
- Authors edit or delete their own content. Moderators act through moderation actions only, never direct edits.

_Rate limits:_

- posts: 10 per hour
- comments: 60 per hour
- reactions: 300 per hour
- reports: 20 per day
- connection requests: 50 per day

_Events → consumers:_ `PostCreated`, `CommentCreated`, `ReactionAdded`, `ConnectionRequested`, `ConnectionAccepted`, `ReportSubmitted`, `ModerationActionTaken` → notifications, search index, analytics.

_Admin API:_

- `GET /admin/reports`, `GET /admin/moderation-cases`, `POST /admin/moderation-cases/{id}/actions`, `POST /admin/moderation-cases/{id}/assign`
- `/admin/groups` (CRUD, assign moderators, pin)
- `POST /admin/announcements`

_Jobs:_ link-preview fetch, nightly counter reconciliation, moderation backlog alert (cases older than 48 h).

_Seed:_ reference: none (official groups are created by admins); demo: groups, posts, comments, connections.

**Build**

1. **Feed:** header with "+" → compose; tab chips Feed / Discussions / Groups / People; composer prompt; post cards with type pills (colours from section 8), media, like (optimistic, pink active state), replies, share, save.
2. **Discussion:** full thread, replies with timestamps, fixed reply bar, overflow menu: Save discussion, Mute thread, Block author, Report (reason sheet using `ReportReason`, optional note, confirmation that explains what happens next).
3. **Compose:** type chips (Update, Question, Discussion, Collaboration; Announcement only for staff), text, attachments (photo, video, link with preview; "Opportunity" attaches an opportunity from P1-M9 — until it lands, "Soon · P1"), audience row ("Atarah members" default; Public, Connections, or a group), autosaved draft ("Draft saved automatically"), Post.
4. **Groups:** "Your groups" carousel, discover with type filters, Join/Joined toggle; **Group:** hero, join/share, pinned announcement, recent discussions, group-scoped posting.
5. **People to meet:** reason line, filter chips (discipline, county, verified, open to work), cards with save and Connect/Requested. Connection requests notify the recipient; accepting notifies the requester (notifications delivered in-app and push).
6. Reuse the connection endpoints from P1-M3; add the connections list and incoming-requests view under Community → People.
7. Blocking hides content both ways and prevents connection requests, comments and mentions.
8. Admin: moderation queue (report, content, reporter, author, reason, priority, status, history, actions from `ModerationAction`), user restrictions, group management (create official groups, assign moderators, pin announcements), staff announcements.

**Tests:** feed pagination and audience filtering; block enforcement in feed, comments and search; report → moderation → action → reporter notified without internal details; optimistic like rollback on failure.

**Done when:** two test accounts on emulator(s) can connect, post, reply, report and see moderation outcomes.

### P1-M9 — Opportunities

**Screens:** `opps`, `opp_list`, `opp`, `opp_leave`, `opp_saved`, and the `applications` view data (screen ships in P1-M11). `opp_ai` → "Soon · P3".

**Database:** `OpportunityProvider` (organisation name, type, logo, website, verification status, opportunities count), `Opportunity` (type, title, provider, summary, about, requirements list, benefits list, eligibility rules (structured), value amount + currency or text, deadline, location/county/remote/hybrid, application method + URL/domain, trust badge, status, source details: original URL, imported at, last checked at, featured), `OpportunityRequirementRule` (structured checks: residency, age range, discipline set, min projects, document type such as artist statement), `OpportunityTracking` (user, status, applied at, outcome, notes), `ExternalLinkCheck`.

**API:** `GET /opportunities` (filters: type, discipline, county, remote, deadline window, trust; sort: deadline, recent, relevance), `GET /opportunities/{id}` (includes the **profile-gap** evaluation for the signed-in viewer), save/unsave, `POST /opportunities/{id}/track` (status changes), `GET /me/opportunities?tab=all|closing|applied|completed`, provider endpoints for later (`/provider/opportunities`, behind the OPPORTUNITY_PROVIDER role, submissions land in `PENDING_REVIEW`).

**Backend & database (complete)**

_Tables_ (module `opportunities`):

- `opportunity_providers`: `name`, `type` (government, NGO, corporate, festival, studio, education, other), `logo_media_id`, `website`, `verification_status`, `owner_user_id` (nullable), `opportunities_count`.
- `opportunities`:
  - `provider_id`, unique `slug`, `type` (`OpportunityType`), `title`, `summary`, `about`, `requirements` (jsonb list), `benefits` (jsonb list)
  - value: `value_min_minor`, `value_max_minor`, `value_currency`, `value_text`
  - `deadline_at` (timestamptz), `country_id`, `county_id`, `work_mode` (`ONSITE`, `REMOTE`, `HYBRID`)
  - `application_method` (`ApplicationMethod`), `application_url`, `application_domain` (derived)
  - `trust` (`OpportunityTrust`), `status` (`OpportunityStatus`), `featured_until`, `is_public` (for P3 web)
  - source and link health: `source_url`, `imported_at`, `last_checked_at`, `link_status`
  - `created_by`, `search_vector`, timestamps
- `opportunity_disciplines`: join table.
- `opportunity_requirement_rules`: `opportunity_id`, `rule_type` (`RESIDENCY`, `AGE_RANGE`, `DISCIPLINE_IN`, `SKILL_IN`, `MIN_PROJECTS`, `DOCUMENT`, `CUSTOM_TEXT`), `params` (jsonb, validated per type), `label`, `is_blocking`, `sort_order`.
- `opportunity_trackings`: unique (`user_id`, `opportunity_id`), `status` (`OpportunityTrackingStatus`), `saved_at`, `applied_at`, `completed_at`, `outcome` (`OpportunityOutcome`), `checklist` (jsonb), `notes`.
- `notification_dispatches`: shared, unique `dedupe_key`.
- `external_link_checks`: `opportunity_id`, `checked_at`, `http_status`, `result`.

_Indexes:_

- partial index on (`status`, `deadline_at`) where `status = 'PUBLISHED'`
- (`type`, `status`), (`county_id`, `status`), GIN on `search_vector`
- `opportunity_trackings` (`user_id`, `status`)

_Services and rules:_

- `RequirementRuleEngine` evaluates the rules server-side against the viewer's own profile. It returns met / missing / unknown per rule plus a fix link. It never exposes other members' data, and caches results per user and opportunity for 5 minutes.
- Tracking state machine: `SAVED → IN_PROGRESS → APPLIED → COMPLETED`; un-saving is allowed only from `SAVED`.
- "Closing soon" is computed, not stored.
- Providers cannot set `trust` or publish while unverified; only `opportunity.verify` can set `VERIFIED` (audited).

_Jobs:_

- hourly: expire opportunities past their deadline
- daily at 08:00 EAT: deadline reminders at 7 days and 1 day, respecting preferences and de-duplicated through `notification_dispatches`
- weekly: link-health check with a polite user-agent and timeout (flag only, never auto-remove)
- opportunity counts per provider and county refreshed nightly

_Events:_ `OpportunityPublished`, `OpportunitySaved`, `OpportunityApplied`, `OpportunityCompleted` → notifications, analytics, Passport achievements (when the outcome is `AWARDED`).

_Admin API:_

- `/admin/opportunities` (CRUD, structured rules editor), `POST …/{id}/publish|archive|feature|verify|set-trust`
- `/admin/opportunity-providers` (CRUD, verify)
- `POST /admin/opportunities/import` (CSV → validation report → preview → commit as `DRAFT` only)
- `GET /admin/opportunities/link-health`

_Rate limits:_ tracking changes 60 per minute; search 120 per minute.

_Seed:_ reference: none; demo: providers and opportunities of every type with rules.

**Build**

1. **Opportunities home:** header, saved button with live count badge, search entry, category tiles (All, Funding, Grants, Jobs, Internships, Gigs, Competitions, Festivals, Partnerships), Featured, Closing soon (urgency pills), Recently added.
2. **Category list:** title, "{n} open grants", sort control ("Deadline: soonest"), cards with trust badge, save, value and deadline tiles, filters sheet.
3. **Detail:** hero, type pill and trust badge ("✓ Verified by Atarah" only when status is `VERIFIED`), provider row, facts grid, **profile-gap card** computed by the backend from the structured rules against the member's real profile ("Your profile is missing 2 requirements", met/missing rows, "Add" links → `project_new`, CV → "Soon · P2", etc.), "Help me understand this" → "Soon · P3", About / Requirements / Benefits, save toggle, primary CTA labelled by method ("Apply on external website ↗").
4. **Leaving Atarah modal:** names the destination domain, states "Atarah doesn't receive or process this application.", checkbox "Track this as applied in Activity" (default on), "Continue to website ↗" (opens the system browser and records `APPLIED` only if the box was checked), "Stay on Atarah".
5. **My opportunities:** segmented All / Closing soon / Applied / Completed with status pills and the empty state ("Nothing completed yet …"). Members can mark an application completed with an outcome; `AWARDED` offers to add an achievement.
6. **Deadline reminders:** scheduled jobs notify members about saved opportunities 7 days and 1 day before the deadline (respecting preferences); expired opportunities move to `EXPIRED` automatically.
7. **Link health:** a weekly job checks external URLs and flags broken ones for admins (never silently removes).
8. Admin: opportunities CRUD with structured eligibility rules, providers, trust badge decisions with audit, featured flag, review queue for provider submissions, link-health report, CSV import with validation that **never auto-publishes**.

**Tests:** profile-gap rule engine unit tests; tracking state transitions; deadline job; trust badge cannot be set by a provider; external link modal behaviour.

**Done when:** a member discovers, saves, checks eligibility, leaves to apply, tracks and completes an opportunity on the emulator, and admins manage listings and badges.

### P1-M10 — Skill Labs (learning)

**Screens:** `labs`, `lab_cat`, `course`, `lesson`, `my_learning`.

**Database:** `LearningCategory` (group CREATIVE/BUSINESS/PROFESSIONAL), `LearningContent` (type, title, summary, category, disciplines, level, duration, source, delivery, provider name, instructor link, external URL, embed URL, cover, access FREE/PREMIUM_CONTENT, status), `Course`, `Lesson` (sequence, title, duration, body blocks, video asset or embed URL, practice prompt), `Enrolment`, `LessonProgress` (status, last position seconds), `ContentProgress` (for non-course items: started/completed), `Certificate` (issued on course completion, linked to an `Achievement`).

**API:** `GET /learning` (hub payload: continue learning, featured, categories, recommended with reasons), `GET /learning/categories/{slug}?type=`, `GET /learning/{id}` (detail with lesson states for the viewer), `POST /learning/{id}/enrol`, `PUT /learning/lessons/{id}/progress` (position, completed; idempotent), `GET /me/learning?tab=active|completed|saved`, `GET /me/learning/stats`.

**Backend & database (complete)**

_Tables_ (module `learning`):

- `learning_categories`: unique `slug`, `group` (`LearningCategoryGroup`), `name`, `sort_order`.
- `learning_contents`:
  - unique `slug`, `type` (`LearningContentType`), `title`, `summary`, `category_id`, `level` (`SkillLevel`), `duration_minutes`
  - `source` (`ContentSource`), `delivery` (`ContentDelivery`), `provider_name`, `instructor_user_id`
  - `external_url`, `embed_url` (host must be on the allow-list in `PlatformSetting`), `cover_media_id`, `access` (`FREE`, `PREMIUM_CONTENT`)
  - `status` (`PublicationStatus`), `published_at`, `what_you_learn` (jsonb), `who_its_for`, `search_vector`
- `learning_content_disciplines`, `learning_content_skills`: join tables (used by recommendations and "Improve this skill").
- `courses`: PK/FK to `learning_contents`, `lesson_count`, `total_minutes`, `sequential` (bool).
- `lessons`: `course_id`, `sequence` (unique per course), `title`, `duration_minutes`, `video_media_id` or `embed_url`, `body` (jsonb blocks), `practice_prompt`, `practice_skill_id`.
- `enrolments`: unique (`user_id`, `course_id`).
- `lesson_progress`: unique (`user_id`, `lesson_id`), `status` (`LessonProgressStatus`), `last_position_seconds`, `completed_at`.
- `content_progress`: unique (`user_id`, `content_id`), for non-course items.
- `learning_activity_daily`: (`user_id`, `date`, `minutes`), for "This month".
- `certificates`: unique (`user_id`, `course_id`), `certificate_number`, `issued_at`, `achievement_id`.

_Indexes:_ (`category_id`, `status`, `type`), GIN on `search_vector`, `lesson_progress` (`user_id`, `updated_at desc`).

_Services and rules:_

- Progress writes are idempotent and monotonic: position only moves forward unless the lesson is restarted; `completed_at` is set once.
- Sequential unlocking is computed from progress.
- Course completion runs in **one transaction**: certificate, achievement ("Atarah Skill Lab certificate · {month year}"), skill source updated to `LEARNING`, then emits `CourseCompleted`.
- `PREMIUM_CONTENT` items return `PREMIUM_REQUIRED` for free members, including on the video URL endpoint.
- Video: uploaded through the media pipeline. A worker job transcodes to 720p H.264 MP4 (ffmpeg) with a poster frame; playback uses short-lived signed URLs.

_Events:_ `CourseStarted`, `LessonCompleted`, `CourseCompleted` → Passport growth, notifications ("New Skill Lab recommended"), analytics.

_Admin API:_

- `/admin/learning/categories`, `/admin/learning/contents` (CRUD and publish workflow)
- `/admin/courses/{id}/lessons` (CRUD and reorder)
- `POST /admin/learning/progress-overrides` (explicit, reasoned, audited)
- `GET /admin/learning/analytics`

_Jobs:_ video transcode, embed availability check (weekly; flags broken embeds), daily learning-minutes rollup.

_Seed:_ reference: the learning categories (section 6.8) and the embed host allow-list; demo: courses with lessons of every content type and source.

**Build**

1. **Skill Labs hub:** "My learning" pill, Continue learning dark card (ring with real %), Featured Labs (source pill on image), Categories in the three tinted groups, Recommended with a reason line from the member's areas to develop and skills.
2. **Category:** group pill, title, count, type chips (All, Course, Tutorial, Toolkit, Webinar, Masterclass), cards with type and source pills; empty state per type ("No masterclasses in Portfolio Building yet. Explore all types").
3. **Course detail:** source pill ("✓ Atarah Course", "Partner content", "External resource") and delivery pill ("In-app lessons", "Embedded", "Opens outside Atarah"); level, lesson count, duration; progress box; What you'll learn; Who it's for; lessons with Done / Current / Locked states (lessons unlock sequentially for courses; non-course items have no locking); provider row; sticky CTA "Start learning" / "Continue learning".
4. **Lesson player:** native video from Supabase Storage (HLS or progressive MP4 with signed URLs) **or** an embedded player for permitted YouTube/Vimeo content; scrubber, play/pause, resume from last position; 7-segment lesson progress; body text; Practice box (its CTA "Add to portfolio" opens `project_new` prefilled with the lesson's skill); "What should I learn next?" → "Soon · P3"; "All lessons"; "Mark complete & next".
5. **External content:** opening an external resource uses the leaving-Atarah pattern and marks it started; the member can mark it complete manually.
6. **External failure states:** if an embed fails, show the prototype's "YouTube isn't responding … Atarah is working normally." error with "Go back to course"; if a link is dead, show "This link no longer works" with "Find similar".
7. **Completion:** issuing a course certificate creates an Achievement ("Atarah Skill Lab certificate · {month year}") and updates the Passport learning growth bar and the skill's source (`LEARNING`).
8. **My learning:** stat tiles (in progress, completed, hours this month — computed from progress events), segmented Active / Completed / Saved with progress bars.
9. Admin: learning CMS — categories, content items of all types, courses and lessons (ordering, video upload or embed URL validation against an allow-list of embeddable hosts), source and delivery labels, access level, publish workflow, instructor assignment, progress overrides (explicit and audited), content analytics (starts, completions).

**Tests:** progress idempotency and resume; sequential unlocking; certificate issuance exactly once; embed host allow-list; premium-content access denied for free members with `PREMIUM_REQUIRED` (gate UI uses `AtPremiumGate`; no premium content needs to exist yet).

**Done when:** a member enrols, watches, resumes after closing the app, completes a course and sees the certificate on their Passport on the emulator.

### P1-M11 — Activity, notifications, saved items, settings and system states

**Screens:** `activity`, `notifications`, `saved`, `applications`, `settings`, `account`, `privacy`, `notif_settings`, `security`, `help`, `legal`, `delete`, `membership` (read-only in Phase 1), and the system states `st_loading`, `st_empty`, `st_error`, `st_offline`, `st_premium` as reusable patterns.

**Database:** `SavedItem` (polymorphic: opportunity, learning, creative, listing, mentor, article, post; optional collection), `HelpArticle`, `FaqEntry`, `LegalDocument` (type, version, effective date, body), `DataExportRequest`, `AccountDeletionRequest`, `TwoStepSetting`.

**API:** `GET /me/activity` (resume cards + hub counts), notifications (`GET /notifications?category=`, mark read, mark all read, unread count), saved items (`GET /me/saved?type=`, add, remove — reused by every save button), `GET /me/applications`, account (`PATCH /me/account`, change email/phone with re-verification, username), privacy (`GET/PATCH /me/privacy` per field), notification preferences (category × push/email), security (`POST /me/password`, two-step on/off, sessions list and revoke), help (search, FAQ), legal documents, `POST /me/export` (queued, emailed link), `POST /me/delete` (requires typing DELETE and recent re-authentication).

**Backend & database (complete)**

_Tables_ (modules `saved`, `notifications`, `identity`, `content`, `admin`):

- `saved_items`: unique (`user_id`, `item_type`, `item_id`), `collection` (nullable). A nightly job hides entries whose target was removed.
- `notifications`: `user_id`, `category` (`NotificationCategory`), `type`, `title`, `body`, `target_route`, `data` (jsonb), `read_at`, `created_at`. Index on (`user_id`, `read_at`, `created_at desc`). Retained for 180 days.
- `notification_preferences`: unique (`user_id`, `category`, `channel`), `enabled`.
- `member_preferences`: `appearance` (from P1-M7), `locale`, `time_zone` (default `Africa/Nairobi`), `marketing_opt_in`.
- `profile_field_visibility`: unique (`user_id`, `field`). Extends P1-M3 section visibility to the per-field controls on the Privacy screen.
- Email and phone changes use Supabase Auth's change flows (secure email change with confirmation on both addresses; phone change with OTP). NestJS mirrors the confirmed values into `public.users` through the sync trigger and notifies the old contact.
- Two-step settings live in Supabase MFA factors (phone). `GET /me/security` reports the enrolled factors.
- `user_devices`: `user_id`, `device_hash`, `name`, `platform`, `last_seen_at` (from P1-M6). Used for "new device" detection and the sessions list.
- `help_articles`, `faq_entries`: ordered, published flag, `search_vector`.
- `legal_documents`: unique (`type`, `version`), `effective_at`, `body`, `published`. `consent_records` reference the version accepted.
- `data_export_requests`: `status`, `file_media_id`, `expires_at`.
- `account_deletion_requests`: `requested_at`, `purge_after` (+30 days), `status`, `cancelled_at`.

_Services and rules:_

- `GET /me/activity` is assembled from the learning, opportunities, portfolio, mentorship and marketplace modules through their services (P2 modules return empty until built).
- Unread counts are cached in Redis and invalidated on write.
- Notification dispatcher order:
  1. read preferences
  2. write in-app
  3. push through FCM
  4. email through the email provider
  5. de-duplicate through `notification_dispatches`
- Two-step sign-in: when the member has a phone MFA factor and signs in on a device not in `user_devices`, the app must complete the MFA challenge (AAL2) before the API accepts requests.
- Password change and contact change revoke other sessions.
- **Account deletion:**
  - Immediately: account `DEACTIVATED`, profile hidden, sessions revoked.
  - Within the 30-day grace period: sign-in offers "Restore account".
  - After 30 days, the purge job deletes personal data, media and private records, and deletes the Supabase Auth user through the admin API. Community posts and comments remain as "Deleted member" (record this in `DECISIONS.md`). The audit trail keeps only non-personal identifiers.
- **Data export:** a job builds a ZIP (JSON of every personal record plus the member's media), stores it privately, and emails a signed link valid for 7 days.

_Admin API:_

- `/admin/notifications/broadcasts` (targeting, scheduling, audited)
- `/admin/help-articles`, `/admin/faq`, `/admin/legal-documents` (versioned publish)
- `GET /admin/privacy-requests` (exports and deletions log)

_Jobs:_ notification fan-out, data export build, deletion purge (daily), saved-item cleanup (nightly), notification retention cleanup (daily).

_Rate limits:_

- export: 1 per 24 h
- contact change codes: 5 per hour
- password change: 5 per hour

**Build**

1. **Activity:** "Pick up where you left off" (unfinished lesson, opportunity with unmet requirements, draft project — real data) and the hub grid with live counts (Mentorship and Marketplace tiles → "Soon · P2").
2. **Notifications:** category chips, Today/Earlier grouping, unread styling and dot, tap → target screen via deep link, push notifications through FCM that open the same targets.
3. **Saved:** type chips and rows for every saved type; unsave from the row.
4. **Applications:** tracked opportunities with status pills (Applied, In progress, Completed) and meta lines.
5. **Settings** and sub-screens exactly as the prototype (the Appearance row from P1-M7 stays in the Account group): Account (verified badges on email/phone, "Save changes"), Privacy & visibility (per-field segmented control; changes apply immediately everywhere), Notification settings (toggle grid), Security (change password, two-step verification toggle with SMS/email code on new-device sign-in, active sessions with "Sign out"), Help (search, FAQ accordion, "Chat with us" → opens a support email or support form; record the choice in `DECISIONS.md`; "Safety centre" → help article on report/block/mute), Legal (renders `LegalDocument`s; seeded drafts are labelled "DRAFT — pending legal review"), Log out, **Delete account** (modal with consequences, type DELETE, re-auth, then soft-delete immediately, hide the profile, revoke sessions, and purge personal data after a 30-day grace period via a scheduled job; audit it).
6. **Membership (Phase 1):** shows the current plan (Free), the Free vs Pro table and the scholarship note; "Upgrade to Pro" → "Soon · P2".
7. **System states:** make `AtSkeleton`, `AtEmptyState` (the four prototype variants), `AtErrorState` (Atarah / External / Invalid link), offline handling and `AtPremiumGate` reusable, and confirm every Phase 1 screen uses them. **Offline:** cache the Passport, saved opportunities and in-progress lesson metadata for read-only offline use; mark server-only actions ("Apply", "Post", "Book") as needing a connection.
8. Admin: notification broadcast (targets: all members, role, discipline, county; scheduled; audited), help/FAQ and legal document management with versioning, data-export and deletion request log.

**Tests:** saved-item polymorphism; notification preference enforcement; privacy changes reflected in public profile and search; delete-account flow including grace-period purge job; two-step sign-in on a new device.

**Done when:** every Activity and Settings screen works with real data on the emulator, and every Phase 1 screen shows correct loading, empty, error and offline states.

### P1-M12 — Admin operations, analytics and Phase 1 hardening

**Build**

1. **Admin dashboard:** attention queues (reports pending, opportunities awaiting review, broken links, specialisation suggestions, failed jobs) with priority; key counts (new members, onboarding completion rate, active members, posts, saved/applied opportunities, course completions).
2. **Users:** full detail view (profile, roles, membership, status history, sessions, reports involving them), role assignment by permitted admins with re-auth and audit, suspension with reason and duration.
3. **Analytics events:** implement the event catalogue (registration, onboarding completion, profile completion, project created, post created, connection created, opportunity viewed/saved/applied, course started/completed, search performed) into an `AnalyticsEvent` table with a privacy-safe schema; basic charts in admin.
4. **End-to-end journeys** (Flutter `integration_test` on the emulator): (a) new creative: sign-up → verify → onboarding → home → add project → public profile; (b) opportunity: search → detail → gap card → save → leave → applied → completed; (c) learning: hub → course → lesson → resume → complete → certificate; (d) community: post → reply → report → moderation outcome; (e) settings: privacy change → another account sees the change; delete account.
5. **Hardening:** fix every issue found; run accessibility checks on all Phase 1 screens (screen reader labels, contrast, text scale 200%); performance check (cold start, list scrolling, image sizes); audit that every visible entry point is real or a labelled `AtFutureScreen`.

**Backend & database completion audit (Phase 1)** — do this before the gate checks:

1. **Schema:**
   - Migrate from an empty database, seed, and run all tests.
   - Migrate a copy of the dev database carrying data from every Phase 1 milestone.
   - Regenerate the ER diagram.
   - Check every foreign key, unique constraint and index against Appendix A and section 7.9.
2. **API coverage:**
   - Every Phase 1 endpoint in Appendix A exists, is in OpenAPI with examples and error codes, and is called by the generated clients.
   - A script compares the OpenAPI paths against Appendix A and fails on gaps.
3. **Authorisation matrix:** an automated test runs every Phase 1 endpoint as anonymous, member (owner), member (non-owner), suspended member, moderator, content admin, platform admin and super admin, and asserts the expected allow/deny.
4. **Performance:**
   - Load a volume seed (10,000 members, 50,000 posts, 200,000 comments, 2,000 opportunities, 500 learning items, 100,000 notifications).
   - Confirm p95 < 300 ms for reads and < 600 ms for writes on the hot endpoints (home, feed, search, opportunity list/detail, learning hub, notifications) locally.
   - Capture `EXPLAIN ANALYZE` for each and add missing indexes.
   - No N+1 queries.
5. **Jobs:** every queue has retries, backoff, a dead-letter queue, idempotent handlers and appears in the admin failed-jobs view. Test the scheduled jobs (expiry, reminders, purge, exports, reconciliation) with time travel.
6. **Security:**
   - Rate limits on every mutating and search endpoint.
   - Payload size limits.
   - Review of every raw SQL query.
   - IDOR tests on every `{id}` route.
   - Secret scan.
   - Admin endpoints require TOTP and permissions.
7. **Data lifecycle:** soft delete, retention and purge rules documented in `DATABASE.md` and tested.
8. **Backups (local):** `scripts/db-backup.sh` and `scripts/db-restore.sh` (pg_dump/pg_restore against the Supabase database), tested once with a restore into a scratch database. Production backups use Supabase point-in-time recovery in P3-M8.
9. **Observability:** request logs with request IDs, error reporting, `/metrics` (request latency, queue depth, job failures), health checks green.
10. **Supabase posture:**
    - `check-rls.sql` passes.
    - The anon key cannot access any application table.
    - The service-role key appears only in the backend secret store.
    - The Auth settings (OTP length and expiry, password policy, refresh rotation, MFA, rate limits) match section 5.5.

Fix everything found before the gate.

**Phase 1 gate checks**

- All Phase 1 screens (entry, onboarding, home, explore, search, filters, article, community set, opportunities set except `opp_ai`, learning set, identity set except CV/verification/AI, activity and settings sets, system states) match the prototype **in light and dark** and run on the emulator against the real backend.
- Brand: the logo is used only from the logo pack at the sizes in section 8.4; `check-colors.sh` passes; launcher icon and native splash show the new logo.
- The five end-to-end journeys pass on the emulator, in light and dark.
- Backend, mobile, web and admin: all tests, lint, typecheck, format and builds pass; authorisation matrix tests pass for every Phase 1 permission.
- **Supabase:** app, web and admin run on Supabase Auth, Postgres, Storage and Realtime as in section 5.7; RLS is enabled everywhere; no client queries application tables directly.
- **Backend and database complete:** the P1-M12 completion audit passes — every table, endpoint and job in Appendix A exists and is tested, migrations run from empty and from the previous state, the OpenAPI-vs-Appendix check passes, performance budgets are met on the volume seed, and backup/restore has been tested locally.
- No hard-coded sample data in UI code; demo seed only in `dev`.
- No dead UI: a scripted check (widget test or route audit) confirms every route target exists.
- Docs and register current.

Then announce **`PHASE 1 CORE MEMBER EXPERIENCE REQUIREMENTS COMPLETE`**, write the gate report and stop.

---

## PHASE 2 — PREMIUM, ECONOMY & TRUST

Goal: Atarah Pro, real payments through Luxaion's infrastructure (M-Pesa first), the marketplace foundation, mentorship with paid booking, verification as a real trust layer, and the Creative CV/EPK — plus the admin and finance operations to run them safely.

### P2-M1 — Payments foundation (Luxaion payment infrastructure)

**Database:** `Payment` (purpose, polymorphic reference, payer, amount minor units, currency, method, provider, provider reference, status, idempotency key, failure reason), `PaymentEvent` (every provider callback and status change, raw payload stored encrypted), `Refund`, `Transaction` (ledger: payer, payee, gross, platform fee, net, type), `Payout` (table only; payouts are not automated in Phase 2).

**Build**

1. `payments` module with a `PaymentProvider` interface: `initiate`, `queryStatus`, `refund`, `verifyWebhook`, `parseWebhook`.
2. **M-Pesa adapter (Safaricom Daraja):** STK Push initiation with the member's +254 number, callback endpoint `/api/v1/webhooks/payments/mpesa` (Daraja callbacks are not signed, so protect the route with an unguessable path token and an IP allow-list where possible, match by checkout request ID, **confirm every success with an STK status query before marking the payment succeeded**, and process idempotently), status query fallback job when no callback arrives within the timeout, sandbox credentials in `dev` and `staging`.
3. **Card adapter:** implement the interface and UI path; enable it only when the product owner confirms the card provider and supplies credentials (until then the Card option is hidden behind the `card-payments` flag — not dead).
4. Payment state machine (`INITIATED → PENDING → SUCCEEDED | FAILED | CANCELLED`, then `REFUNDED | PARTIALLY_REFUNDED`). **Only verified provider confirmation moves a payment to `SUCCEEDED`.** Client-reported status is ignored.
5. Domain events `PaymentSucceeded`, `PaymentFailed`, `PaymentRefunded` consumed by membership and mentorship.
6. Mobile payment UI components reused by membership and mentorship: method radio cards (M-Pesa "Pay with your Safaricom line", Card "Visa or Mastercard"), `+254` number field, helper "You'll get an M-Pesa prompt to confirm with your PIN.", "Secure payment processed by Luxaion", a waiting state that polls the server while the STK prompt is open, timeout and retry, failure messages that say what to do.
7. Admin: payments list (metadata only, never card data), payment detail with event history, manual status re-query, refund action (needs `payment.manage`, re-auth, audit).

**Tests:** webhook idempotency (duplicate callbacks), out-of-order callbacks, timeout → query fallback, amount mismatch rejected, refund flows, permission tests for finance actions. Sandbox walkthrough on the emulator with a real STK prompt to a Safaricom sandbox/test number when credentials exist; otherwise mark the live-sandbox check BLOCKED and say so.

**Done when:** a sandbox M-Pesa payment completes end to end with a verified callback and the ledger is correct.

### P2-M2 — Atarah Pro membership, entitlements and scholarships

**Screens:** `membership` (full), `st_premium` (premium gate), upgrade payment path (reuses `pay`).

**Build**

1. Subscription lifecycle: upgrade (pays KES 1,200 for one month through P2-M1), renewal reminders 3 days before, renewal payment prompt (M-Pesa has no automatic card-style recurring billing — the member confirms each renewal via STK; card renewals can be automatic once the card provider supports it), grace period of 3 days (`PAST_DUE`), then `EXPIRED`; cancel anytime (active until period end).
2. Entitlements granted and revoked from membership state; every premium endpoint checks entitlements on the server.
3. **Membership screen:** plan card (Free or "Atarah Pro · Renews {date} · KES 1,200/month"), Free vs Pro table, scholarship box, billing section with next payment, upgrade CTA "Upgrade to Pro · KES 1,200/month" and "Cancel anytime. No hidden fees.", cancel subscription with clear consequences.
4. **Premium gate:** `st_premium` pattern ("Mentorship is part of Pro", what it does / why it matters / how to get it, "See Pro · KES 1,200/month", "Check scholarship eligibility") used by every premium entry point.
5. **Scholarships:** "Check scholarship eligibility" → application form (category such as student or programme participant, institution/programme, short statement, optional evidence upload) → admin review queue → approval grants Pro with `SCHOLARSHIP` source for a set period. Criteria text comes from the product owner (section 12); until then the form shows a neutral description and the admin decides case by case.
6. Admin: memberships (search, view history, grant/revoke with reason, extend), scholarship queue, plan price setting (re-auth, audit), reports on active Pro, churn and scholarships.

**Tests:** entitlement enforcement on every premium endpoint; lifecycle transitions with time travel; double-upgrade protection; scholarship grant/expiry.

**Done when:** a free member upgrades with sandbox M-Pesa on the emulator, premium gates open, and expiry closes them again.

### P2-M3 — Marketplace foundation

**Screens:** `market`, `market_browse`, `listing`, `seller`, `listing_new`, `my_listings`; profile `services` now links to listings.

**Database:** `SellerProfile` (user link — never a separate person record; status, verification status, stats: rating, completed count, median reply time), `Listing` (type, title, category, description, included items, delivery time, location/remote, audience text, pricing type, price/min/max, currency, status, rejection reason), `ListingMedia`, `ListingPortfolioLink` (to projects), `ListingReview` (only from members with a closed enquiry with that seller; rating 1–5 + text), `Enquiry` (buyer, listing, message, budget, preferred timing, status), `EnquiryMessage` (simple thread between buyer and seller for that enquiry only).

**Build**

1. **Marketplace home:** "My listings" pill for sellers, search, segmented Services / Products / Sellers, featured carousel, category grid, popular sellers, the "Start selling on Atarah" promo for non-sellers.
2. **Browse:** category title, count, sort ("Recommended", price, rating, newest), filters sheet, 2-column cards with save.
3. **Listing detail:** media carousel, save and share, category pill, title, "From KES x", seller card (→ seller profile), What's included, delivery and location tiles, Who it's for, portfolio examples (linked projects), reviews, bottom bar: message icon (opens the enquiry thread) and **"Request booking"**, which sends an `Enquiry` (form: what you need, budget, timing) and changes to "Request sent · We'll notify you". **No checkout, escrow or payouts** — those are deferred (section 4.2). Make this explicit in Help and in a one-line note under the CTA ("You'll agree details and payment directly with the seller.") — record the wording in `DECISIONS.md`.
4. **Seller profile:** header, stats (rating, completed, reply time), trust lines only when real ("Identity verified by Atarah", "Skill verified: …" from P2-M6), services and products.
5. **Create listing:** 4-step flow (Details, Media, Pricing, Preview) with Service/Product choice, category, description, pricing type (Fixed / Range / On request), KES price, media, included items, delivery time, linked portfolio projects; "Save draft"; Preview → **Submit**. First listings from a new seller go to `UNDER_REVIEW`; sellers with a clean history may publish directly (setting controlled by admins).
6. **Becoming a seller:** creating the first listing grants the `SELLER` role automatically after the member accepts the seller terms (terms text from the product owner; draft placeholder until then).
7. **My listings:** stats (live, new interest, views in 30 days), listings with status pills and an overflow menu (edit, pause/archive, delete draft), buyer interest list with "Reply" (opens the enquiry thread).
8. **Profile services:** "Publish" converts a profile service into a draft listing; "View listing" opens it; status pill switches to "On Marketplace".
9. Notifications: new enquiry (seller), reply (buyer), listing approved/rejected.
10. Admin: sellers, listing review queue (approve, reject with reason, suspend), reported listings, marketplace categories, featured listings, review moderation.

**Tests:** seller role grant; listing state machine; enquiry permissions (only the two parties see the thread); reviews only after a closed enquiry; search integration.

**Done when:** one test account publishes a service (after admin approval) and another discovers it, sends a request and receives a reply, on the emulator.

### P2-M4 — Mentorship discovery and mentor onboarding

**Screens:** `mentorship`, `mentors`, `mentor`, `mentor_tools` (not-yet-mentor and mentor states), plus the mentor application flow.

**Database:** `MentorProfile` (user link, headline, years of experience, bio, expertise tags, disciplines, credentials list, time zone, video-call link default, status: applied/approved/paused/removed, verification status), `MentorSessionType` (name, description, duration minutes, price, currency, format, number of sessions for programmes, active), `MentorAvailability` (weekday, start, end, time zone), `MentorAvailabilityException` (dates off), `MentorApplication` (statement, evidence links, Passport snapshot, review status, reviewer notes).

**Build**

1. **Mentorship hub:** Premium pill, explanation, next-session card for Pro members with a booking (P2-M5 data), How it works (3 steps), Who it's for, Top mentors carousel, "Find a mentor".
2. **Directory:** filter chips (Verified, discipline, "Available this week", price under X, Video call) plus the filters sheet; mentor cards with tags, next availability (computed from real availability and bookings), rating and "From KES x".
3. **Mentor profile:** hero, stats (rating and review count, sessions count, time zone), bio, expertise pills, "Choose a session" radio cards from the mentor's session types, credentials; CTA for Pro: "Book session · KES x" → `book`; for Free: "Unlock mentorship with Pro" → premium gate. **Discovery is open to all members; booking requires `MENTORSHIP_BOOKING`.**
4. **Become a mentor:** "Apply to mentor" (Mentor tools for non-mentors and Help) → application form prefilled from the Passport (statement, expertise, credentials, proposed session types and prices, evidence links) → admin review → approval grants the `MENTOR` role and publishes the mentor profile.
5. **Mentor tools (mentor):** weekly availability (Mon–Sun toggles with time ranges; exceptions for specific dates), session types (create/edit/deactivate with price and duration), profile editing, and the "Booking requests" list (populated in P2-M5).
6. Admin: mentor applications queue (approve/reject with reasons, audited), mentors list (pause/remove), session type oversight, featured mentors.

**Tests:** availability computation across time zones and exceptions; booking CTA gating by entitlement on the server; application approval grants the role exactly once.

**Done when:** a member applies, an admin approves, and the new mentor appears in the directory with real availability and prices.

### P2-M5 — Mentorship booking, payment and sessions

**Screens:** `book`, `pay_summary`, `pay`, `pay_done`, `my_mentorship`, `mentor_tools` booking requests.

**Database:** `MentorshipBooking` (mentee, mentor, session type, scheduled start/end UTC, objective text, status per section 6.6, price snapshot, service fee, payment link, meeting link, cancellation info, version), `MentorshipFeedback` (rating 1–5, comment, visibility), unique constraint preventing two active bookings in the same mentor slot.

**Build**

1. **Book:** summary row, month header with navigation, day grid (unavailable days disabled), "Available times · EAT" (from availability minus existing bookings, shown in the member's time zone with its label), objective textarea; "Review booking". The slot is **held for 10 minutes** while the member pays.
2. **Order summary:** mentor, session, date, time, duration, format "Video call", session price, service fee ("KES 0 · Pro member" — fee rules in `PlatformSetting`), total, cancellation box ("free up to 24 hours before. After that, 50% is refunded."); "Continue to payment".
3. **Payment:** P2-M1 components; on verified success the booking becomes `CONFIRMED` (section 6.6), both parties are notified, and the slot is locked.
4. **Confirmation:** "Booking confirmed", "Payment received. {Mentor} has been notified and you'll get a reminder an hour before.", when/paid tiles, "Go to My mentorship", **"Add to calendar"** (generates an `.ics` file / device calendar intent).
5. **My mentorship:** Upcoming (with "Join call" opening the mentor's meeting link when the session is within 15 minutes of start, and "Reschedule" to another free slot up to 24 hours before), Past (rating prompt "How was your session?" → feedback), Payments (receipts list), Your mentors.
6. **Mentor side:** "Booking requests" shows newly confirmed bookings with **Accept** (acknowledge) and **Decline** (cancels with a full automatic refund through P2-M1 and notifies the mentee); mentor can add or change the meeting link per booking.
7. **Cancellations and refunds:** mentee cancellation applies the 24-hour / 50% rule automatically; mentor cancellation always refunds 100%; no-show handling by admin.
8. **Reminders:** 24 hours and 1 hour before (push + email per preferences).
9. Mentor earnings are recorded in the `Transaction` ledger; **payouts to mentors are manual in Phase 2** (admin exports a payout report). The commission rate comes from the product owner (section 12).
10. Admin: bookings list and detail, cancellations, refunds, no-show resolution, payout report export, feedback moderation.

**Tests:** slot hold expiry; concurrent booking of the same slot (only one succeeds); payment failure releases the hold; refund amounts for each cancellation case; reminder scheduling; reschedule rules.

**Done when:** a Pro member books, pays with sandbox M-Pesa, gets confirmed, the mentor sees and accepts it, both get reminders, and feedback is recorded — on the emulator.

### P2-M6 — Verified Creative and skill verification

**Screens:** `verification`, skill verification entry from `skills`, trust badges across the app.

**Database:** `VerificationCase` (subject type: CREATIVE_IDENTITY, SKILL, SELLER, OPPORTUNITY_PROVIDER, MENTOR; subject id; status per section 6.2; submitted at; reviewer; decision notes; expires at), `VerificationRequirement` (per case type), `VerificationEvidence` (type: GOVERNMENT_ID, PORTFOLIO_PROJECT, REFERENCE, DOCUMENT, LINK; stored in the private evidence bucket), `Reference` (referee name, contact, relationship; Atarah emails a confirmation request), `VerificationBadge` (active badges derived from approved cases).

**Build**

1. **Verified Creative (Pro):** the prototype screen — intro ("…a trust signal for clients, funders and mentors — not a guarantee of quality."), status timeline (Application submitted → Under review → Decision), What's required with met/unmet ticks (government ID — private, never shown; 3 portfolio projects with your role; one reference from a client or collaborator), and the "Next" box (reviewer SLA from settings, "We'll notify you either way."). Submission flow: ID capture/upload, choose projects, add reference.
2. **Skill verification (Pro):** from a skill card, "Verify" → choose evidence (projects showing that skill, certificates, links, a reference) → submit → skill shows "Under review" → decision sets `VERIFIED` and the skill source.
3. **Reviewer workspace (admin):** case queue by type and age, case view with applicant, profile, evidence viewer (short-lived URLs, watermark with reviewer ID), previous decisions, notes, decision (approve, reject with feedback, request more information), expiry date, revoke; every action audited; reviewers cannot review their own case.
4. **Badges everywhere:** verified tick on names, "Identity verified" and skill pills on the Passport, seller trust lines, mentor "Verified" filter, "Verified only" search filter — all driven by `VerificationBadge`. Expired or revoked verifications remove badges automatically.
5. Evidence retention: delete government ID images 90 days after a decision (keep the decision record); document this in `SECURITY.md`.

**Tests:** entitlement gating; evidence access restricted to assigned reviewers; badge propagation and removal; self-review prevented; expiry job.

**Done when:** a Pro member submits, an admin reviews, and the badge appears across profile, Passport, search and marketplace on the emulator.

### P2-M7 — Creative CV / EPK and sharing

**Screens:** `cv`; Passport "Create CV / EPK" and "Copy link"; services/profile share.

**Build**

1. Four formats from one data source: **Creative CV**, **Artist biography**, **Electronic press kit**, **Portfolio presentation (Deck)**. The member picks which sections and projects to include; private and members-only fields are excluded from public outputs unless the member explicitly includes them.
2. In-app preview card exactly as the prototype (avatar, name, format subtitle, summary, selected work, skills with verified marks).
3. **Download PDF:** server-side rendering (HTML templates → PDF with a headless renderer in a worker), Atarah-branded templates per format, A4, stored privately, signed download link.
4. **Share link:** public, revocable share URLs (`atarah.app/{handle}/cv/{token}`) with optional expiry; the public web renders them in P3-M4 (until then the link opens a minimal server-rendered page).
5. Analytics: generated, downloaded, shared, viewed (aggregated, privacy-safe).

**Tests:** visibility filtering in each format; PDF generation job; revoked link returns 404.

**Done when:** a member generates all four formats, downloads a PDF on the emulator and opens a share link in a browser.

### P2-M8 — Phase 2 admin, finance operations and hardening

**Build**

1. Admin finance area with separated permissions: payments, refunds, membership revenue, mentorship earnings, payout report export, reconciliation report against provider statements (CSV import), failed payments queue.
2. Admin verification centre consolidated (creative, skill, mentor, seller, provider) with SLA tracking.
3. Phase 2 analytics: Pro conversions and churn, scholarship grants, bookings, listing enquiries, verification throughput.
4. **End-to-end journeys** on the emulator: (a) upgrade to Pro with sandbox M-Pesa; (b) book, pay, attend (simulated time), rate a mentor; (c) mentee cancellation inside 24 hours with 50% refund; (d) become a seller, publish after review, receive and answer an enquiry; (e) Verified Creative submission and approval; (f) CV/EPK PDF and share link.
5. Security review of payment, booking and verification code paths (threat model in `SECURITY.md`); fix findings.

**Phase 2 gate checks**

- All Phase 2 screens (marketplace set, mentorship set, membership, premium gate, verification, CV/EPK) match the prototype and work on the emulator against the real backend.
- Sandbox payments verified end to end with real provider callbacks (or the check is reported BLOCKED with the missing credential named).
- Every premium action is denied server-side without the entitlement (tests prove it).
- Ledger totals reconcile for all test journeys.
- All tests, lint, typecheck, format and builds pass; docs and register current.

Then announce **`PHASE 2 PREMIUM, ECONOMY & TRUST REQUIREMENTS COMPLETE`**, write the gate report and stop.

---

## PHASE 3 — INTELLIGENCE, ECOSYSTEM & PRODUCTION LAUNCH

Goal: contextual AI inside existing screens, the Kenya creative economy layer, the public web as the acquisition engine, offline and performance quality, security and compliance hardening, full QA, and a production-ready release candidate. Nothing is deployed to production without the product owner's written go-ahead.

### P3-M1 — AI foundation (intelligence layer)

**Build**

1. `intelligence` module with an `AiProvider` interface (`complete`, `structuredOutput`, `moderate`) and one adapter for the provider the product owner selects (section 12). A deterministic fake provider is used in tests and `dev` when no key exists — clearly labelled as such in the UI ("AI preview (test mode)") so nobody mistakes it for real output.
2. **Context builder:** each AI capability declares exactly which fields it may read; the builder fetches them through the same visibility and ownership policies as the API, strips contact details, ID data and other members' private data, and never sends verification evidence or payment data.
3. Prompt templates versioned in the repo (`apps/backend/src/intelligence/prompts/`), with output schemas validated before use.
4. `AiInteraction` log (capability, user, template version, token counts, latency, outcome; **no raw prompt or output stored by default** — opt-in debug retention of 7 days in `dev` only).
5. Per-user and global rate limits, monthly usage caps per plan (Free vs Pro limits in `PlatformSetting`), kill switch per capability via feature flags, graceful failure ("AI help isn't available right now. Your work is unchanged.").
6. Safety: input and output moderation, refusal handling, and a rule that AI output is **never written to the member's data without an explicit Apply**.
7. Admin: AI settings (enable/disable capabilities, limits, provider config reference — keys stay in the secret store), usage dashboard (aggregates only; admins cannot read members' AI content).

**Tests:** context builder never leaks private fields (property-based tests across visibility settings); rate limits; kill switch; schema validation failures handled.

**Done when:** capabilities can be switched on and off per flag, every AI call is authorised, filtered and logged, and the leak tests pass.

### P3-M2 — Contextual AI features

Replace every "Soon · P3" AI entry point with the real feature, using `AtAiSheet`:

1. **Improve my bio** (`ai_bio`): Current vs Suggestion, tone chips Professional / Warm / Short (regenerates), disclaimer "Check facts and names before applying — you're responsible for what you publish.", Discard / Apply (Apply writes the bio and records `aiAssisted = true`).
2. **Help me write this** (onboarding bio): same pattern, from discipline, specialisations and skills.
3. **Help describe this** (add project): drafts a description from title, role, skills and collaborators; member edits before saving.
4. **Help me understand this** (`opp_ai`, "In plain words"): plain-language summary, "You likely qualify / Prepare / Timing" points computed from the **real profile-gap result** plus the AI summary, disclaimer "AI-assisted summary · review before relying on it", **Copy** (copies the summary) and **Help me prepare** (creates a checklist in the opportunity's tracking record and links to the missing items).
5. **What should I learn next?** (lesson, Skill Labs): recommendations drawn only from Atarah's published catalogue, each with a reason.
6. Label all AI output with the sparkles mark and "AI-assisted"; never present it as verified information.

**Tests:** each feature's happy path, provider failure, moderation block and "Apply never auto-writes" checks; widget tests for the sheets.

**Done when:** every AI entry point in the prototype works on the emulator with the configured provider (or is reported BLOCKED pending a provider key, with the fake provider demonstrating the flow in `dev`).

### P3-M3 — Creative economy layer

**Screens:** `economy`, `county`, plus "Rising talent" and organisation detail.

**Database:** `CreativeOrganisation` (name, type: government agency, creative space, festival, studio, gallery, venue, training organisation, label, NGO, other; county; website; verified), `CountyEcosystemStat` (materialised: creatives per discipline, organisations, open opportunities; refreshed nightly), `RisingTalentPick` (curated by admins with a stated reason; never a popularity score alone).

**Build**

1. **Creative economy:** Kenya pill (country switcher hidden until a second country exists), intro, **interactive county map** (bundled simplified GeoJSON of Kenya's 47 counties rendered with a Flutter map/canvas widget; tap a county → county ecosystem; pins sized by creatives count; accessible list alternative), stat tiles (counties, creatives, open calls — real aggregates), county list with codes and counts.
2. **County ecosystem:** header with counts, discipline bars, organisations (→ organisation detail with website through the leaving-Atarah pattern), rising talent (→ creative profiles), regional opportunities (filtered list).
3. Privacy: counts only include members whose location visibility allows it; counts below 5 are shown as "Fewer than 5" to avoid identifying people.
4. Admin: organisations CRUD and CSV import (never auto-published), rising talent curation, stat refresh trigger, data-quality report.
5. Replace the "Creative economy" Explore tile's future screen.

**Tests:** aggregation correctness and small-count suppression; map tap targets and screen-reader list.

**Done when:** the county map and county pages show real, privacy-safe aggregates on the emulator and admins can manage organisations and rising talent.

### P3-M4 — Public web (acquisition layer)

**Build** in `apps/web` with server rendering and good SEO:

1. **Landing site:** proposition, pillars, how it works, featured public creatives, featured opportunities, latest articles, Pro overview, join CTAs (app-store links when they exist; web sign-up otherwise).
2. **Public creative profiles** at `atarah.app/{handle}` (only `PUBLIC` sections; Open Graph images generated per profile), **public projects**, **shared CV/EPK** pages from P2-M7.
3. **Opportunities** listing and detail pages for opportunities the admin marks public, with "Save in the app" prompts.
4. **Articles** with structured data (Article schema), categories and an RSS feed.
5. **Member web (light):** sign in, view and edit profile and Passport visibility, saved items, notification settings — reuse the API; do not duplicate the whole mobile app.
6. **Deep links:** Android App Links (`assetlinks.json`) and iOS Universal Links (`apple-app-site-association`) so `atarah.app/...` opens the app when installed and the web page otherwise.
7. Legal pages, cookie notice (analytics only with consent), accessibility (WCAG 2.2 AA), Core Web Vitals budgets (LCP < 2.5 s, CLS < 0.1, INP < 200 ms on 4G).

**Tests:** Playwright for landing → profile → join; SEO checks (metadata, sitemap, robots); Lighthouse CI budgets.

**Done when:** a signed-out visitor can discover Atarah on the web, open a shared profile or CV link, and land in the app (or join) through a working deep link; Lighthouse budgets pass.

### P3-M5 — Offline, performance and resilience

**Build**

1. Formalise the offline strategy: local store (drift/Isar or equivalent) for the Passport, saved items, in-progress learning metadata and downloaded lesson notes; stale-while-revalidate for Home, Explore and lists; offline screen as in the prototype ("Saved for offline", "Needs a connection" with Apply, Book and Post marked offline); queued safe actions (save/unsave, mark lesson complete) replayed on reconnect with conflict handling.
2. Performance: image CDN-style variants and caching headers, list virtualisation, pagination everywhere, backend query review with `EXPLAIN ANALYZE` on hot endpoints, indexes added, N+1 elimination, Redis caching for home and taxonomy payloads, response compression.
3. Resilience: timeouts and circuit breakers for providers (payments, SMS, email, AI, embeds), retry with backoff in jobs, dead-letter queues visible in admin.
4. Budgets verified: mobile cold start < 2.5 s (release, mid-range device), p95 API latency < 300 ms for reads and < 600 ms for writes at target load, app size reported.

**Done when:** the offline walkthrough in the prototype works on the emulator in airplane mode, queued actions replay correctly, and the budgets are measured and met (or the gaps are reported).

### P3-M6 — Security, privacy and compliance hardening

**Build**

1. Threat model update across all modules; fix findings.
2. OWASP ASVS Level 2 checklist and OWASP MASVS checklist for the mobile app, recorded in `SECURITY.md` with evidence per item.
3. Dependency and container scanning (npm audit/`osv-scanner`, `dart pub outdated`, Trivy), secret scanning, SAST (Semgrep) — wired into CI; zero high/critical findings at gate time or an owner-approved exception.
4. Mobile hardening: certificate/TLS configuration, no sensitive data in logs or screenshots of sensitive screens (payment, verification), root/jailbreak advisory (warn, don't block), obfuscation for release builds.
5. Admin: enforced TOTP, IP and session controls, sensitive-action re-auth, quarterly access-review report.
6. Privacy: data inventory and retention schedule, consent records, data export and deletion verified end to end, processor list (hosting, email, SMS, payments, AI) for the owner's privacy notice, breach-response runbook. Note that registration with Kenya's Office of the Data Protection Commissioner and the final privacy notice are the owner's legal tasks; list them in the gate report.
7. Abuse: rate-limit review, spam and fake-account heuristics for sign-up and posting, report-volume alerts.

**Done when:** the checklists are filled with evidence, the scanners run in CI, and no high or critical finding is open without an owner-approved exception.

### P3-M7 — Full QA and test completion

**Build**

1. Coverage review: fill gaps so that domain services and policies have meaningful unit tests and every endpoint has integration tests for success and the main failure cases (target ≥ 80% line coverage for backend domain modules; report actual numbers honestly).
2. Complete the end-to-end suite across **all** journeys from Phases 1–3 on the Android emulator, plus a smoke run on an iOS simulator.
3. Device matrix (at least: small Android phone, mid-range Android, large Android, one iOS device class) with text scale 100% and 200%.
4. **Load test** with k6 against staging-like local infrastructure: sign-in, home, search, opportunity list/detail, feed, lesson progress, booking with payment mock — report throughput and p95/p99 latencies against the P3-M5 budgets.
5. Accessibility audit of every screen (TalkBack walkthroughs), fix issues.
6. Visual regression: golden tests for all key screens compared with the prototype.
7. A bug bash list in `docs/TESTING.md` with every defect found, its severity and its resolution.

**Done when:** every result above is recorded in `docs/TESTING.md` with real numbers, and every critical or high defect is fixed.

### P3-M8 — Production readiness and release candidate

**Build** (prepare everything; deploy nothing without written authorisation)

1. **Infrastructure as code** in `infrastructure/` for staging and production (cloud provider chosen by the owner, section 12): the **Supabase production project** (database with point-in-time recovery, Auth with production SMTP and SMS hook, Storage buckets and policies, Realtime), Supabase staging project parity, managed Redis, container hosting for the NestJS API and workers, CDN, TLS, WAF/rate limiting at the edge, secrets manager.
2. **Environments:** staging mirrors production; seeds: reference seed only (no demo data) in staging and production.
3. **Observability:** dashboards (API latency, errors, queue depth, payment success rate, sign-up funnel), alerts with thresholds, uptime checks, log retention, Sentry release tracking for all apps.
4. **Backups and recovery:** documented and **tested** restore of the database into a scratch environment; record the result.
5. **CI/CD:** pipelines that build signed release artefacts using secrets from the CI secret store (keys never in the repo), run migrations safely (expand/contract pattern), and deploy to staging on approval. Production deploy job exists but requires a manual approval step by the owner.
6. **Mobile release prep:** release builds (Android App Bundle; iOS archive if Apple credentials exist), versioning scheme, store listing draft text, screenshots captured from the real app, privacy "data safety" answers drafted from the data inventory, in-app review of permissions text. Do not upload to stores.
7. **Runbooks** (`docs/RUNBOOK.md`): deploy, rollback, migration failure, payment provider outage, SMS outage, AI outage, incident response, on-call contacts placeholder. **Release checklist** (`docs/RELEASE.md`).
8. **Feature flags** set for launch: everything in scope on; Google sign-in and card payments on only if credentials exist.
9. Final production-readiness review against section 11 and a **launch risks list**.

**Phase 3 gate checks**

- Every screen in the prototype is implemented with real data; no `AtFutureScreen` remains for anything inside Phases 0–3 (only "Soon · Later" items, if any).
- Full test suite, E2E journeys, device matrix, accessibility audit and load test completed with results recorded.
- Security scans clean (or owner-approved exceptions); ASVS/MASVS checklists filled with evidence.
- Staging environment built from IaC, deployed with owner approval, smoke-tested; backup restore tested.
- Signed release artefacts build in CI from the secret store.
- All docs, runbooks and the release checklist complete; register current.

Then announce **`PHASE 3 INTELLIGENCE, ECOSYSTEM & PRODUCTION LAUNCH REQUIREMENTS COMPLETE`**, write the gate report **plus a Production Readiness Report** (what is ready, what is blocked on the owner, risks, recommended launch steps) and stop. Production deployment and store submission happen only when the product owner says so.

# 11. Definition of done (every feature)

A feature is done only when all of these are true:

- Requirements understood and matched to the prototype and specs.
- Database schema, migration, constraints and indexes in place.
- API implemented, validated, authorised (role, entitlement, ownership, visibility), documented in OpenAPI; clients regenerated.
- Mobile UI matches the prototype, uses design-system components, and has loading, empty, error, offline and gated states.
- Admin tooling exists where operations need it, with audit logging.
- Unit, integration and widget tests written and passing; E2E journey updated where relevant.
- Walked through on the Android emulator against the real backend.
- Accessibility checked; analytics events emitted where defined.
- No dead UI, no hard-coded sample data, no secrets.
- Docs, `DECISIONS.md` and `PROJECT_PROGRESS.md` updated; changed files listed for the owner.

Status language: say **MOCKED**, **PARTIAL**, **ARCHITECTED ONLY** or **BLOCKED** when that is the truth. Never say "done", "complete" or "production ready" without verified evidence.

# 12. Decisions the product owner must supply

Proceed with the stated default and record it in `DECISIONS.md`; flag the item in every gate report until the owner answers. Never invent legal or commercial text.

| #   | Decision                                                                                                                              | Default until answered                                        | Needed by             |
| --- | ------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------- | --------------------- |
| 1   | Production domain (`atarah.app` assumed) and app IDs (`app.atarah.mobile`)                                                            | Use the assumed values                                        | P0-M2                 |
| 2   | Email provider and sender domain (custom SMTP for Supabase Auth and Atarah emails)                                                    | Supabase local mail catcher in dev; adapter interface only    | P1-M1 (prod by P3-M8) |
| 3   | SMS provider for Kenya (OTP, two-step; used through the Supabase Send SMS hook)                                                       | Log sink in dev; adapter interface only                       | P1-M1 (prod by P3-M8) |
| 4   | Google sign-in OAuth credentials                                                                                                      | Feature flag off                                              | Any time              |
| 5   | Terms of Service, Privacy Policy, Community Guidelines, Payments & Refunds, seller terms, mentor terms                                | Seeded "DRAFT — pending legal review" placeholders            | P3-M8                 |
| 6   | Card payment provider used by Luxaion, plus M-Pesa Daraja production credentials (shortcode, passkey)                                 | M-Pesa sandbox; card flag off                                 | P2-M1 (prod by P3-M8) |
| 7   | Mentorship commission rate and payout process                                                                                         | 0% commission recorded; manual payout report                  | P2-M5                 |
| 8   | Marketplace fees (and the Pro "reduced fees" amount)                                                                                  | No fees charged (no checkout in scope)                        | P2-M3                 |
| 9   | Pro price confirmation (KES 1,200/month from the design) and annual plan, if any                                                      | KES 1,200/month, monthly only                                 | P2-M2                 |
| 10  | Scholarship eligibility criteria and duration                                                                                         | Admin decides case by case; 6-month grant                     | P2-M2                 |
| 11  | Verification fees (if any) and reviewer staffing / SLA                                                                                | No separate fee; 5 working days                               | P2-M6                 |
| 12  | AI provider and data-processing terms                                                                                                 | Fake provider in dev; features flagged off in prod            | P3-M1                 |
| 13  | Cloud provider and region for staging/production                                                                                      | Write IaC provider-agnostic where practical; ask before P3-M8 | P3-M8                 |
| 14  | Member-to-member direct messaging (the prototype shows "Message" buttons; no spec defines messaging)                                  | "Soon · Later", except enquiry threads in P2-M3               | P1-M3                 |
| 15  | Support channel behind "Chat with us"                                                                                                 | Support email / form                                          | P1-M11                |
| 16  | Brand imagery licences (welcome collage photos)                                                                                       | Prototype photos in dev only                                  | P3-M8                 |
| 17  | Default appearance (Light, as in the prototype) or follow the phone's system setting                                                  | Light by default; member can switch                           | P1-M7                 |
| 18  | Supabase organisation, plan and region (nearest available region to Kenya) for dev, staging and production; project creation and keys | Local Supabase stack until supplied; cloud checks BLOCKED     | P1-M6 (prod by P3-M8) |
| 19  | SMS provider for Supabase Auth's Send SMS hook (Kenyan delivery)                                                                      | Log sink locally; adapter interface                           | P1-M6 (prod by P3-M8) |

# 13. First actions (v2.3 — resuming)

1. Read this whole document, especially section 0.1, sections 5.5 and 5.7 (Supabase), section 8 and P1-M6/P1-M7. Open the **updated** prototype in a browser (`design/prototype/Atarah Mobile App.dc.html` served from a local static server) and switch the Appearance between Light and Dark.
2. Follow the resume steps in section 0.1:
   - update `docs/MASTER_PROMPT.md`
   - reconcile `docs/PROJECT_PROGRESS.md` (new P1-M6 and P1-M7; later milestones renumbered to P1-M8 … P1-M12)
   - write the backend platform report (`docs/SUPABASE_ADOPTION.md`)
   - confirm a green baseline
   - run the backend and database baseline audit against Appendix A
3. Build **P1-M6 — Supabase platform adoption**, then **P1-M7 — Brand refresh and dark appearance**, then continue through **P1-M8 … P1-M12** milestone by milestone, posting a milestone report after each.
4. At the end of Phase 1, run the gate checks, announce **`PHASE 1 CORE MEMBER EXPERIENCE REQUIREMENTS COMPLETE`**, write the gate report, list the changed files for the owner to commit, and **stop**.

Remember: you never run git write commands, you never fake progress, and you never leave dead UI. Build the real thing, prove it works, and report honestly.

# Appendix A — Phase 1 data model and API inventory

This is the complete backend and database scope for Phase 1. Tables are listed by owning module, with the milestone that introduces them. Milestones marked ✓ were completed under v2.0. During the resume steps (section 0.1), **audit them against this appendix and fill any gaps as part of P1-M6** before building P1-M7.

## A.1 Tables

| Module               | Tables                                                                                                                                                                                                                                                                                                                                  | Milestone                                |
| -------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------- |
| identity             | Supabase `auth` schema (users, identities, sessions, refresh tokens, MFA factors — managed by Supabase); Atarah tables `users` (id = `auth.users.id`), `consent_records`, `device_tokens`, `user_devices`, `account_deletion_requests`, `data_export_requests`                                                                          | P0-M4/M5 ✓, P1-M1 ✓, **P1-M6**, P1-M11   |
| access               | `roles`, `permissions`, `role_permissions`, `user_roles`, `admin_sessions` (TOTP)                                                                                                                                                                                                                                                       | P0-M4/M5 ✓                               |
| membership           | `membership_plans`, `memberships` (FREE created at registration), `entitlements`, `membership_entitlements`                                                                                                                                                                                                                             | P0-M4 ✓                                  |
| taxonomy & locations | `disciplines`, `specialisations`, `skills`, `interests`, `development_areas`, `specialisation_suggestions`, `countries`, `counties`, `towns`                                                                                                                                                                                            | P0-M4 ✓, P1-M2 ✓                         |
| creative             | `creative_profiles`, `creative_disciplines`, `creative_specialisations`, `creative_skills`, `creative_interests`, `creative_development_areas`, `creative_passports`, `profile_section_visibility`, `profile_field_visibility`, `profile_links`, `experiences`, `achievements`, `profile_services`, `member_preferences`, `connections` | P1-M2 ✓, P1-M3 ✓, P1-M4 ✓, P1-M7, P1-M11 |
| portfolio            | `projects`, `project_media`, `project_skills`, `project_collaborators`                                                                                                                                                                                                                                                                  | P1-M4 ✓                                  |
| content              | `articles`, `content_categories`, `home_curation`, `help_articles`, `faq_entries`, `legal_documents`                                                                                                                                                                                                                                    | P1-M5 ✓, P1-M11                          |
| search               | `search_vector` columns + GIN indexes on profiles, projects, articles, posts, opportunities, learning, help; `recent_searches`                                                                                                                                                                                                          | P1-M5 ✓ (extended in M7–M10)             |
| community            | `posts`, `post_media`, `post_links`, `post_attachments`, `comments`, `reactions`, `groups`, `group_memberships`, `group_pins`, `blocks`, `mutes`                                                                                                                                                                                        | P1-M8                                    |
| moderation           | `reports`, `moderation_cases`, `moderation_actions`                                                                                                                                                                                                                                                                                     | P1-M8                                    |
| opportunities        | `opportunity_providers`, `opportunities`, `opportunity_disciplines`, `opportunity_requirement_rules`, `opportunity_trackings`, `external_link_checks`                                                                                                                                                                                   | P1-M9                                    |
| learning             | `learning_categories`, `learning_contents`, `learning_content_disciplines`, `learning_content_skills`, `courses`, `lessons`, `enrolments`, `lesson_progress`, `content_progress`, `learning_activity_daily`, `certificates`                                                                                                             | P1-M10                                   |
| saved                | `saved_items`                                                                                                                                                                                                                                                                                                                           | P1-M11 (endpoint first wired in P1-M5 ✓) |
| notifications        | `notifications`, `notification_preferences`, `notification_dispatches`                                                                                                                                                                                                                                                                  | P0-M9 ✓, P1-M9, P1-M11                   |
| media                | `media_assets` (+ variants)                                                                                                                                                                                                                                                                                                             | P0-M9 ✓                                  |
| admin & platform     | `platform_settings`, `feature_flags`, `audit_logs`, `analytics_events` (partitioned monthly); Supabase Storage buckets `public-media`, `private-media`, `verification-evidence`; Realtime publication on `notifications`                                                                                                                | P0-M3 ✓, P1-M12                          |

## A.2 Endpoint families (all under `/api/v1`)

Access legend: **Pub** = anyone · **Mem** = signed-in active member · **Own** = the resource owner · **Perm(x)** = admin permission x.

| Family                 | Main endpoints                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | Access                                                                                                                   | Milestone                  |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------ | -------------------------- |
| Auth                   | Sign-up, OTP verify/resend, sign-in, refresh, sign-out, recovery and MFA go **directly to Supabase Auth** from the clients. NestJS: `GET/DELETE /auth/sessions` (service role), `POST /auth/hooks/send-sms` (Supabase hook, signature-verified), `GET /me/security`                                                                                                                                                                                                                                                      | Pub / Mem / Hook                                                                                                         | P0-M5 ✓, **P1-M6**, P1-M11 |
| Me                     | `GET /users/me`, `PATCH /me/account`, `GET/PATCH /me/preferences`, `GET/PATCH /me/privacy`, `GET/PATCH /me/notification-preferences`, `GET /me/security`, `POST /me/export` (password, email/phone change and two-step MFA go through Supabase Auth from the client), `POST /me/delete`, `POST /me/restore`                                                                                                                                                                                                              | Mem/Own                                                                                                                  | P1-M7, P1-M11              |
| Taxonomy & locations   | `GET /taxonomy/*`, `GET /locations/*`, `POST /taxonomy/specialisations/suggestions`                                                                                                                                                                                                                                                                                                                                                                                                                                      | Pub / Mem                                                                                                                | P1-M2 ✓                    |
| Onboarding & profile   | `PATCH /me/onboarding`, `POST /me/onboarding/complete`, `GET /handles/{h}/availability`, `GET/PATCH /me/profile`, `GET /me/passport`, `PATCH /me/passport/visibility`, `GET /me/growth`, `GET /creatives`, `GET /creatives/{handle}`                                                                                                                                                                                                                                                                                     | Mem / Pub (visibility-filtered)                                                                                          | P1-M2 ✓, P1-M3 ✓           |
| Portfolio & identity   | `/me/projects` (CRUD, publish), `/me/projects/{id}/media`, `/me/skills`, `/me/experiences`, `/me/achievements`, `/me/services`, `/creatives/{handle}/projects` …                                                                                                                                                                                                                                                                                                                                                         | Own / Pub (filtered)                                                                                                     | P1-M4 ✓                    |
| Connections            | `POST /connections`, `POST /connections/{id}/accept                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | decline`, `DELETE /connections/{id}`, `GET /me/connections`, `GET /me/connection-requests`, `GET /creatives/suggestions` | Mem                        | P1-M3 ✓, P1-M8 |
| Home, search, articles | `GET /home`, `GET /search`, `GET/DELETE /me/recent-searches`, `GET /articles`, `GET /articles/{slug}`                                                                                                                                                                                                                                                                                                                                                                                                                    | Mem / Pub                                                                                                                | P1-M5 ✓                    |
| Community              | `GET /community/feed`, `/posts` (CRUD), `/posts/{id}/comments`, `/posts/{id}/reactions`, `/groups`, `/groups/{id}/join                                                                                                                                                                                                                                                                                                                                                                                                   | leave`, `/groups/{id}/posts`, `POST /blocks`, `POST /mutes`, `POST /reports`, `GET /me/reports`                          | Mem                        | P1-M8          |
| Opportunities          | `GET /opportunities`, `GET /opportunities/{id}`, `POST /opportunities/{id}/track`, `GET /me/opportunities`, `GET /me/applications`, `/provider/opportunities` (role OPPORTUNITY_PROVIDER)                                                                                                                                                                                                                                                                                                                                | Pub (public items) / Mem                                                                                                 | P1-M9                      |
| Learning               | `GET /learning`, `GET /learning/categories/{slug}`, `GET /learning/{id}`, `POST /learning/{id}/enrol`, `PUT /learning/lessons/{id}/progress`, `PUT /learning/{id}/progress`, `GET /me/learning`, `GET /me/learning/stats`, `GET /learning/lessons/{id}/playback`                                                                                                                                                                                                                                                         | Mem (premium items need entitlement)                                                                                     | P1-M10                     |
| Saved & activity       | `GET /me/saved`, `POST /me/saved`, `DELETE /me/saved/{id}`, `GET /me/activity`                                                                                                                                                                                                                                                                                                                                                                                                                                           | Mem                                                                                                                      | P1-M11                     |
| Notifications          | `GET /notifications`, `GET /notifications/unread-count`, `POST /notifications/{id}/read`, `POST /notifications/read-all`, `POST /devices`                                                                                                                                                                                                                                                                                                                                                                                | Mem                                                                                                                      | P0-M9 ✓, P1-M11            |
| Help & legal           | `GET /help/articles`, `GET /help/faq`, `GET /legal/{type}`                                                                                                                                                                                                                                                                                                                                                                                                                                                               | Pub                                                                                                                      | P1-M11                     |
| Media                  | `POST /media/uploads`, `POST /media/uploads/{id}/complete`, `GET /media/{id}/url`                                                                                                                                                                                                                                                                                                                                                                                                                                        | Mem (owner/visibility)                                                                                                   | P0-M9 ✓                    |
| Admin                  | `/admin/users`, `/admin/roles`, `/admin/taxonomy/*`, `/admin/articles`, `/admin/home-curation`, `/admin/reports`, `/admin/moderation-cases`, `/admin/groups`, `/admin/announcements`, `/admin/opportunities`, `/admin/opportunity-providers`, `/admin/learning/*`, `/admin/courses/*`, `/admin/notifications/broadcasts`, `/admin/help-articles`, `/admin/faq`, `/admin/legal-documents`, `/admin/privacy-requests`, `/admin/analytics/*`, `/admin/jobs`, `/admin/audit-logs`, `/admin/settings`, `/admin/feature-flags` | Perm(x) + TOTP                                                                                                           | P0-M8 ✓ … P1-M12           |
| Ops                    | `GET /health/live`, `GET /health/ready`, `GET /metrics` (internal)                                                                                                                                                                                                                                                                                                                                                                                                                                                       | Internal                                                                                                                 | P0-M3 ✓                    |

## A.3 Background jobs in Phase 1

Email, SMS and push sending · media validation and image variants · video transcode · link-preview fetch · search index updates · opportunity expiry (hourly) · deadline reminders (daily 08:00 EAT) · link-health and embed checks (weekly) · counter reconciliation (nightly) · learning-minutes rollup (daily) · saved-item cleanup (nightly) · notification retention (daily) · data export build · account purge (daily) · moderation backlog alert · analytics aggregation (nightly).
