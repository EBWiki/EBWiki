# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Release::DeploymentId do
  it 'accepts a UUID deployment id' do
    expect(described_class.validate!('11111111-2222-4333-8444-555555555555')).to eq(
      '11111111-2222-4333-8444-555555555555'
    )
  end

  it 'rejects a non-UUID deployment id' do
    expect do
      described_class.validate!('dep-123')
    end.to raise_error(Release::RollbackError, /not a UUID/)
  end
end
