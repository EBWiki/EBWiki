# frozen_string_literal: true

require 'net/http'
require 'json'

module Release
  # Minimal HTTP GET client for post-deploy smoke checks.
  class HttpClient
    Response = Data.define(:status, :body, :headers)

    def initialize(basic_auth: nil, open_timeout: 10, read_timeout: 30)
      @basic_auth = basic_auth
      @open_timeout = open_timeout
      @read_timeout = read_timeout
    end

    def get(url)
      uri = URI.parse(url)
      perform_get(uri, build_request(uri))
    end

    private

    def build_request(uri)
      Net::HTTP::Get.new(uri).tap { |request| apply_basic_auth(request) }
    end

    def perform_get(uri, request)
      Net::HTTP.start(
        uri.host,
        uri.port,
        use_ssl: uri.scheme == 'https',
        open_timeout: @open_timeout,
        read_timeout: @read_timeout
      ) do |http|
        to_response(http.request(request))
      end
    end

    def to_response(response)
      Response.new(
        status: response.code.to_i,
        body: response.body.to_s,
        headers: response.to_hash
      )
    end

    def apply_basic_auth(request)
      return if @basic_auth.blank?

      request.basic_auth(@basic_auth.fetch(:username), @basic_auth.fetch(:password))
    end
  end
end
