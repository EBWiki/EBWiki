# frozen_string_literal: true

require_relative 'staging_exposure_check/cloudflare_access'
require_relative 'staging_exposure_check/http_client'
require_relative 'staging_exposure_check/railway_urls'

# Verifies EBWiki staging is not reachable on public Railway URLs and that
# staging.ebwiki.org is gated by Cloudflare Access (see docs/staging-access.md).
module StagingExposureCheck
  class CheckFailed < StandardError; end

  DEFAULT_RAILWAY_URL = 'https://ebwiki-web-production-cc7e.up.railway.app'
  DEFAULT_STAGING_URL = 'https://staging.ebwiki.org'
  HEALTH_PATH = '/up'

  CF_ACCESS_CLIENT_ID_ENV = 'CF_ACCESS_CLIENT_ID'
  CF_ACCESS_CLIENT_SECRET_ENV = 'CF_ACCESS_CLIENT_SECRET'
  CF_ACCESS_CLIENT_ID_HEADER = 'CF-Access-Client-Id'
  CF_ACCESS_CLIENT_SECRET_HEADER = 'CF-Access-Client-Secret'

  module_function

  def resolve_railway_urls(argv:, env_railway_urls:)
    RailwayUrls.resolve(argv: argv, env_railway_urls: env_railway_urls)
  end

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
    check_staging_health_with_service_token!(
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

    return if CloudflareAccess.present?(response)
    return raise_app_basic_auth_failure! if CloudflareAccess.staging_app_basic_auth_only?(response)

    raise CheckFailed, "Staging root is not gated by Cloudflare Access (HTTP #{response.code.to_i})"
  end

  def check_staging_health_with_service_token!(staging_base_url, client_id, client_secret, http)
    ensure_service_token_present!(client_id, client_secret)

    root = normalize_base_url(staging_base_url)
    health_url = "#{root}#{HEALTH_PATH}"
    response = http.call(
      health_url,
      headers: token_headers(client_id, client_secret),
      method: :get,
      follow_redirects: false
    )

    ensure_health_response!(health_url, response)
  end

  def ensure_service_token_present!(client_id, client_secret)
    return unless client_id.to_s.strip.empty? || client_secret.to_s.strip.empty?

    raise CheckFailed,
          'Missing Cloudflare Access service token env vars ' \
          "(set #{CF_ACCESS_CLIENT_ID_ENV} and #{CF_ACCESS_CLIENT_SECRET_ENV})"
  end

  def ensure_health_response!(health_url, response)
    unless response.answered?
      raise CheckFailed, "Could not reach #{health_url} with service token headers (no response)"
    end

    code = response.code.to_i
    return if code == 200

    raise CheckFailed,
          "Staging #{HEALTH_PATH} with service token did not return 200 (HTTP #{code})"
  end

  def cloudflare_access_redirect?(response)
    CloudflareAccess.redirect?(response)
  end

  def cloudflare_access_present?(response)
    CloudflareAccess.present?(response)
  end

  def staging_app_basic_auth_only?(response)
    CloudflareAccess.staging_app_basic_auth_only?(response)
  end

  def normalize_base_url(url)
    url.to_s.delete_suffix('/')
  end

  def token_headers(client_id, client_secret)
    {
      CF_ACCESS_CLIENT_ID_HEADER => client_id,
      CF_ACCESS_CLIENT_SECRET_HEADER => client_secret
    }
  end

  def raise_app_basic_auth_failure!
    raise CheckFailed,
          'Staging root returned app basic auth (401) but not Cloudflare Access ' \
          '(missing Access redirect or Cloudflare Access response markers)'
  end
  private_class_method :raise_app_basic_auth_failure!
end
