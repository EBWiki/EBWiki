# frozen_string_literal: true

module FriendlyPhotos
  # Raised when an API key is configured but planner or vision cannot complete.
  class AiError < StandardError; end
end
