#!/bin/bash
set -u

mkdir -p /logs/verifier

if [ ! -f /tmp/contributor_setup.txt ]; then
  echo 0 > /logs/verifier/reward.txt
  exit 0
fi

if grep -q "Rails" /tmp/contributor_setup.txt && grep -qx "ready" /tmp/contributor_setup.txt; then
  echo 1 > /logs/verifier/reward.txt
  exit 0
fi

echo 0 > /logs/verifier/reward.txt
exit 0
