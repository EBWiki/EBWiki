# frozen_string_literal: true

require 'uri'

require_relative 'text_fragments'

module PhotoFinder
  # Drops booking photos, arrest databases, and similar sources before review.
  module MugshotFilter
    BLOCKED_HOST_FRAGMENTS = %w[
      mugshot
      mugshots
      arrests.org
      jailbase
      bustednews
      whosarrested
      inmate
      booking
      vincentmugshots
      findmugshots
    ].freeze

    BLOCKED_TEXT_FRAGMENTS = [
      'mugshot',
      'mug shot',
      'booking photo',
      'booking photograph',
      'jail photo',
      'inmate photo',
      'arrest photo',
      'perp walk',
      'county jail',
      'sheriff booking'
    ].freeze

    module_function

    def mugshot?(candidate)
      haystack = candidate.context_text.downcase
      uri_host = host_fragment(candidate.image_url) + host_fragment(candidate.source_page_url)

      TextFragments.haystack_includes_any?(uri_host, BLOCKED_HOST_FRAGMENTS) ||
        TextFragments.haystack_includes_any?(haystack, BLOCKED_TEXT_FRAGMENTS)
    end

    def host_fragment(url)
      return '' if url.blank?

      URI.parse(url.to_s).host.to_s.downcase
    rescue URI::InvalidURIError
      url.to_s.downcase
    end
    private_class_method :host_fragment
  end
end
