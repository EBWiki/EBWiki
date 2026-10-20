# frozen_string_literal: true

require 'json'

require_relative '../plain'
require_relative 'railway_graphql_client'
require_relative 'railway_deployment_verifier'

module Release
  class Rollback
    # Railway public GraphQL API (deploymentRollback mutation).
    class RailwayApi
      ROLLBACK_MUTATION = Plain.squish(<<~GQL)
        mutation DeploymentRollback($id: String!) {
          deploymentRollback(id: $id)
        }
      GQL

      def self.perform_rollback(
        deployment_id:,
        service_name:,
        environment_name:,
        token: ENV.fetch('RAILWAY_TOKEN', nil),
        http: Net::HTTP
      )
        new(http: http).perform_rollback(
          deployment_id: deployment_id,
          service_name: service_name,
          environment_name: environment_name,
          token: token
        )
      end

      def initialize(http: Net::HTTP)
        @client = RailwayGraphqlClient.new(http: http)
        @verifier = RailwayDeploymentVerifier.new(client: @client)
      end

      def perform_rollback(deployment_id:, service_name:, environment_name:, token:)
        ensure_token!(token)
        ensure_deployment_matches!(deployment_id, service_name, environment_name, token)
        invoke_rollback!(deployment_id, token)
      end

      def ensure_token!(token)
        return if Plain.present?(token)

        raise RollbackError, 'Set RAILWAY_TOKEN before rolling back on Railway.'
      end

      def ensure_deployment_matches!(deployment_id, service_name, environment_name, token)
        deployment = @verifier.fetch!(deployment_id: deployment_id, token: token)
        @verifier.verify!(
          deployment,
          service_name: service_name,
          environment_name: environment_name
        )
      end

      def invoke_rollback!(deployment_id, token)
        response = @client.post(
          token: token,
          query: ROLLBACK_MUTATION,
          variables: { id: deployment_id }
        )
        parse_mutation_success!(response)
      end

      private

      def parse_mutation_success!(response)
        body = JSON.parse(response.body.to_s)
        @client.raise_graphql_errors!(body)
        return if body.dig('data', 'deploymentRollback')

        raise RollbackError, 'Railway rollback failed: deploymentRollback returned false'
      rescue JSON::ParserError => e
        raise RollbackError, "Railway rollback failed: invalid JSON (#{e.message})"
      end
    end
  end
end
