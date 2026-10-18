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
        response = @client.post(token: token, query: PROJECTS_QUERY, variables: {})
        body = JSON.parse(response.body.to_s)
        @client.raise_graphql_errors!(body)
        project = find_project(body, project_name)
        service_id = find_service(project, service_name)
        environment_id = find_environment(project, environment_name)
        project_id = project.fetch('id')
        { project_id: project_id, service_id: service_id, environment_id: environment_id }
      rescue JSON::ParserError => e
        raise RollbackError, "Railway API returned invalid JSON (#{e.message})"
      end

      private

      def find_project(body, name)
        node = body.fetch('data', {}).fetch('projects', {}).fetch('edges', []).filter_map { |e| e['node'] }
                   .find { |p| p['name'] == name }
        raise RollbackError, "Railway project #{name.inspect} not found." if Plain.blank?(node)

        node
      end

      def find_service(project, name)
        id = project.fetch('services', {}).fetch('edges', []).filter_map { |e| e['node'] }
                    .find { |s| s['name'] == name }&.fetch('id', nil)
        raise RollbackError, "Railway service #{name.inspect} not found." if Plain.blank?(id)

        id
      end

      def find_environment(project, name)
        id = project.fetch('environments', {}).fetch('edges', []).filter_map { |e| e['node'] }
                    .find { |env| env['name'] == name }&.fetch('id', nil)
        raise RollbackError, "Railway environment #{name.inspect} not found." if Plain.blank?(id)

        id
      end
    end
  end
end
