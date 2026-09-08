#!/usr/bin/env bash
set -euo pipefail

load_structure() {
  echo "*** Loading structure.sql (PG16-compatible) ***"
  tmp="$(mktemp)"
  grep -v 'transaction_timeout' db/structure.sql > "$tmp"
  psql "$DATABASE_URL" --set ON_ERROR_STOP=1 --quiet --file "$tmp"
  rm -f "$tmp"
}

echo "*** Preparing database ***"
if bundle exec rails db:migrate; then
  echo "*** Migrations applied ***"
else
  load_structure
  bundle exec rails db:migrate
fi

# Never seed against a shared/review corpus unless explicitly requested.
# The Neon ebwiki-review database already has the restored case set.
if [ "${REVIEW_SEED_MAP_CASES:-}" = "1" ]; then
  echo "*** Seeding review map cases ***"
  bundle exec rake review:seed_map_cases
fi
