# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Static pages', type: :request do
  it 'states how to help' do
    get '/how-to-help'
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Search first so we do not create a duplicate.')
  end

  it 'states how to get involved' do
    get '/get-involved'
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Open a case and choose Follow')
  end
end
