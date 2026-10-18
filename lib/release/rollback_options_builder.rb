# frozen_string_literal: true

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
      detect_platform_conflict!

      RollbackOptions.new(**options_hash)
    end

    private

    def options_hash
      flags = parse_flags(@argv)
      {
        platform: ENV.fetch('RELEASE_ROLLBACK_PLATFORM', detect_platform),
        app_name: ENV['HEROKU_APP_NAME'].presence || ENV['RELEASE_HEROKU_APP'].presence,
        service_name: ENV['RAILWAY_SERVICE'].presence,
        deployment_id: ENV['RAILWAY_ROLLBACK_DEPLOYMENT_ID'].presence,
        environment_slug: ENV['RAILWAY_ENVIRONMENT'].presence,
        dry_run: flags[:dry_run],
        skip_confirm: flags[:skip_confirm]
      }
    end

    def reject_unknown_flags!
      unknown = @argv.select { |arg| arg.start_with?('--') && ALLOWED_FLAGS.exclude?(arg) }
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
      heroku = ENV['HEROKU_APP_NAME'].present? || ENV['RELEASE_HEROKU_APP'].present?
      railway = ENV['RAILWAY_SERVICE'].present?
      return 'heroku' if heroku && !railway
      return 'railway' if railway && !heroku

      nil
    end

    def detect_platform_conflict!
      heroku = ENV['HEROKU_APP_NAME'].present? || ENV['RELEASE_HEROKU_APP'].present?
      return unless heroku && ENV['RAILWAY_SERVICE'].present?

      raise RollbackError,
            'Both Heroku and Railway are configured. Unset one platform before rolling back.'
    end
  end
end
