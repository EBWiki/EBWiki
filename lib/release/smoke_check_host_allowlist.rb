# frozen_string_literal: true

require 'uri'

require_relative 'plain'

module Release
  # Restricts smoke-check targets to known EBWiki HTTPS URLs.
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
      uri = parse_uri(base_url)
      return false unless uri
      return false unless secure_https_url!(uri)
      return false unless host_allowlisted!(uri)

      true
    end

    def parse_uri(base_url)
      URI.parse(base_url.to_s)
    rescue URI::InvalidURIError
      warn 'Smoke check base URL is invalid.'
      nil
    end

    def secure_https_uri?(uri)
      uri.scheme == 'https' &&
        Plain.blank?(uri.user) && Plain.blank?(uri.password) &&
        uri.port == uri.default_port
    end

    def secure_https_url!(uri)
      unless uri.scheme == 'https'
        warn 'Smoke check requires HTTPS.'
        return false
      end
      if Plain.present?(uri.user) || Plain.present?(uri.password)
        warn 'Smoke check URL must not include embedded credentials.'
        return false
      end
      unless uri.port == uri.default_port
        warn 'Smoke check URL must use the default HTTPS port.'
        return false
      end

      true
    end

    def host_allowlisted!(uri)
      host = uri.host
      return true if Plain.present?(host) && allowed_hosts.include?(host)

      warn "Smoke check host #{host.inspect} is not allowlisted. " \
           "Set RELEASE_SMOKE_ALLOWED_HOSTS or use #{DEFAULT_HOSTS.join(' or ')}."
      false
    end
  end
end
