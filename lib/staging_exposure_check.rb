# frozen_string_literal: true

require_relative 'staging_exposure_check/http_client'

# Verifies EBWiki staging is not reachable on public Railway URLs and that
# staging.ebwiki.org is gated by Cloudflare Access (see docs/staging-access.md).
module StagingExposureCheck
  class CheckFailed < StandardError; end

  DEFAULT_RAILWAY_URL = 'https://ebwiki-web-production-cc7e.up.railway.app'
  DEFAULT_STAGING_URL = 'https://staging.ebwiki.org'
  CF_ACCESS_CLIENT_ID_ENV = 'CF-Access-Client-Id'
  CF_ACCESS_CLIENT_SECRET_ENV = 'CF-Access-Client-Secret'

  module_function

  def call(
    railway_urls:,
    staging_url:,
    cf_access_client_id:,
    cf_access_client_secret:,
    http: nil
  )
    http ||= HttpClient.new.method(:request)

    Array(railway_urls).each { |url| check_railway_url!(url, http) }
    check_staging_public_gate!(staging_url, http)
    check_staging_up_with_service_token!(
      staging_url,
      cf_access_client_id,
      cf_access_client_secret,
      http
    )
  end

  def check_railway_url!(url, http)
    response = http.call(url, headers: {}, method: :get, follow_redirects: false)
    return unless response.answered?
    return if response.code.to_i == 404

    raise CheckFailed,
          "Railway URL still answers on the public internet: #{url} (HTTP #{response.code})"
  end

  def check_staging_public_gate!(staging_base_url, http)
    root = normalize_base_url(staging_base_url)
    response = http.call("#{root}/", headers: {}, method: :get, follow_redirects: false)

    unless response.answered?
      raise CheckFailed, "Could not reach staging hostname at #{root}/ (no response)"
    end

    code = response.code.to_i
    return if [401, 403].include?(code)
    return if cloudflare_access_redirect?(response)

    raise CheckFailed, "Staging root is not gated by Cloudflare Access (HTTP #{code})"
  end

  def check_staging_up_with_service_token!(staging_base_url, client_id, client_secret, http)
    ensure_service_token_present!(client_id, client_secret)

    root = normalize_base_url(staging_base_url)
    response = http.call(
      "#{root}/up",
      headers: token_headers(client_id, client_secret),
      method: :get,
      follow_redirects: false
    )

    ensure_up_response!(root, response)
  end

  def ensure_service_token_present!(client_id, client_secret)
    return unless client_id.to_s.strip.empty? || client_secret.to_s.strip.empty?

    raise CheckFailed,
          'Missing Cloudflare Access service token env vars ' \
          "(set #{CF_ACCESS_CLIENT_ID_ENV} and #{CF_ACCESS_CLIENT_SECRET_ENV})"
  end

  def ensure_up_response!(root, response)
    unless response.answered?
      raise CheckFailed, "Could not reach #{root}/up with service token headers (no response)"
    end

    code = response.code.to_i
    return if [200, 401].include?(code)

    raise CheckFailed,
          "Staging /up with service token did not return 200 or basic-auth 401 (HTTP #{code})"
  end

  def cloudflare_access_redirect?(response)
    code = response.code.to_i
    return false unless [301, 302, 303, 307, 308].include?(code)

    location = response.headers['location']
    return false if location.to_s.strip.empty?

    host = URI.parse(location).host.to_s
    host.end_with?('.cloudflareaccess.com')
  rescue URI::InvalidURIError
    false
  end

  def normalize_base_url(url)
    url.to_s.delete_suffix('/')
  end

  def token_headers(client_id, client_secret)
    {
      CF_ACCESS_CLIENT_ID_ENV => client_id,
      CF_ACCESS_CLIENT_SECRET_ENV => client_secret
    }
  end
end
