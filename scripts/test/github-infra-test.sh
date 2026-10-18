#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

CURL_LOG="$TMP/curl.log"
export CURL_LOG

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

pass() {
  echo "PASS: $*"
}

write_curl_stub() {
  cat >"$TMP/curl" <<'CURL'
#!/usr/bin/env bash
set -euo pipefail
method=GET
out=""
url=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    -X) method="$2"; shift 2 ;;
    -o) out="$2"; shift 2 ;;
    -w) shift 2 ;;
    -H|-H@*) shift 2 ;;
    https://*) url="$1"; shift ;;
    *) shift ;;
  esac
done
printf '%s %s\n' "$method" "$url" >>"${CURL_LOG:?}"
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

preflight_with() {
  local scenario="$1"
  export GITHUB_STUB_SCENARIO="$scenario"
  : >"$CURL_LOG"
  export TF_VAR_state_passphrase="0123456789abcdef"
  export TF_VAR_github_token="ghp_stub_token_value"
  export TF_VAR_staging_username="user"
  export TF_VAR_staging_password="pass"
  export TF_VAR_rollbar_access_token="rollbar"
  # shellcheck source=../lib/github-preflight.sh
  source "$ROOT/scripts/lib/github-preflight.sh"
  github_preflight
}

write_curl_stub
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

if ( preflight_with non_admin ) 2>/dev/null; then
  fail "preflight should reject non-admin token"
else
  pass "preflight rejects non-admin token"
fi

: >"$CURL_LOG"
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

preflight_with env_exists
[[ "${TF_VAR_existing_release_smoke_environment:-}" == true ]] || fail "expected env exists"
[[ "${TF_VAR_existing_main_policy_id:-}" == 9001 ]] || fail "expected main policy id"
pass "preflight passes when environment exists"

if grep -q 'ghp_stub_token_value' "$CURL_LOG"; then
  fail "token appeared in curl log"
else
  pass "token not logged in curl argv"
fi

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

if ( printf 'wrong\n' | github_delete_repo_secrets 1 ) 2>/dev/null; then
  fail "delete should reject wrong confirmation"
else
  pass "delete rejects wrong confirmation"
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

echo "All GitHub infra script tests passed."
