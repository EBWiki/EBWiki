# frozen_string_literal: true

module Release
  RollbackOptions = Data.define(
    :platform,
    :service_name,
    :deployment_id,
    :environment_slug,
    :dry_run,
    :skip_confirm
  )
end
