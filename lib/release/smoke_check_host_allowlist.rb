# frozen_string_literal: true

require 'uri'

require_relative 'plain'

module Release
  # Restricts smoke-check targets to known EBWiki hosts.
  module SmokeCheckHostAllowlist
    DEFAULT_HOSTS = %w[staging.ebwiki.org ebwiki.org].freeze

    module_function

    def allowed_hosts
      ENV.fetch('RELEASE_SMOKE_ALLOWED_HOSTS', DEFAULT_HOSTS.join(','))
         .split(',')
         .map(&:strip)
         .reject(&:empty?)
    end

    def permitted!(base_url)
      host = URI.parse(base_url.to_s).host
      return true if Plain.present?(host) && allowed_hosts.include?(host)

      warn "Smoke check host #{host.inspect} is not allowlisted. " \
           "Set RELEASE_SMOKE_ALLOWED_HOSTS or use #{DEFAULT_HOSTS.join(' or ')}."
      false
    rescue URI::InvalidURIError
      warn 'Smoke check base URL is invalid.'
      false
    end
  end
end
