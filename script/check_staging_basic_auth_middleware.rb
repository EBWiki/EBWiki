# frozen_string_literal: true

# Verifies config/environments/staging.rb registers StagingBasicAuth on the stack.
# Invoked from spec/config/environments/staging_middleware_spec.rb in a subprocess.

ENV['RAILS_ENV'] = 'test'
require File.expand_path('../config/application', __dir__)

load Rails.root.join('config/environments/staging.rb')
Rails.application.initialize!

present = Rails.application.middleware.map(&:klass).include?(StagingBasicAuth)
exit(present ? 0 : 1)
