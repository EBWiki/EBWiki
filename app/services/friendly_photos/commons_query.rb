# frozen_string_literal: true

module FriendlyPhotos
  # File search against Wikimedia Commons, excluding obvious booking-photo terms.
  class CommonsQuery
    BASE_PARAMS = {
      action: 'query',
      format: 'json',
      generator: 'search',
      gsrnamespace: 6,
      prop: 'imageinfo',
      iiprop: 'url|extmetadata|mime',
      iiurlwidth: 400
    }.freeze

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
      BASE_PARAMS.merge(
        gsrsearch: "#{query} -mugshot -booking -inmate",
        gsrlimit: limit
      )
    end

    def hit(page)
      info = page.dig('imageinfo', 0)
      image_url = info && (info['thumburl'].presence || info['url'])
      return unless WikimediaClient.allowed_image_url?(image_url)

      WikimediaClient::Hit.new(ResponseParser.commons_attrs(page, info, image_url))
    end
  end
end
