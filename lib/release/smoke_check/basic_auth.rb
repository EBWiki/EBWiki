# frozen_string_literal: true

require 'uri'

require_relative '../plain'

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
        host = URI.parse(@base_url.to_s).host
        host == staging_host_name
      rescue URI::InvalidURIError
        false
      end

      def staging_host_name
        ENV.fetch('RELEASE_SMOKE_STAGING_HOST', STAGING_HOST)
      end
    end
  end
end
