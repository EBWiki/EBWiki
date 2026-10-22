# frozen_string_literal: true

# Minimal audit row when an admin hides a case link photo (case id, action, time only).
class CasePhotoAdminAuditLog < ApplicationRecord
  self.record_timestamps = false

  belongs_to :case, class_name: 'Case'

  ACTIONS = {
    hide: 'hide'
  }.freeze

  validates :action, presence: true, inclusion: { in: ACTIONS.values }
  validates :created_at, presence: true

  def self.record_hide!(case_record)
    create!(
      case: case_record,
      action: ACTIONS[:hide],
      created_at: Time.current
    )
  end
end
