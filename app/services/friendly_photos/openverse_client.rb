# frozen_string_literal: true

module FriendlyPhotos
  # Creative Commons Openverse search. Does not query mugshot or booking DBs.
  class OpenverseClient
    include HTTParty

    base_uri 'https://api.openverse.org'
    headers 'User-Agent' => WikimediaClient::USER_AGENT
    default_timeout WikimediaClient::TIMEOUT

    SEARCH_PARAMS = {
      license: 'cc0,by,by-sa,pdm',
      mature: false
    }.freeze

    def search(query:, limit: 8)
      return StubResults.openverse_for(query) if WikimediaClient.stubbed?

      response = self.class.get(
        '/v1/images/',
        query: SEARCH_PARAMS.merge(q: query, page_size: limit)
      )
      return [] unless response.success?

      Array(response['results']).filter_map { |row| hit(row) }
    end

    private

    def hit(row)
      image_url = row['url'].presence || row['thumbnail']
      return unless SourcePolicy.allowed_image_url?(image_url)

      attrs = hit_attrs(row, image_url)
      built = WikimediaClient::Hit.new(attrs)
      built unless SourcePolicy.excluded_hit?(built)
    end

    def hit_attrs(row, image_url)
      {
        source: 'openverse',
        title: row['title'].presence || 'Openverse image',
        image_url: image_url,
        page_url: safe_page_url(row['foreign_landing_url']),
        license: license_label(row),
        license_url: row['license_url'],
        author: row['creator'],
        description: [row['source'], row['attribution']].compact.join(' ')
      }
    end

    def safe_page_url(url)
      url if SourcePolicy.allowed_page_url?(url)
    end

    def license_label(row)
      raw = row['license'].to_s
      return if raw.blank?

      name = raw.upcase.start_with?('CC') ? raw.upcase : "CC #{raw.upcase}"
      [name, row['license_version']].compact_blank.join(' ')
    end
  end
end
