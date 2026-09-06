# frozen_string_literal: true

class PhotoCandidate < ApplicationRecord
  belongs_to :case

  enum :source, {
    wikimedia_commons: 'wikimedia_commons',
    wikipedia: 'wikipedia',
    openverse: 'openverse'
  }

  enum :status, {
    pending: 'pending',
    accepted: 'accepted',
    rejected: 'rejected'
  }

  validates :subject_name, :source, :image_url, :status, presence: true
  validates :image_url, uniqueness: { scope: :case_id }
  validate :urls_use_allowed_hosts

  scope :friendly, -> { where(likely_mugshot: false, likely_homonym: false, vision_failed: false) }
  scope :ranked, lambda {
    order(likely_mugshot: :asc, likely_homonym: :asc, score: :desc, created_at: :desc)
  }

  def friendly?
    !likely_mugshot? && !likely_homonym? && !vision_failed?
  end

  def applyable?
    pending? && friendly? && vision_verified?
  end

  def vision_verified?
    return true unless FriendlyPhotos::AiConfig.require_ai?

    vision_ai_used?
  end

  private

  def urls_use_allowed_hosts
    if image_url.present? && !FriendlyPhotos::SourcePolicy.allowed_image_url?(image_url)
      errors.add(:image_url, 'must be an allowed Wikimedia or Openverse HTTPS image URL')
    end
    return if page_url.blank?
    return if FriendlyPhotos::SourcePolicy.allowed_page_url?(page_url)

    errors.add(:page_url, 'must be an allowed Wikimedia, Wikipedia, or Openverse HTTPS URL')
  end
end
