# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Staging cache store configuration' do
  let(:redis_url) { ENV.fetch('REDIS_URL', 'redis://127.0.0.1:6379/1') }

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
    store = ActiveSupport::Cache.lookup_store(:redis_cache_store, staging_redis_cache_options)

    key = "staging_cache_smoke_#{SecureRandom.hex(8)}"
    store.write(key, 'ok', expires_in: 1.minute)

    expect(store.read(key)).to eq('ok')
  ensure
    store&.delete(key)
  end
end
