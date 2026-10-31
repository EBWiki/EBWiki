#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SRC="$ROOT/infra/github"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

export TF_VAR_state_passphrase="ci-test-passphrase-16chars"
export TF_VAR_github_token="ghp_ci_validate_only_token"
export TF_VAR_staging_username="ci-staging-user"
export TF_VAR_staging_password="ci-staging-pass"
export TF_VAR_rollbar_access_token="ci-rollbar-token"
export TF_VAR_existing_release_smoke_environment=false
export TF_VAR_existing_main_policy_id=""

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

pass() {
  echo "PASS: $*"
}

copy_stack() {
  rm -rf "$WORK/stack"
  mkdir -p "$WORK/stack"
  cp -a "$SRC/." "$WORK/stack/"
  rm -rf "$WORK/stack/.terraform"
}

run_tofu_test() {
  (cd "$WORK/stack" && tofu init -backend=false >/dev/null && tofu test 2>&1)
}

echo "=== baseline (unmodified copy) ==="
copy_stack
baseline_out="$(run_tofu_test)" || {
  echo "$baseline_out"
  fail "baseline tofu test must pass"
}
pass "baseline tofu test passed"

echo "=== TF_VAR_main_branch_pattern has no effect (undeclared var ignored) ==="
copy_stack
knob_out="$(TF_VAR_main_branch_pattern='*' run_tofu_test)" || {
  echo "$knob_out"
  fail "tofu test must pass when obsolete TF_VAR_main_branch_pattern is set"
}
pass "obsolete TF_VAR_main_branch_pattern does not change plan"

run_mutant() {
  local name="$1"
  local expect_msg="$2"
  shift 2
  copy_stack
  "$@"
  echo "=== mutant: $name ==="
  set +e
  out="$(run_tofu_test)"
  rc=$?
  set -e
  if [[ "$rc" -eq 0 ]]; then
    echo "$out"
    fail "mutant $name must fail tofu test (exit 0)"
  fi
  if ! grep -Fq "$expect_msg" <<<"$out"; then
    echo "$out"
    fail "mutant $name must mention: $expect_msg"
  fi
  pass "mutant $name failed with expected message"
}

run_mutant branch_pattern_wildcard "branch_pattern must be main" \
  sed -i 's/branch_pattern = "main"/branch_pattern = "*"/' "$WORK/stack/release_smoke.tf"

run_mutant protected_branches_true "protected_branches must be false" \
  sed -i 's/protected_branches     = false/protected_branches     = true/' "$WORK/stack/release_smoke.tf"

run_mutant custom_branch_policies_false "custom_branch_policies must be true" \
  sed -i 's/custom_branch_policies = true/custom_branch_policies = false/' "$WORK/stack/release_smoke.tf"

run_mutant policy_resource_removed "release_smoke_main" \
  bash -c 'sed -i "/resource \"github_repository_environment_deployment_policy\" \"release_smoke_main\"/,/^}/d" "$1/release_smoke.tf" && awk '"'"'BEGIN{skip=0;n=0} /^import \{/ {n++; if (n==2) skip=1} skip {if (/^\}/) {skip=0; next} next} {print}'"'"' "$1/imports.tf" > "$1/imports.tf.tmp" && mv "$1/imports.tf.tmp" "$1/imports.tf"' _ "$WORK/stack"

run_mutant username_secret_name_changed "smoke secret names must match" \
  sed -i 's/secret_name     = "STAGING_USERNAME"/secret_name     = "WRONG_USERNAME"/' "$WORK/stack/release_smoke.tf"

run_mutant password_repo_level_secret "staging_password" \
  bash -c 'sed -i "/resource \"github_actions_environment_secret\" \"staging_password\"/,/^}/ {
    s/resource \"github_actions_environment_secret\" \"staging_password\"/resource \"github_actions_secret\" \"staging_password\"/
    /environment/d
  }" "$1/release_smoke.tf"' _ "$WORK/stack"

run_mutant environment_name_changed "smoke secrets must use the release-smoke environment" \
  sed -i 's/environment     = github_repository_environment.release_smoke.environment/environment     = "production"/' "$WORK/stack/release_smoke.tf"

run_mutant import_to_typo "release_smoke_main_typo" \
  sed -i 's/release_smoke_main/release_smoke_main_typo/' "$WORK/stack/imports.tf"

run_mutant admins_can_bypass "release-smoke must set can_admins_bypass to false" \
  sed -i 's/can_admins_bypass = false/can_admins_bypass = true/' "$WORK/stack/release_smoke.tf"

run_mutant reviewer_id_changed "release-smoke must include reviewer user id 5750239" \
  sed -i 's/users = \[5750239\]/users = [1]/' "$WORK/stack/release_smoke.tf"

run_mutant reviewers_removed "release-smoke must include reviewer user id 5750239" \
  bash -c 'sed -i "/^  reviewers {/,/^  }/d" "$1/release_smoke.tf"' _ "$WORK/stack"

run_mutant tags_admins_can_bypass "release-tags must set can_admins_bypass to false" \
  sed -i 's/can_admins_bypass = false/can_admins_bypass = true/' "$WORK/stack/release_tags.tf"

run_mutant tags_reviewers_removed "release-tags must include reviewer user id 5750239" \
  bash -c 'sed -i "/^  reviewers {/,/^  }/d" "$1/release_tags.tf"' _ "$WORK/stack"

run_mutant tags_branch_pattern_wildcard "release-tags must deploy from main only" \
  sed -i 's/branch_pattern = "main"/branch_pattern = "*"/' "$WORK/stack/release_tags.tf"

echo "All GitHub tftest mutations passed."
