# frozen_string_literal: true

require 'httparty'

require_relative 'allowed_image_download'

module PhotoFinder
  class OpenverseClient
    API_ENDPOINT = 'https://api.openverse.org/v1/images/'

    def search(query, case_record: nil) # rubocop:disable Lint/UnusedMethodArgument
      return [] if query.blank?

      response = HTTParty.get(
        API_ENDPOINT,
        query: { q: query, page_size: 15, license: 'cc0,pdm,by,by-sa' },
        timeout: 15
      )
      return [] unless response.success?

      parse_results(response.parsed_response)
    rescue StandardError
      []
    end

    private

    def parse_results(payload)
      (payload['results'] || []).filter_map { |row| candidate_from_row(row) }
    end

    def candidate_from_row(row)
      image_url = row['thumbnail'].presence
      return if image_url.blank?
      return unless AllowedImageDownload.permitted?(image_url)

      Candidate.new(**openverse_row_attributes(row, image_url))
    end

    def openverse_row_attributes(row, image_url)
      {
        image_url: image_url,
        source_page_url: row['foreign_landing_url'] || row['detail_url'],
        source_name: 'openverse',
        license_label: row['license']&.upcase,
        license_url: row['license_url'],
        title: row['title'],
        description: row['creator']
      }
    end
  end
end
