#!/usr/bin/env bash
# Runs the real github-plan.sh, github-apply.sh, github-delete-repo-secrets.sh,
# staging-plan.sh and staging-apply.sh against stubbed doppler, curl, tofu, gh, git,
# railway, aws and npm plus logging bash and jq shims. Checks full argv of every
# shimmed command for secrets and TMPDIR for leftovers after every phase. Rollbar
# counts as reported only when the posted header file carries the stg token.
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
cp -a "$SRC/infra/staging" "$REPO/infra/staging"
REAL_BASH="$(command -v bash)"
REAL_JQ="$(command -v jq)"
export ARGV_LOG="$TMP/argv.log" GH_STUB_STATE="$TMP/state"
: >"$ARGV_LOG"
mkdir -p "$GH_STUB_STATE"

SECRETS=(ghp_e2e_token_sentinel stg_user_sentinel stg_pass_sentinel rollbar_e2e_sentinel state_pass_sentinel_0123
  cf_e2e_sentinel dp_e2e_sentinel railway_e2e_sentinel awssec_e2e_sentinel)

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
shim jq "exec \"$REAL_JQ\" \"\$@\""
shim gh 'exit 0'
shim git 'exit 0'
shim railway 'exit 0'
shim aws 'exit 0'
shim npm 'exit 0'
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
  plan)
    for a in "$@"; do case "$a" in -out=*) : >"${a#-out=}" ;; esac; done
    [ "${TOFU_FAIL:-}" = plan ] && exit 1 ;;
  apply) [ "${TOFU_FAIL:-}" = apply ] && exit 1 ;;
  show) printf "%s\n" "{\"resource_changes\":[],\"planned_values\":{\"root_module\":{\"resources\":[{\"address\":\"cloudflare_dns_record.legacy_staging_ebwiki\",\"values\":{\"content\":\"${TOFU_PLANNED_CNAME:-abc123.up.railway.app}\",\"proxied\":${TOFU_PLANNED_PROXIED:-false}}}]}}}" ;;
esac
exit 0'
cat >"$BIN/curl" <<'CURLSTUB'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "curl $*" >>"$ARGV_LOG"
out=""; url=""; method=GET; rollbar_token=""; github_mode=0
kcfg=""
while [ $# -gt 0 ]; do
  case "$1" in
    -o) out="$2"; shift 2 ;;
    -w) github_mode=1; shift 2 ;;
    -X) method="$2"; shift 2 ;;
    -K)
      if [ "${2:-}" = "-" ]; then
        kcfg="$(cat)"
        url="$(printf "%s\n" "$kcfg" | sed -n 's/^url = //p' | tr -d '"')"
        shift 2
      else
        shift 2
      fi
      ;;
    -H) case "$2" in @*) grep -Fq rollbar_e2e_sentinel "${2#@}" && rollbar_token=1 ;; esac; shift 2 ;;
    --data-binary) shift 2 ;;
    https://*) url="$1"; shift ;;
    *) shift ;;
  esac
