# frozen_string_literal: true

module StagingDatabaseScrub
  class Asserter
    class AssertionFailedError < StandardError; end

    DEFAULT_DATABASE_URL_ENV = 'EBWIKI_SCRUBBED_DATABASE_URL'

    Result = Struct.new(:case_count, :violations, keyword_init: true) do
      def success?
        violations.empty?
      end
    end

    class << self
      def assertion_record_class
        @assertion_record_class ||= StagingDatabaseScrub.const_set(
          :AssertionRecord,
          Class.new(::ApplicationRecord) do
            self.abstract_class = true
          end
        )
      end
    end

    def initialize(database_url: ENV.fetch(DEFAULT_DATABASE_URL_ENV, nil), logger: Rails.logger)
      @database_url = database_url
      @logger = logger
    end

    def run
      ensure_database_url!
      result = build_result(connect!)
      log_report(result)
      result
    rescue StandardError => e
      ErrorReporter.report(e, phase: 'assert')
      raise
    ensure
      disconnect!
    end

    private

    attr_reader :database_url, :logger

    def ensure_database_url!
      return if database_url.present?

      raise AssertionFailedError, "Set #{DEFAULT_DATABASE_URL_ENV} to the scrubbed database URL"
    end

    def connect!
      assertion_record_class.establish_connection(database_url)
      assertion_record_class.connection
    end

    def disconnect!
      assertion_record_class.remove_connection
    end

    def assertion_record_class
      self.class.assertion_record_class
    end

    def build_result(connection)
      violations = {}
      collect_invalid_emails!(connection, violations)
      collect_sensitive_columns!(connection, violations)
      case_count = connection.select_value('SELECT COUNT(*) FROM cases').to_i
      Result.new(case_count: case_count, violations: violations)
    end

    def collect_invalid_emails!(connection, violations)
      domain = ColumnCatalog::SCRUBBED_EMAIL_DOMAIN
      invalid_email_count = connection.select_value(<<~SQL.squish).to_i
        SELECT COUNT(*) FROM users
        WHERE email NOT LIKE '%#{domain}'
      SQL
      violations[:invalid_emails] = invalid_email_count if invalid_email_count.positive?
    end

    def collect_sensitive_columns!(connection, violations)
      sensitive_groups.each do |group|
        group.each { |table, column| record_violation(connection, violations, table, column) }
      end
    end

    def sensitive_groups
      [
        ColumnCatalog.token_columns_for_assertion,
        ColumnCatalog.password_digest_columns_for_assertion,
        ColumnCatalog.ip_columns_for_assertion
      ]
    end

    def record_violation(connection, violations, table, column)
      count = non_null_count(connection, table, column)
      key = :"#{table}_#{column}"
      violations[key] = count if count.positive?
    end

    def non_null_count(connection, table, column)
      connection.select_value("SELECT COUNT(*) FROM #{table} WHERE #{column} IS NOT NULL").to_i
    end

    def log_report(result)
      logger.info(
        {
          event: 'assert_report',
          component: 'staging_database_scrub',
          case_count: result.case_count,
          violations: result.violations
        }.to_json
      )
    end
  end
end
