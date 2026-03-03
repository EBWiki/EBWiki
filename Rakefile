# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('config/application', __dir__)

Rails.application.load_tasks

namespace :pre_commit do
  task ci: %i[rubocop brakeman spec]

  task rubocop: :environment do
    require 'rubocop'
    result = RuboCop::CLI.new.run(%w[--format simple])
    raise 'Rubocop failed' unless result.zero?
  end

  task brakeman: :environment do
    require 'brakeman'
    tracker = Brakeman.run(app_path: Rails.root.to_s, print_report: true, min_confidence: 2)
    raise 'Brakeman found security warnings' if tracker.filtered_warnings.any?
  end
end

ENV['NEWRELIC_AGENT_ENABLED'] = 'false'
