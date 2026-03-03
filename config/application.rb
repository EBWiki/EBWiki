# frozen_string_literal: true

require_relative 'boot'

require 'logger'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module EBWiki
  class Application < Rails::Application
    # Initialize configuration defaults for Rails 7.1
    # Incrementally upgrading: 7.0 → 7.1 → 7.2 → 8.0 → 8.1
    config.load_defaults 7.1

    # Use structure.sql instead of schema.rb for database schema
    config.active_record.schema_format = :sql

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
