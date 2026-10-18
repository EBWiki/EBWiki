# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Release::RollbackRailwayValidator do
  def options(overrides = {})
    defaults = {
      platform: 'railway',
      app_name: nil,
      service_name: 'ebwiki',
      deployment_id: '11111111-2222-4333-8444-555555555555',
      environment_slug: 'staging',
      dry_run: true,
      skip_confirm: false
    }
    Release::RollbackOptions.new(**defaults.merge(overrides))
  end

  it 'requires RAILWAY_SERVICE' do
    expect do
      described_class.validate!(options(service_name: nil))
    end.to raise_error(Release::RollbackError, /RAILWAY_SERVICE/)
  end

  it 'rejects an invalid service name' do
    expect do
      described_class.validate!(options(service_name: 'Bad_Name'))
    end.to raise_error(Release::RollbackError, /Railway service name/)
  end

  it 'requires RAILWAY_ENVIRONMENT' do
    expect do
      described_class.validate!(options(environment_slug: nil))
    end.to raise_error(Release::RollbackError, /RAILWAY_ENVIRONMENT/)
  end

  it 'requires RAILWAY_ROLLBACK_DEPLOYMENT_ID' do
    expect do
      described_class.validate!(options(deployment_id: nil))
    end.to raise_error(Release::RollbackError, /RAILWAY_ROLLBACK_DEPLOYMENT_ID/)
  end

  it 'rejects a non-UUID deployment id' do
    expect do
      described_class.validate!(options(deployment_id: 'dep-123'))
    end.to raise_error(Release::RollbackError, /not a UUID/)
  end

  it 'passes for a valid Railway option set' do
    expect { described_class.validate!(options) }.not_to raise_error
  end
end
