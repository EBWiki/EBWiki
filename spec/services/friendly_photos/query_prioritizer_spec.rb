# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FriendlyPhotos::QueryPrioritizer do
  it 'puts killing and shooting queries first' do
    queries = described_class.call(
      queries: [
        'Walter Scott',
        'Killing of Walter Scott',
        'Walter Scott portrait',
        'Shooting of Walter Scott'
      ]
    )

    expect(queries.first(2)).to contain_exactly(
      'Killing of Walter Scott',
      'Shooting of Walter Scott'
    )
  it 'drops nil and blank queries' do
    queries = described_class.call(
      queries: ['Jordan Doe', nil, ' ', 'Killing of Jordan Doe']
    )

    expect(queries).to eq(['Killing of Jordan Doe', 'Jordan Doe'])
  end
end
