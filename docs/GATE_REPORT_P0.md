# Phase 0 gate report — Foundation

**PHASE 0 FOUNDATION REQUIREMENTS COMPLETE**

Date: 2026-10-17. Nine of 35 milestones are done (P0-M1 to P0-M9). Work stops here until the product owner says to start Phase 1.

## Gate checks (Master Prompt, Phase 0)

| Check                                               | Result      | Evidence                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| --------------------------------------------------- | ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Clean-machine setup following `DEVELOPMENT.md`      | **PARTIAL** | No second machine was available. I verified a clean copy of the tree (no `node_modules`, builds or env files): `pnpm install --frozen-lockfile`, format, Prisma generate, backend build, lint, typecheck, unit, web and admin tests, web and admin production builds all pass. `pnpm bootstrap` was run end to end against the running services (idempotent). The clean-copy check found and I fixed a real gap: `pnpm install` does not generate the Prisma client, so bootstrap now does. `pnpm gen:api` needs the `.env` that bootstrap creates. |
| Backend, worker, web, admin, mobile build and start | PASS        | API and worker start and `/health/ready` is up; both Next apps build and run; Android debug APK builds and runs on the emulator.                                                                                                                                                                                                                                                                                                                                                                                                                    |
| All tests pass                                      | PASS        | Backend 234 (unit 90, integration 144; real PostgreSQL, Redis and S3 via Testcontainers). Admin kit 13. Web 5. Flutter 239. Playwright 1. Emulator journey 1.                                                                                                                                                                                                                                                                                                                                                                                       |
| Lint, typecheck, format, brand check                | PASS        | `pnpm lint`, `pnpm typecheck`, `pnpm format:check`, `dart format`, `flutter analyze`, `pnpm check:brand` all clean.                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| Auth matrix tests                                   | PASS        | `test/access.int-spec.ts` and `test/auth.int-spec.ts` inside the 234.                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| Admin TOTP flow in Playwright                       | PASS        | `apps/admin/e2e/admin-flow.spec.ts`: enrolment, recovery codes, wrong then right re-auth, suspend, audit entry, reactivate, sign-out.                                                                                                                                                                                                                                                                                                                                                                                                               |
| Mobile shell on the Android emulator                | PASS        | A member was registered through the API, verified with the code from Mailpit, then signed in on the emulator: splash, welcome, sign in, tab shell, every other tab shows "Soon · P1", profile from the real API, session survives restart, sign out. Run with the seeded member and with the freshly registered one.                                                                                                                                                                                                                                |
| No secrets in the repository                        | PASS        | `gitleaks dir . --config .gitleaks.toml`: no leaks found (2.5 MB scanned). The workspace is not a git repository, so this scanned the working tree.                                                                                                                                                                                                                                                                                                                                                                                                 |
| Registers and docs current                          | PASS        | `PROGRESS.md` (9/35), `DECISIONS.md` (DEC-001 to DEC-031), `DEVELOPMENT.md` rewritten, API, ARCHITECTURE, SECURITY, TESTING updated.                                                                                                                                                                                                                                                                                                                                                                                                                |

## What is mocked, partial or not verified

- **FCM push**: not verified against Google (no credentials). Development uses a recording sink; deployed environments without credentials fail loudly.
- **Email and SMS production providers**: not chosen. Local mail goes to Mailpit; SMS is a development log sink that the environment schema refuses in staging and production.
- **iOS**: not configured or built; this host is Windows.
- **CI workflow**: written and parsed, never executed on GitHub.
- **Firebase** is not initialised in the mobile app.
- **Real S3 provider**: tested against Scality CloudServer (MinIO images are not pullable, DEC-009); only the S3 API is used.

## Changes since the P0-M7 report that matter

- `sentry_flutter` 10 and `minSdk` 26 (DEC-026): devices below Android 8.0 are unsupported.
- Admin console is a backend-for-frontend with httpOnly cookies (DEC-027); sidebar phase labels are my reading of the milestone list.
- Media rules and notification behaviour (DEC-029, DEC-030). Documents are PDF only; Word CVs are an open question.
- Generated Dart is committed and must be formatted after generation (CI checks for no diff).

## Owner decisions needed (Master Prompt section 12)

1. Domain and app identifiers (assumed `atarah.app`, `app.atarah.mobile`, DEC-007), used in deep links, email links and API hosts.
2. Production email provider and SMS provider.
3. Google sign-in credentials, card payment provider details, Firebase project (needed to verify push).
4. Legal text (Terms, Privacy), commission and fee rules, scholarship criteria: not needed until Phases 1 and 2, but placeholders must stay labelled as drafts.
5. Confirm the phase labels on the admin sidebar (DEC-027) and whether Word documents must be accepted for uploads (DEC-029).
6. Whether staging and production API hosts (`api.staging.atarah.app`, `api.atarah.app`) are right.

## Files changed in P0-M7 to P0-M9 (no git commands were run)

Backend `src/admin`, `src/media`, `src/notifications`, storage and config additions, tests `admin`, `media`, `notifications`, scripts `e2e-fixtures.ts`. Web `apps/web`, admin `apps/admin` (including `e2e`). `packages/api-contracts` (typed client, schema, regenerated contract). Mobile: Sentry upgrade, minSdk, regenerated client, journey test parameters. Root: `scripts/bootstrap.mjs`, `.github/workflows/ci.yml`, `.gitleaks.toml`, `.gitignore`, `.prettierignore`, `justfile`, `package.json`, `pnpm-workspace.yaml`. Docs as listed above.

Waiting for the product owner. I will not start Phase 1 until told.
