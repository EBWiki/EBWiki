# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Release::HttpClient do
  it 'returns status and body from a GET request' do
    stub_request(:get, 'https://example.com/up').to_return(status: 200, body: 'ok')

    response = described_class.new.get('https://example.com/up')

    expect(response.status).to eq(200)
    expect(response.body).to eq('ok')
  end

  it 'sends basic auth when configured' do
    stub = stub_request(:get, 'https://example.com/health')
           .with(basic_auth: %w[user pass])
           .to_return(status: 200, body: '{}')

    described_class.new(basic_auth: { username: 'user', password: 'pass' }).get('https://example.com/health')

    expect(stub).to have_been_requested
  end
end
