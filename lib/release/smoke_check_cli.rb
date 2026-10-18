# frozen_string_literal: true

require_relative 'plain'

module Release
  # Runs the HTTP smoke check without booting Rails.
  class SmokeCheckCli
    def self.system(*args)
      Kernel.system(*args)
    end

    def self.run(argv)
      new(argv).run
    end

    def initialize(argv)
      @argv = argv
    end

    def run
      RollbarSetup.configure!
      Release::SmokeCheck.new(base_url: resolve_base_url).call
    end

    private

    def resolve_base_url
      url = @argv.first
      url = ENV.fetch('RELEASE_SMOKE_BASE_URL', nil) if Plain.blank?(url)
      return url if Plain.present?(url)

      warn 'Set RELEASE_SMOKE_BASE_URL or pass the base URL as the first argument.'
      exit 1
    end
  end
end
