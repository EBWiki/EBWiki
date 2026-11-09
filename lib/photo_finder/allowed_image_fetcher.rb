# frozen_string_literal: true

require 'httparty'
require 'uri'

require_relative 'allowed_image_download'

module PhotoFinder
  # Downloads an image over HTTPS with manual redirect handling and per-hop allowlisting.
  class AllowedImageFetcher
    class Error < StandardError; end

    MAX_REDIRECTS = 5
    REDIRECT_STATUS = [301, 302, 303, 307, 308].freeze

    class << self
      def fetch(start_url, timeout: 30)
        follow_redirects(start_url, timeout: timeout, redirects_followed: 0)
      end

      private

      def follow_redirects(current_url, timeout:, redirects_followed:)
        ensure_permitted!(current_url)
        response = HTTParty.get(current_url, follow_redirects: false, timeout: timeout)
        return response if response.success?
        if redirect?(response)
          return redirect_response(current_url, response, timeout, redirects_followed)
        end

        raise Error, 'Could not download the image.'
      end

      def redirect?(response)
        REDIRECT_STATUS.include?(response.code)
      end

      def redirect_response(current_url, response, timeout, redirects_followed)
        handle_redirect(
          current_url,
          response,
          timeout: timeout,
          redirects_followed: redirects_followed
        )
      end

      def handle_redirect(current_url, response, timeout:, redirects_followed:)
        redirects_followed += 1
        raise Error, 'Too many redirects.' if redirects_followed > MAX_REDIRECTS

        location = response.headers['location']
        raise Error, 'Redirect response did not include a location.' if location.blank?

        next_url = absolute_redirect_url(current_url, location)
        follow_redirects(next_url, timeout: timeout, redirects_followed: redirects_followed)
      end

      def ensure_permitted!(url)
        return if AllowedImageDownload.permitted?(url)

        raise Error, 'Image URL is not from an allowed Wikimedia Commons or Openverse host.'
      end

      def absolute_redirect_url(base_url, location)
        URI.join(base_url, location).to_s
      rescue URI::InvalidURIError
        raise Error, 'Redirect location is not a valid URL.'
      end
    end
  end
end
