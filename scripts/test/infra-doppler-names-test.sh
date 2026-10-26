#!/usr/bin/env bash
# Every doppler_secret name in infra/ must match Doppler: ^[A-Z0-9_]+$
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

pass() {
  echo "PASS: $*"
}

export ROOT
names="$(
  cd "$ROOT" && python3 <<'PY'
import os
import pathlib
import re

root = pathlib.Path(os.environ["ROOT"]) / "infra"
pattern = re.compile(r'resource\s+"doppler_secret"\s+"[^"]+"\s*\{[^}]*?name\s*=\s*"([^"]+)"', re.S)
for path in sorted(root.rglob("*.tf")):
    text = path.read_text()
    for match in pattern.finditer(text):
        print(f"{path}:{match.group(1)}")
PY
)"

[ -n "$names" ] || fail "no doppler_secret resources found under infra/"

while IFS= read -r line; do
  [ -n "$line" ] || continue
  name="${line#*:}"
  if ! printf '%s' "$name" | grep -Eq '^[A-Z0-9_]+$'; then
    fail "invalid doppler_secret name ${name} (from ${line%%:*})"
  fi
done <<<"$names"

count="$(printf '%s\n' "$names" | grep -c . || true)"
pass "all ${count} doppler_secret names match ^[A-Z0-9_]+$"

echo "All doppler name tests passed."
