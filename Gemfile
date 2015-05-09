source 'https://rubygems.org'
gem 'dotenv-rails', :groups => [:development, :test], :require => 'dotenv/rails-now'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.1'
# Use postgresql as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Simple Captcha for signing up
gem 'gotcha'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'pry-byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'rspec-rails', '~> 3.0'
  gem 'rspec-activemodel-mocks'

  gem 'factory_girl_rails'
  # tests and runs specs for you automatically when it detects changes
  gem 'guard-rspec'
end

group :test do
  gem "faker", "~> 1.4.3"
  # makes it easy to programatically simulate users’ interactions
  gem "capybara", "~> 2.4.3"
  gem "database_cleaner", "~> 1.3.0"
  gem "launchy", "~> 2.4.2"
  gem "selenium-webdriver", "~> 2.43.0"
  gem 'shoulda-matchers', '~> 2.6.2'
end

gem 'rails_12factor', group: :production
gem 'bootstrap-sass'
gem 'devise'
gem 'simple_form'
gem 'datetimepicker-rails', github: 'zpaulovics/datetimepicker-rails', branch: 'master', submodules: true
gem 'momentjs-rails'

# for aws cloud storage
gem 'fog'
# photo resizing
gem "mini_magick"
# file upload solution
gem 'carrierwave'

#CMS panel for admin
gem 'rails_admin'

gem 'puma'
gem 'geocoder'
gem 'gmaps4rails'

# implement elasticsearch
gem 'searchkick'

# manage nested forms
gem 'cocoon'

# add social share buttons
gem 'social-share-button'

# follower functionality
gem "acts_as_follower"

#track changes in model objects
gem 'paper_trail', '~> 4.0.0.beta'

gem 'friendly_id', '~> 5.1.0' # Note: You MUST use 5.0.0 or greater for Rails 4.0+
ruby "2.2.1"
