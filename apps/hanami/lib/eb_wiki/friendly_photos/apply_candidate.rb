# frozen_string_literal: true

require "eb_wiki/friendly_photos/candidate_search"
require "eb_wiki/friendly_photos/source_policy"

module EbWiki
  module FriendlyPhotos
    # Applies a reviewed portrait URL to a case after human approval.
    class ApplyCandidate
      Result = Struct.new(:success, :error)

      def call(hit:)
        error = rejection_reason(hit)
        return failure(error) if error

        Result.new(true, nil)
      end

      def rejection_reason(hit)
        identity_rejection(hit) || rights_rejection(hit)
      end

      private

      def identity_rejection(hit)
        if likely_mugshot?(hit)
          return "This is not a healthy profile picture and cannot be applied."
        end

        nil
      end

      def rights_rejection(hit)
        unless rights_recorded?(hit)
          return "That candidate has no recorded license or rights path."
        end
        return if SourcePolicy.allowed_attach_url?(hit.image_url)

        "That image is not from an allowed Wikimedia or Openverse host."
      end

      def likely_mugshot?(hit)
        return true if hit.likely_mugshot

        text = [hit.title, hit.description, hit.author].join(" ")
        text.match?(CandidateSearch::MUGSHOT_TEXT) ||
          SourcePolicy.excluded_hit?(hit)
      end

      def rights_recorded?(hit)
        !hit.license.to_s.strip.empty? || !hit.license_url.to_s.strip.empty?
      end

      def failure(message)
        Result.new(false, message)
      end
    end
  end
end
