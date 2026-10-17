# Atarah task runner. Install: https://github.com/casey/just  (winget install Casey.Just)
# Windows uses PowerShell; Linux/macOS use sh.
set windows-shell := ["powershell.exe", "-NoLogo", "-NoProfile", "-Command"]

default:
    @just --list

# Install all dependencies and create local .env files from templates
setup:
    node scripts/setup.mjs

# One command from a fresh checkout: install, env files, start services, migrate, seed (Docker must be running)
bootstrap:
    node scripts/bootstrap.mjs

# Start local services (PostgreSQL, Redis, S3-compatible storage, Mailpit). Needs Docker running.
infra-up:
    docker compose -f infrastructure/docker-compose.yml up -d

infra-down:
    docker compose -f infrastructure/docker-compose.yml down

# Run the backend + worker (and web/admin when they exist) in watch mode
dev:
    pnpm --filter @atarah/backend --if-present dev

test:
    pnpm -r --if-present test
    cd apps/mobile; flutter test

lint:
    pnpm -r --if-present lint
    cd apps/mobile; flutter analyze

build:
    pnpm -r --if-present build

format-check:
    pnpm format:check
    cd apps/mobile; dart format --set-exit-if-changed lib test

check-brand:
    node scripts/check-brand.mjs

db-migrate:
    pnpm --filter @atarah/backend --if-present db:migrate

db-seed:
    pnpm --filter @atarah/backend --if-present db:seed

gen-api:
    pnpm --filter @atarah/api-contracts --if-present generate

gen-tokens:
    pnpm --filter @atarah/design-tokens --if-present generate
