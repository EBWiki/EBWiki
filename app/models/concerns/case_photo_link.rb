# frozen_string_literal: true

module CasePhotoLink
  extend ActiveSupport::Concern

  included do
    enum :photo_status, {
      shown: 'shown',
      hidden: 'hidden',
      removed: 'removed'
    }, prefix: :photo, validate: { allow_nil: true }
  end
end
