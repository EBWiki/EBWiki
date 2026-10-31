#!/usr/bin/env bash
# Behavior of scripts/github-require-protected-environment.sh against a stubbed gh.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "PASS: $*"; }

cat >"$TMP/gh" <<'GH'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$GH_STUB_LOG"
case "${GH_STUB_ENV:-}" in
  missing) echo 'gh: Not Found (HTTP 404)' >&2; exit 1 ;;
  no_rules) printf '{"name":"e","can_admins_bypass":false,"protection_rules":[]}' ;;
  no_reviewers) printf '{"name":"e","can_admins_bypass":false,"protection_rules":[{"type":"required_reviewers","reviewers":[]}]}' ;;
  branch_only) printf '{"name":"e","can_admins_bypass":false,"protection_rules":[{"type":"branch_policy"}]}' ;;
  bypass) printf '{"name":"e","can_admins_bypass":true,"protection_rules":[{"type":"required_reviewers","reviewers":[{"type":"User"}]}]}' ;;
  protected) printf '{"name":"e","can_admins_bypass":false,"protection_rules":[{"type":"required_reviewers","reviewers":[{"type":"User"}]},{"type":"branch_policy"}]}' ;;
  *) exit 1 ;;
esac
GH
chmod +x "$TMP/gh"
export PATH="$TMP:$PATH" GH_STUB_LOG="$TMP/gh.log" GITHUB_REPOSITORY=EBWiki/EBWiki
script="$ROOT/scripts/github-require-protected-environment.sh"

out="$(GH_STUB_ENV=protected "$script" release-tags 2>&1)" || fail "protected environment must pass: $out"
grep -q '/repos/EBWiki/EBWiki/environments/release-tags' "$GH_STUB_LOG" || fail "must look up the named environment"
pass "protected environment passes"

for mode in missing no_rules no_reviewers branch_only bypass; do
  out="$(GH_STUB_ENV=$mode "$script" release-tags 2>&1)" && fail "$mode must fail"
  grep -Eq '"event":"environment_(missing|unprotected)"' <<<"$out" || fail "$mode must log why"
done
pass "missing, reviewer-free and bypassable environments fail closed"

"$script" >/dev/null 2>&1 && fail "missing argument must fail"
GITHUB_REPOSITORY='' GH_STUB_ENV=protected "$script" release-tags >/dev/null 2>&1 && fail "missing repository must fail"
pass "missing input fails closed"

echo "All github-require-protected-environment tests passed."
