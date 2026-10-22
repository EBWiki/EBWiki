# frozen_string_literal: true

module MemorialPhotos
  FILTER_PARAM_KEYS = %i[name state_id city year_from year_to agency_id q page].freeze

  # Strongly typed filter bag parsed from query string parameters.
  FilterParams = Data.define(
    :name,
    :state_id,
    :city,
    :year_from,
    :year_to,
    :agency_id,
    :query,
    :page
  ) do
    def self.from_request(params)
      build(params.permit(*MemorialPhotos::FILTER_PARAM_KEYS))
    end

    def self.build(raw)
      new(**attributes_from(raw))
    end

    def self.attributes_from(raw)
      {
        name: normalize_string(raw[:name]),
        state_id: raw[:state_id].presence,
        city: normalize_string(raw[:city]),
        year_from: parse_year(raw[:year_from]),
        year_to: parse_year(raw[:year_to]),
        agency_id: raw[:agency_id].presence,
        query: normalize_string(raw[:q]),
        page: raw[:page].presence || 1
      }
    end

    def self.normalize_string(value)
      value.to_s.strip.presence
    end

    def self.parse_year(value)
      return nil if value.blank?

      year = value.to_i
      return nil unless year.positive? && year <= Date.current.year + 1

      year
    end

    def active?
      [name, state_id, city, year_from, year_to, agency_id, query].any?(&:present?)
    end

    def to_query_hash
      {
        name: name,
        state_id: state_id,
        city: city,
        year_from: year_from,
        year_to: year_to,
        agency_id: agency_id,
        q: query,
        page: page
      }.compact
    end
  end
end
