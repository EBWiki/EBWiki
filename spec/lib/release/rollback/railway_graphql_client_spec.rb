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

  it 'reports and wraps a connection closed mid-response' do
    allow(http).to receive(:start).and_raise(EOFError, 'end of file reached')
    allow(Release::ErrorReporter).to receive(:report)

    expect do
      client.post(token: 'token', query: '{ __typename }', variables: {})
    end.to raise_error(Release::RollbackError, /end of file reached/)

    expect(Release::ErrorReporter).to have_received(:report).with(
      hash_including(event: 'release_rollback_network')
    )
  end

  it 'reports and wraps a malformed HTTP response' do
    allow(http).to receive(:start).and_raise(Net::HTTPBadResponse, 'wrong status line')
    allow(Release::ErrorReporter).to receive(:report)

    expect do
      client.post(token: 'token', query: '{ __typename }', variables: {})
    end.to raise_error(Release::RollbackError, /wrong status line/)

    expect(Release::ErrorReporter).to have_received(:report).with(
      hash_including(event: 'release_rollback_network')
    )
  end
end
