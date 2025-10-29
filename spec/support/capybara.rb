# frozen_string_literal: true

# Capybara configuration for Playwright integration
# Ensure Capybara is loaded before requiring Playwright driver
begin
  require 'capybara/playwright/driver'

  # Register Playwright driver with Capybara
  Capybara.register_driver(:playwright) do |app|
    Capybara::Playwright::Driver.new(
      app,
      browser_type: :chromium,
      headless: ENV['PLAYWRIGHT_HEADED'].nil? || ENV['PLAYWRIGHT_HEADED'] == 'false'
    )
  end

  # Set Playwright as the default JavaScript driver
  # This allows feature specs to use Playwright for browser automation
  Capybara.javascript_driver = :playwright
rescue LoadError => e
  Rails.logger.warn "Capybara Playwright driver not available: #{e.message}" if defined?(Rails)
end

# Keep rack_test as the default driver for faster non-JS tests
Capybara.default_driver = :rack_test

# Increase default max wait time for async operations
Capybara.default_max_wait_time = 10

# Configure server settings
Capybara.server_host = '127.0.0.1'
Capybara.server_port = 3001

# Screenshot and save behavior for debugging
Capybara.save_path = Rails.root.join('tmp', 'capybara')
