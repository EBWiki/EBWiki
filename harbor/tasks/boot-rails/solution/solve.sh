#!/bin/bash
set -euo pipefail

cd /usr/src/ebwiki
export PGPASSWORD="${PGPASSWORD:-${BLACKOPS_DATABASE_PASSWORD:-ebwiki}}"
bundle exec rails db:prepare
bundle exec rails runner 'File.write("/tmp/boot.txt", Rails.application.class.name)'
