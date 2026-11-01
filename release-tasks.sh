#!/usr/bin/env bash
# Runs before every deploy (Railway pre-deploy, Procfile release).
#
# Only schema migrations belong here. Never add db:seed, db:reset, db:setup,
# db:prepare, db:schema:load or any sample-data task: those would wipe or
# change the case data on staging or production on every deploy.
# See docs/STAGING_DATA_REFRESH.md.
set -euo pipefail

echo "*** Running any new migrations ***"
bundle exec rails db:migrate
