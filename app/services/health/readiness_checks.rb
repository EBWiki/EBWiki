# frozen_string_literal: true

require 'timeout'

module Health
  # Readiness probes for Postgres and Redis (used by GET /health).
  class ReadinessChecks
    CHECK_TIMEOUT_SEC = 2
    READY_STATUSES = %w[ok skipped].freeze

    def self.call
      new.call
    end

    def call
      checks = {
        postgres: check_postgres,
        redis: check_redis
      }
      { status: overall_status(checks), checks: checks }
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
        redis_pool.with { |conn| conn.ping == 'PONG' }
      end
    end

    def overall_status(checks)
      checks.values.all? { |entry| READY_STATUSES.include?(entry[:status]) } ? 'ok' : 'down'
    end

    def timed_check(&)
      started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      success = Timeout.timeout(CHECK_TIMEOUT_SEC, &)
      build_result(success, started)
    rescue StandardError
      build_result(false, started)
    end

    def build_result(success, started)
      { status: success ? 'ok' : 'down', latency_ms: elapsed_ms(started) }
    end

    def redis_pool
      $redis
    end

    def elapsed_ms(started)
      ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000).round
    end
  end
end
