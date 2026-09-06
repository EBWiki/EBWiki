# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FriendlyPhotos::HeuristicPlanner do
  it 'builds name-first queries with city and year' do
    result = described_class.call(name: 'Jordan Doe', city: 'Albany', year: 2015)

    expect(result.ai_used).to be false
    expect(result.queries).to include(
      'Jordan Doe',
      'Jordan Doe Albany',
      'Jordan Doe 2015',
      'Jordan Doe portrait',
      'Killing of Jordan Doe'
    )
  end
end
