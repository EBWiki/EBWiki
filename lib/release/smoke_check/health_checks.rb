# frozen_string_literal: true

module Release
  class SmokeCheck
    # Validates /health reflects Postgres search (no Elasticsearch probe).
    module HealthChecks
      def verify_postgres_search_path
        response = fetch('/health')
        assert_ok!(:postgres_search_path, response, '/health did not return HTTP 200')

        checks = JSON.parse(response.body).fetch('checks', {})
        assert_postgres_checks!(checks)
        assert_no_elasticsearch_check!(checks)
      end

      private

      def assert_postgres_checks!(checks)
        %w[postgres redis].each do |name|
          message = "/health is missing the #{name} check"
          assert_includes!(:postgres_search_path, checks.keys, name, message)
        end
      end

      def assert_no_elasticsearch_check!(checks)
        return unless checks.key?('elasticsearch')

        raise SmokeCheckFailure.new(
          :postgres_search_path,
          '/health still exposes an Elasticsearch check; Postgres search path is not active'
        )
      end
    end
  end
end
