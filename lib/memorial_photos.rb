# frozen_string_literal: true

# Staging-only memorial photo grid (see config/memorial_photos.yml).
module MemorialPhotos
  module_function

  def enabled?
    Rails.application.config.x.memorial_photos.fetch(:enabled, false)
  end
end
