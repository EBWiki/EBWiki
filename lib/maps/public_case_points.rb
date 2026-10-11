# frozen_string_literal: true

module Maps
  # Builds the public JSON payload for map and globe views.
  class PublicCasePoints
    PUBLIC_FIELDS = %i[id name date city state lat lng url].freeze

    def self.call(cases: Case.with_location.includes(:state))
      new(cases: cases).as_json
    end

    def initialize(cases:, url_helpers: Rails.application.routes.url_helpers)
      @cases = cases
      @url_helpers = url_helpers
    end

    def as_json
      @cases.filter_map { |record| point_for(record) }
    end

    private

    def point_for(record)
      return unless mappable?(record)

      public_point(record)
    end

    def mappable?(record)
      record.latitude.present? && record.longitude.present?
    end

    def public_point(record)
      {
        id: record.id,
        name: record.title,
        date: record.date&.iso8601,
        city: record.city,
        state: state_label(record),
        lat: record.latitude.to_f,
        lng: record.longitude.to_f,
        url: @url_helpers.case_url(record)
      }
    end

    def state_label(record)
      record.state&.ansi_code.presence || record.state&.name
    end
  end
end
