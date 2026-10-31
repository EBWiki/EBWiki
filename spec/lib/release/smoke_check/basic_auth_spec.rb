# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Release::SmokeCheck, 'basic auth credentials' do
  let(:http) do
    instance_double(
      Release::HttpClient,
      get: Release::HttpClient::Response.new(status: 200, body: '', headers: {})
    )
  end

  def basic_auth_for(base_url)
    captured = nil
    allow(Release::HttpClient).to receive(:new) do |**kwargs|
      captured = kwargs[:basic_auth]
      http
    end
    described_class.new(base_url: base_url)
    captured
  end

  around do |example|
    @env_snapshot = ENV.to_hash
    ENV['STAGING_USERNAME'] = 'smoke_user'
    ENV['STAGING_PASSWORD'] = 'smoke_secret'
    example.run
  ensure
    ENV.replace(@env_snapshot)
  end

  it 'sends credentials to https://staging.ebwiki.org' do
    expect(basic_auth_for('https://staging.ebwiki.org')).to eq(
      username: 'smoke_user',
      password: 'smoke_secret'
    )
  end

  it 'does not send credentials to https://ebwiki.org' do
    expect(basic_auth_for('https://ebwiki.org')).to be_nil
  end

  it 'ignores RELEASE_SMOKE_STAGING_HOST and keeps credentials off https://ebwiki.org' do
    ENV['RELEASE_SMOKE_STAGING_HOST'] = 'ebwiki.org'

    expect(basic_auth_for('https://ebwiki.org')).to be_nil
  end

  it 'does not send credentials over http://staging.ebwiki.org' do
    expect(basic_auth_for('http://staging.ebwiki.org')).to be_nil
  end
end
