# frozen_string_literal: true

require 'json'

require_relative '../plain'
require_relative 'railway_graphql_client'

module Release
  class Rollback
    # Resolves the previous successful Railway deployment for staging rollback.
    class PreviousDeploymentResolver
      DEPLOYMENTS_QUERY = Plain.squish(<<~GQL)
        query Deployments($input: DeploymentListInput!, $first: Int!) {
          deployments(first: $first, input: $input) {
            edges { node { id status createdAt } }
          }
        }
      GQL

      def initialize(client: RailwayGraphqlClient.new)
        @client = client
      end

      def resolve!(token:, project_id:, service_id:, environment_id:, skip_current: true)
        response = @client.post(
          token: token,
          query: DEPLOYMENTS_QUERY,
          variables: {
            first: 10,
            input: {
              projectId: project_id,
              serviceId: service_id,
              environmentId: environment_id,
              status: { in: ['SUCCESS'] }
            }
          }
        )
        ids = deployment_ids(response)
        raise RollbackError, 'No successful Railway deployments found to roll back to.' if ids.empty?

        target = skip_current && ids.length > 1 ? ids[1] : ids.first
        raise RollbackError, 'Only one successful deployment exists; set RAILWAY_ROLLBACK_DEPLOYMENT_ID explicitly.' if Plain.blank?(target)

        target
      end

      private

      def deployment_ids(response)
        body = JSON.parse(response.body.to_s)
        @client.raise_graphql_errors!(body)
        body.fetch('data', {}).fetch('deployments', {}).fetch('edges', []).filter_map do |edge|
          edge.dig('node', 'id')
        end
      rescue JSON::ParserError => e
        raise RollbackError, "Railway API returned invalid JSON (#{e.message})"
      end
    end
  end
end
