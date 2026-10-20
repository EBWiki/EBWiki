#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

CONFIRM=0
if [[ "${1:-}" == "--confirm" ]]; then
  CONFIRM=1
fi

doppler run --project ebwiki --config infra -- "$ROOT/scripts/infra-with-tf-vars.sh" bash -c "
  set -Eeuo pipefail
  source \"$ROOT/scripts/lib/infra-export-tf-vars.sh\"
  infra_export_github_smoke_secrets_from_stg
  infra_require_github_tf_vars
  source \"$ROOT/scripts/lib/infra-rollbar.sh\"
  INFRA_SCRIPT_NAME=github-delete-repo-secrets.sh
  trap infra_script_err_trap ERR
  source \"$ROOT/scripts/lib/github-delete-repo-secrets.sh\"
  github_delete_repo_secrets $CONFIRM
"
