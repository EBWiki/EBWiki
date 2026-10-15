# frozen_string_literal: true

require 'httparty'

module PhotoFinder
  class WikimediaCommonsClient
    API_ENDPOINT = 'https://commons.wikimedia.org/w/api.php'
    USER_AGENT = 'EBWikiPhotoFinder/1.0 (https://ebwiki.org; contact@ebwiki.org)'

    def search(query, case_record: nil) # rubocop:disable Lint/UnusedMethodArgument
      return [] if query.blank?

      response = HTTParty.get(
        API_ENDPOINT,
        query: search_params(query),
        headers: { 'User-Agent' => USER_AGENT },
        timeout: 15
      )
      return [] unless response.success?

      parse_pages(response.parsed_response)
    rescue StandardError
      []
    end

    private

    def search_params(query)
      {
        action: 'query',
        format: 'json',
        generator: 'search',
        gsrsearch: query,
        gsrnamespace: 6,
        gsrlimit: 15,
        prop: 'imageinfo',
        iiprop: 'url|extmetadata',
        iiurlwidth: 800
      }
    end

    def parse_pages(payload)
      pages = payload.dig('query', 'pages') || {}
      pages.values.filter_map do |page|
        imageinfo = page['imageinfo']&.first
        next unless imageinfo

        metadata = imageinfo.dig('extmetadata') || {}
        Candidate.new(
          image_url: imageinfo['thumburl'] || imageinfo['url'],
          source_page_url: "https://commons.wikimedia.org/wiki/#{page['title']}",
          source_name: 'wikimedia_commons',
          license_label: metadata.dig('LicenseShortName', 'value'),
          license_url: metadata.dig('LicenseUrl', 'value'),
          title: page['title'],
          description: metadata.dig('ImageDescription', 'value')
        )
      end
    end
  end
end
