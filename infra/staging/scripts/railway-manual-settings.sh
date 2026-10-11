#!/usr/bin/env bash
# Settings the Railway Terraform provider does not expose reliably (GitHub install).
# Requires: railway CLI, RAILWAY_TOKEN, RAILWAY_SERVICE_ID, RAILWAY_PROJECT_ID in the environment.
set -euo pipefail

: "${RAILWAY_SERVICE_ID:?Set RAILWAY_SERVICE_ID}"
: "${RAILWAY_PROJECT_ID:?Set RAILWAY_PROJECT_ID}"
REPO="${RAILWAY_GITHUB_REPO:-EBWiki/EBWiki}"
BRANCH="${RAILWAY_GITHUB_BRANCH:-main}"

echo "Railway service ${RAILWAY_SERVICE_ID} in project ${RAILWAY_PROJECT_ID}"
echo "Expected Git repo: ${REPO} @ ${BRANCH}"
echo ""
echo "Before apply, confirm the Railway GitHub app can access ${REPO}."
echo "After apply, staging builds from main with railway.toml (release-tasks.sh, not db:prepare)."
echo ""
if command -v railway >/dev/null 2>&1; then
  railway status --service "${RAILWAY_SERVICE_ID}" 2>/dev/null || true
else
  echo "Install Railway CLI: https://docs.railway.com/develop/cli"
fi
