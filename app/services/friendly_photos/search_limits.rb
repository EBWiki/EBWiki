# frozen_string_literal: true

module FriendlyPhotos
  # Caps live search work so synchronous POST /search stays under request timeouts.
  class SearchLimits
    VISION_LIMIT = ENV.fetch('FRIENDLY_PHOTOS_VISION_LIMIT', 12).to_i
    HIT_LIMIT_PER_QUERY = ENV.fetch('FRIENDLY_PHOTOS_HIT_LIMIT', 5).to_i
    MAX_QUERIES = ENV.fetch('FRIENDLY_PHOTOS_MAX_QUERIES', 6).to_i
  end
end
