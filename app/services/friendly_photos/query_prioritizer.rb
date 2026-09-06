# frozen_string_literal: true

module FriendlyPhotos
  # Reorders planner queries so incident-specific strings run before bare-name homonyms.
  class QueryPrioritizer
    include Service

    INCIDENT_PREFIXES = ['Killing of', 'Shooting of'].freeze

    def call(queries:)
      incident, rest = Array(queries).partition { |query| incident_query?(query) }
      (incident + rest).map(&:strip).compact_blank.uniq
    end

    private

    def incident_query?(query)
      INCIDENT_PREFIXES.any? { |prefix| query.to_s.start_with?(prefix) }
    end
  end
end
