#!/bin/bash
set -u

mkdir -p /logs/verifier

MODEL="/usr/src/ebwiki/app/models/harbor_annotation_sample.rb"

if [ -f "$MODEL" ] && grep -q "== Schema Information" "$MODEL" && grep -q "harbor_annotation_samples" "$MODEL"; then
  echo 1 > /logs/verifier/reward.txt
  exit 0
fi

echo 0 > /logs/verifier/reward.txt
exit 0
