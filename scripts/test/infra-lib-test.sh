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

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

cat >"$tmpdir/curl" <<'CURL'
#!/usr/bin/env bash
body=""
prev=""
for arg in "$@"; do
  if [ "$prev" = "--data-binary" ]; then
    body="$arg"
  fi
  case "$arg" in
    -K)
      :
      ;;
    -)
      cat >/dev/null
      ;;
  esac
  prev="$arg"
done
if [ -n "${CURL_BODY_FILE:-}" ]; then
  printf '%s' "$body" >"$CURL_BODY_FILE"
fi
if [ -n "${RAILWAY_MOCK_RESPONSE:-}" ]; then
  printf '%s' "$RAILWAY_MOCK_RESPONSE"
  exit 0
fi
echo "mock curl: RAILWAY_MOCK_RESPONSE not set" >&2
exit 1
CURL
chmod +x "$tmpdir/curl"

export PATH="$tmpdir:${PATH}"
export RAILWAY_TOKEN="test-token"
export CURL_BODY_FILE="$tmpdir/last-body.json"

one_project_payload="$(jq -n '{
  data: {
    projects: {
      edges: [{
        node: {
          id: "p1", name: "ebwiki",
          environments: {edges: [{node: {id: "e1", name: "production"}}]},
          services: {edges: [{node: {id: "s1", name: "ebwiki"}}, {node: {id: "db1", name: "Postgres"}}]}
        }
      }]
    }
  }
}')"

two_projects_payload="$(jq -n '{
  data: {
    projects: {
      edges: [
        {node: {id: "p1", name: "ebwiki", environments: {edges: [{node: {id: "e1", name: "production"}}]}, services: {edges: [{node: {id: "s1", name: "ebwiki"}}]}}},
        {node: {id: "p2", name: "ebwiki", environments: {edges: [{node: {id: "e2", name: "production"}}]}, services: {edges: [{node: {id: "s2", name: "ebwiki"}}]}}}
      ]
    }
  }
}')"

zero_projects_payload="$(jq -n '{data: {projects: {edges: []}}}')"

source_railway() {
  # shellcheck source=../lib/infra-railway.sh
  source "$ROOT/scripts/lib/infra-railway.sh"
}

# GraphQL POST body is sent (fix for infra_curl_k dropping args).
export RAILWAY_MOCK_RESPONSE="$one_project_payload"
(
  source_railway
  infra_railway_projects_payload >/dev/null
)
[ -s "$CURL_BODY_FILE" ] || fail "GraphQL POST body file empty"
jq -e '.query and .variables' "$CURL_BODY_FILE" >/dev/null || fail "GraphQL POST body must be JSON with query and variables"
pass "infra_curl_post_json sends request body"

# Real infra_railway_find_project_service_env fails closed (zero projects).
export RAILWAY_MOCK_RESPONSE="$zero_projects_payload"
if (
  source_railway
  infra_railway_find_project_service_env
); then
  fail "infra_railway_find_project_service_env should fail with zero projects"
else
  pass "infra_railway_find_project_service_env fails with zero projects"
fi

# Real function fails with duplicate project names.
export RAILWAY_MOCK_RESPONSE="$two_projects_payload"
if (
  source_railway
  infra_railway_find_project_service_env
); then
  fail "infra_railway_find_project_service_env should fail with two matching projects"
else
  pass "infra_railway_find_project_service_env fails with two matching projects"
fi

# Real function succeeds with exactly one match.
export RAILWAY_MOCK_RESPONSE="$one_project_payload"
ids="$(
  source_railway
  infra_railway_find_project_service_env
)" || fail "infra_railway_find_project_service_env should succeed with one project"
read -r project_id service_id environment_id <<<"$ids"
[ "$project_id" = "p1" ] && [ "$service_id" = "s1" ] && [ "$environment_id" = "e1" ] \
  || fail "unexpected Railway ids: $ids"
pass "infra_railway_find_project_service_env returns ids for one project"

db_id="$(
  source_railway
  infra_railway_find_postgres_service_id
)" || fail "infra_railway_find_postgres_service_id should succeed"
[ "$db_id" = "db1" ] || fail "unexpected Postgres service id: $db_id"
pass "infra_railway_find_postgres_service_id returns Postgres service id"

# Snapshot pipe + upload (no /tmp)
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

object_key="staging/db-snapshots/test.dump"
bash -c "$INFRA_SNAPSHOT_PIPE_CMD" | aws s3 cp - "s3://${R2_BUCKET_NAME}/${object_key}" --endpoint-url "$R2_S3_ENDPOINT" --only-show-errors
[ -f "$tmpdir/uploaded.dump" ] && [ "$(cat "$tmpdir/uploaded.dump")" = "PGDMPmock" ] \
  || fail "streamed snapshot upload"
pass "snapshot streams to aws s3 cp without temp dump file"

echo "All infra-lib tests passed."
