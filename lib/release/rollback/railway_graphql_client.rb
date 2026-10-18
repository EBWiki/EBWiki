# frozen_string_literal: true

require 'json'
require 'net/http'

require_relative '../plain'

module Release
  class Rollback
    # Low-level Railway GraphQL HTTP client.
    class RailwayGraphqlClient
      ENDPOINT = URI('https://backboard.railway.com/graphql/v2')

      def initialize(http: Net::HTTP)
        @http = http
      end

      def post(token:, query:, variables:)
        request = Net::HTTP::Post.new(ENDPOINT)
        request['Authorization'] = "Bearer #{token}"
        request['Content-Type'] = 'application/json'
        request.body = { query: query, variables: variables }.to_json

        @http.start(ENDPOINT.host, ENDPOINT.port, use_ssl: true) do |http|
          http.request(request)
        end
      end

      def raise_graphql_errors!(body)
        return if Plain.blank?(body['errors'])

        message = body['errors'].map { |entry| entry['message'] }.join('; ') # rubocop:disable Rails/Pluck
        raise RollbackError, "Railway API error: #{message}"
      end
    end
  end
end
