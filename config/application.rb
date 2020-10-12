# frozen_string_literal: true

require File.expand_path('boot', __dir__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module EBWiki
  # Main EBWiki app
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins 'https://d39r1dufm4jbqr.cloudfront.net'
        resource '*', headers: :any, methods: %i[get post options]
      end
    end

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run 'rake -D time' for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Eastern Time (US & Canada)'

    config.autoload_paths << Rails.root.join('lib')

    # Do not swallow errors in after_commit/after_rollback callbacks.

    config.active_record.raise_in_transactional_callbacks = true

    config.generators do |g|
      g.test_framework :rspec,
                       fixtures: true,
                       view_specs: false,
                       helper_specs: false,
                       routing_specs: false,
                       controller_specs: false,
                       request_specs: true
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
    end

    config.active_record.schema_format = :sql

    config.action_mailer.preview_path = "#{Rails.root}/spec/mailers/previews"
  end
end
