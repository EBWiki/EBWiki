# frozen_string_literal: true

# Staging host allow-list from HOST (custom domain) and RAILWAY_PUBLIC_DOMAIN (Railway default).
module StagingRailwayHosts
  # When no hosts are configured, Rails treats an empty allow-list as "permit all".
  # This sentinel keeps host authorization enabled while denying every Host header.
  DENY_ALL_HOSTS = ->(_host) { false }.freeze

  module_function

  def configure!(
    app_config,
    host: ENV.fetch('HOST', nil),
    railway_public_domain: ENV.fetch('RAILWAY_PUBLIC_DOMAIN', nil)
  )
    allowed = [host, railway_public_domain].filter_map { |value| normalize_host(value) }.uniq

    if allowed.empty?
      app_config.hosts << DENY_ALL_HOSTS
    else
      allowed.each { |allowed_host| app_config.hosts << allowed_host }
    end

    app_config.host_authorization = {
      exclude: ->(request) { request.path == '/up' }
    }
  end

  def normalize_host(value)
    return nil if value.nil?

    stripped = value.to_s.strip
    stripped.empty? ? nil : stripped
  end
end
