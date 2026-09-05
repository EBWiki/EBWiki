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

  scope :friendly, -> { where(likely_mugshot: false) }
  scope :ranked, -> { order(likely_mugshot: :asc, score: :desc, created_at: :desc) }

  def friendly?
    !likely_mugshot?
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

# == Schema Information
#
# Table name: photo_candidates
#
#  id             :integer          not null, primary key
#  author         :string
#  image_url      :string           not null
#  likely_mugshot :boolean          default(FALSE), not null
#  license        :string
#  license_url    :string
#  notes          :text
#  page_url       :string
#  score          :integer          default(0), not null
#  source         :string           not null
#  status         :string           default("pending"), not null
#  subject_name   :string           not null
#  title          :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  case_id        :integer          not null
#
# Indexes
#
#  index_photo_candidates_on_case_id                (case_id)
#  index_photo_candidates_on_case_id_and_image_url  (case_id,image_url) UNIQUE
#  index_photo_candidates_on_status                 (status)
#
# Foreign Keys
#
#  fk_rails_...  (case_id => cases.id)
#
