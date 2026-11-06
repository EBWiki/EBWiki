#!/usr/bin/env bash

echo "*** Running any new migrations ***"
bundle exec rails db:migrate

if [[ "${RAILS_ENV:-}" == "staging" ]]; then
  echo "*** Ensuring staging sample cases (idempotent) ***"
  bundle exec rails staging:sample_content
fi