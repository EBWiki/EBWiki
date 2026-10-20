# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Release::RollbackOptionsBuilder do
  let(:staging_context) { instance_double(Release::Rollback::StagingContext) }
  let(:deployment_resolver) { instance_double(Release::Rollback::PreviousDeploymentResolver) }
  let(:original_env) { ENV.to_h }

  before do
    allow(staging_context).to receive(:ids_for!).and_return(
      { project_id: 'p', service_id: 's', environment_id: 'e' }
    )
    allow(deployment_resolver).to receive(:resolve!).and_return('dep-previous')
    ENV['RAILWAY_TOKEN'] = 'token'
    ENV.delete('RELEASE_ROLLBACK_PLATFORM')
    ENV.delete('RAILWAY_SERVICE')
    ENV.delete('RAILWAY_ENVIRONMENT')
    ENV.delete('RAILWAY_ROLLBACK_DEPLOYMENT_ID')
  end

  after { ENV.replace(original_env) }

  it 'defaults Railway staging targets and resolves the previous deployment' do
    options = described_class.from_argv(
      [],
      staging_context: staging_context,
      deployment_resolver: deployment_resolver
    )

    expect(options.platform).to eq('railway')
    expect(options.service_name).to eq('ebwiki')
    expect(options.environment_slug).to eq('production')
    expect(options.deployment_id).to eq('dep-previous')
  end
end
