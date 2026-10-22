# frozen_string_literal: true

# Private family request to remove or replace a case link photo. Not shown on the public site.
class CasePhotoChangeRequest < ApplicationRecord
  CONTACT_RETENTION_DAYS = 90

  belongs_to :case, class_name: 'Case'

  enum :request_type, {
    remove: 'remove',
    replace: 'replace'
  }, validate: true

  enum :status, {
    pending: 'pending',
    resolved: 'resolved'
  }, validate: true

  mount_uploader :replacement_photo, CasePhotoReplacementUploader

  validates :request_type, presence: true
  validates :message, length: { maximum: 5000 }, allow_blank: true
  validates :requester_contact, length: { maximum: 500 }, allow_blank: true

  def resolve!
    return if resolved?

    now = Time.current
    update!(
      status: :resolved,
      resolved_at: now,
      contact_purge_after: now + CONTACT_RETENTION_DAYS.days
    )
  end

  def purge_requester_contact!
    return if requester_contact.blank?
    return if contact_purge_after.present? && contact_purge_after > Time.current

    update!(requester_contact: nil)
  end
end
