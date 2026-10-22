# frozen_string_literal: true

require 'bundler/setup'
require 'rspec/core'
require 'brakeman'
require 'rubocop'

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
require File.expand_path('support/pre_commit_git_repo.rb', __dir__)

require 'ebwiki/pre_commit'
require 'ebwiki/pull_request/style_security_disclosure'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
