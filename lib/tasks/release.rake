# frozen_string_literal: true

namespace :release do
  desc 'HTTP smoke check after deploy (base URL from arg or RELEASE_SMOKE_BASE_URL)'
  task :smoke_check, [:base_url] => :environment do |_task, args|
    base_url = args[:base_url].presence || ENV.fetch('RELEASE_SMOKE_BASE_URL', nil)
    if base_url.blank?
      warn 'Set RELEASE_SMOKE_BASE_URL or pass the base URL: bin/rails release:smoke_check[https://staging.example.com]'
      exit 1
    end

    success = Release::SmokeCheck.new(base_url: base_url).call
    exit(success ? 0 : 1)
  end
end

namespace :search do
  desc 'Alias for release:smoke_check (Postgres search post-deploy verification)'
  task :smoke, [:base_url] => :environment do |_task, args|
    Rake::Task['release:smoke_check'].reenable
    Rake::Task['release:smoke_check'].invoke(args[:base_url])
  end
end
