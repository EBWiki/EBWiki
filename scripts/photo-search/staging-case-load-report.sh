#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

: "${DATABASE_URL:?DATABASE_URL must be set (Doppler ebwiki/stg after scrubbed Neon branch load)}"

bundle exec rake photo_search:review_database:staging_report
