# frozen_string_literal: true

require_relative 'plain'
require_relative 'deployment_id'
require_relative 'resource_name'

module Release
  # Validates Railway-specific rollback options.
  class RollbackRailwayValidator
    def self.validate!(options)
      new(options).validate!
    end

    def initialize(options)
      @options = options
    end

    def validate!
      validate_service!
      validate_environment!
      validate_deployment!
    end

    private

    def validate_service!
      if Plain.blank?(@options.service_name)
        raise RollbackError, 'Set RAILWAY_SERVICE before rolling back on Railway.'
      end

      ResourceName.validate!(@options.service_name, label: 'Railway service name')
    end

    def validate_environment!
      return if Plain.present?(@options.environment_slug)

      raise RollbackError, 'Set RAILWAY_ENVIRONMENT before rolling back on Railway.'
    end

    def validate_deployment!
      if Plain.blank?(@options.deployment_id)
        raise RollbackError, 'Set RAILWAY_ROLLBACK_DEPLOYMENT_ID to the deployment id to restore.'
      end

      DeploymentId.validate!(@options.deployment_id)
    end
  end
end
