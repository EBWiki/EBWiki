# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Release::Rollback::RailwayApi do
  let(:connection) { instance_double(Net::HTTP) }
  let(:response) { instance_double(Net::HTTPResponse, body: { data: { deploymentRollback: true } }.to_json) }

  before do
    allow(Net::HTTP).to receive(:start).and_yield(connection)
    allow(connection).to receive(:request).and_return(response)
  end

  it 'posts the deploymentRollback mutation' do
    described_class.new.perform_rollback(deployment_id: 'dep-1', token: 'token')

    expect(connection).to have_received(:request) do |request|
      body = JSON.parse(request.body)
      expect(body['variables']).to eq('id' => 'dep-1')
      expect(request['Authorization']).to eq('Bearer token')
    end
  end

  it 'raises when Railway returns GraphQL errors' do
    allow(response).to receive(:body).and_return({ errors: [{ message: 'nope' }] }.to_json)

    expect do
      described_class.new.perform_rollback(deployment_id: 'dep-1', token: 'token')
    end.to raise_error(Release::RollbackError, /nope/)
  end
end
