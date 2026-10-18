# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Release::SmokeCheck, 'basic auth credentials' do
  def basic_auth_for(base_url)
    captured = nil
    http = instance_double(
      Release::HttpClient,
      get: Release::HttpClient::Response.new(status: 200, body: '', headers: {})
    )
    allow(Release::HttpClient).to receive(:new) do |**kwargs|
      captured = kwargs[:basic_auth]
      http
    end

    described_class.new(base_url: base_url)
    captured
  end

  before do
    ENV['STAGING_USERNAME'] = 'smoke_user'
    ENV['STAGING_PASSWORD'] = 'smoke_secret'
  end

  after do
    ENV.delete('STAGING_USERNAME')
    ENV.delete('STAGING_PASSWORD')
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

  it 'does not send credentials over http://staging.ebwiki.org' do
    expect(basic_auth_for('http://staging.ebwiki.org')).to be_nil
  end

end
