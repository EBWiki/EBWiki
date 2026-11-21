#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

: "${EBWIKI_REVIEW_DATABASE_URL:?EBWIKI_REVIEW_DATABASE_URL must be set (Doppler; see docs/photo_search/REVIEW_DATABASE_SCRUB.md)}"

bundle exec rake photo_search:review_database:scrub
