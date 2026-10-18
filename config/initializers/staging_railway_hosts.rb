# frozen_string_literal: true

if Rails.env.staging?
  require Rails.root.join('lib/staging_railway_hosts')
  StagingRailwayHosts.configure!(Rails.application.config)
end
