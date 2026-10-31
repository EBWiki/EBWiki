# frozen_string_literal: true

require 'uri'

require_relative '../plain'
require_relative '../smoke_check_host_allowlist'

module Release
  class SmokeCheck
    module BasicAuth
      STAGING_HOST = 'staging.ebwiki.org'

      private

      def default_http_client
        Release::HttpClient.new(basic_auth: basic_auth_credentials)
      end

      def basic_auth_credentials
        return unless staging_host?

        username = Plain.env_presence('RELEASE_SMOKE_BASIC_AUTH_USERNAME')
        username ||= Plain.env_presence('STAGING_USERNAME')
        password = Plain.env_presence('RELEASE_SMOKE_BASIC_AUTH_PASSWORD')
        password ||= Plain.env_presence('STAGING_PASSWORD')
        return if Plain.blank?(username) || Plain.blank?(password)

        { username: username, password: password }
      end

      def staging_host?
        uri = SmokeCheckHostAllowlist.parse_uri(@base_url.to_s)
        return false unless uri
        return false unless SmokeCheckHostAllowlist.secure_https_uri?(uri)

        uri.host == staging_host_name
      end

      def staging_host_name
        STAGING_HOST
      end
    end
  end
end
