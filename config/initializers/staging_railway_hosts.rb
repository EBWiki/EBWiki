# frozen_string_literal: true

# Staging host allow-list from HOST (custom domain) and RAILWAY_PUBLIC_DOMAIN (Railway default).
if Rails.env.staging?
  [
    ENV['HOST'].presence,
    ENV['RAILWAY_PUBLIC_DOMAIN'].presence
  ].compact.uniq.each do |host|
    Rails.application.config.hosts << host
  end

  Rails.application.config.host_authorization = {
    exclude: ->(request) { request.path == '/up' }
  }
end
