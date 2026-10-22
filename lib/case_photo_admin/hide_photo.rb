# frozen_string_literal: true

module CasePhotoAdmin
  # Sets photo_status to hidden and writes a minimal audit log. Does not delete files or URLs.
  class HidePhoto
    def self.call(case_record)
      new(case_record).call
    end

    def initialize(case_record)
      @case_record = case_record
    end

    def call
      Case.transaction do
        case_record.update!(photo_status: :hidden)
        CasePhotoAdminAuditLog.record_hide!(case_record)
      end
      case_record
    rescue StandardError => e
      ErrorReporter.report(e, case_id: case_record.id, action: 'hide_photo')
      raise
    end

    private

    attr_reader :case_record
  end
end
