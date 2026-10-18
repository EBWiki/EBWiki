#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TMP="$(mktemp -d)"
LEAK_TMP="$TMP/leak"
mkdir -p "$LEAK_TMP"
export TMPDIR="$LEAK_TMP"
trap 'rm -rf "$TMP"' EXIT

CURL_LOG="$TMP/curl.log"
ROLLBAR_LOG="$TMP/rollbar.log"
export CURL_LOG ROLLBAR_LOG

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

pass() {
  echo "PASS: $*"
}

assert_no_hdr_leaks() {
  local leftover
  leftover="$(find "$LEAK_TMP" -type f -name 'hdr' 2>/dev/null | head -1 || true)"
  [ -z "$leftover" ] || fail "header file left in TMPDIR: $leftover"
}

write_curl_stub() {
  cat >"$TMP/curl" <<'CURL'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$@" >>"${CURL_LOG:?}"
method=GET
out=""
body_file=""
url=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    -X) method="$2"; shift 2 ;;
    -o) out="$2"; shift 2 ;;
    --data-binary)
      if [ -f "$2" ]; then
        body_file="$2"
      else
        printf '%s' "$2" >>"${ROLLBAR_LOG:?}"
      fi
      shift 2
      ;;
    -w) shift 2 ;;
    -H|-H@*) shift 2 ;;
    https://*) url="$1"; shift ;;
    *) shift ;;
  esac
done
if [[ "$url" == *api.rollbar.com* ]]; then
  if [ -n "$body_file" ] && [ -f "$body_file" ]; then
    cat "$body_file" >>"${ROLLBAR_LOG:?}"
  fi
  printf '204'
  exit 0
fi
case "${GITHUB_STUB_SCENARIO:-}" in
  non_admin)
    if [[ "$url" == *"/repos/"*"/actions/secrets/public-key" ]]; then
      code=200; body='{"key":"k","key_id":"kid"}'
    elif [[ "$url" == *"/repos/"* ]] && [[ "$url" != *"/environments/"* ]]; then
      code=200; body='{"permissions":{"admin":false}}'
    else
      code=404; body='{}'
    fi
    ;;
  env_missing)
    if [[ "$url" == *"/environments/release-smoke" ]] && [[ "$url" != *deployment-branch-policies* ]] && [[ "$url" != *"/secrets/"* ]]; then
      code=404; body='{}'
    elif [[ "$url" == *"/repos/"*"/actions/secrets/public-key" ]]; then
      code=200; body='{"key":"k","key_id":"kid"}'
    elif [[ "$url" == *"/repos/"* ]] && [[ "$url" != *"/environments/"* ]]; then
      code=200; body='{"permissions":{"admin":true}}'
    else
      code=404; body='{}'
    fi
    ;;
  env_exists)
    if [[ "$url" == *"/environments/release-smoke/deployment-branch-policies" ]]; then
      code=200; body='{"branch_policies":[{"id":9001,"name":"main","type":"branch"}]}'
    elif [[ "$url" == *"/environments/release-smoke" ]] && [[ "$url" != *"/secrets/"* ]]; then
      code=200; body='{"name":"release-smoke"}'
    elif [[ "$url" == *"/repos/"*"/actions/secrets/public-key" ]]; then
      code=200; body='{"key":"k","key_id":"kid"}'
    elif [[ "$url" == *"/repos/"* ]] && [[ "$url" != *"/environments/"* ]]; then
      code=200; body='{"permissions":{"admin":true}}'
    else
      code=404; body='{}'
    fi
    ;;
  two_main_policies)
    if [[ "$url" == *deployment-branch-policies* ]]; then
      code=200; body='{"branch_policies":[{"id":1,"name":"main","type":"branch"},{"id":2,"name":"main","type":"branch"}]}'
    elif [[ "$url" == *"/environments/release-smoke" ]]; then
      code=200; body='{}'
    elif [[ "$url" == *public-key* ]]; then
      code=200; body='{"key":"k","key_id":"kid"}'
    else
      code=200; body='{"permissions":{"admin":true}}'
    fi
    ;;
  extra_policy)
    if [[ "$url" == *deployment-branch-policies* ]]; then
      code=200; body='{"branch_policies":[{"id":1,"name":"main","type":"branch"},{"id":2,"name":"release/*","type":"branch"}]}'
    elif [[ "$url" == *"/environments/release-smoke" ]]; then
      code=200; body='{}'
    elif [[ "$url" == *public-key* ]]; then
      code=200; body='{"key":"k","key_id":"kid"}'
    else
      code=200; body='{"permissions":{"admin":true}}'
    fi
    ;;
  delete_missing_env)
    if [[ "$url" == *"/environments/release-smoke/secrets/"* ]]; then
      code=404; body='{}'
    elif [[ "$url" == *public-key* ]]; then
      code=200; body='{"key":"k","key_id":"kid"}'
    elif [[ "$url" == *"/environments/release-smoke" ]]; then
      code=200; body='{}'
    else
      code=200; body='{"permissions":{"admin":true}}'
    fi
    ;;
  delete_*)
    name="${GITHUB_STUB_SCENARIO#delete_}"
    if [[ "$url" == *"/environments/release-smoke/secrets/$name" ]]; then
      code=200; body='{}'
    elif [[ "$url" == *"/actions/secrets/$name" ]] && [[ "$method" == DELETE ]]; then
      code="${DELETE_HTTP_CODE:-204}"; body=''
    elif [[ "$url" == *"/actions/secrets/$name" ]]; then
      code=200; body='{}'
    elif [[ "$url" == *public-key* ]]; then
      code=200; body='{"key":"k","key_id":"kid"}'
    elif [[ "$url" == *"/environments/release-smoke" ]]; then
      code=200; body='{}'
    else
      code=200; body='{"permissions":{"admin":true}}'
    fi
    ;;
  *)
    code=500; body='{}'
    ;;
