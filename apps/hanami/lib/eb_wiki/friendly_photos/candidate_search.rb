# frozen_string_literal: true

require "json"
require "net/http"
require "uri"
require "eb_wiki/friendly_photos/hit"
require "eb_wiki/friendly_photos/source_policy"

module EbWiki
  module FriendlyPhotos
    # Finds openly licensed portraits. Sources are locked: Commons, Wikipedia, Openverse.
    class CandidateSearch
      USER_AGENT = "EBWikiHanamiPhotos/1.0 (https://ebwiki.org; info@ebwiki.org)"
      COMMONS_API = "https://commons.wikimedia.org/w/api.php"
      WIKIPEDIA_API = "https://en.wikipedia.org/w/api.php"
      OPENVERSE_API = "https://api.openverse.org/v1/images/"
      MUGSHOT_TEXT = /mugshot|booking.?photo|jail|inmate|arrest|sheriff/i
      TIMEOUT = 8

      def initialize(name:, city: nil)
        @name = name.to_s.strip
        @city = city.to_s.strip
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
        wikipedia_hits(query) + commons_hits(query) + openverse_hits(query)
      rescue
        []
      end

      def wikipedia_hits(query)
        data = get_json(WIKIPEDIA_API, {
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
        data = get_json(COMMONS_API, {
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

      def openverse_hits(query)
        data = get_json(OPENVERSE_API, {q: query, page_size: "6", license_type: "all"})
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

      def get_json(url, params)
        uri = URI(url)
        uri.query = URI.encode_www_form(params)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.open_timeout = TIMEOUT
        http.read_timeout = TIMEOUT
        request = Net::HTTP::Get.new(uri)
        request["User-Agent"] = USER_AGENT
        response = http.request(request)
        return {} unless response.is_a?(Net::HTTPSuccess)

        JSON.parse(response.body)
      rescue JSON::ParserError, SocketError, Timeout::Error, Errno::ECONNREFUSED
        {}
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
