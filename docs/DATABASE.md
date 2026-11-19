# Atarah — Database

**Supabase PostgreSQL** (managed; the local Supabase CLI stack in development) + Prisma 6. Authentication data lives in Supabase's own `auth` schema, which Atarah never modifies except for the documented triggers (see "Supabase specifics"). A generated ER diagram is in [DATABASE-ERD.md](DATABASE-ERD.md) (`pnpm --filter @atarah/backend db:erd`). Schema is split by domain in `apps/backend/prisma/schema/`:

| File                         | Contents                                                                                                                             |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| `schema.prisma`              | generator + datasource (`ATARAH_DATABASE_URL` = pooler, `ATARAH_DIRECT_URL` = migrations)                                            |
| `enums.prisma`               | Master Prompt §6 canonical enums                                                                                                     |
| `system.prisma`              | `AuditLog`, `PlatformSetting`, `FeatureFlag`                                                                                         |
| `identity.prisma`            | `User` (id = `auth.users.id`), `MemberPreference`, `UserDevice`, `ConsentRecord`, `LegalDocument`                                    |
| `access.prisma`              | `Role`, `Permission`, `RolePermission`, `UserRole`                                                                                   |
| `membership.prisma`          | `MembershipPlan`, `Entitlement`, `MembershipEntitlement`, `Membership`                                                               |
| `taxonomy.prisma`            | `Country`, `County`, `Town`, disciplines, specialisations, skills, interests, development areas, learning and marketplace categories |
| `media-notifications.prisma` | `MediaAsset`, `Notification`, `NotificationPreference`, `NotificationDispatch`, `DeviceToken`                                        |

Entities, relationships and rules: `docs/DOMAIN.md`.

## Conventions (Master Prompt §7.3)

- UUID primary keys; `createdAt` and `updatedAt` on every table (`audit_logs` is append-only and has no `updatedAt`); `deletedAt` where users can delete what they own.
- Lifecycles are enums, never booleans such as `isVerified` / `isPremium`.
- Tables snake_case plural via `@@map`; Prisma fields camelCase.
- Foreign keys, unique and check constraints, and an index for every filter and sort the API exposes. Searchable entities carry a generated `searchVector` (`tsvector`) with a GIN index: `creative_profiles` (name, handle, headline) and `articles` (title, summary, byline). Later milestones add their own.
- Money: integer minor units + ISO-4217 code. Times: UTC.
- Never edit an applied migration. Destructive changes (dropping or renaming columns that hold data) need written owner approval.
- Extensions: `pg_trgm`, `unaccent`, `citext` (created in `init_system`; on Supabase they install into `public`).
- Every new table enables Row Level Security **in the same migration** (deny all; no policies) and `node scripts/check-rls.mjs` must pass.
- Prisma `migrate dev` cannot run against a database that has the `auth` schema's foreign key (introspection error P4002), so migrations are written by hand or from `prisma migrate diff --from-schema-datamodel <old> --to-schema-datamodel <new> --script` and applied with `prisma migrate deploy`.

## Constraints Prisma cannot express (in migration SQL)

| Constraint                        | Where             | Purpose                                                        |
| --------------------------------- | ----------------- | -------------------------------------------------------------- |
| `audit_logs` append-only triggers | `init_system`     | Reject UPDATE, DELETE, TRUNCATE for every role.                |
| `users_identifier_present`        | `init_foundation` | Email or phone required.                                       |
| `users_phone_e164`                | `init_foundation` | Phone stored as `+<country><number>`.                          |
| `memberships_one_live_per_user`   | `init_foundation` | Partial unique index: one ACTIVE/PAST_DUE membership per user. |
| `counties_code_format`            | `init_foundation` | Three upper-case letters.                                      |
| `media_assets_size_positive`      | `init_foundation` | Sanity checks.                                                 |

## Migrations log

