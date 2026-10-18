# frozen_string_literal: true

require 'cgi'
require 'json'
require 'logger'
require 'openssl'

require_relative 'plain'

module Release
  # Verifies a deployed environment serves pages and Postgres-backed search.
  class SmokeCheck
    include HealthChecks
    include SearchRequests
    include BasicAuth
    include FailureReporting

    DEFAULT_SEARCH_TERM = '*'
    JUNK_SEARCH_TERM = 'ebwiki_smoke_check_no_results_xyz'
    NETWORK_ERRORS = [
      JSON::ParserError,
      OpenSSL::SSL::SSLError,
      SocketError,
      SystemCallError,
      Timeout::Error,
      Net::OpenTimeout,
      Net::ReadTimeout,
      Errno::ECONNREFUSED,
      Errno::ETIMEDOUT
    ].freeze

    def initialize(
      base_url:,
      http_client: nil,
      search_term: nil,
      logger: nil,
      error_reporter: Release::ErrorReporter
    )
      @base_url = normalize_base_url(base_url)
      @log_base_url = UrlSanitizer.for_log(@base_url)
      @http_client = http_client || default_http_client
      @search_term = Plain.presence(search_term) || ENV.fetch(
        'RELEASE_SMOKE_SEARCH_TERM',
        DEFAULT_SEARCH_TERM
      )
      @logger = logger || Logger.new($stderr)
      @error_reporter = error_reporter
    end

    def call
      steps.each { |step| run_step(step) }
      log_success
      true
    rescue SmokeCheckFailure => e
      report_failure(e)
      false
    end

    private

    def steps
      %i[home_page known_search empty_search postgres_search_path]
    end

    def run_step(step)
      case step
      when :home_page then verify_home_page
      when :known_search then verify_known_search
      when :empty_search then verify_empty_search
      when :postgres_search_path then verify_postgres_search_path
      else
        raise ArgumentError, "unknown smoke step #{step}"
      end
    rescue *NETWORK_ERRORS => e
      raise SmokeCheckFailure.new(step, "HTTP request failed: #{e.message}")
    end

    def fetch(path, step:)
      url = "#{@base_url}#{path}"
      @http_client.get(url).tap { |response| log_step(path, response.status) }
    rescue *NETWORK_ERRORS => e
      raise SmokeCheckFailure.new(step, "HTTP request failed: #{e.message}")
    end

    def assert_ok!(step, response, message)
      return if response.status == 200

      raise SmokeCheckFailure.new(step, "#{message} (got #{response.status})")
    end

    def assert_includes!(step, haystack, needle, message)
      return if haystack.to_s.include?(needle)

      raise SmokeCheckFailure.new(step, message)
    end

    def refute_includes!(step, haystack, needle, message)
      return unless haystack.to_s.include?(needle)

      raise SmokeCheckFailure.new(step, message)
    end

    def normalize_base_url(url)
      normalized = url.to_s.strip.chomp('/')
      raise ArgumentError, 'base URL is required' if Plain.blank?(normalized)

      normalized
    end
  end
end
