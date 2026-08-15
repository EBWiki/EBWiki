# frozen_string_literal: true

ruby '3.4.2'

source 'https://rubygems.org'
git_source(:github) { |repo_name| "https://github.com/#{repo_name}.git" }

gem 'json', '~> 2.21'

gem 'active_median', '~> 0.2'
gem 'activerecord-session_store', '~> 2.3'
gem 'acts_as_follower', github: 'EBWiki/acts_as_follower', branch: 'main'
gem 'aws-sdk-s3', require: false
gem 'bootsnap', '~> 1.24', require: false
gem 'bootstrap', '~> 5.3'
gem 'bullet', '~> 8.1'
gem 'chartkick', '~> 5.0'
gem 'connection_pool'
gem 'dartsass-rails'
gem 'devise', '~> 5.0'
gem 'dotenv-rails', '~> 3.0'
gem 'friendly_id', '~> 5.7'
gem 'geocoder', '~> 1.6'
gem 'gibbon', '~> 3.4'
gem 'groupdate', '~> 6.0'
gem 'hightop', '~> 0.2'
gem 'httparty', '~> 0.24'
gem 'image_processing', '~> 1.12'
gem 'importmap-rails'
gem 'jb', '~> 0.8.2'
gem 'kaminari', '~> 1.2', '>= 1.2.1'
gem 'lograge', '~> 0.15'
gem 'montrose', '~> 0.12'
gem 'newrelic_rpm', '~> 9.0'
gem 'paper_trail'
gem 'paper_trail-association_tracking'
gem 'pg', '~> 1.2'
gem 'pg_search', '~> 2.3'
gem 'propshaft'
gem 'puma', '~> 7.0'
gem 'pundit', '~> 2.1'
gem 'rack-cors', '~> 2.0', require: 'rack/cors'
gem 'rack-host-redirect', '~> 1.3'
# Override action_text-trix to 2.1.17+ for XSS security fix (issue #4317)
gem 'action_text-trix', '~> 2.1.19'
gem 'administrate', '~> 1.0'
gem 'rails', '~> 8.1.3'
gem 'recaptcha', '~> 5.21'
gem 'redis', '~> 5'
gem 'redis-namespace', '~> 1.8'
gem 'rollbar', '~> 3.8'
gem 'rollout', '~> 2.5'
gem 'simple_form', '~> 5.4'
gem 'sitemap_generator', '~> 6.1'
gem 'statistics'
gem 'stimulus-rails'
gem 'turbo-rails'

group :development, :test do
  gem 'debug', '>= 1.0.0'
  gem 'factory_bot_rails', '~> 6.2'
  gem 'faker'
  gem 'mock_redis', '~> 0.26'
  gem 'pre-commit', '~> 0.39'
  gem 'rake', require: false
  gem 'rspec-rails'
  gem 'rubocop', '~> 1.65', require: false
  gem 'rubocop-performance', '~> 1.23', require: false
  gem 'rubocop-rails', '~> 2.26', require: false
  gem 'standard', '>= 1.35.1', require: false
end

group :development do
  gem 'annotaterb', '~> 4.22'
  gem 'brakeman', '~> 8.0', require: false
  gem 'derailed_benchmarks', '~> 1.8'
  gem 'listen', '~> 3.7'
  gem 'rails_real_favicon', '~> 0.0.13'
  gem 'web-console', '~> 4.2'
end

group :test do
  gem 'capybara', '~> 3.40'
  gem 'database_cleaner-active_record', '~> 2.0'
  gem 'launchy', '~> 2.5'
  gem 'selenium-webdriver', '~> 4.0'
  gem 'shoulda-matchers', '~> 6.0'
  gem 'simplecov', '~> 0.22.0', require: false
  gem 'vcr', '~> 6.0'
  gem 'webmock', '~>3.9', '>= 3.9.1'
end

group :production do
  gem 'cloudflare-rails', '~> 7.0'
end
