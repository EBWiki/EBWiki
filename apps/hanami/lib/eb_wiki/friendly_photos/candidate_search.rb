# frozen_string_literal: true

require "eb_wiki/friendly_photos/hit"
require "eb_wiki/friendly_photos/openverse_search_client"
require "eb_wiki/friendly_photos/source_policy"
require "eb_wiki/friendly_photos/wikimedia_search_client"

module EbWiki
  module FriendlyPhotos
    # Finds openly licensed portraits. Sources are locked: Commons, Wikipedia, Openverse.
    class CandidateSearch
      MUGSHOT_TEXT = /mugshot|booking.?photo|jail|inmate|arrest|sheriff/i

      def initialize(name:, city: nil, wikimedia: WikimediaSearchClient.new, openverse: OpenverseSearchClient.new)
        @name = name.to_s.strip
        @city = city.to_s.strip
        @wikimedia = wikimedia
        @openverse = openverse
      end

      def call
        return [] if @name.empty?

        hits = stubbed? ? stub_hits : live_hits
        hits
          .uniq(&:image_url)
          .reject { |hit| SourcePolicy.excluded_hit?(hit) }
          .map { |hit| annotate(hit) }
      end

      private

      def stubbed?
        ENV["E2E_STUB_WIKIMEDIA"] == "1"
      end

      def stub_hits
        [
          Hit.new(
            source: "wikimedia_commons",
            title: "E2E family portrait",
            image_url: "https://upload.wikimedia.org/wikipedia/commons/a/ab/e2e-portrait.jpg",
            page_url: "https://commons.wikimedia.org/wiki/File:E2E_family_portrait.jpg",
            license: "CC BY-SA 4.0",
            author: "E2E fixture",
            description: "Family photo portrait"
          ),
          Hit.new(
            source: "wikimedia_commons",
            title: "E2E institutional photo",
            image_url: "https://upload.wikimedia.org/wikipedia/commons/b/bc/e2e-mugshot.jpg",
            page_url: "https://commons.wikimedia.org/wiki/File:E2E_institutional_photo.jpg",
            license: "Public domain",
            author: "Sheriff",
            description: "County jail booking photo"
          ),
          Hit.new(
            source: "openverse",
            title: "E2E openverse portrait",
            image_url: "https://live.staticflickr.com/e2e/e2e-openverse-portrait.jpg",
            page_url: "https://www.flickr.com/photos/e2e/e2e-openverse-portrait",
            license: "CC BY 4.0",
            author: "E2E Flickr",
            description: "Family photo portrait from Openverse"
          )
        ]
      end

      def live_hits
        query = [@name, @city].reject(&:empty?).join(" ")
        @wikimedia.search(query) + @openverse.search(query)
      rescue
        []
      end

      def annotate(hit)
        hit.likely_mugshot = mugshot?(hit)
        hit
      end

      def mugshot?(hit)
        [hit.title, hit.description, hit.author].join(" ").match?(MUGSHOT_TEXT)
      end
    end
  end
end
