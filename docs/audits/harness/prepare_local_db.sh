#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
cd "$ROOT"

if [[ ! -f config/database.yml ]]; then
  cp config/database.ci.yml config/database.yml
fi

export RAILS_ENV=test

_db_cfg=()
while IFS= read -r line; do
  _db_cfg+=("$line")
done < <(bundle exec ruby -ryaml -rerb -ruri <<'RUBY'
test = YAML.safe_load(ERB.new(File.read('config/database.yml')).result, aliases: true)['test']
h = test.transform_keys(&:to_s)
host = h['host'].to_s
user = h['username'].to_s
db = h['database'].to_s
pass = h['password'].to_s
db_host = host.empty? ? 'localhost' : host
url = if user.empty?
  "postgres://#{db_host}/#{db}"
else
  "postgres://#{URI.encode_uri_component(user)}:#{URI.encode_uri_component(pass)}@#{db_host}/#{db}"
end
puts host
puts user
puts db
puts pass
puts url
RUBY
)

DB_HOST="${_db_cfg[0]}"
DB_USER="${_db_cfg[1]}"
DB_NAME="${_db_cfg[2]}"
DB_PASS="${_db_cfg[3]}"
export DATABASE_URL="${_db_cfg[4]}"

bundle exec rails db:create

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
