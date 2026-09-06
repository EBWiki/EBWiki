#!/usr/bin/env bash
set -euo pipefail

run_review_deploy_prepare() {
  bundle exec rake review:deploy_prepare
}

echo "*** Preparing database ***"
if [ "${REVIEW_SERVER:-}" = "1" ]; then
  echo "*** Review deploy: migrate, reset pool, seed (single process) ***"
  if run_review_deploy_prepare; then
    echo "*** Review deploy prepare complete ***"
  else
    echo "*** review:deploy_prepare failed; loading structure.sql (PG16-compatible) ***"
    tmp="$(mktemp)"
    grep -v 'transaction_timeout' db/structure.sql > "$tmp"
    psql "$DATABASE_URL" --set ON_ERROR_STOP=1 --quiet --file "$tmp"
    rm -f "$tmp"
    if run_review_deploy_prepare; then
      echo "*** Review deploy prepare complete ***"
    else
      echo "*** WARNING: review deploy prepare failed; ensuring sessions table ***"
      bundle exec rake review:ensure_sessions || true
      echo "*** WARNING: continuing deploy (migrations may have applied) ***"
    fi
  fi
elif bundle exec rails db:migrate; then
  echo "*** Migrations applied ***"
else
  echo "*** db:migrate failed; loading structure.sql (PG16-compatible) ***"
  tmp="$(mktemp)"
  grep -v 'transaction_timeout' db/structure.sql > "$tmp"
  psql "$DATABASE_URL" --set ON_ERROR_STOP=1 --quiet --file "$tmp"
  rm -f "$tmp"
  bundle exec rails db:migrate
fi
