# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Release::Rollback::PreviousDeploymentResolver do
  let(:connection) { double('http') }
  let(:client) { Release::Rollback::RailwayGraphqlClient.new(http: connection) }

  def graphql_response(body)
    instance_double(Net::HTTPResponse, body: body.to_json)
  end

  it 'returns the previous successful deployment id' do
    allow(connection).to receive(:start).and_yield(connection)
    allow(connection).to receive(:request).and_return(
      graphql_response(
        data: {
          deployments: {
            edges: [
              { node: { id: '98b66eec-8d76-4447-849a-8edb27867710', status: 'SUCCESS' } },
              { node: { id: '96ee0929-a867-4a18-8cc4-ef24cddaee0f', status: 'SUCCESS' } }
            ]
          }
        }
      )
    )

    id = described_class.new(client: client).resolve!(
      token: 'token',
      project_id: 'proj',
      service_id: 'svc',
      environment_id: 'env'
    )

    expect(id).to eq('96ee0929-a867-4a18-8cc4-ef24cddaee0f')
  end

  it 'ignores non-success deployments returned outside the SUCCESS filter' do
    allow(connection).to receive(:start).and_yield(connection)
    allow(connection).to receive(:request).and_return(
      graphql_response(
        data: {
          deployments: {
            edges: [
              { node: { id: '98b66eec-8d76-4447-849a-8edb27867710', status: 'SUCCESS' } }
            ]
          }
        }
      )
    )

    expect do
      described_class.new(client: client).resolve!(
        token: 'token',
        project_id: 'proj',
        service_id: 'svc',
        environment_id: 'env'
      )
    end.to raise_error(Release::RollbackError, /Only one successful deployment/)
  end
end