| Migration                        | Summary                                                                                                                            |
| -------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `20261016233118_init_system`     | Extensions; `audit_logs` (append-only), `platform_settings`, `feature_flags`.                                                      |
| `20261016235442_init_foundation` | 51 enums total; identity, access, membership, taxonomy, media and notification tables; constraints above.                          |
| `20261017000213_admin_auth`      | `admin_totp` (encrypted TOTP secret, replay time step, hashed recovery codes); `sessions.reauthAt`. Dropped in `drop_nestjs_auth`. |

| `20261017152813` … `20261019082322` | P1-M2 to P1-M5: creative profile and onboarding, visibility and connections, portfolio, articles and search (see below). |
| `20261022110000_member_preferences` | P1-M7. Enum `Appearance`; `member_preferences` (one row per user: `appearance` default LIGHT, `locale` default `en`, `timeZone` default `Africa/Nairobi`, `marketingOptIn` default false); RLS enabled, no policies, no `anon`/`authenticated` grants; backfills a row per existing user from `users.timeZone`/`users.locale`, then drops those two columns (`member_preferences` is the source of truth). Rows are created lazily by the backend. |
| `20261022090000_supabase_platform` | P1-M6. `user_devices`, `notification_dispatches`; FK `users.id → auth.users.id`; triggers `atarah_on_auth_user_created/updated`; RLS enabled on every table, `anon`/`authenticated` privileges revoked, the `notifications_select_own` policy and the Realtime publication; the `atarah_backend` role (BYPASSRLS, no password in SQL); `atarah_auth_*` security-definer functions. |
| `20261022091500_user_device_session` | `user_devices.lastSessionId` links a device to its Supabase session. |
| `20261022092000_storage_buckets_function_hardening` | The three storage buckets; trigger function not callable by client roles. |
| `20261022093000_drop_nestjs_auth` | Drops `credentials`, `sessions`, `verification_codes`, `admin_totp` and the `SessionClient`, `CodeChannel`, `CodePurpose` enums (dev and staging only; no production data, DEC-061). |
| `20261022094500_search_vectors` | Generated `searchVector` columns and GIN indexes on `creative_profiles` and `articles`. |
| `20261024090000_opportunities` | P1-M9: opportunities, providers, rules, tracking and link checks (see the Opportunities section). |

## Supabase specifics (P1-M6)

- `public.users.id` **is** `auth.users.id`. An INSERT on `auth.users` fires `public.handle_auth_user_created()` (creates the `users` row and the consent records from the sign-up metadata); an UPDATE fires `handle_auth_user_updated()` (email, phone, verification timestamps, `lastLoginAt`, and the first `PENDING_VERIFICATION → ACTIVE`). The FK cascades: deleting the auth user deletes the member's rows. Demo and test users are therefore created through the Auth admin API, never with a bare `INSERT INTO users`.
- Roles: `postgres` runs migrations; `atarah_backend` is the application role (BYPASSRLS, `search_path = public, extensions`); `anon` and `authenticated` have no table privileges except `SELECT` on `notifications` (with the single `notifications_select_own` policy). Run `pnpm --filter @atarah/backend db:provision` after migrating to set the backend role's password from `ATARAH_BACKEND_DB_PASSWORD`.
- Supabase-managed objects Atarah touches (all in migrations): triggers on `auth.users`, the `supabase_realtime` publication (only `notifications`), rows in `storage.buckets`. Nothing else in `auth`, `storage` or `realtime` is modified. Reads of `auth.sessions` and `auth.mfa_factors` go through `public.atarah_auth_*` functions.
- Connections: the app and worker use the transaction pooler (`?pgbouncer=true&connection_limit=10`, user `atarah_backend.<tenant>`, tenant `pooler-dev` locally and the project ref in the cloud); Prisma migrations and long jobs use `ATARAH_DIRECT_URL`.
- Retention and purge rules (soft delete, account purge, notification retention) are documented here as each lifecycle lands (P1-M11/M12). Today: `users.deletedAt` is soft delete; `audit_logs` is permanent; `notification_dispatches` rows are keys for de-duplication and may be pruned after 30 days.

## Seeds

`prisma/seed/` — run with `pnpm db:seed` (from `apps/backend`) or `prisma db seed`.

