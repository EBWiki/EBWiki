# frozen_string_literal: true

require_relative 'boot'

require 'logger'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module EBWiki
  class Application < Rails::Application
    # Rails framework defaults, fully upgraded to 8.1
    config.load_defaults 8.1

    # Intentional override: allow belongs_to associations to be optional.
    # Rails default is true (required). EBWiki's data model relies on optional associations.
    config.active_record.belongs_to_required_by_default = false

    # Use structure.sql instead of schema.rb for database schema
    config.active_record.schema_format = :sql

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
