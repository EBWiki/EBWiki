# frozen_string_literal: true

module Release
  class SmokeCheck
    module BasicAuth
      private

      def default_http_client
        Release::HttpClient.new(basic_auth: basic_auth_credentials)
      end

      def basic_auth_credentials
        username = ENV['RELEASE_SMOKE_BASIC_AUTH_USERNAME'].presence
        username ||= ENV['STAGING_USERNAME'].presence
        password = ENV['RELEASE_SMOKE_BASIC_AUTH_PASSWORD'].presence
        password ||= ENV['STAGING_PASSWORD'].presence
        return if username.blank? || password.blank?

        { username: username, password: password }
      end
    end
  end
end
