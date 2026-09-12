# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Search', type: :request do
  let(:new_york) { create(:state_ny) }
  let!(:floyd) do
    create(
      :case,
      title: 'Killing of George Floyd',
      city: 'Albany',
      state: new_york,
      overview: 'An overview of the case',
      blurb: 'Blurb about the case',
      summary: 'Added case'
    )
  end

  before do
    create(:subject, case: floyd, name: 'George Floyd')
  end

  it 'renders matching cases from the header search form' do
    get search_path, params: { query: 'George Floyd' }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Killing of George Floyd')
    expect(response.body).to include('has returned 1 result')
  end

  it 'does not raise when the query is empty' do
    get search_path, params: { query: '', commit: 'Search' }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Killing of George Floyd')
  end
end
