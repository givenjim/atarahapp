#!/usr/bin/env sh
# Thin wrapper so CI on Linux/macOS can call the brand check by its documented name.
# The implementation is cross-platform Node (scripts/check-brand.mjs).
set -e
cd "$(dirname "$0")/.."
exec node scripts/check-brand.mjs
