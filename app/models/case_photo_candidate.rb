# frozen_string_literal: true

class CasePhotoCandidate < ApplicationRecord
  belongs_to :case
  belongs_to :reviewed_by, class_name: 'User', optional: true

  enum :status, {
    pending: 'pending',
    approved: 'approved',
    rejected: 'rejected'
  }, validate: true

  validates :image_url, :source_name, presence: true
  validates :image_url, uniqueness: { scope: :case_id }

  scope :awaiting_review, -> { pending.order(created_at: :desc) }

  def self.create_from_photo_finder_candidate!(case_record, finder_candidate)
    create!(
      case: case_record,
      image_url: finder_candidate.image_url,
      source_page_url: finder_candidate.source_page_url,
      source_name: finder_candidate.source_name,
      license_label: finder_candidate.license_label,
      license_url: finder_candidate.license_url,
      title: finder_candidate.title,
      description: finder_candidate.description,
      status: :pending
    )
  end
end
