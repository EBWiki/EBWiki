# frozen_string_literal: true

require 'json'
require 'net/http'

require_relative '../plain'
require_relative '../error_reporter'

module Release
  class Rollback
    # Low-level Railway GraphQL HTTP client.
    class RailwayGraphqlClient
      ENDPOINT = URI('https://backboard.railway.com/graphql/v2')
      OPEN_TIMEOUT = 10
      READ_TIMEOUT = 30

      NETWORK_ERRORS = [
        IOError,
        Net::HTTPBadResponse,
        OpenSSL::SSL::SSLError,
        SocketError,
        SystemCallError,
        Timeout::Error
      ].freeze

      def initialize(http: Net::HTTP)
        @http = http
      end

      def post(token:, query:, variables:)
        request = build_request(token, query, variables)
        dispatch(request)
      rescue *NETWORK_ERRORS => e
        report_network_error(e)
        raise RollbackError, "Railway API request failed: #{e.message}"
      end

      def raise_graphql_errors!(body)
        return if Plain.blank?(body['errors'])

        message = body['errors'].map { |entry| entry['message'] }.join('; ') # rubocop:disable Rails/Pluck
        raise RollbackError, "Railway API error: #{message}"
      end

      private

      def build_request(token, query, variables)
        request = Net::HTTP::Post.new(ENDPOINT)
        request['Authorization'] = "Bearer #{token}"
        request['Content-Type'] = 'application/json'
        request.body = { query: query, variables: variables }.to_json
        request
      end

      def dispatch(request)
        @http.start(ENDPOINT.host, ENDPOINT.port,
                    use_ssl: true, open_timeout: OPEN_TIMEOUT, read_timeout: READ_TIMEOUT) do |http|
          http.request(request)
        end
      end

      def report_network_error(error)
        Release::ErrorReporter.report(
          event: 'release_rollback_network',
          message: error.message,
          context: { client: 'RailwayGraphqlClient', step: 'post' }
        )
      end
    end
  end
end
