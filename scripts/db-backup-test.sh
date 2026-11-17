#!/usr/bin/env bash
# Proves a backup is restorable: dumps a database, restores it into a scratch database and compares the row count of
# every public table and auth.users between the two. Exits 1 on any difference.
#
#   bash scripts/db-backup-test.sh [source-database]      default: postgres (the dev database)
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
container="${ATARAH_DB_CONTAINER:-supabase_db_atarah}"
src="${1:-postgres}"
dump="$(ATARAH_BACKUP_DB="$src" bash "$here/db-backup.sh" "${TMPDIR:-/tmp}")"
echo "dump: $dump ($(wc -c < "$dump") bytes)"
bash "$here/db-restore.sh" "$dump" atarah_restore_test >/dev/null
counts() {
  docker exec -i "$container" psql -U supabase_admin -d "$1" -Atq -c "
    SELECT t.table_name || ' ' || (xpath('/row/c/text()', query_to_xml('select count(*) as c from public.\"' || t.table_name || '\"', false, true, '')))[1]::text
    FROM information_schema.tables t WHERE t.table_schema = 'public' AND t.table_type = 'BASE TABLE' AND t.table_name NOT LIKE 'analytics_events_%'
    UNION ALL SELECT 'auth.users ' || count(*) FROM auth.users ORDER BY 1"
}
counts "$src" > "${TMPDIR:-/tmp}/atarah-counts-src.txt"
counts atarah_restore_test > "${TMPDIR:-/tmp}/atarah-counts-restored.txt"
if diff -u "${TMPDIR:-/tmp}/atarah-counts-src.txt" "${TMPDIR:-/tmp}/atarah-counts-restored.txt"; then
  echo "backup-restore test: OK ($(wc -l < "${TMPDIR:-/tmp}/atarah-counts-src.txt") tables compared)"
else
  echo "backup-restore test: FAILED (row counts differ)" >&2; status=1
fi
docker exec -i "$container" psql -U supabase_admin -d postgres -Atq -c "DROP DATABASE IF EXISTS atarah_restore_test" >/dev/null
rm -f "$dump"
exit "${status:-0}"
