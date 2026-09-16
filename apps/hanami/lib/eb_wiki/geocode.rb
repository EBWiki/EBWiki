# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

module EbWiki
  # Looks up lat/lng via Nominatim. Tests skip the network unless GEOCODE=1.
  module Geocode
    USER_AGENT = "EBWikiHanami/1.0 (https://ebwiki.org; info@ebwiki.org)"
    ENDPOINT = "https://nominatim.openstreetmap.org/search"
    TIMEOUT = 5

    module_function

    def lookup(address:, city:, zipcode: nil)
      return if skip_network?

      query = [address, city, zipcode, "United States"].map { |part| part.to_s.strip }.reject(&:empty?).join(", ")
      return if query.empty? || city.to_s.strip.empty?

      uri = URI(ENDPOINT)
      uri.query = URI.encode_www_form(q: query, format: "json", limit: 1)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = TIMEOUT
      http.read_timeout = TIMEOUT
      request = Net::HTTP::Get.new(uri)
      request["User-Agent"] = USER_AGENT
      response = http.request(request)
      return unless response.is_a?(Net::HTTPSuccess)

      row = Array(JSON.parse(response.body)).first
      return unless row

      {latitude: Float(row["lat"]), longitude: Float(row["lon"])}
    rescue JSON::ParserError, SocketError, Timeout::Error, Errno::ECONNREFUSED, ArgumentError
      nil
    end

    def skip_network?
      return false if ENV["GEOCODE"] == "1"

      defined?(Hanami) && Hanami.env?(:test)
    end
  end
end