- **Reference seed (every environment).** Create-if-missing only: permissions (62), roles (8) and role grants, entitlements (5), plans (FREE, PRO), Kenya + 47 counties, 12 disciplines, 54 specialisations, skills, interests, development areas, learning (15) and marketplace (8) categories, 27 platform settings (Pro price 120000 minor units KES, cancellation 24 h / 50 %, verification SLA 5 working days, …), feature flags from the registry, six DRAFT legal placeholders. It never overwrites operator edits and running it twice changes nothing.
- **Demo seed (`ATARAH_ENV=dev` only).** Eight illustrative accounts (five creatives from the prototype plus a moderator, an admin and a super admin), created in Supabase Auth through the admin API, all `isDemo = true`, shared dev password `Atarah-demo-1`. Needs `ATARAH_SUPABASE_URL` and `ATARAH_SUPABASE_SECRET_KEY`. Skipped in every other environment; set `ATARAH_SEED_REFERENCE_ONLY=1` to skip in dev too. Demo content for later domains (opportunities, courses, listings, mentors) is added by the milestones that create those tables.

## Working with the database

```bash
just infra-up                          # Supabase stack (Postgres on localhost:55322) + Redis
just supabase-env                      # writes the Supabase URL and keys into apps/backend/.env
cd apps/backend
pnpm db:migrate:deploy                 # apply migrations (direct connection)
pnpm db:provision                      # set the atarah_backend role password
pnpm db:seed                           # reference (+ demo in dev)
pnpm db:erd                            # regenerate docs/DATABASE-ERD.md
node ../../scripts/check-rls.mjs       # RLS everywhere, one allow-listed policy, anon has no access
npx supabase db reset                  # wipe the local database, then migrate and seed again
```

When adding a table: write the SQL (start from `prisma migrate diff --script`), enable RLS in the same migration, add indexes for every filter and sort, run `check-rls`. **Integration tests reset the local database** (every Auth user and application table is emptied; the script refuses any non-local address).

One-off dev migration from the pre-Supabase database: `apps/backend/scripts/migrate-dev-data.ts` (see its header). It recreates users through the Auth admin API with the same ids and a temporary password (Argon2 hashes are not importable), copies every other table in foreign-key order, and copies storage objects.

## Community and moderation (P1-M8)

Migration `20261022120000_community_moderation`. Written from `prisma migrate diff --script` and reviewed by hand (DEC-061); column names follow the existing camelCase convention. New tables, all with Row Level Security enabled, no policies and no `anon`/`authenticated` grants: `posts`, `post_media`, `post_links`, `post_attachments`, `comments`, `reactions`, `groups`, `group_memberships`, `group_pins`, `blocks`, `mutes`, `reports`, `moderation_cases`, `moderation_actions`, `community_restrictions`. New enums: `PostStatus`, `GroupVisibility`, `GroupRole`, `MuteTargetType`, `ReportTargetType`, `ModerationPriority`; `SavedItemType` gains `POST` (saved posts reuse `saved_items`). `connections` already had the unordered-pair unique index and the `requesterId <> addresseeId` check (P1-M3); nothing changed there.

| Rule                                                                                                                          | Where                                                                                             |
| ----------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| `posts.body` <= 5,000 characters; `comments.body` 1-2,000; `reports.note` <= 1,000                                            | CHECK                                                                                             |
| `posts.groupId` is set exactly when `audience = GROUP`                                                                        | CHECK `posts_group_audience`                                                                      |
| At most ten media per post: `post_media.sortOrder` 0-9 and unique per post                                                    | CHECK + unique index                                                                              |
| One reply level: a reply's parent is a top-level comment on the same post                                                     | trigger `comments_one_level`                                                                      |
| `moderation_actions` is append-only (UPDATE, DELETE and TRUNCATE refused for every role)                                      | triggers, like `audit_logs`; `actorId` has no foreign key so deleting an account never touches it |
| Nobody blocks themselves; counters never go negative                                                                          | CHECK                                                                                             |
| Search: stored generated `posts.searchVector` (body) with a GIN index                                                         | migration                                                                                         |
| One reaction per member and post; one block per direction; one report per reporter and target; one moderation case per target | unique indexes                                                                                    |

