# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Maps', type: :request do
  describe 'GET /maps' do
    before { Rails.cache.clear }

    it 'returns the case map page' do
      get '/maps'

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Case Map')
      expect(response.body).to include('map-container')
      expect(response.body).to include('case-map-data')
      expect(response.body).to include('Showing 0 documented cases')
    end

    it 'includes geocoded cases in the map payload' do
      this_case = create(:case, title: 'Mapped Case')
      this_case.update_columns(latitude: 42.6525793, longitude: -73.7562317)

      get '/maps'

      expect(response.body).to include('Mapped Case')
      expect(response.body).to include(this_case.slug)
    end
  end
end
