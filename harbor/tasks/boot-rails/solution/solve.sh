#!/bin/bash
set -euo pipefail

cd /usr/src/ebwiki
bundle exec rails db:prepare
bundle exec rails runner 'File.write("/tmp/boot.txt", Rails.application.class.name)'
