# frozen_string_literal: true

require 'httparty'

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
      results = payload['results'] || []
      results.filter_map do |row|
        image_url = row['url']
        next if image_url.blank?

        Candidate.new(
          image_url: image_url,
          source_page_url: row['foreign_landing_url'] || row['detail_url'],
          source_name: 'openverse',
          license_label: row['license']&.upcase,
          license_url: row['license_url'],
          title: row['title'],
          description: row['creator']
        )
      end
    end
  end
end
