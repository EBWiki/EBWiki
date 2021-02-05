# frozen_string_literal: true

unless %w[production staging].include?(ENV['RAILS_ENV'])
  require 'simplecov'

  namespace :coverage do
    desc 'Process coverage results'
    task :process do
      SimpleCov.collate(Dir['/tmp/coverage-results/.resultset*.json'], 'rails') do
        # minimum_coverage 100
        merge_timeout 3600
      end
    end
  end
end
