# frozen_string_literal: true

module StagingDatabaseScrub
  module ScrubberSteps
    SCRUB_USERS_SQL = <<~SQL.squish
      UPDATE users
      SET email = 'scrubbed-user-' || id::text || '%<domain>s',
          name = 'Scrubbed User ' || id::text,
          description = 'Scrubbed description',
          city = 'Scrubbed City',
          state = 'Scrubbed',
          facebook_url = NULL,
          twitter_url = NULL,
          linkedin = NULL,
          storytime_name = NULL,
          latitude = NULL,
          longitude = NULL,
          slug = 'scrubbed-user-' || id::text,
          updated_at = COALESCE(updated_at, NOW())
    SQL

    module_function

    def allow_null_password_digest!(connection, logger: Rails.logger)
      connection.execute(<<~SQL.squish)
        ALTER TABLE users
        ALTER COLUMN encrypted_password DROP NOT NULL
      SQL
    rescue ActiveRecord::StatementInvalid => e
      raise unless e.message.include?('constraint') || e.message.include?('already')

      logger.warn({ event: 'allow_null_password_digest_skipped', message: e.message }.to_json)
    end

    def scrub_users!(connection)
      domain = ColumnCatalog::SCRUBBED_EMAIL_DOMAIN
      connection.execute(format(SCRUB_USERS_SQL, domain: domain))
    end

    def clear_sessions!(connection)
      connection.execute('DELETE FROM sessions')
    end

    def null_sensitive_user_columns!(connection)
      connection.execute(<<~SQL.squish)
        UPDATE users
        SET encrypted_password = NULL,
            reset_password_token = NULL,
            confirmation_token = NULL,
            current_sign_in_ip = NULL,
            last_sign_in_ip = NULL
      SQL
    end

    def scrub_user_version_history!(connection)
      connection.execute(<<~SQL.squish)
        UPDATE versions
        SET object = NULL,
            object_changes = NULL
        WHERE item_type = 'User'
      SQL
    end

    def null_version_ips!(connection)
      connection.execute('UPDATE versions SET ip = NULL WHERE ip IS NOT NULL')
    end

    def null_visit_ips!(connection)
      connection.execute('UPDATE visits SET ip = NULL WHERE ip IS NOT NULL')
    end

    def scrub_version_whodunnit_values!(connection)
      connection.execute(<<~SQL.squish)
        UPDATE versions
        SET whodunnit = 'scrubbed'
        WHERE whodunnit IS NOT NULL
          AND whodunnit !~ '^[0-9]+$'
      SQL
    end
  end
end
