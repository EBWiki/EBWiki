# frozen_string_literal: true

module FriendlyPhotos
  # Looks up the Wikipedia page image for a person, when one exists.
  class WikipediaQuery
    def initialize(http)
      @http = http
    end

    def search(query)
      title = page_title(query)
      return [] if title.blank?

      response = http.get(WikimediaClient::WIKIPEDIA_API, query: image_params(title))
      return [] unless response.success?

      ResponseParser.pages(response).filter_map { |page| hit(page) }
    end

    private

    attr_reader :http

    def page_title(query)
      response = http.get(WikimediaClient::WIKIPEDIA_API, query: title_params(query))
      return unless response.success?

      response.dig('query', 'search', 0, 'title')
    end

    def title_params(query)
      { action: 'query', format: 'json', list: 'search', srsearch: query, srlimit: 1 }
    end

    def image_params(title)
      {
        action: 'query', format: 'json', titles: title,
        prop: 'pageimages|info', inprop: 'url',
        piprop: 'original|name', pithumbsize: 500
      }
    end

    def hit(page)
      image_url = page.dig('original', 'source').presence || page.dig('thumbnail', 'source')
      return unless WikimediaClient.allowed_image_url?(image_url)

      WikimediaClient::Hit.new(ResponseParser.wikipedia_attrs(page, image_url))
    end
  end
end
