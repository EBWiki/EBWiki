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
  describe 'staging indexing protection' do
    it 'marks missing, wrong and unconfigured credentials as noindex without weakening auth' do
      [nil, basic_auth_header('wrong', 'creds')].each do |authorization|
        status, headers, = call('/cases', authorization: authorization)
        expect(status).to eq(401)
        expect(headers['WWW-Authenticate']).to eq('Basic realm="Staging"')
        expect(headers['x-robots-tag']).to eq('noindex, nofollow')
      end
      ENV['STAGING_USERNAME'] = ''
      status, headers, = call('/cases', authorization: valid_auth)
      expect(status).to eq(401)
      expect(headers['x-robots-tag']).to eq('noindex, nofollow')
    end

    it 'marks authenticated and exempt responses as noindex' do
      [['/cases', valid_auth], ['/up', nil]].each do |path, authorization|
        status, headers, body = call(path, authorization: authorization)
        expect(status).to eq(200)
        expect(body).to eq(['OK'])
        expect(headers['Content-Type']).to eq('text/plain')
        expect(headers['x-robots-tag']).to eq('noindex, nofollow')
      end
    end

    [302, 404, 500].each do |response_status|
      context "when the app returns #{response_status}" do
        let(:inner_app) { ->(_env) { [response_status, { 'Location' => '/next' }, ['response']] } }

        it 'preserves the response and adds noindex' do
          status, headers, body = call('/cases', authorization: valid_auth)
          expect(status).to eq(response_status)
          expect(headers['Location']).to eq('/next')
          expect(headers['x-robots-tag']).to eq('noindex, nofollow')
          expect(body).to eq(['response'])
        end
      end
    end

    context 'with frozen headers and an existing robots directive' do
      let(:original_headers) { { 'X-Robots-Tag' => 'index, follow', 'Content-Type' => 'text/plain' }.freeze }
      let(:inner_app) { ->(_env) { [200, original_headers, ['OK']] } }

      it 'replaces case variants without mutating the application headers' do
        _, headers, = call('/cases', authorization: valid_auth)
        expect(headers['x-robots-tag']).to eq('noindex, nofollow')
        expect(headers).not_to have_key('X-Robots-Tag')
        expect(original_headers['X-Robots-Tag']).to eq('index, follow')
        expect(original_headers).not_to have_key('x-robots-tag')
      end
    end

    it 'is configured only in staging, not production or the shared application config' do
      expect(Rails.root.join('config/environments/staging.rb').read).to include('StagingBasicAuth')
      expect(Rails.root.join('config/environments/production.rb').read).not_to include('StagingBasicAuth')
      expect(Rails.root.join('config/application.rb').read).not_to include('StagingBasicAuth')
    end
  end

end
