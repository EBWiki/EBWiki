# frozen_string_literal: true

module Release
  RollbackOptions = Data.define(
    :platform,
    :app_name,
    :service_name,
    :deployment_id,
    :dry_run,
    :skip_confirm,
    :with_migration_down
  ) do
    def self.from_argv(argv)
      flags = parse_flags(argv)
      new(
        platform: ENV.fetch('RELEASE_ROLLBACK_PLATFORM', detect_platform),
        app_name: ENV['HEROKU_APP_NAME'].presence || ENV['RELEASE_HEROKU_APP'].presence,
        service_name: ENV['RAILWAY_SERVICE'].presence,
        deployment_id: ENV['RAILWAY_ROLLBACK_DEPLOYMENT_ID'].presence,
        dry_run: flags[:dry_run],
        skip_confirm: flags[:skip_confirm],
        with_migration_down: flags[:with_migration_down]
      )
    end

    def self.parse_flags(argv)
      argv.each_with_object(default_flags) do |arg, memo|
        apply_flag(arg, memo)
      end
    end

    def self.default_flags
      { dry_run: true, skip_confirm: false, with_migration_down: false }
    end

    def self.apply_flag(arg, memo)
      case arg
      when '--execute' then memo[:dry_run] = false
      when '--yes' then memo[:skip_confirm] = true
      when '--with-migration-down' then memo[:with_migration_down] = true
      end
    end

    def self.detect_platform
      return 'heroku' if ENV['HEROKU_APP_NAME'].present? || ENV['RELEASE_HEROKU_APP'].present?
      return 'railway' if ENV['RAILWAY_SERVICE'].present?

      nil
    end
  end
end
