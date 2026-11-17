#!/usr/bin/env bash
# Runs a command while holding a machine-wide lock, so parallel workers never use a shared resource at once
# (the integration suites reset the one local database; the API client generators rewrite the same files).
#   scripts/with-lock.sh int      node --experimental-vm-modules node_modules/jest/bin/jest.js --selectProjects integration
#   scripts/with-lock.sh gen      pnpm gen:api
# Waits up to 90 minutes. A lock left by a crashed run is cleared after 90 minutes.
set -u
name="$1"; shift
dir="${TMPDIR:-/tmp}/atarah-lock-$name"
waited=0
until mkdir "$dir" 2>/dev/null; do
  if [ -d "$dir" ] && [ -n "$(find "$dir" -maxdepth 0 -mmin +90 2>/dev/null)" ]; then rmdir "$dir" 2>/dev/null; continue; fi
  sleep 10; waited=$((waited+10)); [ $waited -gt 5400 ] && { echo "lock $name busy for too long" >&2; exit 75; }
done
trap 'rmdir "$dir" 2>/dev/null' EXIT INT TERM
"$@"
