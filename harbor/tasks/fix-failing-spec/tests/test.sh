#!/bin/bash
set -u

mkdir -p /logs/verifier

cd /usr/src/ebwiki

export RAILS_ENV="${RAILS_ENV:-test}"
export DATABASE_URL="${DATABASE_URL:-postgres://blackops:ebwiki@postgres:5432/blackops_test}"
export PGHOST="${PGHOST:-postgres}"
export PGUSER="${PGUSER:-blackops}"
export PGPASSWORD="${PGPASSWORD:-ebwiki}"
export PGDATABASE="${PGDATABASE:-blackops_test}"
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH:-}"

if bundle exec rspec spec/harbor/addition_spec.rb; then
  echo 1 > /logs/verifier/reward.txt
  exit 0
fi

echo 0 > /logs/verifier/reward.txt
exit 0
