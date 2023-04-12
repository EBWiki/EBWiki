# frozen_string_literal: true

ruby '2.7.2'

source 'https://rubygems.org'
git_source(:github) { |repo_name| "https://github.com/#{repo_name}.git" }

gem 'dotenv-rails', '~> 2.7', groups: %i[development test production], require: 'dotenv/rails-now'
gem 'rails', '~> 5.2.7.1'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.2'
# Use SCSS for stylesheets
gem 'sassc-rails', '~> 2.1'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '4.2'

# Reduce N+1 queries
gem 'bullet', '~> 6.1'

# Use gem pundit for authorization
gem 'pundit', '~> 2.1'
# Use jquery as the JavaScript library
gem 'jquery-rails', '~> 4.4'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '~> 5.2'

gem 'momentjs-rails', '~> 2.20'
gem 'rack', '~> 2.2'

# For configurable CORS domain settings
gem 'rack-cors', '~> 1.1', require: 'rack/cors'

# help with charts and graphs

gem 'active_median', '~> 0.2'
gem 'chartkick', '~> 3.4'
gem 'groupdate', '~> 5.0'
gem 'hightop', '~> 0.2'

# xml sitemap
gem 'sitemap_generator', '~> 6.1'

gem 'rollbar', '~> 3.0'

gem 'simplecov', '~> 0.19.0'

gem 'twitter', '~> 7.0'

gem 'montrose', '~> 0.12'

# JSON renderer for Rails
gem 'jb', '~> 0.7.1'

group :development, :test do
  gem 'factory_bot_rails', '~> 6.1'
  gem 'faker', '~> 2.14.0'
  gem 'mock_redis', '~> 0.26'
  gem 'pre-commit', '~> 0.39'
  gem 'pry-byebug', '~> 3.9'
  gem 'rake', require: false
  gem 'rspec-rails', '~> 4.0', '>= 4.0.1'
  gem 'rubocop', '~> 1.12', require: false
  gem 'rubocop-performance', '~> 1.10', require: false
  gem 'rubocop-rails', '~> 2.9', require: false
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
  # makes it easy to programatically simulate users' interactions
  gem 'capybara', '~> 3.4'
  gem 'cucumber-rails', '~> 1.6', require: false
  gem 'database_cleaner-active_record', '~> 1.8.0'
  gem 'launchy', '~> 2.5'
  gem 'selenium-webdriver', '~> 2.53.0'
  gem 'shoulda-matchers', '~> 4.4', '>= 4.4.1'
  gem 'vcr', '~> 6.0'
  gem 'webmock', '~>3.9', '>= 3.9.1'
end

gem 'bootstrap3-datetimepicker-rails', '~> 4.17'
gem 'bootstrap-sass', '>= 3.4.1'
gem 'devise', '4.7.3'
gem 'simple_form', '5.0'

# for aws cloud storage
gem 'fog-aws', '~> 3.10'
# photo resizing
gem 'mini_magick', '~> 4.10'
# file upload solution
gem 'carrierwave', '~> 2.1'
# image optimizer that works with carrierwave
gem 'carrierwave-imageoptimizer', '~> 1.6'

# CMS panel for admin
gem 'rails_admin', '~> 2.0'

gem 'geocoder', '~> 1.6'
gem 'puma', '~> 5.6'

# implement elasticsearch
gem 'elasticsearch'
gem 'elasticsearch-transport'
gem 'searchkick', '~> 3.1'

# manage nested forms
gem 'cocoon', '~> 1.2'

# add social share buttons
gem 'social-share-button', '~> 1.2'

# select tag jquery plugin
gem 'select2-rails', '~> 4.0'

# follower functionality
gem 'acts_as_follower', github: 'tcocca/acts_as_follower'

# messaging
gem 'mailboxer', '~> 0.15'

# track changes in model objects
gem 'paper_trail', '~> 10.3'

# needed for paper_trail to track changes done via rails_admin views
gem 'paper_trail-association_tracking', '~> 2.1'

# pretty urls
gem 'friendly_id', '~> 5.2' # NOTE: You MUST use 5.0.0 or greater for Rails 4.0+

# pagination
gem 'kaminari', '~> 1.2', '>= 1.2.1'

gem 'hiredis', '~> 0.6'
gem 'redis', '~> 4.2'
gem 'redis-namespace', '~> 1.8'
gem 'redis-rails', '~> 5.0'
gem 'redis-store', '~> 1.9'

# access mailchimp api
gem 'gibbon', '~> 3.4'

# Google News API help
gem 'galerts', '~> 1.1'

gem 'ckeditor', '~> 5.1'

# New Relic performance monitor
gem 'newrelic_rpm', '~> 7.0'

# for HTTParty
gem 'httparty', '~> 0.21'

# for setting middleware redirects
gem 'rack-host-redirect', '~> 1.3'

# for storing cookies via active record storage to avoid 4kb limit
gem 'activerecord-session_store', '~> 2.0'

gem 'lograge', '~> 0.11'

gem 'recaptcha', '~> 5.8'

group :production do
  gem 'cloudflare-rails', '~> 2.0'
end

gem 'sprockets', '~> 3.7.2'

gem 'bootsnap', '~> 1.7', require: false

# fast feature flags based on Redis
gem 'rollout', '~> 2.5'
