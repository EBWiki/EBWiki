# frozen_string_literal: true

require 'json'
require 'net/http'

module Release
  class Rollback
    # Railway public GraphQL API (deploymentRollback mutation).
    class RailwayApi
      ENDPOINT = URI('https://backboard.railway.com/graphql/v2')
      MUTATION = <<~GQL.squish
        mutation DeploymentRollback($id: String!) {
          deploymentRollback(id: $id)
        }
      GQL

      def self.rollback!(deployment_id:, token: ENV.fetch('RAILWAY_TOKEN', nil), http: Net::HTTP)
        new(http: http).rollback!(deployment_id: deployment_id, token: token)
      end

      def initialize(http: Net::HTTP)
        @http = http
      end

      def rollback!(deployment_id:, token:)
        raise RollbackError, 'Set RAILWAY_TOKEN before rolling back on Railway.' if token.blank?

        response = post_graphql(token: token, deployment_id: deployment_id)
        parse_success!(response)
        true
      end

      private

      def post_graphql(token:, deployment_id:)
        request = Net::HTTP::Post.new(ENDPOINT)
        request['Authorization'] = "Bearer #{token}"
        request['Content-Type'] = 'application/json'
        request.body = {
          query: MUTATION,
          variables: { id: deployment_id }
        }.to_json

        @http.start(ENDPOINT.host, ENDPOINT.port, use_ssl: true) do |http|
          http.request(request)
        end
      end

      def parse_success!(response)
        body = JSON.parse(response.body.to_s)
        if body['errors'].present?
          message = body['errors'].map { |entry| entry['message'] }.join('; ')
          raise RollbackError, "Railway rollback failed: #{message}"
        end
        return if body.dig('data', 'deploymentRollback')

        raise RollbackError, 'Railway rollback failed: deploymentRollback returned false'
      rescue JSON::ParserError => e
        raise RollbackError, "Railway rollback failed: invalid JSON (#{e.message})"
      end
    end
  end
end
