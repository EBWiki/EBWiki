#!/usr/bin/env bash
# Fails unless a GitHub environment exists with required reviewers and no admin bypass.
#   github-require-protected-environment.sh ENVIRONMENT
# GitHub creates a missing environment, unprotected, when a job names it, so a
# workflow runs this in an earlier job that does not name the environment.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/infra-logging.sh
source "$ROOT/scripts/lib/infra-logging.sh"

env_name="${1:-}"
[[ -n "$env_name" ]] || die environment_input "usage: github-require-protected-environment.sh ENVIRONMENT"
[[ -n "${GITHUB_REPOSITORY:-}" ]] || die environment_input "GITHUB_REPOSITORY must be set"

body="$(gh api -H "Accept: application/vnd.github+json" \
  "/repos/${GITHUB_REPOSITORY}/environments/${env_name}" 2>/dev/null)" \
  || die environment_missing "environment ${env_name} does not exist; apply the GitHub stack (make apply) first"

jq -e '[.protection_rules[]? | select(.type == "required_reviewers") | (.reviewers == null or (.reviewers | length > 0))] | any' \
  <<<"$body" >/dev/null 2>&1 \
  || die environment_unprotected "environment ${env_name} has no required reviewers"
jq -e '.can_admins_bypass == false' <<<"$body" >/dev/null 2>&1 \
  || die environment_unprotected "environment ${env_name} lets admins bypass its reviewers"

log_json info environment_protected "environment ${env_name} requires reviewer approval"
