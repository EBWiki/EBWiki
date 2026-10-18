# frozen_string_literal: true

module Release
  RollbackOptions = Data.define(
    :platform,
    :app_name,
    :service_name,
    :deployment_id,
    :environment_slug,
    :dry_run,
    :skip_confirm
  ) do
    ALLOWED_FLAGS = %w[--execute --yes].freeze

    def self.from_argv(argv)
      unknown = argv.select { |arg| arg.start_with?('--') && ALLOWED_FLAGS.exclude?(arg) }
      raise RollbackError, "Unknown flag #{unknown.first}" if unknown.any?

      flags = parse_flags(argv)
      detect_platform_conflict!

      new(
        platform: ENV.fetch('RELEASE_ROLLBACK_PLATFORM', detect_platform),
        app_name: ENV['HEROKU_APP_NAME'].presence || ENV['RELEASE_HEROKU_APP'].presence,
        service_name: ENV['RAILWAY_SERVICE'].presence,
        deployment_id: ENV['RAILWAY_ROLLBACK_DEPLOYMENT_ID'].presence,
        environment_slug: ENV['RAILWAY_ENVIRONMENT'].presence,
        dry_run: flags[:dry_run],
        skip_confirm: flags[:skip_confirm]
      )
    end

    def self.parse_flags(argv)
      argv.each_with_object(default_flags) do |arg, memo|
        case arg
        when '--execute' then memo[:dry_run] = false
        when '--yes' then memo[:skip_confirm] = true
        end
      end
    end

    def self.default_flags
      { dry_run: true, skip_confirm: false }
    end

    def self.detect_platform
      heroku = ENV['HEROKU_APP_NAME'].present? || ENV['RELEASE_HEROKU_APP'].present?
      railway = ENV['RAILWAY_SERVICE'].present?
      return 'heroku' if heroku && !railway
      return 'railway' if railway && !heroku

      nil
    end

    def self.detect_platform_conflict!
      heroku = ENV['HEROKU_APP_NAME'].present? || ENV['RELEASE_HEROKU_APP'].present?
      return unless heroku && ENV['RAILWAY_SERVICE'].present?

      raise RollbackError, 'Both Heroku and Railway are configured. Unset one platform before rolling back.'
    end
  end
end
