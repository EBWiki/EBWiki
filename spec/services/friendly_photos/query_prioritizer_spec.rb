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
  end
end
