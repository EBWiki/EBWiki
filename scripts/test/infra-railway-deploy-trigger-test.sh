#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=../lib/infra-railway-deploy-trigger.sh
source "$ROOT/scripts/lib/infra-railway-deploy-trigger.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "PASS: $*"; }

infra_railway_assert_workspace_or_account_token() { :; }

infra_railway_find_project_service_env() {
  printf '%s %s %s\n' proj svc env
}

RAILWAY_STUB_TRIGGERS='[]'

infra_railway_gql() {
  local query="$1"
  case "$query" in
    *deploymentTriggers*)
      printf '{"data":{"deploymentTriggers":{"edges":%s}}}' "$RAILWAY_STUB_TRIGGERS"
      ;;
    *) fail "unexpected gql query" ;;
  esac
}

run_preflight() {
  export INFRA_SCRIPT_NAME=test
  infra_railway_preflight_github_autodeploy 2>&1
}

RAILWAY_STUB_TRIGGERS='[]'
out="$(run_preflight)" && fail "missing trigger should fail"
grep -q railway_deploy_trigger_missing <<<"$out" || fail "missing trigger event"
pass "preflight fails closed when trigger is missing"

RAILWAY_STUB_TRIGGERS='[{"node":{"id":"t1","branch":"main","repository":"evil/other","checkSuites":true,"provider":"github"}}]'
out="$(run_preflight)" && fail "wrong repo trigger should fail"
grep -q railway_deploy_trigger_repo <<<"$out" || fail "wrong repo event"
pass "preflight fails closed when repo or branch is wrong"

RAILWAY_STUB_TRIGGERS='[{"node":{"id":"t2","branch":"main","repository":"EBWiki/EBWiki","checkSuites":false,"provider":"github"}}]'
out="$(run_preflight)" && fail "disabled trigger should fail"
grep -q railway_deploy_trigger_disabled <<<"$out" || fail "disabled trigger event"
pass "preflight fails closed when checkSuites is false"

RAILWAY_STUB_TRIGGERS='[{"node":{"id":"t3","branch":"main","repository":"EBWiki/EBWiki","checkSuites":true,"provider":"github"}}]'
out="$(run_preflight)" || fail "valid trigger should pass: $out"
grep -q railway_deploy_trigger_ok <<<"$out" || fail "ok event"
pass "preflight passes when trigger matches and checkSuites is true"

echo "All infra-railway-deploy-trigger tests passed."
