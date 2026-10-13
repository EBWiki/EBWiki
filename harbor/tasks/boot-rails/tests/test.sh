#!/bin/bash
set -u

mkdir -p /logs/verifier

if [ -f /tmp/boot.txt ] && grep -q "EBWiki::Application" /tmp/boot.txt; then
  echo 1 > /logs/verifier/reward.txt
  exit 0
fi

echo 0 > /logs/verifier/reward.txt
exit 0
