# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FriendlyPhotos::CaseLookup do
  let!(:jordan) do
    create(:case, title: 'Jordan Case', city: 'Albany', date: Date.new(2015, 4, 4))
  end
  let!(:riley) do
    create(:case, title: 'Riley Case', city: 'Buffalo', date: Date.new(2018, 1, 2),
                  avatar_kind: 'mugshot')
  end

  before do
    create(:subject, case: jordan, name: 'Jordan Doe')
    create(:subject, case: riley, name: 'Riley Mugshot')
  end

  it 'finds a case by subject name' do
    results = described_class.call(filter: 'needs_photo', query: 'Jordan')

    expect(results).to include(jordan)
    expect(results).not_to include(riley)
  end

  it 'finds a case by city' do
    results = described_class.call(filter: 'needs_photo', location: 'Buffalo')

    expect(results).to include(riley)
    expect(results).not_to include(jordan)
  end

  it 'finds a case by date' do
    results = described_class.call(filter: 'needs_photo', date: '2015-04-04')

    expect(results).to include(jordan)
    expect(results).not_to include(riley)
  end

  it 'finds a case by id or slug' do
    expect(described_class.call(filter: 'needs_photo', case_id: jordan.id.to_s))
      .to contain_exactly(jordan)
    expect(described_class.call(filter: 'needs_photo', case_id: jordan.slug))
      .to contain_exactly(jordan)
  end
end
