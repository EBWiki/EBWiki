# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('lib/staging_railway_hosts')

RSpec.describe StagingRailwayHosts do
  let(:inner_app) { ->(_env) { [200, { 'Content-Type' => 'text/plain' }, ['OK']] } }

  def build_app_config
    Class.new do
      attr_accessor :host_authorization

      def initialize
        @hosts = []
      end

      attr_reader :hosts
    end.new
  end

  def middleware_for(host: nil, railway_public_domain: nil)
    app_config = build_app_config
    described_class.configure!(
      app_config,
      host: host,
      railway_public_domain: railway_public_domain
    )
    exclude = app_config.host_authorization[:exclude]
    ActionDispatch::HostAuthorization.new(inner_app, app_config.hosts, exclude: exclude)
  end

  def call(middleware, path, host_header:)
    env = Rack::MockRequest.env_for(path, 'HTTP_HOST' => host_header)
    middleware.call(env)
  end

  def expect_up_allowed(middleware)
    status, _headers, body = call(middleware, '/up', host_header: 'any-host.example')
    expect(status).to eq(200)
    expect(body).to eq(['OK'])
  end

  context 'when neither HOST nor RAILWAY_PUBLIC_DOMAIN is set' do
    it 'allows GET /up for any Host header' do
      expect_up_allowed(middleware_for(host: nil, railway_public_domain: nil))
    end

    it 'returns 403 for other paths' do
      middleware = middleware_for(host: nil, railway_public_domain: nil)
      status, = call(middleware, '/cases', host_header: 'evil.example')
      expect(status).to eq(403)
    end
  end

  context 'when only HOST is set' do
    let(:custom_host) { 'staging.ebwiki.org' }

    it 'allows GET /up for any Host header' do
      expect_up_allowed(middleware_for(host: custom_host, railway_public_domain: nil))
    end

    it 'allows requests to the configured host' do
      middleware = middleware_for(host: custom_host, railway_public_domain: nil)
      status, = call(middleware, '/cases', host_header: custom_host)
      expect(status).to eq(200)
    end

    it 'blocks other hosts' do
      middleware = middleware_for(host: custom_host, railway_public_domain: nil)
      status, = call(middleware, '/cases', host_header: 'other.example')
      expect(status).to eq(403)
    end
  end

  context 'when only RAILWAY_PUBLIC_DOMAIN is set' do
    let(:railway_host) { 'ebwiki-staging.up.railway.app' }

    it 'allows GET /up for any Host header' do
      expect_up_allowed(middleware_for(host: nil, railway_public_domain: railway_host))
    end

    it 'allows requests to the Railway default host' do
      middleware = middleware_for(host: nil, railway_public_domain: railway_host)
      status, = call(middleware, '/cases', host_header: railway_host)
      expect(status).to eq(200)
    end

    it 'blocks other hosts' do
      middleware = middleware_for(host: nil, railway_public_domain: railway_host)
      status, = call(middleware, '/cases', host_header: 'wrong.example')
      expect(status).to eq(403)
    end
  end

  context 'when both HOST and RAILWAY_PUBLIC_DOMAIN are set' do
    let(:custom_host) { 'staging.ebwiki.org' }
    let(:railway_host) { 'ebwiki-staging.up.railway.app' }

    it 'allows GET /up for any Host header' do
      expect_up_allowed(
        middleware_for(host: custom_host, railway_public_domain: railway_host)
      )
    end

    it 'allows either configured host' do
      middleware = middleware_for(host: custom_host, railway_public_domain: railway_host)

      custom_status, = call(middleware, '/cases', host_header: custom_host)
      railway_status, = call(middleware, '/cases', host_header: railway_host)

      expect(custom_status).to eq(200)
      expect(railway_status).to eq(200)
    end

    it 'blocks unlisted hosts' do
      middleware = middleware_for(host: custom_host, railway_public_domain: railway_host)
      status, = call(middleware, '/cases', host_header: 'attacker.example')
      expect(status).to eq(403)
    end
  end
end
