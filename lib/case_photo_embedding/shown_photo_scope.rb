# frozen_string_literal: true

module CasePhotoEmbedding
  # Shared query scope for cases that display a link-only photo.
  module ShownPhotoScope
    extend ActiveSupport::Concern

    included do
      scope :with_shown_photo, lambda {
        where(photo_status: photo_statuses[:shown]).where.not(photo_url: [nil, ''])
      }
    end
  end
end
