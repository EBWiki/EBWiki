# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HttpBasicAuth do
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

  describe '.required?' do
    it 'is false when credentials are missing' do
      with_env(
        'HTTP_BASIC_AUTH_ENABLED' => 'true',
        'HTTP_BASIC_AUTH_USERNAME' => nil,
        'HTTP_BASIC_AUTH_PASSWORD' => nil,
        'STAGING_USERNAME' => nil,
        'STAGING_PASSWORD' => nil
      ) do
        expect(described_class.required?).to be(false)
      end
    end

    it 'is false in test when the enable flag is unset' do
      with_env(
        'HTTP_BASIC_AUTH_ENABLED' => nil,
        'HTTP_BASIC_AUTH_USERNAME' => 'ebwiki',
        'HTTP_BASIC_AUTH_PASSWORD' => 'secret'
      ) do
        expect(described_class.required?).to be(false)
      end
    end

    it 'is true when credentials and the enable flag are present' do
      with_env(
        'HTTP_BASIC_AUTH_ENABLED' => 'true',
        'HTTP_BASIC_AUTH_USERNAME' => 'ebwiki',
        'HTTP_BASIC_AUTH_PASSWORD' => 'secret'
      ) do
        expect(described_class.required?).to be(true)
      end
    end

    it 'is true on the legacy staging host when credentials are present' do
      with_env(
        'HTTP_BASIC_AUTH_ENABLED' => nil,
        'HTTP_BASIC_AUTH_USERNAME' => 'ebwiki',
        'HTTP_BASIC_AUTH_PASSWORD' => 'secret',
        'HOST' => 'ebwiki-newstack.herokuapp.com'
      ) do
        expect(described_class.required?).to be(true)
      end
    end

    it 'falls back to STAGING_USERNAME and STAGING_PASSWORD' do
      with_env(
        'HTTP_BASIC_AUTH_ENABLED' => 'true',
        'HTTP_BASIC_AUTH_USERNAME' => nil,
        'HTTP_BASIC_AUTH_PASSWORD' => nil,
        'STAGING_USERNAME' => 'legacy-user',
        'STAGING_PASSWORD' => 'legacy-pass'
      ) do
        expect(described_class.username).to eq('legacy-user')
        expect(described_class.password).to eq('legacy-pass')
        expect(described_class.required?).to be(true)
      end
    end
  end

  describe '.credentials_match?' do
    it 'accepts the configured username and password' do
      with_env(
        'HTTP_BASIC_AUTH_USERNAME' => 'ebwiki',
        'HTTP_BASIC_AUTH_PASSWORD' => 'secret'
      ) do
        expect(described_class.credentials_match?('ebwiki', 'secret')).to be(true)
        expect(described_class.credentials_match?('ebwiki', 'wrong')).to be(false)
      end
    end
  end
end
