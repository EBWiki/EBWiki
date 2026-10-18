#!/usr/bin/env bash
# Behavior of the GitHub autodeploy trigger check (plan) and Wait for CI write (apply).
# The GraphQL stub only answers the fields Railway's schema has, so a query for a
# field that does not exist fails here the way it fails against the real API.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=../lib/infra-railway-deploy-trigger.sh
source "$ROOT/scripts/lib/infra-railway-deploy-trigger.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "PASS: $*"; }

STATE="$(mktemp -d)"
trap 'rm -rf "$STATE"' EXIT
export INFRA_SCRIPT_NAME=test

infra_railway_find_project_service_env() {
  [ "${STUB_IDS_FAIL:-0}" = 1 ] && return 1
  printf '%s %s %s\n' proj svc env
}

# STUB_TRIGGERS: JSON array of trigger nodes before any update.
# STUB_UPDATE: ok (sets checkSuites true), noop (answers true, stores nothing), false, error.
infra_railway_gql() {
  local query="$1" vars="${2:-}"
  printf '%s\n' "$query" >>"$STATE/queries"
  case "$query" in
    *deploymentTriggerUpdate*)
      jq -e '.input == {checkSuites: true}' <<<"$vars" >/dev/null || fail "update must send input {checkSuites: true}"
      echo update >>"$STATE/updates"
      case "${STUB_UPDATE:-ok}" in
        ok) jq '[.[] | .checkSuites = true]' <<<"$(cat "$STATE/triggers")" >"$STATE/triggers.new"
            mv "$STATE/triggers.new" "$STATE/triggers"
            printf '{"data":{"deploymentTriggerUpdate":{"id":"t","checkSuites":true}}}' ;;
        noop) printf '{"data":{"deploymentTriggerUpdate":{"id":"t","checkSuites":true}}}' ;;
        false) printf '{"data":{"deploymentTriggerUpdate":{"id":"t","checkSuites":false}}}' ;;
        error) printf '{"errors":[{"message":"Not Authorized"}],"data":null}' ;;
      esac
      ;;
    *deploymentTriggers\(*)
      jq -c '{data:{deploymentTriggers:{edges:[.[] | {node: .}]}}}' "$STATE/triggers"
      ;;
    *)
      printf '{"errors":[{"message":"Cannot query field"}],"data":null}'
      ;;
  esac
}

reset_stub() { # triggers_json
  printf '%s' "$1" >"$STATE/triggers"
  rm -f "$STATE/queries" "$STATE/updates"
}

updates() { [ -f "$STATE/updates" ] && wc -l <"$STATE/updates" | tr -d ' ' || echo 0; }

good='[{"id":"t1","branch":"main","repository":"EBWiki/EBWiki","checkSuites":true,"provider":"github"}]'
off='[{"id":"t1","branch":"main","repository":"EBWiki/EBWiki","checkSuites":false,"provider":"github"}]'
wrong_repo='[{"id":"t1","branch":"main","repository":"evil/other","checkSuites":true,"provider":"github"}]'
wrong_branch='[{"id":"t1","branch":"develop","repository":"EBWiki/EBWiki","checkSuites":true,"provider":"github"}]'

# Plan (read only).
reset_stub '[]'
out="$( (infra_railway_assert_deployment_trigger) 2>&1)" && fail "plan: missing trigger must fail"
grep -q railway_deploy_trigger_missing <<<"$out" || fail "plan: missing trigger event"
pass "plan fails closed when the trigger is missing"

for t in "$wrong_repo" "$wrong_branch"; do
  reset_stub "$t"
  out="$( (infra_railway_assert_deployment_trigger) 2>&1)" && fail "plan: wrong repo or branch must fail"
  grep -q railway_deploy_trigger_repo <<<"$out" || fail "plan: wrong repo event"
done
pass "plan fails closed when the repo or branch is wrong"

reset_stub "$off"
out="$( (infra_railway_assert_deployment_trigger) 2>&1)" || fail "plan: checkSuites false must not block the plan: $out"
grep -q railway_deploy_trigger_pending <<<"$out" || fail "plan: pending event"
[ "$(updates)" = 0 ] || fail "plan must never write"
pass "plan reports checkSuites=false as pending and writes nothing"

reset_stub "$good"
out="$( (infra_railway_assert_deployment_trigger) 2>&1)" || fail "plan: valid trigger must pass: $out"
grep -q railway_deploy_trigger_ok <<<"$out" || fail "plan: ok event"
pass "plan passes when the trigger matches and checkSuites is true"

reset_stub "$good"
( STUB_IDS_FAIL=1; infra_railway_assert_deployment_trigger ) >/dev/null 2>&1 && fail "plan: id lookup failure must fail"
( STUB_IDS_FAIL=1; infra_railway_ensure_deployment_trigger ) >/dev/null 2>&1 && fail "apply: id lookup failure must fail"
STUB_IDS_FAIL=0
pass "plan and apply fail closed when the Railway ids cannot be resolved"

reset_stub '{"not":"an array"}'
( infra_railway_assert_deployment_trigger ) >/dev/null 2>&1 && fail "plan: malformed trigger list must fail"
pass "plan fails closed on a malformed trigger list"

# Apply.
reset_stub "$off"
out="$( (infra_railway_ensure_deployment_trigger) 2>&1)" || fail "apply: enabling checkSuites must pass: $out"
[ "$(updates)" = 1 ] || fail "apply must send exactly one update"
jq -e '.[0].checkSuites == true' "$STATE/triggers" >/dev/null || fail "apply must leave checkSuites true"
grep -q railway_deploy_trigger_enabled <<<"$out" || fail "apply: enabled event"
[ "$(grep -c 'deploymentTriggers(' "$STATE/queries")" = 2 ] || fail "apply must read the trigger back after the update"
pass "apply turns on checkSuites once and reads it back"

out="$( (infra_railway_ensure_deployment_trigger) 2>&1)" || fail "apply: second run must pass: $out"
[ "$(updates)" = 1 ] || fail "apply must not write again when checkSuites is already true"
pass "apply is idempotent"

reset_stub "$off"
( STUB_UPDATE=noop; infra_railway_ensure_deployment_trigger ) >/dev/null 2>&1 \
  && fail "apply: read-back still false must fail"
pass "apply fails closed when the read-back is not true"

for mode in false error; do
  reset_stub "$off"
  ( STUB_UPDATE=$mode; infra_railway_ensure_deployment_trigger ) >/dev/null 2>&1 \
    && fail "apply: update answer $mode must fail"
done
pass "apply fails closed when the update is refused"

for t in '[]' "$wrong_repo"; do
  reset_stub "$t"
  ( infra_railway_ensure_deployment_trigger ) >/dev/null 2>&1 && fail "apply: missing or wrong trigger must fail"
  [ "$(updates)" = 0 ] || fail "apply must not write without the right trigger"
done
pass "apply fails closed and writes nothing without the main trigger"

echo "All infra-railway-deploy-trigger tests passed."
