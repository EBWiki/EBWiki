# frozen_string_literal: true

require 'date'

module MpvPhotoImport
  # One row from a Mapping Police Violence export (CSV).
  class Row
    NAME_HEADERS = %w[name victim_name victims_name].freeze
    DATE_HEADERS = %w[date date_of_death date_of_incident].freeze
    STATE_HEADERS = %w[state state_abbreviation].freeze
    IMAGE_HEADERS = %w[victim_image image_url photo_url].freeze
    SOURCE_HEADERS = %w[source_url source_page_url url].freeze
    CREDIT_HEADERS = %w[photo_credit image_credit credit].freeze

    DEFAULT_CREDIT = 'Mapping Police Violence'
    DEFAULT_SOURCE = 'https://mappingpoliceviolence.org/'

    attr_reader :line_number, :raw

    def initialize(line_number:, raw:)
      @line_number = line_number
      @raw = normalize_keys(raw)
    end

    def name
      fetch(NAME_HEADERS)
    end

    def date
      value = fetch(DATE_HEADERS)
      return nil if value.blank?

      Date.parse(value.to_s)
    rescue ArgumentError
      nil
    end

    def state_code
      fetch(STATE_HEADERS).to_s.strip.upcase.presence
    end

    def victim_image_url
      fetch(IMAGE_HEADERS).to_s.strip.presence
    end

    def photo_source_url
      fetch(SOURCE_HEADERS).presence || DEFAULT_SOURCE
    end

    def photo_credit
      fetch(CREDIT_HEADERS).presence || DEFAULT_CREDIT
    end

    def valid_for_matching?
      name.present? && date.present? && state_code.present? && victim_image_url.present?
    end

    private

    def normalize_keys(raw)
      raw.transform_keys do |key|
        key.to_s.downcase.gsub(/\s+/, '_').delete("'").gsub(/[^a-z0-9_]/, '')
      end
    end

    def fetch(headers)
      headers.each do |header|
        value = raw[header]
        return value if value.present?
      end
      nil
    end
  end
end
