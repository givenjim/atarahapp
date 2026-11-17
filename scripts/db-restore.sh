#!/usr/bin/env bash
# Restores a db-backup.sh dump into a NEW scratch database on the LOCAL Supabase Postgres, never over the shared dev
# database: the target name must differ from `postgres` (pass --allow-postgres only to rebuild an empty dev database
# on purpose).
#
#   bash scripts/db-restore.sh <dump-file> [target-database]     default target: atarah_restore
#
# The target is dropped and recreated first. Prints the row counts of the main tables when it finishes.
set -euo pipefail
container="${ATARAH_DB_CONTAINER:-supabase_db_atarah}"
file="${1:?usage: db-restore.sh <dump-file> [target-database]}"
target="${2:-atarah_restore}"
[ -s "$file" ] || { echo "no such dump: $file" >&2; exit 1; }
if [ "$target" = "postgres" ] && [ "${3:-}" != "--allow-postgres" ]; then
  echo "refusing to restore over the shared dev database 'postgres'" >&2; exit 1
fi
psql() { docker exec -i "$container" psql -U supabase_admin -v ON_ERROR_STOP=1 -Atq "$@"; }
psql -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$target'" >/dev/null
psql -d postgres -c "DROP DATABASE IF EXISTS \"$target\""
psql -d postgres -c "CREATE DATABASE \"$target\""
psql -d "$target" -c "CREATE SCHEMA IF NOT EXISTS extensions; CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\" SCHEMA extensions; CREATE EXTENSION IF NOT EXISTS pgcrypto SCHEMA extensions; CREATE EXTENSION IF NOT EXISTS citext SCHEMA public; CREATE EXTENSION IF NOT EXISTS pg_trgm SCHEMA public; CREATE EXTENSION IF NOT EXISTS unaccent SCHEMA public"
# pg_restore reads the file from stdin inside the container.
docker exec -i "$container" pg_restore -U supabase_admin -d "$target" --no-owner --no-privileges --exit-on-error < "$file" 2>"${TMPDIR:-/tmp}/atarah-restore.err" || {
  echo "pg_restore reported problems (first lines):" >&2; head -5 "${TMPDIR:-/tmp}/atarah-restore.err" >&2; exit 1; }
for t in users creative_profiles posts comments opportunities notifications audit_logs; do
  echo "$t: $(psql -d "$target" -c "SELECT count(*) FROM public.\"$t\"" 2>/dev/null || echo n/a)"
done
echo "auth.users: $(psql -d "$target" -c 'SELECT count(*) FROM auth.users')"
