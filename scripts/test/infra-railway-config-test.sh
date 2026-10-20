#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=../lib/infra-railway-config.sh
source "$ROOT/scripts/lib/infra-railway-config.sh"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

pass() {
  echo "PASS: $*"
}

clean="$ROOT/scripts/test/fixtures/railway-plan-no-destroy.json"
bad="$ROOT/scripts/test/fixtures/railway-plan-with-destroys.json"

[ "$(infra_railway_config_plan_destroy_count "$clean")" = "0" ] \
  || fail "clean plan should report 0 destroys"
pass "destroy count parses zero-destroy summary"

[ "$(infra_railway_config_plan_destroy_count "$bad")" = "22" ] \
  || fail "destructive plan should report 22 destroys"
pass "destroy count parses non-zero summary"

infra_railway_config_assert_plan_no_destructive "$clean" \
  || fail "clean plan should pass delete gate"
pass "delete gate accepts zero-destroy plan"

if infra_railway_config_assert_plan_no_destructive "$bad"; then
  fail "destructive plan should fail delete gate"
else
  pass "delete gate rejects destroy plan"
fi

command -v node >/dev/null 2>&1 || fail "node is required for CLI wrapper test"
export RAILWAY_PROJECT_ID="test-project"
export RAILWAY_ENVIRONMENT_ID="test-environment"
env_underscore="$(env -u RAILWAY_TOKEN RAILWAY_API_TOKEN="test-token" node -p 'process.env._ || ""' 2>/dev/null || true)"
subshell_underscore="$(infra_railway_config_run_cli "test-token" node -p 'process.env._ || ""')"
[ "$env_underscore" = "/usr/bin/env" ] || fail "sanity: env -u should set process.env._ to /usr/bin/env (got ${env_underscore:-empty})"
[ "$subshell_underscore" != "/usr/bin/env" ] \
  || fail "subshell wrapper must not set process.env._ to /usr/bin/env"
pass "subshell CLI wrapper keeps Railway SDK process.env._ usable"

# Wiring: plan runs only read-only checks; apply turns on Wait for CI before
# railway config apply, and stops before it when a check fails.
calls="$(mktemp)"
stub_bin="$(mktemp -d)"
trap 'rm -rf "$calls" "$stub_bin"' EXIT
printf '#!/bin/sh\nexit 0\n' >"$stub_bin/railway"
chmod +x "$stub_bin/railway"
wiring() { # fail_step function args...
  local fail_step="$1"
  shift
  (
    PATH="$stub_bin:$PATH"
    export RAILWAY_TOKEN=test-token
    infra_railway_assert_workspace_or_account_token() { echo token >>"$calls"; [ "$fail_step" != token ]; }
    infra_railway_assert_deployment_trigger() { echo trigger_check >>"$calls"; [ "$fail_step" != trigger_check ]; }
    infra_railway_ensure_deployment_trigger() { echo trigger_ensure >>"$calls"; [ "$fail_step" != trigger_ensure ]; }
    infra_railway_config_ensure_sdk() { :; }
    infra_railway_config_target_env() { :; }
    infra_railway_config_run_cli() { shift; echo "cli $*" >>"$calls"; [ "$3" != plan ] || cp "$clean" "$5"; }
    "$@"
  )
}

plan_out="$(mktemp)"
: >"$calls"
wiring none infra_railway_config_plan "$plan_out" >/dev/null || fail "config plan should pass"
[ "$(tr '\n' ' ' <"$calls")" = "token trigger_check cli railway config plan --out $plan_out " ] \
  || fail "config plan must run token and trigger checks, then plan, and never write the trigger (got: $(tr '\n' ' ' <"$calls"))"
rm -f "$plan_out"
pass "config plan runs read-only token and trigger checks before railway config plan"

: >"$calls"
wiring none infra_railway_config_apply "$clean" >/dev/null || fail "config apply should pass"
[ "$(tr '\n' ' ' <"$calls")" = "token trigger_ensure cli railway config apply --plan $clean --yes " ] \
  || fail "config apply must check the token and turn on Wait for CI before railway config apply (got: $(tr '\n' ' ' <"$calls"))"
pass "config apply turns on Wait for CI before railway config apply"

for step in token trigger_ensure; do
  : >"$calls"
  wiring "$step" infra_railway_config_apply "$clean" >/dev/null 2>&1 && fail "config apply must fail when $step fails"
  grep -q '^cli ' "$calls" && fail "config apply must not run railway config apply when $step fails"
done
for step in token trigger_check; do
  : >"$calls"
  wiring "$step" infra_railway_config_plan "$(mktemp -u)" >/dev/null 2>&1 && fail "config plan must fail when $step fails"
  grep -q '^cli ' "$calls" && fail "config plan must not run railway config plan when $step fails"
done
pass "config plan and apply stop before the Railway CLI when a check fails"

echo "All infra-railway-config tests passed."
