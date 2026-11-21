# frozen_string_literal: true

module StagingDatabaseScrub
  class ProductionGuard
    class RefusedError < StandardError; end

    PRODUCTION_DATABASE_NAME_PATTERN = %r{
      (?:^|[/_-])
      (?:production|prod|ebwiki_production|ebwiki-prod)
      (?:$|[/_-])
    }ix

    def self.enforce(connection: ActiveRecord::Base.connection)
      new(connection: connection).enforce
    end

    def initialize(connection: ActiveRecord::Base.connection)
      @connection = connection
    end

    def enforce
      refuse_if_production_rails_env!
      refuse_if_scrub_not_explicitly_allowed!
      refuse_if_production_database_name!
      refuse_if_production_database_url!
    end

    private

    attr_reader :connection

    def refuse_if_production_rails_env!
      return unless Rails.env.production?

      raise RefusedError, 'Refusing to scrub while RAILS_ENV is production'
    end

    def refuse_if_scrub_not_explicitly_allowed!
      allowed = ActiveModel::Type::Boolean.new.cast(
        ENV.fetch('EBWIKI_STAGING_DATABASE_SCRUB_ALLOWED', nil)
      )
      return if allowed

      raise RefusedError,
            'Set EBWIKI_STAGING_DATABASE_SCRUB_ALLOWED=true to run the staging database scrub'
    end

    def refuse_if_production_database_name!
      database_name = connection.current_database.to_s
      return unless database_name.match?(PRODUCTION_DATABASE_NAME_PATTERN)

      raise RefusedError, "Refusing to scrub database named #{database_name.inspect}"
    end

    def refuse_if_production_database_url!
      database_url = ENV.fetch('DATABASE_URL', nil).to_s
      return if database_url.blank?
      return unless database_url.match?(PRODUCTION_DATABASE_NAME_PATTERN)

      raise RefusedError, 'Refusing to scrub because DATABASE_URL looks like a production database'
    end
  end
end
