# frozen_string_literal: true

ruby '2.7.8'

source 'https://rubygems.org'
git_source(:github) { |repo_name| "https://github.com/#{repo_name}.git" }

gem 'active_median', '~> 0.2'
gem 'acts_as_follower', github: 'EBWiki/acts_as_follower', branch: 'main'
gem 'bootsnap', '~> 1.7', require: false
gem 'bootstrap-sass', '>= 3.4.1'
gem 'bootstrap3-datetimepicker-rails', '~> 4.17'
gem 'bullet', '~> 6.1'
gem 'carrierwave', '~> 2.1'
gem 'carrierwave-imageoptimizer', '~> 1.6'
gem 'chartkick', '~> 3.4'
gem 'ckeditor', '~> 5.1'
gem 'cocoon', '~> 1.2'
gem 'connection_pool'
gem 'devise', '4.7.3'
gem 'dotenv-rails', '~> 2.7', groups: %i[development test production], require: 'dotenv/rails-now'
gem 'elasticsearch'
gem 'elasticsearch-transport'
gem 'fog-aws', '~> 3.10'
gem 'friendly_id', '~> 5.2'
gem 'galerts', '~> 1.1'
gem 'gibbon', '~> 3.4'
gem 'geocoder', '~> 1.6'
gem 'groupdate', '~> 5.0'
gem 'hightop', '~> 0.2'
gem 'hiredis', '~> 0.6'
gem 'httparty', '~> 0.21'
gem 'jb', '~> 0.7.1'
gem 'jquery-rails', '~> 4.4'
gem 'kaminari', '~> 1.2', '>= 1.2.1'
gem 'lograge', '~> 0.11'
gem 'mailboxer', '~> 0.15'
gem 'mini_magick', '~> 4.10'
gem 'momentjs-rails', '~> 2.20'
gem 'montrose', '~> 0.12'
gem 'newrelic_rpm', '~> 7.0'
gem 'paper_trail'
gem 'paper_trail-association_tracking'
gem 'pg', '~> 1.2'
gem 'pundit', '~> 2.1'
gem 'puma', '~> 5.6'
gem 'rack', '~> 2.2'
gem 'rack-cors', '~> 1.1', require: 'rack/cors'
gem 'rack-host-redirect', '~> 1.3'
gem 'rails', '~> 6.1.7.7'
gem 'rails_admin', '~> 2.0'
gem 'redis', '~> 5'
gem 'redis-namespace', '~> 1.8'
gem 'redis-rails', '~> 5.0'
gem 'redis-store', '~> 1.9'
gem 'recaptcha', '~> 5.8'
gem 'rollbar', '~> 3.0'
gem 'rollout', '~> 2.5'
gem 'sassc-rails', '~> 2.1'
gem 'searchkick', '~> 3.1'
gem 'select2-rails', '~> 4.0'
gem 'simple_form', '5.0'
gem 'simplecov', '~> 0.19.0'
gem 'sitemap_generator', '~> 6.1'
gem 'social-share-button', '~> 1.2'
gem 'sprockets', '~> 3.7.2'
gem 'turbolinks', '~> 5.2'
gem 'twitter', '~> 7.0'
gem 'uglifier', '4.2'
gem 'webpacker'

group :development, :test do
  gem 'debug', '>= 1.0.0'
  gem 'factory_bot_rails', '~> 6.2'
  gem 'faker', '~> 2.14.0'
  gem 'mock_redis', '~> 0.26'
  gem 'pre-commit', '~> 0.39'
  gem 'rake', require: false
  gem 'rspec-rails'
  gem 'rubocop', '~> 1.12', require: false
  gem 'rubocop-performance', '~> 1.10', require: false
  gem 'rubocop-rails', '> 2.9', require: false
  gem 'standard', '>= 1.35.1', require: false

end

group :development do
  gem 'annotate', '~> 3.1', '>= 3.1.1'
  gem 'brakeman', '~> 4.10', require: false
  gem 'derailed_benchmarks', '~> 1.8'
  gem 'listen', '~> 3.7'
  gem 'rails_real_favicon', '~> 0.0.13'
  gem 'web-console', '~> 3.7'
end

group :test do
  gem 'capybara', '~> 3.4'
  gem 'cucumber-rails', '~> 1.6', require: false
  gem 'database_cleaner-active_record', '~> 1.8.0'
  gem 'launchy', '~> 2.5'
  gem 'selenium-webdriver', '~> 2.53.0'
  gem 'shoulda-matchers', '~> 4.4', '>= 4.4.1'
  gem 'vcr', '~> 6.0'
  gem 'webmock', '~>3.9', '>= 3.9.1'
end

group :production do
  gem 'cloudflare-rails', '~> 2.0'

  gem 'activerecord-session_store', '~> 2.0'
end