esac
if [ -n "$out" ]; then
  printf '%s' "$body" >"$out"
fi
printf '%s' "$code"
CURL
  chmod +x "$TMP/curl"
}

write_tofu_stub() {
  cat >"$TMP/tofu" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
case "${1:-}" in
  fmt) exit 0 ;;
  init) exit 0 ;;
  plan)
    out=""
    while [ "$#" -gt 0 ]; do
      case "$1" in
        -out) out="$2"; shift 2 ;;
        -out=*) out="${1#-out=}"; shift ;;
        *) shift ;;
      esac
    done
    [ -n "$out" ] && : >"$out"
    exit 0
    ;;
  apply)
    while [ "$#" -gt 0 ]; do
      if [ -f "${1:-}" ]; then rm -f "$1"; fi
      shift
    done
    exit 0
    ;;
  test) exit 0 ;;
  *) exit 0 ;;
esac
EOF
  chmod +x "$TMP/tofu"
}

preflight_with() {
  local scenario="$1"
  export GITHUB_STUB_SCENARIO="$scenario"
  : >"$CURL_LOG"
  export TF_VAR_state_passphrase="0123456789abcdef"
  export TF_VAR_github_token="ghp_stub_token_value"
  export TF_VAR_staging_username="user"
  export TF_VAR_staging_password="pass"
  export TF_VAR_rollbar_access_token="rollbar"
  unset TF_VAR_main_branch_pattern || true
  # shellcheck source=../lib/github-preflight.sh
  source "$ROOT/scripts/lib/github-preflight.sh"
  github_preflight
}

write_curl_stub
write_tofu_stub
export PATH="$TMP:$PATH"

if ( export TF_VAR_state_passphrase="" TF_VAR_github_token=x TF_VAR_staging_username=u TF_VAR_staging_password=p TF_VAR_rollbar_access_token=r
     source "$ROOT/scripts/lib/github-preflight.sh"
     github_preflight ) 2>/dev/null; then
  fail "preflight should reject empty TF_VAR_state_passphrase"
