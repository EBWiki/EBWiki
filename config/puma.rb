# frozen_string_literal: true

# Puma configuration for Rails 8.1.
threads_count = ENV.fetch('RAILS_MAX_THREADS', 5)
threads threads_count, threads_count

port ENV.fetch('PORT', 3000)
environment ENV.fetch('RAILS_ENV', 'development')
pidfile ENV.fetch('PIDFILE', 'tmp/pids/server.pid')

# workers ENV.fetch('WEB_CONCURRENCY', 2)
# preload_app!

plugin :tmp_restart
plugin :solid_queue if ENV['SOLID_QUEUE_IN_PUMA']
