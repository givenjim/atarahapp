# Atarah — instructions for Claude Code

Atarah is a Luxaion Creatives product: a Creative Operating Layer for Kenyan creatives.

**The contract is `docs/MASTER_PROMPT.md`.** Read the section for the active milestone before starting it. The register of record is `docs/PROGRESS.md`; decisions go in `docs/DECISIONS.md`.

## Hard rules (summary — the Master Prompt §1 wins)

- **No git write commands**, ever. Read-only (`status`, `diff`, `log`, `show`) is fine. Report changed files instead of committing.
- Work one phase at a time. **Stop at every phase gate**, announce it by its exact name, write the gate report, and wait for the product owner.
- **Never fabricate** listings, verification outcomes, payments, legal text, provider behaviour, test results or build success. Say MOCKED / PARTIAL / BLOCKED when that is the truth.
- **No secrets in the repo or client.** `.env` git-ignored; `.env.example` committed; signing keys outside the repo.
- **No dead UI.** Unbuilt features open `AtFutureScreen` ("Soon · P#" / "Soon · Later"). No hard-coded sample data in UI code.
- Ask only when blocked or when two important sources conflict on money, security, privacy, legal or permissions. Otherwise decide and record it.
- No deploys, store publishing or production changes without written authorisation.
- Locked stack: Flutter + Riverpod + go_router + dio; Next.js (web, admin); NestJS modular monolith; PostgreSQL 16 + Prisma; Redis + BullMQ; S3-compatible storage.
- Authorisation is never a single `user.role`: account status + roles + entitlements + verification + ownership + visibility + flags, enforced on the backend.

## Layout

`apps/{mobile,web,admin,backend}` · `packages/{api-contracts,design-tokens,shared-config}` · `infrastructure/` · `design/prototype/` (reference only; ignore `_ds/`) · `docs/`.

## Commands

`just --list` (or the `pnpm` scripts). Details in `docs/DEVELOPMENT.md`.

## Milestone reporting (owner, 2026-10-19; DEC-047)

No per-milestone report files. After every milestone: update `docs/PROGRESS.md` and `docs/DECISIONS.md`, then give a short summary in chat (what was built, test evidence, not verified, decisions to confirm, changed areas, manual check) and stop for the owner.
