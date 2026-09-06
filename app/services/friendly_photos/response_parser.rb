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

    def self.ext_value(metadata, key)
      strip_tags(metadata.dig(key, 'value'))
    end

    def self.commons_attrs(page, info, image_url)
      metadata = info['extmetadata'] || {}
      {
        source: 'wikimedia_commons', title: page['title'].to_s.delete_prefix('File:'),
        image_url: image_url, page_url: page_url(info['descriptionurl']),
        license: ext_value(metadata, 'LicenseShortName'),
        license_url: page_url(ext_value(metadata, 'LicenseUrl')),
        author: ext_value(metadata, 'Artist'),
        description: ext_value(metadata, 'ImageDescription')
      }
    end

    def self.wikipedia_attrs(page, image_url)
      {
        source: 'wikipedia', title: page['pageimage'].presence || page['title'],
        image_url: image_url, page_url: page_url(page['fullurl']),
        license: 'Wikipedia page image', author: nil, description: page['title']
      }
    end
  end
end
