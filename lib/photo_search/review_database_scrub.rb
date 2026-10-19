# frozen_string_literal: true

require 'bcrypt'

module PhotoSearch
  # Removes EBWiki contributor PII from a copy of the ebwiki-review database while
  # leaving published case content (victim names, dates, places, agencies, sources).
  module ReviewDatabaseScrub
    SCRUBBED_EMAIL_DOMAIN = 'example.invalid'
    SCRUBBED_PASSWORD_PLAINTEXT = 'scrubbed-not-a-login-password'

    POST_USER_SCRUB_SQL = [
      'DELETE FROM sessions',
      'UPDATE versions SET whodunnit = NULL, ip = NULL',
      'DELETE FROM ahoy_events',
      'DELETE FROM visits',
      'DELETE FROM mailboxer_receipts',
      'DELETE FROM mailboxer_notifications',
      'DELETE FROM mailboxer_conversation_opt_outs',
      'DELETE FROM mailboxer_conversations'
    ].freeze

    class << self
      def scrubbed_password_digest
        @scrubbed_password_digest ||= BCrypt::Password.create(
          SCRUBBED_PASSWORD_PLAINTEXT,
          cost: BCrypt::Engine.cost
        ).to_s
      end

      # Ordered SQL. Column list: docs/photo_search/REVIEW_DATABASE_SCRUB.md.
      def scrub_sql_statements(password_digest: scrubbed_password_digest)
        quoted_digest = connection_quote(password_digest)
        [users_update_sql(quoted_digest), *POST_USER_SCRUB_SQL]
      end

      def scrub!(connection: ActiveRecord::Base.connection)
        connection.transaction do
          scrub_sql_statements.each do |sql|
            connection.execute(sql)
          end
        end
      end

      private

      # rubocop:disable Metrics/MethodLength -- single UPDATE statement for operators
      def users_update_sql(quoted_digest)
        <<~SQL.squish
          UPDATE users SET
            email = 'user-' || id::text || '@#{SCRUBBED_EMAIL_DOMAIN}',
            name = 'Scrubbed user ' || id::text,
            encrypted_password = #{quoted_digest},
            reset_password_token = NULL,
            reset_password_sent_at = NULL,
            confirmation_token = NULL,
            confirmation_sent_at = NULL,
            current_sign_in_at = NULL,
            last_sign_in_at = NULL,
            current_sign_in_ip = NULL,
            last_sign_in_ip = NULL,
            sign_in_count = 0,
            remember_created_at = NULL,
            facebook_url = NULL,
            twitter_url = NULL,
            linkedin = NULL,
            description = NULL,
            city = NULL,
            storytime_name = NULL,
            latitude = NULL,
            longitude = NULL,
            state = NULL
        SQL
      end
      # rubocop:enable Metrics/MethodLength

      def connection_quote(value)
        ActiveRecord::Base.connection.quote(value)
      end
    end
  end
end
