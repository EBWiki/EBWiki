# frozen_string_literal: true

module FriendlyPhotos
  # Deterministic Wikimedia/Openverse query list used when AI is unavailable.
  class HeuristicPlanner
    include Service

    Result = Struct.new(:queries, :ai_used, keyword_init: true)

    def call(name:, city: nil, year: nil)
      queries = [
        name,
        [name, city].compact.join(' '),
        [name, year].compact.join(' '),
        "#{name} portrait",
        "#{name} family photo",
        "Killing of #{name}",
        "Shooting of #{name}"
      ].map(&:strip).compact_blank.uniq

      Result.new(queries: queries, ai_used: false)
    end
  end
end
