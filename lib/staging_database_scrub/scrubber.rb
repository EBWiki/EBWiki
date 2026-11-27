# frozen_string_literal: true

require 'staging_database_scrub/scrubber_steps'

module StagingDatabaseScrub
  class Scrubber
    class CaseDataChangedError < StandardError; end

    def initialize(connection: ActiveRecord::Base.connection, logger: Rails.logger)
      @connection = connection
      @logger = logger
    end

    def run
      ProductionGuard.enforce(connection: connection)
      case_snapshot = capture_case_snapshot
      log_event('scrub_started', database: connection.current_database)
      connection.transaction { apply_scrub_steps! }
      finish_scrub!(case_snapshot)
      true
    rescue StandardError => e
      ErrorReporter.report(e, phase: 'scrub')
      raise
    end

    private

    attr_reader :connection, :logger

    def apply_scrub_steps!
      ScrubberSteps.allow_null_password_digest!(connection, logger: logger)
      ScrubberSteps.scrub_users!(connection)
      ScrubberSteps.clear_sessions!(connection)
      ScrubberSteps.null_sensitive_user_columns!(connection)
      ScrubberSteps.scrub_user_version_history!(connection)
      ScrubberSteps.null_version_ips!(connection)
      ScrubberSteps.null_visit_ips!(connection)
      ScrubberSteps.scrub_version_whodunnit_values!(connection)
    end

    def log_event(event, **payload)
      logger.info({ event: event, component: 'staging_database_scrub', **payload }.to_json)
    end

    def capture_case_snapshot
      connection.select_all(<<~SQL.squish).to_a
        SELECT id, title, overview, summary, city, address, zipcode, date, state, country,
               blurb, community_action, litigation, slug, video_url
        FROM cases
        ORDER BY id
      SQL
    end

    def verify_cases_unchanged!(before_snapshot)
      after_snapshot = capture_case_snapshot
      return if before_snapshot == after_snapshot

      raise CaseDataChangedError, case_change_message(before_snapshot, after_snapshot)
    end

    def case_change_message(before_snapshot, after_snapshot)
      "Case rows changed during scrub (before=#{before_snapshot.size}, " \
        "after=#{after_snapshot.size})"
    end

    def finish_scrub!(case_snapshot)
      verify_cases_unchanged!(case_snapshot)
      log_event(
        'scrub_finished',
        database: connection.current_database,
        case_count: case_snapshot.size
      )
    end
  end
end
