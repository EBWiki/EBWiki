# frozen_string_literal: true

require 'timeout'

module Health
  # Readiness probes for Postgres, Redis, and Elasticsearch (used by GET /health).
  class ReadinessChecks
    CHECK_TIMEOUT_SEC = 2

    def self.call
      new.call
    end

    def call
      checks = {
        postgres: check_postgres,
        redis: check_redis,
        elasticsearch: check_elasticsearch
      }
      overall = checks.values.all? { |entry| entry[:status] == 'ok' } ? 'ok' : 'down'
      { status: overall, checks: checks }
    end

    private

    def check_postgres
      timed_check do
        ActiveRecord::Base.connection.select_value('SELECT 1')
        true
      end
    end

    def check_redis
      timed_check do
        $redis.with { |conn| conn.ping == 'PONG' }
      end
    end

    def check_elasticsearch
      timed_check do
        Searchkick.client.ping
      end
    end

    def timed_check
      started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      ok = Timeout.timeout(CHECK_TIMEOUT_SEC) { yield }
      build_result(ok, started)
    rescue StandardError, Timeout::Error
      build_result(false, started)
    end

    def build_result(ok, started)
      { status: ok ? 'ok' : 'down', latency_ms: elapsed_ms(started) }
    end

    def elapsed_ms(started)
      ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000).round
    end
  end
end
