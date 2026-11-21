# frozen_string_literal: true

require_relative 'boot'

require 'logger'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module EBWiki
  class Application < Rails::Application
    # Initialize configuration defaults for Rails 8.1
    config.load_defaults 8.1

    # Use structure.sql instead of schema.rb for database schema
    config.active_record.schema_format = :sql
    # Destructive database tasks (db:drop, db:reset, db:purge, db:schema:load,
    # db:structure:load) refuse to run against these environments unless
    # DISABLE_DATABASE_ENVIRONMENT_CHECK=1 is set on purpose. Staging holds a
    # copy of real case data, so it is protected like production.
    config.active_record.protected_environments = %w[production staging]

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
