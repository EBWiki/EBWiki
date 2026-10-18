# frozen_string_literal: true

require 'json'

require_relative '../plain'
require_relative 'railway_graphql_client'

module Release
  class Rollback
    # Confirms a Railway deployment belongs to the expected service and environment.
    class RailwayDeploymentVerifier
      DeploymentRecord = Data.define(:id, :service_name, :environment_name)

      DEPLOYMENT_QUERY = Plain.squish(<<~GQL)
        query Deployment($id: String!) {
          deployment(id: $id) {
            id
            environment { name }
            service { name }
          }
        }
      GQL

      def initialize(client: RailwayGraphqlClient.new)
        @client = client
      end

      def fetch!(deployment_id:, token:)
        response = @client.post(token: token, query: DEPLOYMENT_QUERY, variables: { id: deployment_id })
        parse_deployment_response(response)
      end

      def verify!(deployment, service_name:, environment_name:)
        unless deployment.service_name == service_name
          raise RollbackError,
                "Deployment belongs to service #{deployment.service_name.inspect}, " \
                "not #{service_name.inspect}."
        end
        return if deployment.environment_name == environment_name

        raise RollbackError,
              "Deployment belongs to environment #{deployment.environment_name.inspect}, " \
              "not #{environment_name.inspect}."
      end

      private

      def parse_deployment_response(response)
        body = JSON.parse(response.body.to_s)
        @client.raise_graphql_errors!(body)

        node = body.dig('data', 'deployment')
        raise RollbackError, 'Railway deployment not found.' if Plain.blank?(node)

        DeploymentRecord.new(
          id: node['id'],
          service_name: node.dig('service', 'name'),
          environment_name: node.dig('environment', 'name')
        )
      rescue JSON::ParserError => e
        raise RollbackError, "Railway API returned invalid JSON (#{e.message})"
      end
    end
  end
end
