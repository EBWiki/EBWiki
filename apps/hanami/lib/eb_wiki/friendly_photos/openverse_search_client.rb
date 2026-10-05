# frozen_string_literal: true

require "eb_wiki/friendly_photos/hit"
require "eb_wiki/friendly_photos/remote_get"

module EbWiki
  module FriendlyPhotos
    class OpenverseSearchClient
      OPENVERSE_API = "https://api.openverse.org/v1/images/"

      def initialize(http: RemoteGet.new)
        @http = http
      end

      def search(query)
        data = @http.get_json(OPENVERSE_API, {q: query, page_size: "6", license_type: "all"})
        Array(data["results"]).filter_map do |result|
          Hit.new(
            source: "openverse",
            title: result["title"],
            image_url: result["url"],
            page_url: result["foreign_landing_url"] || result["url"],
            license: result["license"],
            author: result["creator"],
            description: result["title"]
          )
        end
      end
    end
  end
end
