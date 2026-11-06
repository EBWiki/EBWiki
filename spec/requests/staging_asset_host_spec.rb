# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe 'Staging asset host', type: :request do
  let(:redis_url) { ENV.fetch('REDIS_URL', 'redis://127.0.0.1:6379/1') }

  around do |example|
    WebMock.allow_net_connect!
    example.run
  ensure
    WebMock.disable_net_connect!
  end

  def restore_asset_host!(original_host)
    Rails.application.config.action_controller.asset_host = original_host
    ActionController::Base.asset_host = original_host
  end

  it 'leaves action_controller.asset_host unset in staging when ASSET_HOST is blank' do
    host = StagingAssetHostHelper.configured_asset_host(asset_host_env: nil, redis_url: redis_url)
    expect(host).to eq('nil')
  end

  it 'sets action_controller.asset_host in staging from ASSET_HOST' do
    expected = 'https://assets.staging.example.test'
    host = StagingAssetHostHelper.configured_asset_host(
      asset_host_env: expected,
      redis_url: redis_url
    )
    expect(host).to eq(expected)
  end

  describe 'rendered stylesheet URLs' do
    let(:original_asset_host) { Rails.application.config.action_controller.asset_host }

    after do
      restore_asset_host!(original_asset_host)
    end

    it 'stay relative when no asset host is configured' do
      restore_asset_host!(nil)
      get '/'

      hrefs = response.body.scan(/<link[^>]*rel="stylesheet"[^>]*href="([^"]+)"/i).flatten
      expect(hrefs).not_to be_empty
      expect(hrefs).to all(match(%r{\A/assets/}))
    end

    it 'use the configured asset host when one is set' do
      host = 'https://assets.staging.example.test'
      Rails.application.config.action_controller.asset_host = host
      ActionController::Base.asset_host = host
      get '/'

      hrefs = response.body.scan(/<link[^>]*rel="stylesheet"[^>]*href="([^"]+)"/i).flatten
      expect(hrefs).not_to be_empty
      expect(hrefs).to all(start_with("#{host}/assets/"))
    end
  end
end
# rubocop:enable Metrics/BlockLength
