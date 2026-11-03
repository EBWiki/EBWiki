# frozen_string_literal: true

module StagingExposureCheck
  module CloudflareAccess
    module_function

    def present?(response)
      redirect?(response) || response_marker?(response)
    end

    def redirect?(response)
      code = response.code.to_i
      return false unless [301, 302, 303, 307, 308].include?(code)

      location = response.headers['location']
      return false if location.to_s.strip.empty?

      host = URI.parse(location).host.to_s
      host.end_with?('.cloudflareaccess.com')
    rescue URI::InvalidURIError
      false
    end

    def response_marker?(response)
      response.headers.any? do |key, _value|
        normalized = key.to_s.downcase
        normalized.start_with?('cf-access') || normalized == 'cf-middleware-access'
      end || access_set_cookie?(response)
    end

    def access_set_cookie?(response)
      cookie = response.headers['set-cookie'].to_s
      cookie.match?(/CF_Authorization|CF_AppSession|cloudflareaccess/i)
    end

    def staging_app_basic_auth_only?(response)
      return false unless response.code.to_i == 401

      www_auth = response.headers['www-authenticate'].to_s
      www_auth.match?(/\ABasic\b/i) && www_auth.include?('Staging')
    end
  end
end