else
  pass "preflight rejects empty input"
fi

if ( export TF_VAR_state_passphrase="short" TF_VAR_github_token=x TF_VAR_staging_username=u TF_VAR_staging_password=p TF_VAR_rollbar_access_token=r
     source "$ROOT/scripts/lib/github-preflight.sh"
     github_preflight ) 2>/dev/null; then
  fail "preflight should reject short passphrase"
else
  pass "preflight rejects short passphrase"
fi

if ( export TF_VAR_state_passphrase="0123456789abcdef" TF_VAR_github_token=x TF_VAR_staging_username=u TF_VAR_staging_password=p TF_VAR_rollbar_access_token=r TF_VAR_main_branch_pattern='*'
     source "$ROOT/scripts/lib/github-preflight.sh"
     github_preflight ) 2>/dev/null; then
  fail "preflight should reject unexpected TF_VAR_main_branch_pattern"
else
  pass "preflight rejects stray TF_VAR"
fi

if ( preflight_with non_admin ) 2>/dev/null; then
  fail "preflight should reject non-admin token"
else
  pass "preflight rejects non-admin token"
fi

if ( preflight_with two_main_policies ) 2>/dev/null; then
  fail "preflight should reject two main policies"
else
  pass "preflight rejects two main policies"
fi

if ( preflight_with extra_policy ) 2>/dev/null; then
  fail "preflight should reject extra deployment policies"
else
  pass "preflight rejects extra deployment policies"
fi

preflight_with env_missing
[[ "${TF_VAR_existing_release_smoke_environment:-}" == false ]] || fail "expected env missing"
pass "preflight passes when environment is missing"
assert_no_hdr_leaks

preflight_with env_exists
[[ "${TF_VAR_existing_release_smoke_environment:-}" == true ]] || fail "expected env exists"
[[ "${TF_VAR_existing_main_policy_id:-}" == 9001 ]] || fail "expected main policy id"
pass "preflight passes when environment exists"
[[ "$(trap -p EXIT)" == *'rm -rf "$TMP"'* ]] || fail "preflight must restore the caller EXIT trap"
pass "preflight restores the caller EXIT trap"
assert_no_hdr_leaks

( preflight_with env_missing ) >/dev/null 2>&1
[ -d "$TMP" ] || { echo "FAIL: preflight in a subshell ran the parent EXIT trap" >&2; exit 1; }
pass "preflight in a subshell leaves the parent EXIT trap alone"

caller_trap_case() { # name scenario function
  local marker="$TMP/caller-trap-$1"
  rm -f "$marker"
  if GITHUB_STUB_SCENARIO="$2" bash -c '
    trap "echo \"rc=\$?\" >\"$1\"" EXIT
    source "$2/scripts/lib/github-delete-repo-secrets.sh"
    $3' _ "$marker" "$ROOT" "$3" >/dev/null 2>&1; then
    fail "$1: expected failure"
  fi
  [ "$(cat "$marker" 2>/dev/null)" = rc=1 ] || fail "$1: caller EXIT trap must run with exit status 1"
  pass "$1: caller EXIT trap runs with the failing exit status"
}
caller_trap_case preflight-failure non_admin github_preflight
caller_trap_case delete-failure delete_missing_env "github_delete_repo_secrets 0"
assert_no_hdr_leaks

if grep -q 'ghp_stub_token_value' "$CURL_LOG"; then
  fail "token appeared in curl log"
else
  pass "token not logged in curl argv"
fi

PLAN_DIR="$TMP/plan-work/infra/github"
mkdir -p "$PLAN_DIR"
PLAN_FILE="$PLAN_DIR/github.tfplan"
(
  cd "$PLAN_DIR"
  trap 'rc=$?; [ "$rc" -eq 0 ] || rm -f "$PLAN_FILE"' EXIT
  tofu plan -out=github.tfplan
  [ -f "$PLAN_FILE" ] || fail "plan file missing after successful plan"
  trap 'rm -f "$PLAN_FILE"' EXIT
  tofu apply github.tfplan
  [ ! -f "$PLAN_FILE" ] || fail "plan file still present after apply"
)
pass "plan file kept after plan and removed after apply"

