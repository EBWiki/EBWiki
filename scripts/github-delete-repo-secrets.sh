#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
GITHUB_SCRIPT_NAME="github-delete-repo-secrets.sh"

trap 'rm -rf "${GH_TMP:-}"' EXIT

# shellcheck source=lib/github-logging.sh
source "$ROOT/scripts/lib/github-logging.sh"
# shellcheck source=lib/github-rollbar.sh
source "$ROOT/scripts/lib/github-rollbar.sh"
trap 'github_script_err_trap' ERR

CONFIRM=0
if [[ "${1:-}" == "--confirm" ]]; then
  CONFIRM=1
fi

doppler run --project ebwiki --config infra -- "$ROOT/scripts/infra-with-tf-vars.sh" bash -c "
  source \"$ROOT/scripts/lib/infra-export-tf-vars.sh\"
  infra_export_github_smoke_secrets_from_stg
  infra_require_github_tf_vars
  source \"$ROOT/scripts/lib/github-delete-repo-secrets.sh\"
  github_delete_repo_secrets $CONFIRM
"
