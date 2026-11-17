#!/usr/bin/env bash
# Backs up the application data of the LOCAL Supabase database (schemas public and auth) to a compressed
# pg_dump file, using the pg_dump that ships inside the Supabase Postgres container (no client install needed).
#
#   bash scripts/db-backup.sh [output-dir]        default: ./backups  (git-ignored)
#
# Prints the file path. Storage objects (uploaded files) live in the Supabase Storage volume and are NOT part of
# this dump; production backups use Supabase point-in-time recovery (P3-M8). Restore with db-restore.sh.
set -euo pipefail
container="${ATARAH_DB_CONTAINER:-supabase_db_atarah}"
db="${ATARAH_BACKUP_DB:-postgres}"
out="${1:-backups}"
mkdir -p "$out"
file="$out/atarah-${db}-$(date +%Y%m%d-%H%M%S).dump"
docker exec "$container" pg_dump -U supabase_admin -d "$db" -Fc -Z 6 -n public -n auth --no-owner --no-privileges > "$file"
[ -s "$file" ] || { echo "backup is empty: $file" >&2; rm -f "$file"; exit 1; }
echo "$file"
