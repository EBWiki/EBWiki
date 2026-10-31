#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/github-preflight.sh
source "$ROOT/scripts/lib/github-preflight.sh"

github_preflight
