#!/usr/bin/env bash
# Restore the historic latest.dump (2020-09-01) into a throwaway Neon branch
# for EBWiki friendly-photos review. Requires DIRECT connection (not pooler).
#
# Usage:
#   NEON_DIRECT_URL='postgres://...' ./scripts/restore_ebwiki_neon_review.sh
#
# Safety:
#   Aborts if public.cases already has rows unless FORCE=1 is set.
#   Never run against Heroku production.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DUMP_PATH="${DUMP_PATH:-/tmp/latest.dump}"
DUMP_URL="${DUMP_URL:-https://raw.githubusercontent.com/EBWiki/EBWiki/592560514b263c8956d039bdd25c9c8b7fb2a81f/latest.dump}"
COMPAT_SQL="${ROOT}/db/dump_compat.sql"

if [[ -z "${NEON_DIRECT_URL:-}" ]]; then
  echo "Set NEON_DIRECT_URL to the Neon DIRECT connection string (no -pooler host)." >&2
  exit 1
fi

if [[ "$NEON_DIRECT_URL" == *"-pooler."* ]]; then
  echo "NEON_DIRECT_URL looks pooled. pg_restore needs a DIRECT endpoint." >&2
  exit 1
fi

for cmd in pg_restore psql curl; do
  if ! command -v "$cmd" >/dev/null; then
    echo "Missing required command: $cmd" >&2
    exit 1
  fi
done

existing_cases="$(psql "$NEON_DIRECT_URL" -tAc "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public' AND table_name='cases'" 2>/dev/null || echo 0)"
if [[ "$existing_cases" == "1" ]]; then
  row_count="$(psql "$NEON_DIRECT_URL" -tAc 'SELECT COUNT(*) FROM public.cases' 2>/dev/null || echo 0)"
  if [[ "${row_count:-0}" -gt 0 && "${FORCE:-}" != "1" ]]; then
    echo "Abort: public.cases already has ${row_count} rows. Set FORCE=1 to wipe via pg_restore --clean." >&2
    exit 1
  fi
fi

if [[ ! -f "$DUMP_PATH" ]] || [[ "$(wc -c < "$DUMP_PATH")" -lt 1000000 ]]; then
  echo "Downloading dump from ${DUMP_URL} -> ${DUMP_PATH}"
  curl -fsSL -o "$DUMP_PATH" "$DUMP_URL"
fi

list_file="$(mktemp)"
pg_restore -l "$DUMP_PATH" | grep -v EXTENSION > "$list_file"

echo "Restoring dump into Neon (this may take several minutes)..."
pg_restore --verbose --clean --if-exists --no-acl --no-owner \
  -L "$list_file" --dbname="$NEON_DIRECT_URL" "$DUMP_PATH" || true

rm -f "$list_file"

echo "Applying dump compatibility SQL..."
psql "$NEON_DIRECT_URL" -v ON_ERROR_STOP=1 -f "$COMPAT_SQL"

case_count="$(psql "$NEON_DIRECT_URL" -tAc 'SELECT COUNT(*) FROM public.cases')"
user_count="$(psql "$NEON_DIRECT_URL" -tAc 'SELECT COUNT(*) FROM public.users' 2>/dev/null || echo 0)"
subject_count="$(psql "$NEON_DIRECT_URL" -tAc 'SELECT COUNT(*) FROM public.subjects' 2>/dev/null || echo 0)"

echo "Restore complete."
echo "  cases:    ${case_count}"
echo "  subjects: ${subject_count}"
echo "  users:    ${user_count}"
echo ""
echo "Next:"
echo "  1. bundle exec rails db:migrate   # friendly-photos tables on review branch"
echo "  2. Set Railway ebwiki-web DATABASE_URL to Neon POOLED URL (-pooler host)"
echo "  3. Redeploy ebwiki-web (keep REVIEW_SERVER=1, E2E_STUB_WIKIMEDIA=0, OPENAI_API_KEY)"
echo "  4. Optional: FORCE review seed only if disposable login needed:"
echo "     REVIEW_SERVER=1 bundle exec rake review:seed"
