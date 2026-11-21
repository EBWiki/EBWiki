# frozen_string_literal: true

module PhotoSearch
  # Verifies a scrubbed ebwiki-review copy has no real contributor emails, tokens, or IPs.
  module ReviewDatabaseAssertions
    Result = Data.define(:ok, :checks, :errors)

    class << self
      def run(connection: ActiveRecord::Base.connection)
        checks = build_checks(connection)
        errors = checks.filter_map do |check|
          next if check[:actual].zero?

          "#{check[:name]}: expected 0, got #{check[:actual]} (#{check[:detail]})"
        end
        Result.new(ok: errors.empty?, checks: checks, errors: errors)
      end

      def run!(connection: ActiveRecord::Base.connection)
        result = run(connection: connection)
        return result if result.ok?

        result.errors.each { |message| warn(message) }
        raise AssertionError, result.errors.join('; ')
      end

      def documented_checks
        build_checks(nil).map { |c| c.slice(:name, :detail) }
      end

      private

      def build_checks(connection)
        domain = ReviewDatabaseScrub::SCRUBBED_EMAIL_DOMAIN
        digest = ReviewDatabaseScrub.scrubbed_password_digest
        check_specs(domain, digest).map do |spec|
          count_check(connection, **spec)
        end
      end

      # rubocop:disable Metrics/MethodLength -- assertion catalog for operators
      def check_specs(domain, digest)
        digest_sql = ActiveRecord::Base.sanitize_sql_array(
          ['SELECT COUNT(*) FROM users WHERE encrypted_password <> ?', digest]
        )
        [
          {
            name: 'users with non-scrubbed email',
            detail: "email NOT LIKE '%@#{domain}'",
            sql: "SELECT COUNT(*) FROM users WHERE email NOT LIKE '%@#{domain}'"
          },
          {
            name: 'users with reset_password_token set',
            detail: 'users.reset_password_token IS NOT NULL',
            sql: 'SELECT COUNT(*) FROM users WHERE reset_password_token IS NOT NULL'
          },
          {
            name: 'users with confirmation_token set',
            detail: 'users.confirmation_token IS NOT NULL',
            sql: 'SELECT COUNT(*) FROM users WHERE confirmation_token IS NOT NULL'
          },
          {
            name: 'users with non-scrubbed password digest',
            detail: 'encrypted_password differs from scrubbed sentinel',
            sql: digest_sql
          },
          {
            name: 'users with sign-in IP',
            detail: 'current_sign_in_ip or last_sign_in_ip IS NOT NULL',
            sql: <<~SQL.squish
              SELECT COUNT(*) FROM users
              WHERE current_sign_in_ip IS NOT NULL OR last_sign_in_ip IS NOT NULL
            SQL
          },
          {
            name: 'versions with whodunnit or ip',
            detail: 'versions.whodunnit IS NOT NULL OR versions.ip IS NOT NULL',
            sql: <<~SQL.squish
              SELECT COUNT(*) FROM versions
              WHERE whodunnit IS NOT NULL OR ip IS NOT NULL
            SQL
          },
          {
            name: 'sessions rows remaining',
            detail: 'sessions table should be empty',
            sql: 'SELECT COUNT(*) FROM sessions'
          },
          {
            name: 'visits with IP',
            detail: 'visits.ip IS NOT NULL',
            sql: 'SELECT COUNT(*) FROM visits WHERE ip IS NOT NULL'
          }
        ]
      end
      # rubocop:enable Metrics/MethodLength

      def count_check(connection, name:, detail:, sql:)
        actual =
          if connection.nil?
            0
          else
            connection.select_value(sql).to_i
          end
        { name: name, detail: detail, actual: actual }
      end
    end

    class AssertionError < StandardError; end
  end
end
