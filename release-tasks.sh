#!/usr/bin/env bash
set -euo pipefail

echo "*** Preparing database ***"
if bundle exec rails db:migrate; then
  echo "*** Migrations applied ***"
else
  echo "*** db:migrate failed; loading structure.sql (PG16-compatible) ***"
  tmp="$(mktemp)"
  grep -v 'transaction_timeout' db/structure.sql > "$tmp"
  psql "$DATABASE_URL" --set ON_ERROR_STOP=1 --quiet --file "$tmp"
  rm -f "$tmp"
  bundle exec rails db:migrate
fi

if [ "${REVIEW_SERVER:-}" = "1" ]; then
  echo "*** Seeding review server demo data ***"
  bundle exec rake review:seed
fi