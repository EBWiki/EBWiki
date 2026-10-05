# frozen_string_literal: true

require "uri"
require "eb_wiki/friendly_photos/hit"
require "eb_wiki/friendly_photos/remote_get"

module EbWiki
  module FriendlyPhotos
    class WikimediaSearchClient
      COMMONS_API = "https://commons.wikimedia.org/w/api.php"
      WIKIPEDIA_API = "https://en.wikipedia.org/w/api.php"

      def initialize(http: RemoteGet.new)
        @http = http
      end

      def search(query)
        wikipedia_hits(query) + commons_hits(query)
      end

      private

      def wikipedia_hits(query)
        data = @http.get_json(WIKIPEDIA_API, {
          action: "query",
          format: "json",
          generator: "search",
          gsrsearch: query,
          gsrlimit: "5",
          prop: "pageimages|info",
          piprop: "original",
          inprop: "url"
        })
        pages = data.dig("query", "pages") || {}
        pages.values.filter_map do |page|
          image = page.dig("original", "source")
          next unless image

          Hit.new(
            source: "wikipedia",
            title: page["title"],
            image_url: image,
            page_url: page["fullurl"] || "https://en.wikipedia.org/wiki/#{URI.encode_www_form_component(page["title"])}",
            license: "Wikipedia / Commons",
            author: nil,
            description: page["title"]
          )
        end
      end

      def commons_hits(query)
        data = @http.get_json(COMMONS_API, {
          action: "query",
          format: "json",
          generator: "search",
          gsrsearch: query,
          gsrnamespace: "6",
          gsrlimit: "8",
          prop: "imageinfo",
          iiprop: "url|extmetadata"
        })
        pages = data.dig("query", "pages") || {}
        pages.values.filter_map do |page|
          info = Array(page["imageinfo"]).first
          next unless info && info["url"]

          meta = info["extmetadata"] || {}
          Hit.new(
            source: "wikimedia_commons",
            title: page["title"],
            image_url: info["url"],
            page_url: info["descriptionurl"] || "https://commons.wikimedia.org/wiki/#{URI.encode_www_form_component(page["title"])}",
            license: meta.dig("LicenseShortName", "value"),
            author: meta.dig("Artist", "value"),
            description: meta.dig("ImageDescription", "value")
          )
        end
      end
    end
  end
end
