release: bash release-tasks.sh
web: bundle exec puma -t 1:1 -b tcp://0.0.0.0:${PORT:-3000} -e ${RACK_ENV:-development}
