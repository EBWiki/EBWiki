# frozen_string_literal: true

module FriendlyPhotos
  # Deterministic Wikimedia/Openverse query list used when AI is unavailable.
  class HeuristicPlanner
    include Service

    Result = Struct.new(:queries, :ai_used, keyword_init: true)

    def call(name:, city: nil, year: nil, slug: nil)
      incident = [
        "Killing of #{name}",
        "Shooting of #{name}"
      ]
      contextual = [
        [name, city, year].compact.join(' '),
        slug.present? ? slug.tr('-', ' ') : nil,
        [name, city].compact.join(' '),
        [name, year].compact.join(' ')
      ]
      portrait = [
        "#{name} portrait",
        "#{name} family photo",
        name
      ]

      queries = QueryPrioritizer.call(queries: incident + contextual + portrait)
      Result.new(queries: queries, ai_used: false)
    end
  end
end
