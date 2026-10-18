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
              { node: { id: 'dep-current', status: 'SUCCESS' } },
              { node: { id: 'dep-previous', status: 'SUCCESS' } }
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

    expect(id).to eq('dep-previous')
  end
end
