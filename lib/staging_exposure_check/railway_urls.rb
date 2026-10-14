# frozen_string_literal: true

module StagingExposureCheck
  module RailwayUrls
    module_function

    def resolve(argv:, env_railway_urls:)
      return argv if argv.any?
      return [StagingExposureCheck::DEFAULT_RAILWAY_URL] if env_railway_urls.nil?

      urls = env_railway_urls.split(',').map(&:strip).reject(&:empty?)
      if urls.empty?
        raise StagingExposureCheck::CheckFailed,
              'STAGING_EXPOSURE_RAILWAY_URLS is set but contains no URLs ' \
              "(use a comma-separated list or unset it to use #{StagingExposureCheck::DEFAULT_RAILWAY_URL})"
      end

      urls
    end
  end
end
