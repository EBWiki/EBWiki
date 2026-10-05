# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FriendlyPhotos::HeuristicPlanner do
  it 'builds incident-first queries with city, year, and slug' do
    result = described_class.call(
      name: 'Jordan Doe',
      city: 'Albany',
      year: 2015,
      slug: 'jordan-doe-albany'
    )

    expect(result.ai_used).to be false
    expect(result.queries.first).to eq('Killing of Jordan Doe')
    expect(result.queries.second).to eq('Shooting of Jordan Doe')
    expect(result.queries).to include('Jordan Doe Albany 2015', 'jordan doe albany')
  end
end
