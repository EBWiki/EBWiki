# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('config/application', __dir__)

Rails.application.load_tasks

namespace :pre_commit do
  desc 'Static checks (RuboCop on staged content, Brakeman snapshot). Same as the git hook.'
  task static: :environment do
    require Rails.root.join('lib/ebwiki/pre_commit/cli')
    Ebwiki::PreCommit::Cli.run_static!(repo_root: Rails.root.to_s)
  end

  desc 'Static checks plus the full RSpec suite (local full check; CI remains authoritative).'
  task full: [:static] do
    Rake::Task['spec'].invoke
  end

  desc 'Legacy alias: runs static checks only (no longer boots Brakeman/RuboCop via Rails).'
  task ci: [:static]
end

ENV['NEWRELIC_AGENT_ENABLED'] = 'false'
