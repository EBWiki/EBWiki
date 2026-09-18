#!/bin/bash
set -euo pipefail

cd /usr/src/ebwiki
export PGPASSWORD="${PGPASSWORD:-${BLACKOPS_DATABASE_PASSWORD:-ebwiki}}"
bundle exec rails db:prepare
