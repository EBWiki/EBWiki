# frozen_string_literal: true

module FriendlyPhotos
  # Reorders planner queries so incident-specific strings run before bare-name homonyms.
  class QueryPrioritizer
    include Service

    INCIDENT_PREFIXES = ['Killing of', 'Shooting of'].freeze

    def call(queries:)
      cleaned = Array(queries).map { |query| query.to_s.strip }.compact_blank
      incident, rest = cleaned.partition { |query| incident_query?(query) }
      (incident + rest).uniq
    end

    private

    def incident_query?(query)
      INCIDENT_PREFIXES.any? { |prefix| query.to_s.start_with?(prefix) }
    end
  end
end
