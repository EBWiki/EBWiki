# frozen_string_literal: true

class CaseMpvPhotoReview < ApplicationRecord
  belongs_to :case

  validates :mpv_name, :mpv_state, :victim_image_url, :match_detail, presence: true
  validates :status, inclusion: { in: %w[pending confirmed rejected] }
end
