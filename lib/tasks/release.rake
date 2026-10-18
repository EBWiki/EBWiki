# frozen_string_literal: true

require Rails.root.join('lib/release/smoke_check_cli')

namespace :release do
  desc 'HTTP smoke check after deploy (base URL from arg or RELEASE_SMOKE_BASE_URL)'
  task :smoke_check, [:base_url] do |_task, args|
    smoke_bin = File.expand_path('../../bin/release-smoke-check', __dir__)
    base_url = args[:base_url].to_s.strip
    command = [smoke_bin]
    command << base_url unless base_url.empty?

    success = Release::SmokeCheckCli.system(*command)
    exit(success ? 0 : 1)
  end
end

namespace :search do
  desc 'Alias for release:smoke_check (Postgres search post-deploy verification)'
  task :smoke, [:base_url] do |_task, args|
    Rake::Task['release:smoke_check'].reenable
    Rake::Task['release:smoke_check'].invoke(args[:base_url])
  end
end