Indexes: `posts (groupId, createdAt desc)`, `(authorId, createdAt desc)`, `(status, createdAt desc)`, GIN on `searchVector`; `comments (postId, createdAt)`; `reports (status, createdAt)`; `moderation_cases (status, createdAt)`. `post_attachments.opportunityId` has no foreign key until the opportunities table exists (P1-M9). Counters (`posts.reactionCount`, `posts.replyCount`, `groups.memberCount`) change in the same transaction as their cause and are reconciled nightly. Seed: the demo seed (development only) adds finished profiles for the demo members, five groups, posts of every type and audience, comments, reactions and connections, all flagged `isDemo`; no reference data. New permissions `community.announce` and `community.group.manage` are in the reference seed (PLATFORM_ADMIN and SUPER_ADMIN).

## Opportunities (P1-M9)

Migration `20261024090000_opportunities` (hand-written; RLS on every table, `anon` and `authenticated` revoked, `atarah_backend` granted). Tables: `opportunity_providers`, `opportunities`, `opportunity_disciplines`, `opportunity_requirement_rules`, `opportunity_trackings`, `external_link_checks`. Enums added: `OpportunityProviderType`, `WorkMode`, `LinkStatus`, `OpportunityRuleType` (the six from section 6.3 already existed).

Constraints beyond Prisma: value range and non-negative CHECKs plus "an amount needs a currency"; `opportunity_trackings` CHECK that an `outcome` exists only when `status = COMPLETED`; unique (`userId`, `opportunityId`); generated `searchVector` (title weight A, summary B) with a GIN index and a trigram index on `title`; partial index on (`status`, `deadlineAt`) where `status = 'PUBLISHED'`; (`type`, `status`), (`countyId`, `status`), (`providerId`, `status`); `post_attachments.opportunityId` now has its foreign key (cascade). Money is stored in minor units (`valueMinMinor`, `valueMaxMinor`, `valueCurrency`); `valueText` holds amounts that are not a number ("Paid stipend"). Provider `opportunitiesCount` counts open published listings and is refreshed on every publish, close and expiry and nightly. Tracking rows are removed with the member or the listing (cascade); link-check rows are kept 90 days.

Saving a listing is a tracking row, not a `saved_items` row (DEC-079). Seed: reference none; the demo seed (development only) adds eight invented providers and twelve listings of every type with rules, all `isDemo`, deadlines relative to the seed day.

## Account, privacy, help and broadcasts (P1-M11)

Migration `20261102100000_account_privacy_help` (hand-written; RLS on every new table, client roles revoked, `atarah_backend` granted).

