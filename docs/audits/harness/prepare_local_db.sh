#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
cd "$ROOT"

if [[ ! -f config/database.yml ]]; then
  cp config/database.ci.yml config/database.yml
fi

export RAILS_ENV=test

bundle exec rails db:create

mapfile -t _db_cfg < <(bundle exec rails runner "
cfg = ActiveRecord::Base.configurations.configs_for(env_name: 'test').first
h = cfg.configuration_hash
[h[:host], h[:username], h[:database], h[:password]].each { |v| puts(v.to_s) }
")

DB_HOST="${_db_cfg[0]}"
DB_USER="${_db_cfg[1]}"
DB_NAME="${_db_cfg[2]}"
DB_PASS="${_db_cfg[3]}"

psql_args=(-v ON_ERROR_STOP=1)
if [[ -n "$DB_HOST" ]]; then
  psql_args+=(-h "$DB_HOST")
fi
if [[ -n "$DB_USER" ]]; then
  psql_args+=(-U "$DB_USER")
fi

export PGPASSWORD="$DB_PASS"
psql "${psql_args[@]}" -d "$DB_NAME" -c 'DROP SCHEMA IF EXISTS public CASCADE; CREATE SCHEMA public;'
grep -v '^SET transaction_timeout' db/structure.sql | psql "${psql_args[@]}" -d "$DB_NAME"
unset PGPASSWORD

bundle exec rails runner "
require 'factory_bot_rails'
include FactoryBot::Syntax::Methods
unless Case.exists?(slug: 'audit-sample-case')
  state = State.first || create(:state)
  c = create(:case, state: state, title: 'Audit Sample Case', blurb: 'Synthetic blurb for accessibility scan.')
  create(:subject, case: c, name: 'Sample Person', age: 30)
end
"
