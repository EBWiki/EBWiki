#!/usr/bin/env bash

echo "*** Running any new migrations ***"
bundle exec rails db:migrate

if [ "$REVIEW_SERVER" = "1" ]; then
  echo "*** Seeding review server demo data ***"
  bundle exec rake review:seed
fi