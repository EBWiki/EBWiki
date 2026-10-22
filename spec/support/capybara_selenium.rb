# frozen_string_literal: true

Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('headless=new')
  options.add_argument('disable-gpu')
  options.add_argument('no-sandbox')
  options.add_argument('window-size=1400,900')

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :selenium_chrome_headless
