# frozen_string_literal: true

module ActiveStorageCutover
  # Blocks dropping legacy CarrierWave photo columns while any case still has
  # unmigrated values in +avatar+, +default_avatar_url+, or +remove_avatar+.
  class CaseAvatarDropGuard
    PHOTO_ATTACHMENT_NAME = 'photo'
    RECORD_TYPE = 'Case'
    UNSAFE_COUNT_SQL = <<~SQL.squish
      SELECT COUNT(*)
      FROM cases c
      WHERE NOT EXISTS (
          SELECT 1
          FROM active_storage_attachments a
          WHERE a.record_type = '#{RECORD_TYPE}'
            AND a.record_id = c.id
            AND a.name = '#{PHOTO_ATTACHMENT_NAME}'
        )
        AND (
          NULLIF(BTRIM(c.avatar::text), '') IS NOT NULL
          OR NULLIF(BTRIM(c.default_avatar_url::text), '') IS NOT NULL
          OR (
            c.remove_avatar IS TRUE
            AND (
              NULLIF(BTRIM(c.avatar::text), '') IS NOT NULL
              OR NULLIF(BTRIM(c.default_avatar_url::text), '') IS NOT NULL
            )
          )
        )
    SQL

    def self.unsafe_case_count(connection = ActiveRecord::Base.connection)
      connection.select_value(UNSAFE_COUNT_SQL).to_i
    end

    def self.refuse_if_unsafe!(connection = ActiveRecord::Base.connection)
      count = unsafe_case_count(connection)
      return if count.zero?

      raise ActiveRecord::MigrationError, failure_message(count)
    end

    def self.failure_message(count)
      noun = count == 1 ? 'case' : 'cases'
      'Refusing to drop legacy case photo columns (avatar, default_avatar_url, remove_avatar): ' \
        "#{count} #{noun} still have legacy photo data but no Active Storage photo. " \
        'The guard only checks that a photo attachment row exists, not that the blob file is readable. ' \
        'Re-run active_storage:backfill_case_photos for cases with a non-blank avatar column, ' \
        'or follow the runbook for rows with only default_avatar_url set (backfill skips those). ' \
        'Restore missing files before dropping the old photo columns. ' \
        'Take a database backup before retrying.'
    end
  end
end
