#!/bin/bash
set -euo pipefail

cd /usr/src/ebwiki

export RAILS_ENV=test
export DATABASE_URL=postgres://blackops:ebwiki@postgres:5432/blackops_test
export PGHOST=postgres
export PGUSER=blackops
export PGPASSWORD=ebwiki
export PGDATABASE=blackops_test
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH:-}"

/usr/bin/psql --set ON_ERROR_STOP=1 --file db/structure.sql "$DATABASE_URL"
bundle exec rails runner 'File.write("/tmp/boot.txt", Rails.application.class.name)'