STAGING_PLAN_DIR="$TMP/plan-work/infra/staging"
mkdir -p "$STAGING_PLAN_DIR"
STAGING_PLAN_FILE="$STAGING_PLAN_DIR/staging.tfplan"
(
  cd "$STAGING_PLAN_DIR"
  trap 'rc=$?; [ "$rc" -eq 0 ] || rm -f "$STAGING_PLAN_FILE"' EXIT
  tofu plan -out=staging.tfplan
  [ -f "$STAGING_PLAN_FILE" ] || fail "staging plan file missing after successful plan"
  false
) && fail "staging plan trap test expected failure after plan"
[ ! -f "$STAGING_PLAN_FILE" ] || fail "staging plan file must be removed after a failed staging plan"
pass "staging plan file kept after plan and removed after a failed plan"

: >"$ROLLBAR_LOG"
export TF_VAR_rollbar_access_token="rollbar_secret_token_value"
PATH="$TMP:$PATH" bash -c "
  set -E
  source \"$ROOT/scripts/lib/infra-rollbar.sh\"
  INFRA_SCRIPT_NAME=github-plan.sh
  trap infra_script_err_trap ERR
  false
" || true
grep -Eq '"exit_code"[[:space:]]*:[[:space:]]*1' "$ROLLBAR_LOG" || fail "rollbar body missing exit_code 1"
grep -q 'Infra script failed' "$ROLLBAR_LOG" || fail "rollbar body missing Infra script failed message"
grep -Eq '"environment"[[:space:]]*:[[:space:]]*"infra"' "$ROLLBAR_LOG" || fail "rollbar body missing infra environment"
grep -q 'rollbar_secret_token_value' "$CURL_LOG" && fail "rollbar token appeared in curl argv"
assert_no_hdr_leaks
pass "rollbar trap posts exit_code and cleans header file"

export GITHUB_STUB_SCENARIO="delete_STAGING_USERNAME"
export DELETE_HTTP_CODE=204
export TF_VAR_state_passphrase="0123456789abcdef"
export TF_VAR_github_token="ghp_stub_token_value"
export TF_VAR_staging_username="user"
export TF_VAR_staging_password="pass"
export TF_VAR_rollbar_access_token="rollbar"

# shellcheck source=../lib/github-delete-repo-secrets.sh
source "$ROOT/scripts/lib/github-delete-repo-secrets.sh"
github_delete_repo_secrets 0 >/dev/null
pass "delete dry run succeeds"
[[ "$(trap -p EXIT)" == *'rm -rf "$TMP"'* ]] || fail "delete must restore the caller EXIT trap"
pass "delete restores the caller EXIT trap"
assert_no_hdr_leaks

if wrong_out="$(printf 'wrong\n' | github_delete_repo_secrets 1 2>&1 >/dev/null)"; then
  fail "delete should reject wrong confirmation"
elif grep -q delete_confirm <<<"$wrong_out"; then
  pass "delete rejects wrong confirmation with delete_confirm log"
else
  fail "delete wrong confirmation must log delete_confirm"
fi

export GITHUB_STUB_SCENARIO="delete_missing_env"
if ( github_delete_repo_secrets 0 ) 2>/dev/null; then
  fail "delete should fail when environment secret missing"
else
  pass "delete fails when environment secret missing"
fi

export GITHUB_STUB_SCENARIO="delete_STAGING_USERNAME"
export DELETE_HTTP_CODE=500
if ( printf 'delete-repo-secrets\n' | github_delete_repo_secrets 1 ) 2>/dev/null; then
  fail "delete should fail on non-204"
else
  pass "delete fails on non-204 DELETE"
fi

assert_no_hdr_leaks
echo "All GitHub infra script tests passed."
