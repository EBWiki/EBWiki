# frozen_string_literal: true

require_relative 'plain'

module Release
  # Builds RollbackOptions from argv and environment variables.
  class RollbackOptionsBuilder
    ALLOWED_FLAGS = %w[--execute --yes].freeze

    def self.from_argv(argv)
      new(argv).build
    end

    def initialize(argv)
      @argv = argv
    end

    def build
      reject_unknown_flags!

      RollbackOptions.new(**options_hash)
    end

    private

    def options_hash
      flags = parse_flags(@argv)
      {
        platform: ENV.fetch('RELEASE_ROLLBACK_PLATFORM', detect_platform),
        service_name: Plain.env_presence('RAILWAY_SERVICE'),
        deployment_id: Plain.env_presence('RAILWAY_ROLLBACK_DEPLOYMENT_ID'),
        environment_slug: Plain.env_presence('RAILWAY_ENVIRONMENT'),
        dry_run: flags[:dry_run],
        skip_confirm: flags[:skip_confirm]
      }
    end

    def reject_unknown_flags!
      unknown = @argv.select { |arg| arg.start_with?('--') && ALLOWED_FLAGS.include?(arg) == false }
      raise RollbackError, "Unknown flag #{unknown.first}" if unknown.any?
    end

    def parse_flags(argv)
      argv.each_with_object(default_flags) do |arg, memo|
        case arg
        when '--execute' then memo[:dry_run] = false
        when '--yes' then memo[:skip_confirm] = true
        end
      end
    end

    def default_flags
      { dry_run: true, skip_confirm: false }
    end

    def detect_platform
      return 'railway' if Plain.present?(ENV.fetch('RAILWAY_SERVICE', nil))

      nil
    end
  end
end
