# frozen_string_literal: true

module FriendlyPhotos
  # File search against Wikimedia Commons, excluding obvious booking-photo terms.
  class CommonsQuery
    def initialize(http)
      @http = http
    end

    def search(query, limit)
      response = http.get(WikimediaClient::COMMONS_API, query: params(query, limit))
      return [] unless response.success?

      ResponseParser.pages(response).filter_map { |page| hit(page) }
    end

    private

    attr_reader :http

    def params(query, limit)
      {
        action: 'query',
        format: 'json',
        generator: 'search',
        gsrsearch: "#{query} -mugshot -booking -inmate",
        gsrnamespace: 6,
        gsrlimit: limit,
        prop: 'imageinfo',
        iiprop: 'url|extmetadata|mime',
        iiurlwidth: 400
      }
    end

    def hit(page)
      info = page.dig('imageinfo', 0)
      return if info.blank?

      image_url = info['thumburl'].presence || info['url']
      return unless WikimediaClient.allowed_image_url?(image_url)

      metadata = info['extmetadata'] || {}
      WikimediaClient::Hit.new(
        source: 'wikimedia_commons',
        title: page['title'].to_s.delete_prefix('File:'),
        image_url: image_url,
        page_url: ResponseParser.page_url(info['descriptionurl']),
        license: metadata.dig('LicenseShortName', 'value'),
        author: ResponseParser.strip_tags(metadata.dig('Artist', 'value')),
        description: ResponseParser.strip_tags(metadata.dig('ImageDescription', 'value'))
      )
    end
  end
end
