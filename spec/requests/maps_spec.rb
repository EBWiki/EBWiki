# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Maps', type: :request do
  describe 'GET /maps' do
    let(:this_case) { create(:case) }

    before do
      Rails.cache.delete('case_locations')
      this_case
      get '/maps'
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(:ok)
    end

    it 'embeds case pin coordinates for the flat map' do
      expected_coordinates = [this_case.latitude, this_case.longitude]
      expect(response.body).to include("window.CASES = #{expected_coordinates.to_json}")
    end

    it 'loads HERE map assets and map page JavaScript' do
      expect(response.body).to include('mapsjs-core.js')
      expect(response.body).to include('/assets/maps')
    end
  end

  describe 'GET /' do
    it 'does not load map page JavaScript on the home page' do
      get '/'

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include('mapsjs-core.js')
      expect(response.body).not_to include('/assets/maps')
    end
  end
end
