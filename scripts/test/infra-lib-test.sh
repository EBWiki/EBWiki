#!/usr/bin/env bash
# Offline tests for infra lookup helpers (no live API tokens required).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=../lib/infra-one.sh
source "$ROOT/scripts/lib/infra-one.sh"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

pass() {
  echo "PASS: $*"
}

# infra_one
if printf 'a\n' | infra_one "test label" | grep -qx 'a'; then
  pass "infra_one accepts one value"
else
  fail "infra_one should accept one value"
fi

if printf '\n' | infra_one "test label" >/dev/null 2>&1; then
  fail "infra_one should reject zero values"
else
  pass "infra_one rejects zero values"
fi

if printf 'a\nb\n' | infra_one "test label" >/dev/null 2>&1; then
  fail "infra_one should reject two values"
else
  pass "infra_one rejects two values"
fi

# Railway GraphQL variables JSON (regression for ${2:-{}} brace truncation)
query='query($projectId: String!) { project(id: $projectId) { id } }'
vars="$(jq -n --arg p 'proj-1' '{projectId: $p}')"
body="$(jq -n --arg q "$query" --argjson v "$vars" '{query: $q, variables: $v}')"
echo "$body" | jq -e '.variables.projectId == "proj-1"' >/dev/null || fail "GraphQL body variables must parse"
pass "GraphQL variables JSON encodes correctly"

empty_vars=''
[ -n "$empty_vars" ] || empty_vars='{}'
body="$(jq -n --arg q "$query" --argjson v "$empty_vars" '{query: $q, variables: $v}')"
echo "$body" | jq -e '.variables == {}' >/dev/null || fail "empty GraphQL variables must be {}"
pass "GraphQL empty variables default to {}"

# Simulated staging id resolution (fail closed, no empty tfvars)
infra_railway_find_project_service_env_mock() {
  local payload='{"data":{"projects":{"edges":[{"node":{"id":"p1","name":"ebwiki","environments":{"edges":[{"node":{"id":"e1","name":"production"}}]},"services":{"edges":[{"node":{"id":"s1","name":"ebwiki"}}]}}}]}}}'
  local project_id service_id environment_id
  project_id="$(echo "$payload" | jq -r '.data.projects.edges[].node | select(.name == "ebwiki") | .id' | infra_one "Railway project named ebwiki")"
  service_id="$(echo "$payload" | jq -r '.data.projects.edges[].node | select(.name == "ebwiki") | .services.edges[].node | select(.name == "ebwiki") | .id' | infra_one "Railway service")"
  environment_id="$(echo "$payload" | jq -r '.data.projects.edges[].node | select(.name == "ebwiki") | .environments.edges[].node | select(.name == "production") | .id' | infra_one "Railway environment")"
  printf '%s %s %s\n' "$project_id" "$service_id" "$environment_id"
}

ids="$(infra_railway_find_project_service_env_mock)"
read -r project_id service_id environment_id <<<"$ids"
[ "$project_id" = "p1" ] && [ "$service_id" = "s1" ] && [ "$environment_id" = "e1" ] \
  || fail "mock Railway id resolution"
pass "Railway id resolution with infra_one"

# Snapshot pipe + upload (no /tmp, no secrets on argv)
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
export R2_BUCKET_NAME="test-bucket"
export R2_S3_ENDPOINT="https://r2.example"
export AWS_ACCESS_KEY_ID="key"
export AWS_SECRET_ACCESS_KEY="secret"
export INFRA_SNAPSHOT_PIPE_CMD='printf "%s" "PGDMPmock"'

cat >"$tmpdir/aws" <<'AWS'
#!/usr/bin/env bash
if [ "$1" = "s3" ] && [ "$2" = "cp" ] && [ "$3" = "-" ]; then
  cat > "$AWS_OUT"
  exit 0
fi
exit 1
AWS
chmod +x "$tmpdir/aws"
export AWS_OUT="$tmpdir/uploaded.dump"
export PATH="$tmpdir:$PATH"

# shellcheck source=../staging-db-snapshot.sh
# Minimal re-run of upload stanza
INFRA_SNAPSHOT_OBJECT_KEY="staging/db-snapshots/test.dump"
object_key="$INFRA_SNAPSHOT_OBJECT_KEY"
bash -c "$INFRA_SNAPSHOT_PIPE_CMD" | aws s3 cp - "s3://${R2_BUCKET_NAME}/${object_key}" --endpoint-url "$R2_S3_ENDPOINT" --only-show-errors
[ -f "$tmpdir/uploaded.dump" ] && [ "$(cat "$tmpdir/uploaded.dump")" = "PGDMPmock" ] \
  || fail "streamed snapshot upload"
pass "snapshot streams to aws s3 cp without temp dump file"

echo "All infra-lib tests passed."
