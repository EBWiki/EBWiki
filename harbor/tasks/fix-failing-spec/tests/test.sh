#!/bin/bash
set -u

mkdir -p /logs/verifier

cd /usr/src/ebwiki

if bundle exec rspec spec/harbor/addition_spec.rb; then
  echo 1 > /logs/verifier/reward.txt
  exit 0
fi

echo 0 > /logs/verifier/reward.txt
exit 0
