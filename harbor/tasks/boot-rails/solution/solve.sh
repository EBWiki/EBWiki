#!/bin/bash
set -euo pipefail

cd /usr/src/ebwiki
export RAILS_ENV="${RAILS_ENV:-test}"
export DATABASE_URL="${DATABASE_URL:-postgres://blackops:ebwiki@postgres:5432/blackops_test}"
export PGHOST="${PGHOST:-postgres}"
export PGUSER="${PGUSER:-blackops}"
export PGPASSWORD="${PGPASSWORD:-${BLACKOPS_DATABASE_PASSWORD:-ebwiki}}"
export PGDATABASE="${PGDATABASE:-blackops_test}"
bundle exec rails db:prepare
bundle exec rails runner 'File.write("/tmp/boot.txt", Rails.application.class.name)'
