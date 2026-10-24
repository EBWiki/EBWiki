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

echo "All infra-railway-config tests passed."
