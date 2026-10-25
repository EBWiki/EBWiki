#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
cd "$ROOT"

if [[ ! -f config/database.yml ]]; then
  cp config/database.ci.yml config/database.yml
fi

grep -v '^SET transaction_timeout' db/structure.sql | psql -v ON_ERROR_STOP=1 "${DATABASE_URL:-postgresql://postgres:postgres@localhost/app_test}"

RAILS_ENV=test bundle exec rails runner "
require 'factory_bot_rails'
include FactoryBot::Syntax::Methods
unless Case.exists?(slug: 'audit-sample-case')
  state = State.first || create(:state)
  c = create(:case, state: state, title: 'Audit Sample Case', blurb: 'Synthetic blurb for accessibility scan.')
  create(:subject, case: c, name: 'Sample Person', age: 30)
end
"
