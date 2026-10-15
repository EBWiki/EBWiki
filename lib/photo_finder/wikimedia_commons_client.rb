# frozen_string_literal: true

require 'httparty'

require_relative 'allowed_image_download'

module PhotoFinder
  class WikimediaCommonsClient
    API_ENDPOINT = 'https://commons.wikimedia.org/w/api.php'
    USER_AGENT = 'EBWikiPhotoFinder/1.0 (https://ebwiki.org; contact@ebwiki.org)'
    SEARCH_DEFAULTS = {
      action: 'query',
      format: 'json',
      generator: 'search',
      gsrnamespace: 6,
      gsrlimit: 15,
      prop: 'imageinfo',
      iiprop: 'url|extmetadata',
      iiurlwidth: 800
    }.freeze

    def search(query, case_record: nil) # rubocop:disable Lint/UnusedMethodArgument
      return [] if query.blank?

      parse_pages(fetch_pages(query))
    rescue StandardError
      []
    end

    private

    def fetch_pages(query)
      response = HTTParty.get(
        API_ENDPOINT,
        query: search_params(query),
        headers: { 'User-Agent' => USER_AGENT },
        timeout: 15
      )
      return {} unless response.success?

      response.parsed_response
    end

    def search_params(query)
      SEARCH_DEFAULTS.merge(gsrsearch: query)
    end

    def parse_pages(payload)
      pages = payload.dig('query', 'pages') || {}
      pages.values.filter_map { |page| candidate_from_page(page) }
    end

    def candidate_from_page(page)
      imageinfo = page['imageinfo']&.first
      return unless imageinfo

      image_url = imageinfo['thumburl'] || imageinfo['url']
      return unless AllowedImageDownload.permitted?(image_url)

      Candidate.new(
        **wikimedia_candidate_attributes(page['title'], imageinfo, image_url)
      )
    end

    def wikimedia_candidate_attributes(title, imageinfo, image_url)
      metadata = imageinfo['extmetadata'] || {}
      {
        image_url: image_url,
        source_page_url: wiki_page_url(title),
        source_name: 'wikimedia_commons',
        license_label: metadata.dig('LicenseShortName', 'value'),
        license_url: metadata.dig('LicenseUrl', 'value'),
        title: title,
        description: metadata.dig('ImageDescription', 'value')
      }
    end

    def wiki_page_url(title)
      "https://commons.wikimedia.org/wiki/#{title}"
    end
  end
end
