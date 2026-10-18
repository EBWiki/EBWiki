#!/usr/bin/env bash
# Runs the real github-plan.sh, github-apply.sh and github-delete-repo-secrets.sh
# against stubbed doppler, curl, tofu, gh and a logging bash shim. Checks full argv
# of every shimmed command for secrets and TMPDIR for leftovers after every phase.
set -euo pipefail

SRC="$(cd "$(dirname "$0")/../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
REPO="$TMP/repo"
BIN="$TMP/bin"
LEAK_TMP="$TMP/leak"
mkdir -p "$REPO/infra" "$BIN" "$LEAK_TMP"
cp -a "$SRC/scripts" "$REPO/scripts"
cp -a "$SRC/infra/github" "$REPO/infra/github"
REAL_BASH="$(command -v bash)"
export ARGV_LOG="$TMP/argv.log" GH_STUB_STATE="$TMP/state"
: >"$ARGV_LOG"
mkdir -p "$GH_STUB_STATE"

SECRETS=(ghp_e2e_token_sentinel stg_user_sentinel stg_pass_sentinel rollbar_e2e_sentinel state_pass_sentinel_0123)

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "PASS: $*"; }

assert_clean() { # phase
  local f
  f="$(find "$LEAK_TMP" -mindepth 1 -print -quit)"
  [ -z "$f" ] || fail "$1: leftover in TMPDIR: $f"
  for s in "${SECRETS[@]}"; do
    ! grep -Fq "$s" "$ARGV_LOG" || fail "$1: secret $s appeared in argv"
  done
  pass "$1: no TMPDIR leftovers, no secrets in argv"
}

shim() { # name body
  { printf '#!%s\n' "$REAL_BASH"
    printf 'printf "%%s\\n" "%s $*" >>"$ARGV_LOG"\n' "$1"
    printf '%s\n' "$2"; } >"$BIN/$1"
  chmod +x "$BIN/$1"
}

shim bash "exec \"$REAL_BASH\" \"\$@\""
shim gh 'exit 0'
shim doppler '
case "$1" in
  run) while [ "$1" != "--" ]; do shift; done; shift; exec "$@" ;;
  secrets)
    case "$3" in
      STAGING_USERNAME) printf stg_user_sentinel ;;
      STAGING_PASSWORD) printf stg_pass_sentinel ;;
      ROLLBAR_ACCESS_TOKEN) printf rollbar_e2e_sentinel ;;
    esac ;;
esac'
shim tofu '
case "$1" in
  plan) [ "${TOFU_FAIL:-}" = plan ] && exit 1
        for a in "$@"; do case "$a" in -out=*) : >"${a#-out=}" ;; esac; done ;;
  apply) [ "${TOFU_FAIL:-}" = apply ] && exit 1 ;;
esac
exit 0'
shim curl '
out=""; url=""; method=GET
while [ $# -gt 0 ]; do case "$1" in -o) out="$2"; shift 2;; -X) method="$2"; shift 2;; -w|-H|--data-binary) shift 2;; https://*) url="$1"; shift;; *) shift;; esac; done
case "$url" in
  *api.rollbar.com*) : >"$GH_STUB_STATE/rollbar_posted"; code=200; body="" ;;
  */environments/release-smoke/secrets/*) code=200; body="{}" ;;
  */environments/release-smoke) code=404; body="{}" ;;
  */actions/secrets/public-key) code=200; body="{}" ;;
  */actions/secrets/*) if [ "$method" = DELETE ]; then code=204; else code=200; fi; body="{}" ;;
  *) code=200; body="{\"permissions\":{\"admin\":${GH_ADMIN:-true}}}" ;;
esac
[ -n "$out" ] && printf "%s" "$body" >"$out"
printf "%s" "$code"'

export PATH="$BIN:$PATH" TMPDIR="$LEAK_TMP"
export STATE_PASSPHRASE=state_pass_sentinel_0123 GITHUB_TOKEN=ghp_e2e_token_sentinel
export R2_BUCKET_NAME=b R2_S3_ENDPOINT=https://r2.example CLOUDFLARE_DNS_API_TOKEN=cf_e2e STAGING_RUNTIME_DOPPLER_TOKEN=dp_e2e STAGING_BASIC_AUTH_USERNAME=bu_e2e
PLAN="$REPO/infra/github/github.tfplan"

"$REPO/scripts/github-plan.sh" >/dev/null 2>&1 || fail "plan should pass with staging TF_VARs present"
[ -f "$PLAN" ] || fail "plan file must be kept after a successful plan"
assert_clean "plan success"

TOFU_FAIL=plan "$REPO/scripts/github-plan.sh" >/dev/null 2>&1 && fail "plan should fail"
[ ! -f "$PLAN" ] || fail "plan file must be deleted after a failed plan"
[ -f "$GH_STUB_STATE/rollbar_posted" ] || fail "failed plan must report to Rollbar"
rm -f "$GH_STUB_STATE/rollbar_posted"
assert_clean "plan failure"

"$REPO/scripts/github-plan.sh" >/dev/null 2>&1
printf 'apply-github\n' | "$REPO/scripts/github-apply.sh" >/dev/null 2>&1 || fail "apply should pass"
[ ! -f "$PLAN" ] || fail "plan file must be deleted after apply"
assert_clean "apply success"

"$REPO/scripts/github-plan.sh" >/dev/null 2>&1
printf 'apply-github\n' | GH_ADMIN=false "$REPO/scripts/github-apply.sh" >/dev/null 2>&1 && fail "apply must fail preflight"
[ ! -f "$PLAN" ] || fail "plan file must be deleted after failed apply"
[ -f "$GH_STUB_STATE/rollbar_posted" ] || fail "preflight failure must report to Rollbar"
rm -f "$GH_STUB_STATE/rollbar_posted"
assert_clean "apply preflight failure"

out="$("$REPO/scripts/github-delete-repo-secrets.sh" </dev/null 2>&1 || true)"; grep -q delete_dry_run <<<"$out" || { echo "$out"; fail "delete must dry run by default"; }
grep -q 'DELETE' "$ARGV_LOG" && fail "dry run must not DELETE"
assert_clean "delete dry run"

printf 'wrong\n' | "$REPO/scripts/github-delete-repo-secrets.sh" --confirm >/dev/null 2>&1 && fail "wrong phrase must abort"
grep -q 'DELETE' "$ARGV_LOG" && fail "wrong phrase must not DELETE"
assert_clean "delete wrong phrase"

printf 'delete-repo-secrets\n' | "$REPO/scripts/github-delete-repo-secrets.sh" --confirm >/dev/null 2>&1 || fail "confirmed delete should pass"
[ "$(grep -c -- '-X DELETE' "$ARGV_LOG")" = 3 ] || fail "confirmed delete must DELETE exactly 3 secrets"
assert_clean "delete confirmed"

echo "All GitHub script end-to-end tests passed."
