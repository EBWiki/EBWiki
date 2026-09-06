#!/usr/bin/env bash
set -euo pipefail

echo "*** Preparing database ***"
if bundle exec rails db:migrate; then
  echo "*** Migrations applied ***"
else
  echo "*** db:migrate failed; loading structure.sql ***"
  bundle exec rails db:schema:load
fi

if [ "${REVIEW_SERVER:-}" = "1" ]; then
  echo "*** Seeding review server demo data ***"
  bundle exec rake review:seed
fi