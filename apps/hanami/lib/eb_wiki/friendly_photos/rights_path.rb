# frozen_string_literal: true

require "eb_wiki/friendly_photos/source_policy"

module EbWiki
  module FriendlyPhotos
    # Validates rights-path URLs and formats license data for attach history.
    module RightsPath
      INVALID_URL_ERROR = "That candidate has an invalid rights path URL."

      module_function

      def sanitize_url(url)
        cleaned = url.to_s.strip
        return if cleaned.empty?
        return unless SourcePolicy.allowed_page_url?(cleaned)

        cleaned
      end

      def recorded?(hit)
        !hit.license.to_s.strip.empty? || !sanitize_url(hit.license_url).nil?
      end

      def invalid_submitted_url?(hit)
        !hit.license_url.to_s.strip.empty? && sanitize_url(hit.license_url).nil?
      end

      def history_fragment(hit)
        label = hit.license.to_s.strip
        url = sanitize_url(hit.license_url)
        parts = []
        parts << label unless label.empty?
        parts << url unless url.nil?
        parts.join("; ")
      end

      def attach_comment(title:, hit:)
        "Applied reviewed profile picture '#{title}' (#{history_fragment(hit)})."
      end
    end
  end
end