done
case "$url" in
  *api.cloudflare.com/client/v4/zones/*/dns_records*type=TXT*)
    code=200
    if [ "${CF_STUB_TXT_MISSING:-}" = 1 ]; then body='{"success":true,"result":[]}'
    else body='{"success":true,"result":[{"id":"txt_stub","content":"railway-verify=stub"}]}'; fi ;;
  *api.cloudflare.com/client/v4/zones/*/dns_records*type=CNAME*)
    code=200
    proxied_field=',"proxied":true'
    [ "${CF_STUB_PROXIED_MISSING:-}" = 1 ] && proxied_field=''
    body="{\"success\":true,\"result\":[{\"id\":\"rec_stub\",\"content\":\"${CF_STUB_CNAME_CONTENT-abc123.up.railway.app}\"${proxied_field}}]}" ;;
  *api.cloudflare.com/client/v4/zones\?*)
    code=200
    if [ "${CF_STUB_ZONE_NO_ID:-}" = 1 ]; then body='{"success":true,"result":[{"name":"ebwiki.org"}]}'
    else body='{"success":true,"result":[{"id":"zone_stub"}]}'; fi ;;
  *api.rollbar.com*) [ -z "$rollbar_token" ] || : >"$GH_STUB_STATE/rollbar_posted"; code=200; body="" ;;
  */environments/release-smoke/secrets/*) code=200; body="{}" ;;
  */environments/release-smoke) code=404; body="{}" ;;
  */actions/secrets/public-key) code=200; body="{}" ;;
  */actions/secrets/*) if [ "$method" = DELETE ]; then code=204; else code=200; fi; body="{}" ;;
  *) code=200; body="{\"permissions\":{\"admin\":${GH_ADMIN:-true}}}" ;;
esac
if [ "$github_mode" = 1 ]; then
  [ -n "$out" ] && printf "%s" "$body" >"$out"
  printf "%s" "$code"
else
  printf "%s" "$body"
fi
CURLSTUB
chmod +x "$BIN/curl"

# Staging helpers only touch local files (no live API).
cat >"$REPO/scripts/infra-write-backend.sh" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BACKEND_FILE="${1:-$ROOT/infra/staging/backend.hcl}"
[ -z "${BACKEND_FAIL:-}" ] || exit 1
mkdir -p "$(dirname "$BACKEND_FILE")"
: >"$BACKEND_FILE"
STUB
cat >"$REPO/scripts/write-staging-tfvars.sh" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-$ROOT/infra/staging/terraform.tfvars}"
mkdir -p "$(dirname "$OUT")"
: >"$OUT"
STUB
cat >"$REPO/scripts/staging-db-snapshot.sh" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
chmod +x "$REPO/scripts/infra-write-backend.sh" "$REPO/scripts/write-staging-tfvars.sh" "$REPO/scripts/staging-db-snapshot.sh"
mkdir -p "$REPO/infra/staging"
echo '{"changeSet":{"changes":[]}}' >"$REPO/infra/staging/staging.railway-plan.json"
mkdir -p "$REPO/node_modules/railway"
cat >>"$REPO/scripts/lib/infra-railway-config.sh" <<'RAILWAY_STUB'

infra_railway_config_plan() {
  local root out
  root="$(infra_railway_config_root)"
  out="${1:-$root/$STAGING_RAILWAY_PLAN_FILE}"
  mkdir -p "$(dirname "$out")"
  [ -f "$out" ] || echo '{"changeSet":{"changes":[]}}' >"$out"
  echo "Wrote Railway config plan: ${out#${root}/}"
}

infra_railway_config_apply() {
  local root plan
  root="$(infra_railway_config_root)"
  plan="${1:-$root/$STAGING_RAILWAY_PLAN_FILE}"
  [ -f "$plan" ] || {
    echo "Missing Railway config plan: $plan (run make plan first)." >&2
    return 1
  }
}
RAILWAY_STUB

export PATH="$BIN:$PATH" TMPDIR="$LEAK_TMP"
export STATE_PASSPHRASE=state_pass_sentinel_0123 GITHUB_TOKEN=ghp_e2e_token_sentinel
export R2_BUCKET_NAME=b R2_S3_ENDPOINT=https://r2.example CLOUDFLARE_DNS_API_TOKEN=cf_e2e_sentinel STAGING_RUNTIME_DOPPLER_TOKEN=dp_e2e_sentinel STAGING_BASIC_AUTH_USERNAME=bu_e2e
export RAILWAY_TOKEN=railway_e2e_sentinel AWS_ACCESS_KEY_ID=awskey_e2e AWS_SECRET_ACCESS_KEY=awssec_e2e_sentinel
PLAN="$REPO/infra/github/github.tfplan"
STAGING_PLAN="$REPO/infra/staging/staging.tfplan"

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
printf 'apply-github\n' | TOFU_FAIL=apply "$REPO/scripts/github-apply.sh" >/dev/null 2>&1 && fail "apply should fail"
[ ! -f "$PLAN" ] || fail "plan file must be deleted after a failed apply"
[ -f "$GH_STUB_STATE/rollbar_posted" ] || fail "failed apply must report to Rollbar"
rm -f "$GH_STUB_STATE/rollbar_posted"
assert_clean "apply failure"

BACKEND_FAIL=1 "$REPO/scripts/github-plan.sh" >/dev/null 2>&1 && fail "plan should fail when the backend write fails"
[ -f "$GH_STUB_STATE/rollbar_posted" ] || fail "failed backend write in plan must report to Rollbar"
rm -f "$GH_STUB_STATE/rollbar_posted"
assert_clean "plan backend failure"

"$REPO/scripts/github-plan.sh" >/dev/null 2>&1
printf 'apply-github\n' | GH_ADMIN=false "$REPO/scripts/github-apply.sh" >/dev/null 2>&1 && fail "apply must fail preflight"
[ ! -f "$PLAN" ] || fail "plan file must be deleted after a failed preflight"
[ -f "$GH_STUB_STATE/rollbar_posted" ] || fail "preflight failure must report to Rollbar"
rm -f "$GH_STUB_STATE/rollbar_posted"
assert_clean "apply preflight failure"

out="$("$REPO/scripts/github-delete-repo-secrets.sh" </dev/null 2>&1 || true)"; grep -q delete_dry_run <<<"$out" || { echo "$out"; fail "delete must dry run by default"; }
grep -q 'DELETE' "$ARGV_LOG" && fail "dry run must not DELETE"
assert_clean "delete dry run"

: >"$ARGV_LOG"
GH_REPO_SLUG=evil/other "$REPO/scripts/github-delete-repo-secrets.sh" </dev/null >/dev/null 2>&1 || true
grep -q 'evil/other' "$ARGV_LOG" && fail "GH_REPO_SLUG from the environment must be ignored"
grep -q '/repos/EBWiki/EBWiki/' "$ARGV_LOG" || fail "delete dry run must target EBWiki/EBWiki"
assert_clean "repo slug pinned"

out="$(printf 'wrong\n' | "$REPO/scripts/github-delete-repo-secrets.sh" --confirm 2>&1 >/dev/null || true)"
grep -q delete_confirm <<<"$out" || fail "wrong phrase must log delete_confirm"
printf 'wrong\n' | "$REPO/scripts/github-delete-repo-secrets.sh" --confirm >/dev/null 2>&1 && fail "wrong phrase must abort"
grep -q 'DELETE' "$ARGV_LOG" && fail "wrong phrase must not DELETE"
[ ! -f "$GH_STUB_STATE/rollbar_posted" ] || fail "wrong phrase must not report to Rollbar"
assert_clean "delete wrong phrase"

: >"$ARGV_LOG"
printf 'delete-repo-secrets\n' | "$REPO/scripts/github-delete-repo-secrets.sh" --confirm >/dev/null 2>&1 || fail "confirmed delete should pass"
for secret in STAGING_USERNAME STAGING_PASSWORD ROLLBAR_ACCESS_TOKEN; do
  grep -Fq -- "-X DELETE" "$ARGV_LOG" || fail "confirmed delete must use DELETE"
  grep -Fq "/actions/secrets/${secret}" "$ARGV_LOG" || fail "confirmed delete must target ${secret}"
done
assert_clean "delete confirmed"

[ ! -f "$GH_STUB_STATE/rollbar_posted" ] || fail "Rollbar marker must be clear before the staging phases"
TOFU_FAIL=plan "$REPO/scripts/staging-plan.sh" >/dev/null 2>&1 && fail "staging plan should fail"
[ ! -f "$STAGING_PLAN" ] || fail "staging plan file must be deleted after a failed staging plan"
[ -f "$GH_STUB_STATE/rollbar_posted" ] || fail "failed staging plan must report to Rollbar"
rm -f "$GH_STUB_STATE/rollbar_posted"
assert_clean "staging plan failure"

"$REPO/scripts/staging-plan.sh" >/dev/null 2>&1 || fail "staging plan should pass"
[ -f "$STAGING_PLAN" ] || fail "staging plan file must exist after successful staging plan"
[ ! -f "$GH_STUB_STATE/rollbar_posted" ] || fail "successful staging plan must not report to Rollbar"
assert_clean "staging plan success"

dns_env_args() { # mode
  case "$1" in
    zone_no_id) env_args=(CF_STUB_ZONE_NO_ID=1) ;;
    cname_not_railway) env_args=(CF_STUB_CNAME_CONTENT=evil.example.com) ;;
    cname_empty) env_args=(CF_STUB_CNAME_CONTENT=) ;;
    proxied_missing) env_args=(CF_STUB_PROXIED_MISSING=1) ;;
    txt_missing) env_args=(CF_STUB_TXT_MISSING=1) ;;
    planned_proxied) env_args=(TOFU_PLANNED_PROXIED=true) ;;
    planned_not_railway) env_args=(TOFU_PLANNED_CNAME=evil.example.com) ;;
    *) fail "unknown DNS mode $1" ;;
  esac
}

dns_assert_failed_closed() { # phase mode output
  grep -Eq '"level":"error","script":"[^"]*","event":"staging_dns_(zone|cname|verify|plan)"' <<<"$3" || { echo "$3"; fail "$1 DNS $2 must log a staging_dns error event"; }
  [ -f "$GH_STUB_STATE/rollbar_posted" ] || fail "$1 DNS $2 must report to Rollbar"
  rm -f "$GH_STUB_STATE/rollbar_posted"
}

# Live record failures must stop the plan before tofu plan runs.
for mode in zone_no_id cname_not_railway cname_empty proxied_missing txt_missing; do
  dns_env_args "$mode"
  : >"$ARGV_LOG"
  out="$(env "${env_args[@]}" "$REPO/scripts/staging-plan.sh" 2>&1 >/dev/null)" && fail "staging plan must fail closed on DNS $mode"
  dns_assert_failed_closed "staging plan" "$mode" "$out"
  grep -Eq '^tofu plan( |$)' "$ARGV_LOG" && fail "staging plan must not run tofu plan when live DNS check $mode fails"
  [ ! -f "$STAGING_PLAN" ] || fail "staging plan file must be deleted after DNS $mode"
  assert_clean "staging DNS preflight $mode"
done

# Planned record failures are caught after tofu plan, and the plan file is removed.
for mode in planned_proxied planned_not_railway; do
  dns_env_args "$mode"
  : >"$ARGV_LOG"
  out="$(env "${env_args[@]}" "$REPO/scripts/staging-plan.sh" 2>&1 >/dev/null)" && fail "staging plan must fail closed on DNS $mode"
  dns_assert_failed_closed "staging plan" "$mode" "$out"
  [ ! -f "$STAGING_PLAN" ] || fail "staging plan file must be deleted after DNS $mode"
  assert_clean "staging DNS preflight $mode"
done

# Apply re-runs the DNS check on the saved plan and must never reach tofu apply.
for mode in cname_not_railway txt_missing planned_proxied planned_not_railway; do
  "$REPO/scripts/staging-plan.sh" >/dev/null 2>&1 || fail "staging plan should pass before apply DNS $mode"
  dns_env_args "$mode"
  : >"$ARGV_LOG"
  out="$(env "${env_args[@]}" "$REPO/scripts/staging-apply.sh" 2>&1 >/dev/null)" && fail "staging apply must fail closed on DNS $mode"
  dns_assert_failed_closed "staging apply" "$mode" "$out"
  grep -Eq '^tofu apply( |$)' "$ARGV_LOG" && fail "staging apply must not run tofu apply when DNS $mode fails"
  assert_clean "staging apply DNS preflight $mode"
done
"$REPO/scripts/staging-plan.sh" >/dev/null 2>&1 || fail "staging plan should pass again after the DNS failure cases"

"$REPO/scripts/staging-apply.sh" >/dev/null 2>&1 || fail "staging apply should pass"
[ ! -f "$GH_STUB_STATE/rollbar_posted" ] || fail "successful staging apply must not report to Rollbar"
assert_clean "staging apply success"

BACKEND_FAIL=1 "$REPO/scripts/staging-apply.sh" >/dev/null 2>&1 && fail "staging apply should fail when the backend write fails"
[ -f "$GH_STUB_STATE/rollbar_posted" ] || fail "failed backend write in staging apply must report to Rollbar"
rm -f "$GH_STUB_STATE/rollbar_posted"
assert_clean "staging apply backend failure"

TOFU_FAIL=apply "$REPO/scripts/staging-apply.sh" >/dev/null 2>&1 && fail "staging apply should fail"
[ -f "$GH_STUB_STATE/rollbar_posted" ] || fail "failed staging apply must report to Rollbar"
rm -f "$GH_STUB_STATE/rollbar_posted"
assert_clean "staging apply failure"

echo "All infra script end-to-end tests passed."
