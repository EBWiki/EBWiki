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
    create!(attributes_from_finder(case_record, finder_candidate))
  end

  def self.attributes_from_finder(case_record, finder_candidate)
    finder_candidate.to_h.merge(case: case_record, status: :pending)
  end
  private_class_method :attributes_from_finder
end
