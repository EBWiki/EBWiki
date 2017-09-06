ruby "2.4.1"

source 'https://rubygems.org'
gem 'dotenv-rails', :groups => [:development, :test, :production], :require => 'dotenv/rails-now'

gem 'rails', '4.2.9'
# Use postgresql as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Syntax
gem 'enumerated_type'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Jquery.turbolinks fixes binded event problems cause by Turbolinks
gem 'jquery-turbolinks'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
# add back rails observer class removed from rails 4
gem 'rails-observers'

gem 'rack'

# For configurable CORS domain settings
gem 'rack-cors', :require => 'rack/cors'

# help with charts and graphs
gem 'chartkick'
gem 'groupdate'
gem 'active_median'
gem 'hightop'

# Simple Captcha for signing up
gem 'gotcha'

# xml sitemap
gem 'sitemap_generator'

# Reduce N+1 queries
gem "bullet"

# internal analytics
gem 'ahoy_matey'

# use split gem for a/b testing
gem 'split', require: 'split/dashboard'

gem 'rollbar', '~> 2.1'


gem 'simplecov'
group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'pry-byebug'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'rspec-rails', '~> 3.0'
  gem 'rspec-activemodel-mocks'
  gem 'factory_girl_rails'
  gem 'guard-rspec'
  # Install a pre-commit hook to enforce code checks before commits
  gem "pre-commit"
end



group :development do
  gem 'brakeman', :require => false
    # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
end

group :test do
  gem "faker", "~> 1.4.3"
  # makes it easy to programatically simulate users’ interactions
  gem "capybara", "~> 2.4.3"
  gem "database_cleaner", "~> 1.3.0"
  gem "launchy", "~> 2.4.2"
  gem "selenium-webdriver", "~> 2.43.0"
  gem 'shoulda-matchers', '~> 2.6.2'
  gem 'cucumber-rails', :require => false
end

gem 'rails_12factor', :groups => [:production, :staging]
gem 'bootstrap-sass'
gem 'devise', '3.5.6'
gem 'simple_form'
gem 'momentjs-rails'
gem 'bootstrap3-datetimepicker-rails'

# for aws cloud storage
gem 'fog'
# photo resizing
gem "mini_magick"
# file upload solution
gem 'carrierwave'
# image optimizer that works with carrierwave
gem 'carrierwave-imageoptimizer'

# allow deflated assets with heroku
gem 'heroku_rails_deflate', :groups => [:production, :staging]

#CMS panel for admin
gem 'rails_admin','0.6.7'

gem 'puma'
gem 'geocoder'
gem 'gmaps4rails'

# implement elasticsearch
gem 'searchkick'

# manage nested forms
gem 'cocoon'

# add social share buttons
gem 'social-share-button'

# select tag jquery plugin
gem "select2-rails"

# follower functionality
gem "acts_as_follower"

# messaging
gem 'mailboxer', git: 'https://github.com/lacco/mailboxer.git'

# track changes in model objects
gem 'paper_trail', '~> 4.0.0.beta'

# pretty urls
gem 'friendly_id', '~> 5.1.0' # Note: You MUST use 5.0.0 or greater for Rails 4.0+

# pagination
gem 'kaminari'

gem 'redis-namespace','~> 1.5.0'

# access mailchimp api
gem 'gibbon'

# metatag helper
gem 'metamagic'

# Google News API help
gem 'galerts'

gem 'ckeditor', :git => 'https://github.com/galetahub/ckeditor.git'

# New Relic performance monitor
gem 'newrelic_rpm'

# for HTTParty
gem 'httparty'

# for setting middleware redirects
gem 'rack-host-redirect'
