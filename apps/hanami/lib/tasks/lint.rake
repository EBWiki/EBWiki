# frozen_string_literal: true

desc "Run Standard Ruby, the preferred style for this app"
task :lint do
  sh "bundle exec standardrb"
end

namespace :security do
  desc "Run bundler-audit and Brakeman"
  task :check do
    sh "bundle exec bundler-audit check --update"
    rails_root = File.expand_path("../../..", __dir__)
    sh "bundle exec brakeman -p #{rails_root} -A --no-pager --no-exit-on-warn --no-exit-on-error"
  end
end
