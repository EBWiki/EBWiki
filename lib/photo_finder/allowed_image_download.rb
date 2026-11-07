# frozen_string_literal: true

require 'uri'

module PhotoFinder
  # HTTPS host allowlist for server-side image downloads after admin approval.
  module AllowedImageDownload
    WIKIMEDIA_IMAGE_HOSTS = %w[upload.wikimedia.org].freeze
    OPENVERSE_IMAGE_HOST = 'api.openverse.org'
    OPENVERSE_THUMBS_PATH_PREFIX = '/v1/thumbs/'

    module_function

    def permitted?(url_string)
      uri = https_uri(url_string)
      return false unless uri

      wikimedia_image_host?(uri) || openverse_thumbnail?(uri)
    end

    def https_uri(url_string)
      uri = URI.parse(url_string.to_s)
      return unless uri.is_a?(URI::HTTPS)
      return if uri.host.blank?

      uri
    rescue URI::InvalidURIError
      nil
    end

    def wikimedia_image_host?(uri)
      WIKIMEDIA_IMAGE_HOSTS.include?(uri.host.downcase)
    end

    def openverse_thumbnail?(uri)
      uri.host.downcase == OPENVERSE_IMAGE_HOST &&
        uri.path.start_with?(OPENVERSE_THUMBS_PATH_PREFIX)
    end
  end
end
