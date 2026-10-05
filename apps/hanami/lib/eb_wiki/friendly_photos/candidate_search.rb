# frozen_string_literal: true

require "eb_wiki/friendly_photos/hit"
require "eb_wiki/friendly_photos/homonym_detector"
require "eb_wiki/friendly_photos/mugshot_classifier"
require "eb_wiki/friendly_photos/openverse_search_client"
require "eb_wiki/friendly_photos/source_policy"
require "eb_wiki/friendly_photos/wikimedia_search_client"

module EbWiki
  module FriendlyPhotos
    # Finds openly licensed portraits. Sources are locked: Commons, Wikipedia, Openverse.
    class CandidateSearch
      def initialize(
        name:,
        city: nil,
        case_year: nil,
        wikimedia: WikimediaSearchClient.new,
        openverse: OpenverseSearchClient.new
      )
        @name = name.to_s.strip
        @city = city.to_s.strip
        @case_year = case_year
        @wikimedia = wikimedia
        @openverse = openverse
      end

      def call
        return [] if @name.empty?

        hits = stubbed? ? stub_hits : live_hits
        hits
          .uniq(&:image_url)
          .select { |hit| SourcePolicy.allowed_hit?(hit) }
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
          ),
          Hit.new(
            source: "wikimedia_commons",
            title: "Portrait of Sir Walter Scott, novelist",
            image_url: "https://upload.wikimedia.org/wikipedia/commons/c/cd/e2e-historical-homonym.jpg",
            page_url: "https://commons.wikimedia.org/wiki/File:Sir_Walter_Scott_19th_century.jpg",
            license: "Public domain",
            author: "Unknown",
            description: "19th century engraving of the Scottish novelist"
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
        text = [hit.title, hit.description, hit.image_url, hit.page_url]
        hit.likely_mugshot = MugshotClassifier.call(
          text: [hit.title, hit.description, hit.author]
        ).likely_mugshot
        homonym = HomonymDetector.call(text: text, case_year: @case_year)
        hit.likely_homonym = homonym.likely_homonym
        hit
      end
    end
  end
end
