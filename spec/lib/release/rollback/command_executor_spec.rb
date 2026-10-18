# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Release::Rollback::CommandExecutor do
  let(:executor) { described_class.new }
  let(:command) do
    Release::RailwayRollbackCommand.new(
      deployment_id: '11111111-2222-4333-8444-555555555555',
      service_name: 'ebwiki',
      environment_slug: 'production',
      description: 'Railway deploymentRollback'
    )
  end

  before { allow(Release::ErrorReporter).to receive(:report) }

  it 'returns a failed result and reports when DNS lookup fails' do
    allow(Release::Rollback::RailwayApi).to receive(:perform_rollback)
      .and_raise(SocketError, 'getaddrinfo: Temporary failure in name resolution')

    result = executor.call([command])

    expect(result.success).to be(false)
    expect(result.message).to include('Railway rollback failed')
    expect(Release::ErrorReporter).to have_received(:report).with(
      hash_including(event: 'release_rollback_network', context: hash_including(client: 'CommandExecutor'))
    )
  end

  it 'returns a failed result without a second report for a wrapped API error' do
    allow(Release::Rollback::RailwayApi).to receive(:perform_rollback)
      .and_raise(Release::RollbackError, 'Railway API request failed: timeout')

    result = executor.call([command])

    expect(result.success).to be(false)
    expect(result.message).to include('Railway API request failed')
    expect(Release::ErrorReporter).not_to have_received(:report)
  end
end
