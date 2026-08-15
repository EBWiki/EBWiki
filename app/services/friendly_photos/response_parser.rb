# frozen_string_literal: true

module FriendlyPhotos
  # Shared parsing for Wikimedia API payloads.
  class ResponseParser
    def self.pages(response)
      response.dig('query', 'pages')&.values || []
    end

    def self.page_url(url)
      url if WikimediaClient.allowed_page_url?(url)
    end

    def self.strip_tags(value)
      return if value.blank?

      ActionController::Base.helpers.strip_tags(value).squish
    end
  end
end
