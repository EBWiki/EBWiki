# frozen_string_literal: true

raise 'Visual review requires RAILS_ENV=test' if ENV['VISUAL_REVIEW'] == '1' && ENV['RAILS_ENV'] != 'test'

require 'rails_helper'
require 'selenium-webdriver'
require 'json'

RSpec.describe 'Merged brand visual review', type: :feature do
  before do
    skip 'Run only in the isolated visual review job' unless ENV['VISUAL_REVIEW'] == '1'
    raise 'Visual review requires disposable test data' unless Rails.env.test?

    WebMock.disable_net_connect!(allow_localhost: true)
    Capybara.register_driver :visual_review do |app|
      options = Selenium::WebDriver::Chrome::Options.new
      %w[--headless=new --no-sandbox --disable-dev-shm-usage --disable-background-networking].each do |arg|
        options.add_argument(arg)
      end
      # Only loopback reaches the Rails test server. Other requests hit a closed local proxy.
      options.add_argument('--proxy-server=http://127.0.0.1:9')
      options.add_argument('--proxy-bypass-list=localhost;127.0.0.1;[::1]')
      Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
    end
    Capybara.server = :puma, { Silent: true }
    Capybara.server_host = '127.0.0.1'
    Capybara.default_max_wait_time = 15
    Capybara.current_driver = :visual_review
    @output = Rails.root.join('tmp/visual-review')
    FileUtils.mkdir_p(@output)
  end

  after do
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end

  it 'captures actual home, case and sign-in templates at desktop and mobile widths' do
    state = create(:state_ny)
    cases = 3.times.map do |index|
      record = create(:case, state: state, city: 'Albany', date: Date.new(2020, 1, index + 1),
                             title: "Visual test record #{index + 1}", video_url: '',
                             overview: 'Synthetic example for visual review. This is not a real incident.',
                             blurb: 'Synthetic visual-review content, not a real incident.',
                             summary: 'Synthetic fixture created only in the disposable CI database.')
      record.subjects.create!(name: "Synthetic example #{index + 1}")
      record
    end
    routes = { home: '/', case: "/cases/#{cases.first.slug}", sign_in: '/users/sign_in' }
    captures = []
    failures = []
    [[1440, 1000], [390, 844]].each do |width, height|
      routes.each do |name, route|
        failure = nil
        begin
          page.driver.browser.execute_cdp('Emulation.setDeviceMetricsOverride',
                                          width: width, height: height, deviceScaleFactor: 1,
                                          mobile: width < 600)
          visit route
          expect(page).to have_css('#ebwiki-site-header')
          expect(page).to have_css('.ebwiki-footer-wordmark')
          expect(page).to have_css('.ebwiki-home-finding', text: '3') if name == :home
          expect(page).to have_css('.case-title', text: 'Synthetic example 1') if name == :case
          expect(page).to have_css('.ebwiki-auth-page h2', text: 'Log in') if name == :sign_in
          expect(page.evaluate_script('document.fonts.ready.then(() => document.fonts.check("18px Barlow"))')).to be(true)
          expect(page.evaluate_script('getComputedStyle(document.body).fontFamily')).to include('Barlow')
          Selenium::WebDriver::Wait.new(timeout: 15).until do
            page.evaluate_script('Array.from(document.images).every(i => i.complete && i.naturalWidth > 0)')
          end
          actual_width = page.evaluate_script('window.innerWidth')
          expect(actual_width).to eq(width)
        rescue RSpec::Expectations::ExpectationNotMetError, StandardError => e
          failure = "#{e.class}: #{e.message}"
          failures << "#{name}-#{width}: #{failure}"
        ensure
          filename = "#{name}-#{width}.png"
          page.save_screenshot(@output.join(filename))
          captures << { file: filename, path: route, viewport: [width, height],
                        actual_viewport: page.evaluate_script('[window.innerWidth, window.innerHeight]'),
                        document_width: page.evaluate_script('document.documentElement.scrollWidth'),
                        body_font: page.evaluate_script('getComputedStyle(document.body).fontFamily'),
                        verification_error: failure }
          File.write(@output.join('manifest.json'), JSON.pretty_generate(
                       source_commit: ENV.fetch('VISUAL_SOURCE_SHA'),
                       data: 'Synthetic CI fixtures only. Not hosted staging acceptance.',
                       external_requests: 'Closed loopback proxy; only local app bypasses proxy.',
                       captures: captures
                     ))
        end
      end
    end
    expect(failures).to be_empty, failures.join("\n")
  end
end
