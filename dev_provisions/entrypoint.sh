#!/bin/bash
# Legacy all-in-one entrypoint (Postgres/Redis/ES inside the app container).
# Local Docker now uses compose.yaml sidecars and docker/entrypoint.sh.
set -euo pipefail
exec docker/entrypoint.sh bundle exec rails server -b 0.0.0.0 -e "${RAILS_ENV:-development}"
