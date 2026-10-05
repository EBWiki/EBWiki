# frozen_string_literal: true

module FriendlyPhotos
  # Deterministic Wikimedia/Openverse query list used when AI is unavailable.
  class HeuristicPlanner
    include Service

    Result = Struct.new(:queries, :ai_used, keyword_init: true)

    def call(name:, city: nil, year: nil, slug: nil)
      queries = QueryPrioritizer.call(
        queries: incident_queries(name) + contextual_queries(name, city, year, slug) +
                 portrait_queries(name)
      )
      Result.new(queries: queries, ai_used: false)
    end

    private

    def incident_queries(name)
      ["Killing of #{name}", "Shooting of #{name}"]
    end

    def contextual_queries(name, city, year, slug)
      [
        [name, city, year].compact.join(' '),
        slug.presence&.tr('-', ' '),
        [name, city].compact.join(' '),
        [name, year].compact.join(' ')
      ].compact_blank
    end

    def portrait_queries(name)
      ["#{name} portrait", "#{name} family photo", name]
    end
  end
end
