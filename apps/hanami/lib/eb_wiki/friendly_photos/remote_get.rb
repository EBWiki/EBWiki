# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

module EbWiki
  module FriendlyPhotos
    class RemoteGet
      USER_AGENT = "EBWikiHanamiPhotos/1.0 (https://ebwiki.org; info@ebwiki.org)"
      TIMEOUT = 8

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
    end
  end
end
