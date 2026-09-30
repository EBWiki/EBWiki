# frozen_string_literal: true

require 'net/http'
require_relative 'cloud_storage/settings'

# Picks object storage for CarrierWave.
# AWS S3 is primary. An S3-compatible provider (Railway, R2, etc.) is used
# when AWS is unconfigured, unreachable, or fails at upload time.
class CloudStorage
  AWS = :aws
  FALLBACK = :fallback
  CONNECT_TIMEOUT = 2
  AWS_PROBE_URL = 'https://s3.amazonaws.com/'
  NETWORK_ERRORS = [
    Timeout::Error,
    SocketError,
    Errno::ECONNREFUSED,
    Errno::ECONNRESET,
    Errno::ETIMEDOUT
  ].freeze

  class << self
    def configure_carrierwave(config)
      apply(config, active_provider)
    end

    def active_provider
      return @forced_provider if @forced_provider

      case ENV.fetch('STORAGE_PROVIDER', nil).to_s.strip
      when 'aws' then AWS if aws_configured?
      when 'fallback' then FALLBACK if fallback_configured?
      else automatic_provider
      end
    end

    def switch_to_fallback(error)
      return if @forced_provider == FALLBACK
      return unless aws_error?(error) && fallback_configured?

      @forced_provider = FALLBACK
      CarrierWave.configure { |config| apply(config, FALLBACK) }
      FALLBACK
    end

    def reset!
      @forced_provider = nil
      @aws_reachable = nil
    end

    def aws_configured?
      filled?('AWS_ACCESS_KEY_ID', 'AWS_SECRET_KEY_ID', 'S3_BUCKET')
    end

    def fallback_configured?
      filled?(
        'FALLBACK_S3_ACCESS_KEY_ID', 'FALLBACK_S3_SECRET_ACCESS_KEY',
        'FALLBACK_S3_BUCKET', 'FALLBACK_S3_ENDPOINT'
      )
    end

    def aws_reachable?
      return @aws_reachable unless @aws_reachable.nil?

      @aws_reachable = ping_aws
    end

    private

    def automatic_provider
      return AWS if aws_configured? && (skip_probe? || aws_reachable?)
      return FALLBACK if fallback_configured?
      return AWS if aws_configured?

      nil
    end

    def apply(config, provider)
      settings = Settings.for(provider)
      unless settings
        config.storage = :file
        return
      end

      config.storage = :fog
      config.fog_public = settings[:public]
      config.fog_directory = settings[:directory]
      config.fog_credentials = settings[:fog]
    end

    def skip_probe?
      ENV.fetch('SECRET_KEY_BASE', nil) == 'build-time-dummy' ||
        ENV.fetch('SKIP_STORAGE_PROBE', nil) == 'true'
    end

    def ping_aws
      uri = URI(AWS_PROBE_URL)
      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = CONNECT_TIMEOUT
      http.read_timeout = CONNECT_TIMEOUT
      http.use_ssl = true
      http.request(Net::HTTP::Head.new(uri.request_uri)).code.to_i < 500
    rescue StandardError
      false
    end

    def aws_error?(error)
      NETWORK_ERRORS.any? { |klass| error.is_a?(klass) } ||
        error.class.name.start_with?('Excon', 'Fog')
    end

    def filled?(*keys)
      keys.all? { |key| ENV.fetch(key, nil).to_s.strip != '' }
    end
  end
end
