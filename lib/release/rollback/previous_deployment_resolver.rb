# frozen_string_literal: true

require 'json'

require_relative '../plain'
require_relative 'railway_graphql_client'

module Release
  class Rollback
    # Finds the deployment a staging rollback should restore: the newest deployment
    # older than the live one that Railway still allows rolling back to.
    #
    # Railway marks a replaced deployment REMOVED, so the live deployment is usually the
    # only SUCCESS one. The candidates are REMOVED (or SUCCESS) deployments with canRollback.
    class PreviousDeploymentResolver
      LOOKBACK = 50
      CANDIDATE_STATUSES = %w[SUCCESS REMOVED].freeze

      DEPLOYMENTS_QUERY = Plain.squish(<<~GQL)
        query Deployments($input: DeploymentListInput!, $first: Int!) {
          deployments(first: $first, input: $input) {
            edges { node { id status canRollback createdAt } }
          }
        }
      GQL

      def initialize(client: RailwayGraphqlClient.new)
        @client = client
      end

      def resolve!(token:, project_id:, service_id:, environment_id:)
        ids = { projectId: project_id, serviceId: service_id, environmentId: environment_id }
        nodes = newest_first(deployment_nodes(@client.post(token: token, query: DEPLOYMENTS_QUERY,
                                                           variables: variables(ids))))
        pick_target(nodes)
      end

      private

      def variables(ids)
        { first: LOOKBACK, input: ids.merge(status: { in: CANDIDATE_STATUSES }) }
      end

      def pick_target(nodes)
        live_index = nodes.index { |node| node['status'] == 'SUCCESS' }
        raise RollbackError, 'No live (SUCCESS) Railway deployment found.' if live_index.nil?

        target = nodes.drop(live_index + 1).find { |node| node['canRollback'] == true }
        return target.fetch('id') if target

        raise RollbackError, 'No earlier Railway deployment can be rolled back to; ' \
                             'set RAILWAY_ROLLBACK_DEPLOYMENT_ID explicitly.'
      end

      def deployment_nodes(response)
        body = JSON.parse(response.body.to_s)
        @client.raise_graphql_errors!(body)
        edges = body.dig('data', 'deployments', 'edges')
        raise RollbackError, 'Railway API returned no deployment list.' unless edges.is_a?(Array)

        edges.filter_map { |edge| edge['node'] if edge.is_a?(Hash) && edge['node'].is_a?(Hash) }
      rescue JSON::ParserError => e
        raise RollbackError, "Railway API returned invalid JSON (#{e.message})"
      end

      def newest_first(nodes)
        nodes.sort_by { |node| node['createdAt'].to_s }.reverse
      end
    end
  end
end
