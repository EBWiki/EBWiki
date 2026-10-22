# frozen_string_literal: true

module CasePhotoAdmin
  # Sets photo_status to hidden and writes a minimal audit log. Does not delete files or URLs.
  class HidePhoto
    Result = Struct.new(:outcome, :reason, keyword_init: true)

    SKIPPED_ALREADY_HIDDEN = 'already_hidden'
    SKIPPED_ALREADY_REMOVED = 'already_removed'
    SKIPPED_NOT_SHOWN = 'photo_not_shown'

    def self.call(case_record)
      new(case_record).call
    end

    def initialize(case_record)
      @case_record = case_record
    end

    def call
      reason = skip_reason
      return skipped_result(reason) if reason

      apply_hide!
      Result.new(outcome: :changed, reason: nil)
    rescue StandardError => e
      ErrorReporter.report(e, case_id: case_record.id, action: 'hide_photo')
      raise
    end

    private

    attr_reader :case_record

    def apply_hide!
      Case.transaction do
        case_record.update!(photo_status: :hidden)
        CasePhotoAdminAuditLog.record_hide!(case_record)
      end
    end

    def skipped_result(reason)
      log_skip(reason)
      Result.new(outcome: :skipped, reason: reason)
    end

    def skip_reason
      return SKIPPED_ALREADY_HIDDEN if case_record.photo_hidden?
      return SKIPPED_ALREADY_REMOVED if case_record.photo_removed?
      return SKIPPED_NOT_SHOWN unless case_record.photo_shown?

      nil
    end

    def log_skip(reason)
      Rails.logger.warn(
        {
          event: 'case_photo_hide_skipped',
          case_id: case_record.id,
          reason: reason
        }.to_json
      )
    end
  end
end
