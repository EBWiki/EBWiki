# frozen_string_literal: true

require 'json'

require_relative '../plain'
require_relative 'railway_graphql_client'

module Release
  class Rollback
    # Resolves default Railway staging rollback targets from the API.
    class StagingContext
      DEFAULT_SERVICE = 'ebwiki'
      DEFAULT_ENVIRONMENT = 'production'
      DEFAULT_PROJECT = 'ebwiki'

      PROJECTS_QUERY = Plain.squish(<<~GQL)
        query {
          projects {
            edges {
              node {
                id
                name
                environments { edges { node { id name } } }
                services { edges { node { id name } } }
              }
            }
          }
        }
      GQL

      def initialize(client: RailwayGraphqlClient.new)
        @client = client
      end

      def ids_for!(token:, service_name: DEFAULT_SERVICE, environment_name: DEFAULT_ENVIRONMENT,
                   project_name: DEFAULT_PROJECT)
        project = find_project(parse_projects(token), project_name)
        {
          project_id: project.fetch('id'),
          service_id: find_service(project, service_name),
          environment_id: find_environment(project, environment_name)
        }
      end

      def parse_projects(token)
        response = @client.post(token: token, query: PROJECTS_QUERY, variables: {})
        body = JSON.parse(response.body.to_s)
        @client.raise_graphql_errors!(body)
        body
      rescue JSON::ParserError => e
        raise RollbackError, "Railway API returned invalid JSON (#{e.message})"
      end

      private

      def project_nodes(body)
        body.fetch('data', {}).fetch('projects', {}).fetch('edges', []).filter_map do |edge|
          edge['node']
        end
      end

      def find_project(body, name)
        node = project_nodes(body).find { |project| project['name'] == name }
        raise RollbackError, "Railway project #{name.inspect} not found." if Plain.blank?(node)

        node
      end

      def find_service(project, name)
        services = project.fetch('services', {}).fetch('edges', []).filter_map do |edge|
          edge['node']
        end
        id = services.find { |service| service['name'] == name }&.fetch('id', nil)
        raise RollbackError, "Railway service #{name.inspect} not found." if Plain.blank?(id)

        id
      end

      def find_environment(project, name)
        environments = project.fetch('environments', {}).fetch('edges', []).filter_map do |edge|
          edge['node']
        end
        id = environments.find { |env| env['name'] == name }&.fetch('id', nil)
        raise RollbackError, "Railway environment #{name.inspect} not found." if Plain.blank?(id)

        id
      end
    end
  end
end
