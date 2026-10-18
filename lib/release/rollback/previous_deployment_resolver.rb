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
        ids = deployment_ids(fetch_deployments(token, project_id, service_id, environment_id))
        ensure_deployments!(ids)
        pick_target(ids, skip_current: skip_current)
      end

      private

      def fetch_deployments(token, project_id, service_id, environment_id)
        @client.post(token: token, query: DEPLOYMENTS_QUERY, variables: deployment_variables(
          project_id, service_id, environment_id
        ))
      end

      def deployment_variables(project_id, service_id, environment_id)
        {
          first: 10,
          input: {
            projectId: project_id,
            serviceId: service_id,
            environmentId: environment_id,
            status: { in: ['SUCCESS'] }
          }
        }
      end

      def ensure_deployments!(ids)
        return if ids.any?

        raise RollbackError, 'No successful Railway deployments found to roll back to.'
      end

      def pick_target(ids, skip_current:)
        target = skip_current && ids.length > 1 ? ids[1] : ids.first
        return target if Plain.present?(target)

        msg = 'Only one successful deployment exists; set RAILWAY_ROLLBACK_DEPLOYMENT_ID explicitly.'
        raise RollbackError, msg
      end

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
