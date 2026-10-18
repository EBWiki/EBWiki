# frozen_string_literal: true

require_relative '../plain'

module Release
  class SmokeCheck
    module BasicAuth
      private

      def default_http_client
        Release::HttpClient.new(basic_auth: basic_auth_credentials)
      end

      def basic_auth_credentials
        username = Plain.env_presence('RELEASE_SMOKE_BASIC_AUTH_USERNAME')
        username ||= Plain.env_presence('STAGING_USERNAME')
        password = Plain.env_presence('RELEASE_SMOKE_BASIC_AUTH_PASSWORD')
        password ||= Plain.env_presence('STAGING_PASSWORD')
        return if Plain.blank?(username) || Plain.blank?(password)

        { username: username, password: password }
      end
    end
  end
end
