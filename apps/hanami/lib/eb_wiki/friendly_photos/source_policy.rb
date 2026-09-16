# frozen_string_literal: true

require "uri"

module EbWiki
  module FriendlyPhotos
    # Allowlist for openly licensed portrait hosts. Mugshot farms never qualify.
    class SourcePolicy
      WIKIMEDIA_IMAGE_HOSTS = %w[upload.wikimedia.org commons.wikimedia.org].freeze
      PAGE_HOSTS = (
        WIKIMEDIA_IMAGE_HOSTS +
        %w[en.wikipedia.org wikipedia.org flickr.com www.flickr.com openverse.org]
      ).freeze
      BLOCKED_HOST_FRAGMENTS = %w[
        mugshot arrests.org jailbase vinelink inmate-lookup offenderlookup
        capturenet booking.photo
      ].freeze
      BLOCKED_TEXT = /
        mugshots?\.com|arrests\.org|jailbase|vinelink|inmate.?lookup|
        offender.?lookup|booking.?database
      /ix

      def self.excluded_hit?(hit)
        blocked_url?(hit.image_url) || blocked_url?(hit.page_url) ||
          blocked_text?([hit.title, hit.description, hit.source].join(" "))
      end

      def self.blocked_url?(url)
        host = https_host_name(url)
        return true if host.to_s.empty?

        blocked_text?(url.to_s) || BLOCKED_HOST_FRAGMENTS.any? { |part| host.include?(part) }
      end

      def self.blocked_text?(text)
        text.to_s.match?(BLOCKED_TEXT)
      end

      def self.https_host_name(url)
        uri = URI.parse(url.to_s)
        return unless uri.is_a?(URI::HTTPS)

        uri.host.to_s.downcase
      rescue URI::InvalidURIError
        nil
      end
    end
  end
end
