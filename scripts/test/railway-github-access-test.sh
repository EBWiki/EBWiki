#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
BIN="$TMP/bin"
mkdir -p "$BIN"

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "PASS: $*"; }

cat >"$BIN/gh" <<'GH'
#!/usr/bin/env bash
set -euo pipefail
case "$*" in
  *"/user/installations/99/repositories"*)
    if [ "${GH_STUB_REPO_VISIBLE:-1}" = 0 ]; then
      printf '\n'
    elif [[ "$*" == *full_name* ]]; then
      printf 'EBWiki/EBWiki\n'
    else
      printf '12345\n'
    fi
    ;;
  *"/orgs/EBWiki/installations"*)
    if [ "${GH_STUB_ORG_INSTALL:-1}" = 0 ]; then
      printf '\n'
    else
      printf '99\n'
    fi
    ;;
  *"/user/installations"*)
    printf '88\n'
    ;;
  *"/repos/EBWiki/EBWiki"*)
    printf '12345\n'
    ;;
  *PUT*)
    printf '{}'
    ;;
  *) echo "unexpected gh $*" >&2; exit 1 ;;
esac
GH
chmod +x "$BIN/gh"

export PATH="$BIN:$PATH"

"$ROOT/scripts/railway-github-access.sh" >/dev/null || fail "org installation with repo visible should pass"
pass "org installation sees EBWiki/EBWiki"

GH_STUB_ORG_INSTALL=0 "$ROOT/scripts/railway-github-access.sh" >/dev/null 2>&1 && fail "missing org install should fail"
pass "missing org installation fails closed"

GH_STUB_ORG_INSTALL=1 GH_STUB_REPO_VISIBLE=0 "$ROOT/scripts/railway-github-access.sh" >/dev/null 2>&1 && fail "invisible repo should fail"
pass "repo not visible on installation fails closed"

echo "All railway-github-access tests passed."
