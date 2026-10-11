# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Staging cache store configuration' do
  let(:redis_url) { ENV['REDIS_URL'].presence || 'redis://127.0.0.1:6379/1' }

  around do |example|
    WebMock.allow_net_connect!
    example.run
  end

  def staging_redis_cache_options
    staging_rb = Rails.root.join('config/environments/staging.rb').read
    expect(staging_rb).to include('pool: { size: 2, timeout: 2 }')
    expect(staging_rb).not_to match(/pool_size|pool_timeout/)

    {
      url: redis_url,
      pool: { size: 2, timeout: 2 }
    }
  end

  it 'builds the staging redis cache store and round-trips a value' do
    expect(Redis.new(url: redis_url).ping).to eq('PONG')

    store = ActiveSupport::Cache.lookup_store(:redis_cache_store, staging_redis_cache_options)

    key = "staging_cache_smoke_#{SecureRandom.hex(8)}"
    expect(store.write(key, 'ok', expires_in: 1.minute)).to be(true)

    expect(store.read(key)).to eq('ok')
  ensure
    store&.delete(key)
  end
end
