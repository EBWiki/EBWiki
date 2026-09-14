# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MapsHelper, type: :helper do
  describe '#fetch_cases' do
    before { Rails.cache.clear }

    it 'returns location payloads for geocoded cases' do
      this_case = create(:case, title: 'Mapped Case')
      this_case.update_columns(latitude: 42.6525793, longitude: -73.7562317)

      locations = helper.fetch_cases

      expect(locations.size).to eq(1)
      expect(locations.first).to include(
        lat: 42.6525793,
        lng: -73.7562317,
        title: 'Mapped Case',
        slug: this_case.slug,
        city: this_case.city,
        url: case_path(this_case)
      )
    end

    it 'omits cases without coordinates' do
      create(:case, title: 'Unmapped Case')
      Case.update_all(latitude: nil, longitude: nil)

      expect(helper.fetch_cases).to eq([])
    end
  end

  describe '#case_has_location?' do
    it 'is true when both coordinates are present' do
      this_case = build(:case, latitude: 40.7, longitude: -74.0)

      expect(helper.case_has_location?(this_case)).to be(true)
    end

    it 'is false when a coordinate is missing' do
      this_case = build(:case, latitude: 40.7, longitude: nil)

      expect(helper.case_has_location?(this_case)).to be(false)
    end
  end
end
