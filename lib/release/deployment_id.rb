# frozen_string_literal: true

module Release
  # Validates Railway deployment ids before rollback.
  module DeploymentId
    UUID_PATTERN = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i

    module_function

    def validate!(value)
      id = value.to_s
      return id if id.match?(UUID_PATTERN)

      raise RollbackError, "RAILWAY_ROLLBACK_DEPLOYMENT_ID #{id.inspect} is not a UUID."
    end
  end
end
