# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Staging cache store configuration' do
  let(:redis_url) { ENV.fetch('REDIS_URL', 'redis://127.0.0.1:6379/1') }

  around do |example|
    WebMock.allow_net_connect!
    example.run
  ensure
    WebMock.disable_net_connect!
  end

  it 'runs the main RSpec process in the test environment, not staging' do
    expect(Rails.env).to eq('test')
    expect(Rails.cache).to be_a(ActiveSupport::Cache::NullStore)
  end

  it 'uses the Rails 8 redis pool shape in config/environments/staging.rb' do
    staging_rb = Rails.root.join('config/environments/staging.rb').read
    expect(staging_rb).to include('pool: { size: 2, timeout: 2 }')
    expect(staging_rb).not_to match(/pool_size|pool_timeout/)
  end

  it 'serves staging assets from the app host unless ASSET_HOST is set' do
    staging_rb = Rails.root.join('config/environments/staging.rb').read
    expect(staging_rb).to include("ENV['ASSET_HOST'].presence")
    expect(staging_rb).not_to include('d2pqbhqdp2wy5y.cloudfront.net')
  end

  it 'rejects legacy pool_size and pool_timeout keywords on redis_cache_store' do
    expect do
      ActiveSupport::Cache.lookup_store(
        :redis_cache_store,
        url: redis_url,
        pool_size: 2,
        pool_timeout: 2
      ).write('legacy_pool_keys', 'value')
    end.to raise_error(ArgumentError, /unknown keywords: :pool_size, :pool_timeout/)
  end

  it 'boots the staging environment and round-trips one value through Rails.cache' do
    expect(Redis.new(url: redis_url).ping).to eq('PONG')

    StagingEnvironmentBoot.cache_round_trip!(redis_url: redis_url)
  end
end
