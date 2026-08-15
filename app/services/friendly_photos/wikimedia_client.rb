# frozen_string_literal: true

module FriendlyPhotos
  # Reads openly licensed portraits from Wikimedia Commons and Wikipedia.
  class WikimediaClient
    include HTTParty

    USER_AGENT = 'EBWikiFriendlyPhotos/1.0 (https://ebwiki.org; info@ebwiki.org)'
    COMMONS_API = 'https://commons.wikimedia.org/w/api.php'
    WIKIPEDIA_API = 'https://en.wikipedia.org/w/api.php'
    ALLOWED_HOSTS = %w[upload.wikimedia.org commons.wikimedia.org].freeze
    ALLOWED_PAGE_HOSTS = (
      ALLOWED_HOSTS + %w[en.wikipedia.org wikipedia.org]
    ).freeze
    TIMEOUT = 8

    headers 'User-Agent' => USER_AGENT
    default_timeout TIMEOUT

    Hit = Struct.new(
      :source, :title, :image_url, :page_url, :license, :author, :description,
      keyword_init: true
    )

    def search(query:, limit: 8)
      hits = WikipediaQuery.new(self.class).search(query) +
             CommonsQuery.new(self.class).search(query, limit)
      hits.uniq(&:image_url)
    end

    def self.allowed_image_url?(url)
      allowed_https_url?(url, ALLOWED_HOSTS)
    end

    def self.allowed_page_url?(url)
      allowed_https_url?(url, ALLOWED_PAGE_HOSTS)
    end

    def self.allowed_https_url?(url, hosts)
      uri = URI.parse(url.to_s)
      uri.is_a?(URI::HTTPS) && hosts.include?(uri.host)
    rescue URI::InvalidURIError
      false
    end
  end
end
