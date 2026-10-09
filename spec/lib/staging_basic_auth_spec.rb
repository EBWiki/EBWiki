# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('lib/staging_basic_auth')

RSpec.describe StagingBasicAuth do
  subject(:middleware) { described_class.new(inner_app) }

  let(:inner_app) { ->(_env) { [200, { 'Content-Type' => 'text/plain' }, ['OK']] } }
  let(:valid_auth) { basic_auth_header('staging_user', 'staging_secret') }

  def call(path, authorization: nil)
    env = Rack::MockRequest.env_for(path)
    env['HTTP_AUTHORIZATION'] = authorization if authorization
    middleware.call(env)
  end

  def basic_auth_header(user, password)
    "Basic #{Base64.strict_encode64("#{user}:#{password}")}"
  end

  around do |example|
    original_username = ENV.fetch('STAGING_USERNAME', nil)
    original_password = ENV.fetch('STAGING_PASSWORD', nil)
    ENV['STAGING_USERNAME'] = 'staging_user'
    ENV['STAGING_PASSWORD'] = 'staging_secret'
    example.run
  ensure
    if original_username.nil?
      ENV.delete('STAGING_USERNAME')
    else
      ENV['STAGING_USERNAME'] = original_username
    end
    if original_password.nil?
      ENV.delete('STAGING_PASSWORD')
    else
      ENV['STAGING_PASSWORD'] = original_password
    end
  end

  describe 'protected paths' do
    it 'returns 401 when credentials are missing' do
      expect(call('/cases').first).to eq(401)
    end

    it 'returns 401 when credentials are wrong' do
      expect(call('/cases', authorization: basic_auth_header('wrong', 'creds')).first).to eq(401)
    end

    it 'returns 401 when STAGING_USERNAME or STAGING_PASSWORD is blank' do
      ENV['STAGING_USERNAME'] = ''
      expect(call('/cases', authorization: valid_auth).first).to eq(401)
    end

    it 'returns 200 when credentials match' do
      status, _headers, body = call('/cases', authorization: valid_auth)
      expect(status).to eq(200)
      expect(body).to eq(['OK'])
    end

    it 'requires credentials for /health' do
      expect(call('/health').first).to eq(401)
    end
  end

  describe 'exempt paths' do
    it 'allows /up without credentials' do
      status, _headers, body = call('/up')
      expect(status).to eq(200)
      expect(body).to eq(['OK'])
    end
  end
end
