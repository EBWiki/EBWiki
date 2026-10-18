# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Release::Rollback::PreviousDeploymentResolver do
  let(:connection) { double('http') }
  let(:client) { Release::Rollback::RailwayGraphqlClient.new(http: connection) }
  let(:sent) { [] }

  def node(id, status, created_at, can_rollback: true)
    { id: id, status: status, createdAt: created_at, canRollback: can_rollback }
  end

  def stub_response(body)
    allow(connection).to receive(:start).and_yield(connection)
    allow(connection).to receive(:request) do |request|
      sent << JSON.parse(request.body)
      instance_double(Net::HTTPResponse, body: body.is_a?(String) ? body : body.to_json)
    end
  end

  def stub_deployments(*nodes)
    stub_response(data: { deployments: { edges: nodes.map { |entry| { node: entry } } } })
  end

  def resolve
    described_class.new(client: client).resolve!(
      token: 'token', project_id: 'proj', service_id: 'svc', environment_id: 'env'
    )
  end

  # The shape Railway returned for staging on 2026-10-18: one SUCCESS (live), then
  # REMOVED deployments, only some of which can still be rolled back to.
  it 'skips the live deployment and REMOVED ones that cannot roll back' do
    stub_deployments(
      node('live', 'SUCCESS', '2026-10-11T22:02:29Z'),
      node('removed-no-rollback-1', 'REMOVED', '2026-10-11T22:00:36Z', can_rollback: false),
      node('removed-no-rollback-2', 'REMOVED', '2026-10-11T22:00:29Z', can_rollback: false),
      node('image-184', 'REMOVED', '2026-10-05T06:00:03Z'),
      node('older', 'REMOVED', '2026-10-05T05:57:43Z')
    )

    expect(resolve).to eq('image-184')
  end

  it 'asks Railway for SUCCESS and REMOVED deployments of this service only' do
    stub_deployments(node('live', 'SUCCESS', '2026-10-11T22:02:29Z'), node('prev', 'REMOVED', '2026-10-05T06:00:03Z'))

    resolve

    variables = sent.first.fetch('variables')
    expect(variables.dig('input', 'status', 'in')).to contain_exactly('SUCCESS', 'REMOVED')
    expect(variables['input']).to include('projectId' => 'proj', 'serviceId' => 'svc', 'environmentId' => 'env')
    expect(sent.first.fetch('query')).to include('canRollback')
  end

  it 'orders by createdAt instead of trusting the response order' do
    stub_deployments(
      node('prev', 'REMOVED', '2026-10-05T06:00:03Z'),
      node('live', 'SUCCESS', '2026-10-11T22:02:29Z')
    )

    expect(resolve).to eq('prev')
  end

  it 'never returns a deployment newer than the live one' do
    stub_deployments(
      node('newer-removed', 'REMOVED', '2026-10-12T10:00:00Z'),
      node('live', 'SUCCESS', '2026-10-11T22:02:29Z')
    )

    expect { resolve }.to raise_error(Release::RollbackError, /No earlier Railway deployment/)
  end

  it 'fails closed when only the live deployment exists' do
    stub_deployments(node('live', 'SUCCESS', '2026-10-11T22:02:29Z'))

    expect { resolve }.to raise_error(Release::RollbackError, /No earlier Railway deployment/)
  end

  it 'fails closed when no deployment is live' do
    stub_deployments(node('prev', 'REMOVED', '2026-10-05T06:00:03Z'))

    expect { resolve }.to raise_error(Release::RollbackError, /No live/)
  end

  it 'fails closed when the earlier deployments cannot be rolled back to' do
    stub_deployments(
      node('live', 'SUCCESS', '2026-10-11T22:02:29Z'),
      node('prev', 'REMOVED', '2026-10-05T06:00:03Z', can_rollback: false)
    )

    expect { resolve }.to raise_error(Release::RollbackError, /No earlier Railway deployment/)
  end

  it 'fails closed on a GraphQL error' do
    stub_response(errors: [{ message: 'Not Authorized' }], data: nil)

    expect { resolve }.to raise_error(Release::RollbackError, /Not Authorized/)
  end

  it 'fails closed when the deployment list is missing' do
    stub_response(data: {})

    expect { resolve }.to raise_error(Release::RollbackError, /no deployment list/)
  end

  it 'fails closed on invalid JSON' do
    stub_response('not json')

    expect { resolve }.to raise_error(Release::RollbackError, /invalid JSON/)
  end
end
