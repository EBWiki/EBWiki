# frozen_string_literal: true

module Release
  RailwayRollbackCommand = Data.define(
    :deployment_id,
    :service_name,
    :environment_slug,
    :description
  ) do
    def to_s
      description || "Railway deploymentRollback(#{deployment_id})"
    end
  end
end
