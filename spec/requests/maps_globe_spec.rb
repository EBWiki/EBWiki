# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Maps globe page', type: :request do
  describe 'GET /maps/globe' do
    before { get globe_maps_path }

    it 'returns success' do
      expect(response).to have_http_status(:ok)
    end

    it 'loads the globe shell and cases JSON endpoint' do
      expect(response.body).to include('globe-viewport')
      expect(response.body).to include('globe.js')
      expect(response.body).to include(cases_maps_path(format: :json))
    end

    it 'links back to the flat map' do
      expect(response.body).to include(maps_path)
    end
  end
end
