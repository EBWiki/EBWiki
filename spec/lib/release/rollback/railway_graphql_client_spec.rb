# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Release::Rollback::RailwayGraphqlClient do
  let(:http) { class_double(Net::HTTP) }
  let(:client) { described_class.new(http: http) }

  it 'reports and wraps DNS failures' do
    allow(http).to receive(:start).and_raise(SocketError, 'getaddrinfo: Temporary failure in name resolution')
    allow(Release::ErrorReporter).to receive(:report)

    expect do
      client.post(token: 'token', query: '{ __typename }', variables: {})
    end.to raise_error(Release::RollbackError, /Railway API request failed/)

    expect(Release::ErrorReporter).to have_received(:report).with(
      hash_including(event: 'release_rollback_network')
    )
  end
end
