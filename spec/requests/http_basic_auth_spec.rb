# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'HTTP Basic Authentication', type: :request do
  def with_env(vars)
    originals = vars.keys.index_with { |key| ENV.fetch(key, nil) }
    vars.each do |key, value|
      if value.nil?
        ENV.delete(key)
      else
        ENV[key] = value
      end
    end
    yield
  ensure
    originals.each do |key, value|
      if value.nil?
        ENV.delete(key)
      else
        ENV[key] = value
      end
    end
  end

  def basic_auth_header(username, password)
    {
      'HTTP_AUTHORIZATION' =>
        ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
    }
  end

  it 'does not challenge requests when HTTP auth is disabled' do
    get '/'

    expect(response).to have_http_status(:ok)
  end

  it 'challenges requests when HTTP auth is enabled' do
    with_env(
      'HTTP_BASIC_AUTH_ENABLED' => 'true',
      'HTTP_BASIC_AUTH_USERNAME' => 'ebwiki',
      'HTTP_BASIC_AUTH_PASSWORD' => 'secret'
    ) do
      get '/'

      expect(response).to have_http_status(:unauthorized)
    end
  end

  it 'allows requests with valid basic auth credentials' do
    with_env(
      'HTTP_BASIC_AUTH_ENABLED' => 'true',
      'HTTP_BASIC_AUTH_USERNAME' => 'ebwiki',
      'HTTP_BASIC_AUTH_PASSWORD' => 'secret'
    ) do
      get '/', headers: basic_auth_header('ebwiki', 'secret')

      expect(response).to have_http_status(:ok)
    end
  end

  it 'rejects requests with invalid basic auth credentials' do
    with_env(
      'HTTP_BASIC_AUTH_ENABLED' => 'true',
      'HTTP_BASIC_AUTH_USERNAME' => 'ebwiki',
      'HTTP_BASIC_AUTH_PASSWORD' => 'secret'
    ) do
      get '/', headers: basic_auth_header('ebwiki', 'nope')

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