- **Saved items:** `SavedItemType` gains `LEARNING`, `CREATIVE`, `OPPORTUNITY`, `LISTING`, `MENTOR` (the last two reserved for Phase 2); `saved_items.collection` (nullable). Opportunities are still saved as `opportunity_trackings` rows (DEC-079); `OPPORTUNITY` exists so the unified list and the Activity counts can name the kind.
- **Notifications:** `notifications.type` (dotted key); index (`userId`, `readAt`, `createdAt desc`) replaces (`userId`, `readAt`); index on `createdAt` for retention. The 180-day retention job deletes older rows daily. `notification_preferences` keeps its push and email columns per category (DEC-086); the API still presents a category × channel grid.
- **Devices:** `user_devices.verifiedAt` (set when the device passed two-step sign-in or was registered while two-step was off; existing rows were back-filled).
- **New tables:** `profile_field_visibility` (`userId`, `field`, `visibility`; today only `ACTIVITY`, the other privacy fields are profile sections), `two_step_settings` (`userId`, `enabled`, `enabledAt`), `contact_change_requests` (`kind`, `oldValue`, `newValue`, `completedAt`), `data_export_requests` (`status`, `fileMediaId`, `expiresAt`), `account_deletion_requests` (**no foreign key**: the row outlives the account; unique open request per member; `purgeAfter` = request + 30 days), `help_articles` and `faq_entries` (ordered, `published`, generated `searchVector` + GIN), `notification_broadcasts` (`target` ALL, ROLE, DISCIPLINE, COUNTY with CHECKs that a targeted broadcast names its target and a deep link is an in-app path).
- **Legal documents** keep their existing `status` (`PUBLISHED` is the spec's `published`); publishing archives the previous published version of the same type, so consent records (which store the accepted version) keep a readable history.

### Data lifecycle (account deletion)

1. **Asking:** account `DEACTIVATED`, `statusReason = DELETION_REQUESTED`, an `account_deletion_requests` row `PENDING`, every Supabase session deleted. Every reader of a profile, post or search requires an `ACTIVE` owner, so the member disappears at once.
2. **Grace period (30 days):** signing in still works but only `GET /users/me` and `POST /me/restore` are allowed; restoring sets the account `ACTIVE` and the request `CANCELLED`.
3. **Purge (daily job):** posts and comments the member wrote are re-attributed to the single "Deleted member" account (created on first use, stored in `platform_settings.system.deleted_member_user_id`, banned, never able to sign in); every file the member uploaded (and its renditions, and any export ZIP) is removed from storage; the Supabase Auth user is deleted, which cascades the `users` row and everything personal that hangs off it (profile, portfolio, connections, saved items, progress, notifications, devices, preferences). The request becomes `PURGED`; the audit trail keeps only the non-personal user id (`account.purge`). A purge that fails (for example a foreign key that restricts) leaves the request `PENDING` and is retried the next day.
4. **Exports:** the ZIP is a private media asset the member owns; it is deleted with the account and expires 7 days after it was built.

## Skill Labs (P1-M10)

Migration `20261102090000_skill_labs` (hand-written; RLS on every table, `anon` and `authenticated` revoked, `atarah_backend` granted). Tables: `learning_contents`, `learning_content_disciplines`, `learning_content_skills`, `courses`, `lessons`, `enrolments`, `lesson_progress`, `content_progress`, `learning_activity_daily`, `certificates`, `learning_progress_overrides`. Enum added: `LearningAccess`; `SavedItemType` gains `LEARNING`. `learning_categories` already existed (P0).

Constraints beyond Prisma: `lesson_progress` CHECK that `status = COMPLETED` exactly when `completedAt` is set (same on `content_progress`) and a non-negative position; `lessons` unique (`courseId`, `sequence`), `sequence >= 1`, and at most one of video and embed; unique (`userId`, `courseId`) on `enrolments` and `certificates`; unique `certificateNumber` fed by sequence `certificate_number_seq`; generated `searchVector` on `learning_contents` (title weight A, summary B) with GIN and trigram indexes; (`categoryId`, `status`, `type`) and (`status`, `featured`); `lesson_progress` (`userId`, `updatedAt` desc). An external or embedded item needs its address before it is published; that is checked at publish, not by the database, so a draft can be saved half-written.

`courses` shares its key with `learning_contents`; `lessonCount` and `totalMinutes` are kept in step with the lessons by the service. `learning_activity_daily` holds minutes per Nairobi day (forward movement of a lesson in whole minutes, at most 15 per write, and a lesson's length when it is completed). Progress, enrolments, certificates and activity are removed with the member (cascade); a certificate's achievement is set null if the achievement is removed. Seed: reference adds the `learning.embed_hosts` setting (the learning categories were already seeded); the demo seed (development only) adds three courses with in-app text lessons (one premium) and five single items of every type and source, all `isDemo`; the two embedded examples are drafts because a demo has no real video to embed.

## Analytics, hardening and data lifecycle (P1-M12)

Migrations `20261102110000_analytics_events` and `20261102120000_phase1_hardening`.

**`analytics_events`** is partitioned by month (`RANGE ("occurredAt")`, primary key `(id, occurredAt)`) with a `DEFAULT` partition for strays. Columns: `name`, `actorHash` (an HMAC of the member id keyed from the backend secret, null for `registration`) and `props` (jsonb, only the allow-listed fields of that event: ids of content, enum values and coarse buckets; never free text, names, contact details or search words). `AnalyticsService.track` validates against a strict schema per event, drops anything that does not match, never fails a request, and is written from the in-process event bus. `registration` is written by a database trigger on `users` (accounts are created by Supabase Auth, outside the API). `analytics_daily_counts` (`date`, `name`, `events`, `actors`) is the nightly roll-up the charts read for past days. Partition maintenance is in the database (`atarah_ensure_analytics_partition`, `atarah_drop_old_analytics_partitions`, both security definer) and run by jobs: next months' partitions daily, whole partitions past 400 days dropped weekly. `users.suspendedUntil` ends a temporary suspension. `posts_visible_created_idx` is a partial index on visible posts newest first, which the feed's windowed ranking reads in order.

**Data lifecycle (what is kept, for how long, and what removes it)**

| Data                                   | Rule                                                                                                                                                                                                                             |
| -------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Posts, comments, projects, media       | Soft delete (`deletedAt`); every read path filters it. A member's own post can be deleted by them; moderators hide or remove (status), never edit.                                                                                |
| Moderation actions, audit log          | Append-only (database trigger rejects UPDATE and DELETE). Kept; the audit trail keeps only non-personal identifiers after an account purge.                                                                                       |
| Notifications                          | Deleted after 180 days (daily job).                                                                                                                                                                                              |
| Analytics events                       | 400 days, dropped a whole month at a time; the daily roll-up stays.                                                                                                                                                              |
| External link checks                   | 90 days (weekly link-health job trims them).                                                                                                                                                                                      |
| Opportunity trackings, learning progress | Removed with the member or the listing (cascade).                                                                                                                                                                                |
| Account deletion                       | Immediately: account `DEACTIVATED`, profile hidden, sessions revoked. Within 30 days the member can restore it. After 30 days the daily purge job removes personal data, media and private records and the Supabase Auth user; community posts and comments remain as "Deleted member". |
| Sessions                               | Supabase Auth owns them; revoked on suspension, password change and deletion.                                                                                                                                                    |

Backups: `scripts/db-backup.sh` and `scripts/db-restore.sh` (local `pg_dump` and `pg_restore` of the public and auth schemas through the Supabase Postgres container; uploaded files live in Storage and are not in the dump). `scripts/db-backup-test.sh` proves a dump restores into a scratch database with identical row counts. Production backups use Supabase point-in-time recovery (P3-M8).


## Payments (P2-M1)

Migration `20261120010000_payments_foundation`: enums `PaymentProviderKey`, `PaymentEventKind`, `PaymentEventSource`, `RefundStatus`, `LedgerEntryType`, `PayoutStatus` (the method, purpose and status enums come from the baseline) and five tables, all with RLS on and the backend role granted.

- `payments`: purpose, polymorphic reference (`referenceType`, `referenceId`, both or neither), payer (FK to `users`, RESTRICT), optional payee, `amountMinor`, `currency`, `platformFeeMinor`, `refundedMinor`, method, provider, `providerReference` (unique with provider), `receiptNumber`, `msisdnLast4`, status, `idempotencyKey` (unique per payer), failure code and reason, `expiresAt`, `lastQueriedAt`, `queryAttempts`, `version`. Checks: amount positive, fee and refunded within the amount.
- `payment_events`: every callback, status query and status change; `payloadEncrypted` (AES-256-GCM), unique `dedupeKey` for callbacks.
- `refunds`: amount, reason, status, mode (`AUTOMATIC` or `MANUAL`), requester, optional `idempotencyKey` (unique per payment).
- `transactions` (the ledger): payer, payee, gross, platform fee, net, `type` PAYMENT or REFUND (refund rows are negative and name their refund). Append-only trigger; partial unique index gives one PAYMENT row per payment; `gross = fee + net` and sign checks.
- `payouts`: table only (payouts are not automated in Phase 2).

Account deletion re-points `payments.payerId` to the "Deleted member" placeholder so financial records survive (DEC-104).
