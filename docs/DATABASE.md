# Atarah — Database

PostgreSQL 16 + Prisma 6. Schema is split by domain in `apps/backend/prisma/schema/`:

| File                         | Contents                                                                                                                             |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| `schema.prisma`              | generator + datasource (`ATARAH_DATABASE_URL`)                                                                                       |
| `enums.prisma`               | Master Prompt §6 canonical enums                                                                                                     |
| `system.prisma`              | `AuditLog`, `PlatformSetting`, `FeatureFlag`                                                                                         |
| `identity.prisma`            | `User`, `Credential`, `Session`, `VerificationCode`, `ConsentRecord`, `LegalDocument`                                                |
| `access.prisma`              | `Role`, `Permission`, `RolePermission`, `UserRole`                                                                                   |
| `membership.prisma`          | `MembershipPlan`, `Entitlement`, `MembershipEntitlement`, `Membership`                                                               |
| `taxonomy.prisma`            | `Country`, `County`, `Town`, disciplines, specialisations, skills, interests, development areas, learning and marketplace categories |
| `media-notifications.prisma` | `MediaAsset`, `Notification`, `NotificationPreference`, `DeviceToken`                                                                |

Entities, relationships and rules: `docs/DOMAIN.md`.

## Conventions (Master Prompt §7.3)

- UUID primary keys; `createdAt` and `updatedAt` on every table (`audit_logs` is append-only and has no `updatedAt`); `deletedAt` where users can delete what they own.
- Lifecycles are enums, never booleans such as `isVerified` / `isPremium`.
- Tables snake_case plural via `@@map`; Prisma fields camelCase.
- Foreign keys, unique and check constraints, and an index for every filter and sort the API exposes. Full-text `tsvector` + GIN indexes arrive with searchable entities (P1-M5).
- Money: integer minor units + ISO-4217 code. Times: UTC.
- Never edit an applied migration. Destructive changes (dropping or renaming columns that hold data) need written owner approval.
- Extensions: `pg_trgm`, `unaccent`, `citext` (created in `init_system`).

## Constraints Prisma cannot express (in migration SQL)

| Constraint                                                         | Where             | Purpose                                                        |
| ------------------------------------------------------------------ | ----------------- | -------------------------------------------------------------- |
| `audit_logs` append-only triggers                                  | `init_system`     | Reject UPDATE, DELETE, TRUNCATE for every role.                |
| `users_identifier_present`                                         | `init_foundation` | Email or phone required.                                       |
| `users_phone_e164`                                                 | `init_foundation` | Phone stored as `+<country><number>`.                          |
| `memberships_one_live_per_user`                                    | `init_foundation` | Partial unique index: one ACTIVE/PAST_DUE membership per user. |
| `counties_code_format`                                             | `init_foundation` | Three upper-case letters.                                      |
| `verification_codes_attempts_nonneg`, `media_assets_size_positive` | `init_foundation` | Sanity checks.                                                 |

## Migrations log

| Migration                        | Summary                                                                                                   |
| -------------------------------- | --------------------------------------------------------------------------------------------------------- |
| `20261016233118_init_system`     | Extensions; `audit_logs` (append-only), `platform_settings`, `feature_flags`.                             |
| `20261016235442_init_foundation` | 51 enums total; identity, access, membership, taxonomy, media and notification tables; constraints above. |
| `20261017000213_admin_auth`      | `admin_totp` (encrypted TOTP secret, replay time step, hashed recovery codes); `sessions.reauthAt`.       |

## Seeds

`prisma/seed/` — run with `pnpm db:seed` (from `apps/backend`) or `prisma db seed`.

- **Reference seed (every environment).** Create-if-missing only: permissions (62), roles (8) and role grants, entitlements (5), plans (FREE, PRO), Kenya + 47 counties, 12 disciplines, 54 specialisations, skills, interests, development areas, learning (15) and marketplace (8) categories, 27 platform settings (Pro price 120000 minor units KES, cancellation 24 h / 50 %, verification SLA 5 working days, …), feature flags from the registry, six DRAFT legal placeholders. It never overwrites operator edits and running it twice changes nothing.
- **Demo seed (`ATARAH_ENV=dev` only).** Five illustrative accounts from the prototype, all `isDemo = true`, shared dev password `Atarah-demo-1`. Skipped in every other environment; set `ATARAH_SEED_REFERENCE_ONLY=1` to skip in dev too. Demo content for later domains (opportunities, courses, listings, mentors) is added by the milestones that create those tables.

## Working with the database

```bash
just infra-up                          # PostgreSQL on localhost:55432
cd apps/backend
npx prisma migrate deploy              # apply migrations
npx prisma migrate dev --name <name>   # create + apply a new migration (dev only)
npx prisma db seed                     # reference (+ demo in dev)
npx prisma studio                      # browse data
```

When adding SQL to a generated migration (constraints, triggers, partial indexes), use `migrate dev --create-only`, edit the SQL, then `migrate deploy`.
