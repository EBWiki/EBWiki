#!/bin/bash
set -euo pipefail

cd /usr/src/ebwiki
bundle exec rails -v > /tmp/rails_version.txt
