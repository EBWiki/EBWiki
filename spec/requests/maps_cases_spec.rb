# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Maps public case points', type: :request do
  describe 'GET /maps/cases' do
    let!(:mapped_case) { create(:case, title: 'Public Case', city: 'Albany') }
    let!(:unmapped_case) do
      Geocoder::Lookup::Test.add_stub('Unmapped City NY', [])
      create(:case, title: 'Hidden From Map', city: 'Unmapped City')
    end

    before { get cases_maps_path(format: :json) }

    it 'returns public map fields only for geocoded cases' do
      expect(response).to have_http_status(:ok)

      payload = response.parsed_body
      expect(payload).to be_an(Array)
      expect(payload.first.keys.map(&:to_sym)).to match_array(Maps::PublicCasePoints::PUBLIC_FIELDS)
      expect(payload.first).to include(
        'id' => mapped_case.id,
        'name' => 'Public Case',
        'city' => 'Albany'
      )
      expect(payload.first['url']).to include("/cases/#{mapped_case.slug}")

      ids = payload.pluck('id')
      expect(ids).to include(mapped_case.id)
      expect(ids).not_to include(unmapped_case.id)

      expect(response.body).not_to include('overview')
      expect(response.body).not_to include('summary')
      expect(response.body).not_to include(unmapped_case.title)
    end
  end
end
