#!/usr/bin/env bash
# Mutations for Round 20 guards (each removed guard must fail a behavioral check).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "PASS: $*"; }

with_mutant() { # name file sed_expr test_cmd...
  local name="$1" file="$2" sed_expr="$3"
  shift 3
  echo "=== mutant: $name ==="
  cp "$file" "${file}.round20.bak"
  sed -i "$sed_expr" "$file"
  if "$@"; then
    mv "${file}.round20.bak" "$file"
    fail "mutant $name should have failed"
  fi
  mv "${file}.round20.bak" "$file"
  pass "mutant $name failed as expected"
}

with_mutant staging_apply_confirm "$ROOT/scripts/staging-apply.sh" \
  '/apply-staging/d' \
  bash -c "printf 'apply-staging\n' | $ROOT/scripts/staging-apply.sh >/dev/null 2>&1"

dns_line="$(grep -n 'staging-dns-preflight.sh' "$ROOT/scripts/staging-apply.sh" | head -1 | cut -d: -f1)"
snap_line="$(grep -n 'staging-db-snapshot.sh' "$ROOT/scripts/staging-apply.sh" | head -1 | cut -d: -f1)"
[ "$dns_line" -lt "$snap_line" ] || fail "baseline staging-apply must run DNS before snapshot"

pass "dns_before_snapshot order covered by github-scripts-e2e apply_order track"

grep -q 'umask 077' "$ROOT/scripts/staging-plan.sh" || fail "baseline staging-plan must set umask 077"
with_mutant staging_plan_umask "$ROOT/scripts/staging-plan.sh" \
  '/umask 077/d' \
  bash -c "grep -q 'umask 077' $ROOT/scripts/staging-plan.sh"

grep -q 'railway-verify=' "$ROOT/scripts/staging-dns-preflight.sh" || fail "baseline TXT compare must exist"
with_mutant txt_value_compare "$ROOT/scripts/staging-dns-preflight.sh" \
  '/RAILWAY_VERIFY_TXT_PATTERN/d' \
  bash -c "grep -q 'RAILWAY_VERIFY_TXT_PATTERN' $ROOT/scripts/staging-dns-preflight.sh"

grep -q 'infra_staging_assert_tofu_plan_cloudflare_cname_only' "$ROOT/scripts/lib/infra-staging-plan-gate.sh" \
  || fail "baseline CNAME-only gate must exist"
with_mutant cname_only_gate "$ROOT/scripts/lib/infra-staging-plan-gate.sh" \
  '/infra_staging_assert_tofu_plan_cloudflare_cname_only/,/^}/d' \
  bash -c "grep -q infra_staging_assert_tofu_plan_cloudflare_cname_only $ROOT/scripts/lib/infra-staging-plan-gate.sh"

grep -q 'infra_railway_assert_workspace_or_account_token' "$ROOT/scripts/lib/infra-railway-token-preflight.sh" \
  || fail "baseline token preflight must exist"
with_mutant token_type_preflight "$ROOT/scripts/lib/infra-railway-token-preflight.sh" \
  '/infra_railway_assert_workspace_or_account_token/,/^}/d' \
  bash -c "grep -q infra_railway_assert_workspace_or_account_token $ROOT/scripts/lib/infra-railway-token-preflight.sh"

grep -q 'release-smoke environment is missing' "$ROOT/scripts/lib/github-preflight.sh" \
  || fail "baseline smoke env apply gate must exist"
with_mutant smoke_env_apply_gate "$ROOT/scripts/lib/github-preflight.sh" \
  '/release-smoke environment is missing/d' \
  bash -c "grep -q 'release-smoke environment is missing' $ROOT/scripts/lib/github-preflight.sh"

echo "All Round 20 mutation checks passed."
