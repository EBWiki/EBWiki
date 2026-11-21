# frozen_string_literal: true

require 'net/http'
require 'uri'

module StagingExposureCheck
  Response = Struct.new(:code, :headers, :error, keyword_init: true) do
    def answered?
      error.nil?
    end
  end

  class HttpClient
    def request(url, headers:, method: :get, follow_redirects: false)
      uri = URI.parse(url)
      response = perform_request(uri, headers, method)
      return build_response(response) unless follow_redirects && redirect?(response)

      location = response['location']
      return build_response(response) if location.to_s.strip.empty?

      request(location, headers: headers, method: method, follow_redirects: true)
    rescue StandardError => e
      Response.new(code: nil, headers: {}, error: e)
    end

    private

    def perform_request(uri, headers, method)
      Net::HTTP.start(uri.host, uri.port, **connection_options(uri)) do |connection|
        connection.max_retries = 0
        connection.request(build_request(uri, headers, method))
      end
    end

    def connection_options(uri)
      {
        use_ssl: uri.scheme == 'https',
        open_timeout: 10,
        read_timeout: 15
      }
    end

    def build_request(uri, headers, method)
      request_class = method == :head ? Net::HTTP::Head : Net::HTTP::Get
      request = request_class.new(uri)
      headers.each { |key, value| request[key] = value }
      request
    end

    def redirect?(response)
      [301, 302, 303, 307, 308].include?(response.code.to_i)
    end

    def build_response(response)
      normalized_headers = response.to_hash.transform_keys(&:downcase).transform_values do |value|
        Array(value).first
      end

      Response.new(code: response.code, headers: normalized_headers, error: nil)
    end
  end
end
