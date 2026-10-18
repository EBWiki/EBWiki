#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/infra-export-tf-vars.sh
source "$ROOT/scripts/lib/infra-export-tf-vars.sh"

infra_export_tf_vars_from_infra_config

if [ "$#" -lt 1 ]; then
  echo "Usage: infra-with-tf-vars.sh command [args...]" >&2
  exit 1
fi

exec "$@"
