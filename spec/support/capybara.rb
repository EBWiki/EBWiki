# frozen_string_literal: true

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('headless=new')
  options.add_argument('disable-gpu')
  options.add_argument('no-sandbox')
  options.add_argument('disable-dev-shm-usage')
  options.add_argument('window-size=1280,900')

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :headless_chrome
Capybara.default_max_wait_time = 15

RSpec.configure do |config|
  config.before(:each, type: :system) do
    WebMock.allow_net_connect!
    driven_by :headless_chrome
  end

  config.after(:each, type: :system) do
    WebMock.disable_net_connect!(allow_localhost: true)
  end
end
