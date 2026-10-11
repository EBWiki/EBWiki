# frozen_string_literal: true

module ActiveStorageCutover
  # Blocks slice 5b (CarrierWave avatar column drop) while any case still has a
  # non-blank legacy +avatar+ value and no Active Storage +photo+ attachment.
  class CaseAvatarDropGuard
    PHOTO_ATTACHMENT_NAME = 'photo'
    RECORD_TYPE = 'Case'
    UNSAFE_COUNT_SQL = <<~SQL.squish
      SELECT COUNT(*)
      FROM cases c
      WHERE NULLIF(BTRIM(c.avatar::text), '') IS NOT NULL
        AND NOT EXISTS (
          SELECT 1
          FROM active_storage_attachments a
          WHERE a.record_type = '#{RECORD_TYPE}'
            AND a.record_id = c.id
            AND a.name = '#{PHOTO_ATTACHMENT_NAME}'
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
      "Refusing to drop cases.avatar: #{count} #{noun} still have a legacy avatar " \
        'value but no Active Storage photo. Re-run active_storage:backfill_case_photos ' \
        'or restore missing files before slice 5b. Take a database backup before retrying.'
    end
  end
end
