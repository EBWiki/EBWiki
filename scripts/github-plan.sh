#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
GITHUB_SCRIPT_NAME="github-plan.sh"

trap 'rm -f "$ROOT/infra/github/github.tfplan"; rm -rf "${GH_TMP:-}"' EXIT

# shellcheck source=lib/github-logging.sh
source "$ROOT/scripts/lib/github-logging.sh"
# shellcheck source=lib/github-rollbar.sh
source "$ROOT/scripts/lib/github-rollbar.sh"
# shellcheck source=lib/github-preflight.sh
source "$ROOT/scripts/lib/github-preflight.sh"
trap 'github_script_err_trap' ERR

doppler run --project ebwiki --config infra -- "$ROOT/scripts/infra-write-backend.sh" \
  "$ROOT/infra/github/backend.hcl" "github/terraform.tfstate"

doppler run --project ebwiki --config infra -- "$ROOT/scripts/infra-with-tf-vars.sh" bash -c "
  source \"$ROOT/scripts/lib/infra-export-tf-vars.sh\"
  infra_export_github_smoke_secrets_from_stg
  infra_require_github_tf_vars
  source \"$ROOT/scripts/lib/github-preflight.sh\"
  github_preflight
  umask 077
  cd \"$ROOT/infra/github\" && tofu fmt -check -recursive && tofu init -backend-config=backend.hcl -input=false && tofu plan -input=false -out=github.tfplan
"
