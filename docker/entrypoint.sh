#!/bin/bash
set -euo pipefail

cd /usr/src/ebwiki
rm -f tmp/pids/server.pid

if [ -n "${BLACKOPS_DATABASE_PASSWORD:-}" ]; then
  export PGPASSWORD="${PGPASSWORD:-$BLACKOPS_DATABASE_PASSWORD}"
fi

if [ -n "${DATABASE_URL:-}" ]; then
  host="${PGHOST:-postgres}"
  user="${PGUSER:-blackops}"
  echo "## Waiting for Postgres at ${host}"
  until pg_isready -h "${host}" -U "${user}"; do
    sleep 1
  done
  echo "## Preparing database"
  bundle exec rails db:prepare
fi

exec "$@"
