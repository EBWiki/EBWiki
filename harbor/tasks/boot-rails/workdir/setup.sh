#!/bin/bash
set -euo pipefail

cd /usr/src/ebwiki
bundle exec rails db:prepare
