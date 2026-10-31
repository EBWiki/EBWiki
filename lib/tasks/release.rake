# frozen_string_literal: true

require File.expand_path('../release/smoke_check_cli', __dir__)

namespace :release do
  desc 'HTTP smoke check after deploy (base URL from arg or RELEASE_SMOKE_BASE_URL)'
  # rubocop:disable Rails/RakeEnvironment -- delegates to bin/release-smoke-check without Rails boot
  task :smoke_check, [:base_url] do |_task, args|
    smoke_bin = File.expand_path('../../bin/release-smoke-check', __dir__)
    base_url = args[:base_url].to_s.strip
    command = [smoke_bin]
    command << base_url unless base_url.empty?

    success = Release::SmokeCheckCli.system(*command)
    exit(success ? 0 : 1)
  end
  # rubocop:enable Rails/RakeEnvironment
end

namespace :search do
  desc 'Alias for release:smoke_check (Postgres search post-deploy verification)'
  # rubocop:disable Rails/RakeEnvironment
  task :smoke, [:base_url] do |_task, args|
    Rake::Task['release:smoke_check'].reenable
    Rake::Task['release:smoke_check'].invoke(args[:base_url])
  end
  # rubocop:enable Rails/RakeEnvironment
end
