# frozen_string_literal: true

module FriendlyPhotos
  # File search against Wikimedia Commons, excluding obvious booking-photo terms.
  class CommonsQuery
    IMAGE_MIMES = %w[image/jpeg image/png image/gif image/webp].freeze
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
        gsrsearch: "#{query} -mugshot -booking -inmate " \
                   '-filemime:application/pdf -filemime:image/vnd.djvu',
        gsrlimit: limit
      )
    end

    def hit(page)
      info = page.dig('imageinfo', 0)
      return unless info && IMAGE_MIMES.include?(info['mime'].to_s.downcase)

      image_url = info['thumburl'].presence || info['url']
      return unless WikimediaClient.allowed_image_url?(image_url)

      WikimediaClient::Hit.new(ResponseParser.commons_attrs(page, info, image_url))
    end
  end
end
