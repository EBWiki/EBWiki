# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Release::Rollback::RailwayApi do
  let(:connection) { double('http') }
  let(:deployment_id) { '11111111-2222-4333-8444-555555555555' }
  let(:token) { 'token' }

  def graphql_response(body)
    instance_double(Net::HTTPResponse, body: body.to_json)
  end

  before do
    allow(connection).to receive(:start).and_yield(connection)
    allow(connection).to receive(:request).and_return(
      graphql_response(
        data: {
          deployment: {
            id: deployment_id,
            environment: { name: 'staging' },
            service: { name: 'ebwiki' }
          }
        }
      ),
      graphql_response(data: { deploymentRollback: true })
    )
  end

  it 'posts deploymentRollback after verifying service and environment' do
    described_class.new(http: connection).perform_rollback(
      deployment_id: deployment_id,
      service_name: 'ebwiki',
      environment_name: 'staging',
      token: token
    )

    expect(connection).to have_received(:request).twice
  end

  it 'refuses when the deployment service does not match' do
    allow(connection).to receive(:request).and_return(
      graphql_response(
        data: {
          deployment: {
            id: deployment_id,
            environment: { name: 'staging' },
            service: { name: 'other-service' }
          }
        }
      )
    )

    expect do
      described_class.new(http: connection).perform_rollback(
        deployment_id: deployment_id,
        service_name: 'ebwiki',
        environment_name: 'staging',
        token: token
      )
    end.to raise_error(Release::RollbackError, /service/)

    expect(connection).to have_received(:request).once
  end

  it 'refuses when the deployment environment does not match' do
    allow(connection).to receive(:request).and_return(
      graphql_response(
        data: {
          deployment: {
            id: deployment_id,
            environment: { name: 'production' },
            service: { name: 'ebwiki' }
          }
        }
      )
    )

    expect do
      described_class.new(http: connection).perform_rollback(
        deployment_id: deployment_id,
        service_name: 'ebwiki',
        environment_name: 'staging',
        token: token
      )
    end.to raise_error(Release::RollbackError, /environment/)

    expect(connection).to have_received(:request).once
  end
end

RSpec.describe Release::Rollback::RailwayDeploymentVerifier do
  let(:connection) { double('http') }
  let(:client) { Release::Rollback::RailwayGraphqlClient.new(http: connection) }
  let(:deployment_id) { '11111111-2222-4333-8444-555555555555' }

  before do
    allow(connection).to receive(:start).and_yield(connection)
  end

  it 'returns service and environment names from the deployment query' do
    allow(connection).to receive(:request).and_return(
      instance_double(
        Net::HTTPResponse,
        body: {
          data: {
            deployment: {
              id: deployment_id,
              environment: { name: 'staging' },
              service: { name: 'ebwiki' }
            }
          }
        }.to_json
      )
    )

    record = described_class.new(client: client).fetch!(deployment_id: deployment_id, token: 'token')

    expect(record.service_name).to eq('ebwiki')
    expect(record.environment_name).to eq('staging')
  end
end
