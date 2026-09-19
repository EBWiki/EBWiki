# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Search', type: :request do
  describe 'GET /search' do
    it 'states plainly when no cases match' do
      allow(CaseSearch).to receive(:new).and_return(
        instance_double(CaseSearch, call: Kaminari.paginate_array([]).page(1))
      )

      get '/search', params: { query: 'no-such-case' }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('No cases matched this search.')
    end
  end
end
