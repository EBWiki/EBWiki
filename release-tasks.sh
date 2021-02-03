#!/usr/bin/env bash

echo "*** Running any new migrations ***"
bundle exec rails db:migrate