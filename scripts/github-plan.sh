#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

trap 'rc=$?; [ "$rc" -eq 0 ] || rm -f "$ROOT/infra/github/github.tfplan"' EXIT

doppler run --project ebwiki --config infra -- "$ROOT/scripts/infra-with-tf-vars.sh" bash -c "
  set -Eeuo pipefail
  source \"$ROOT/scripts/lib/infra-export-tf-vars.sh\"
  infra_export_github_smoke_secrets_from_stg
  infra_require_github_tf_vars
  source \"$ROOT/scripts/lib/github-preflight.sh\"
  source \"$ROOT/scripts/lib/infra-rollbar.sh\"
  INFRA_SCRIPT_NAME=github-plan.sh
  trap infra_script_err_trap ERR
  \"$ROOT/scripts/infra-write-backend.sh\" \"$ROOT/infra/github/backend.hcl\" github/terraform.tfstate
  github_preflight
  umask 077
  cd \"$ROOT/infra/github\"
  tofu fmt -check -recursive
  tofu init -backend-config=backend.hcl -input=false
  tofu plan -input=false -out=github.tfplan
"
