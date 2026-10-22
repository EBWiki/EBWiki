# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Memorial photos browse', type: :request do
  let(:state) { create(:state, name: 'Texas', ansi_code: 'TX') }

  before do
    create(:case, :memorial_photo_shown,
           title: 'Jordan Ellis',
           city: 'Houston',
           date: Date.new(2020, 6, 1),
           state: state)
    create(:case, :memorial_photo_shown, title: 'Other Person', state: create(:state))
  end

  it 'filters by name, state, city, year range, and agency' do
    matching_case = Case.find_by!(title: 'Jordan Ellis')
    agency = create(:agency, name: 'Houston PD', state: state)
    matching_case.agencies << agency

    get memorial_photos_path, params: {
      name: 'Jordan',
      state_id: state.id,
      city: 'Houston',
      year_from: 2020,
      year_to: 2020,
      agency_id: agency.id
    }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Jordan Ellis')
    expect(response.body).not_to include('Other Person')
  end

  it 'searches case text with full-text and trigram' do
    Case.find_by!(title: 'Jordan Ellis').update!(overview: 'Unique memorial phrase alpha-zeta')

    get memorial_photos_path, params: { q: 'alpha-zeta' }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Jordan Ellis')
  end

  it 'shows an empty state with a clear-filters control' do
    get memorial_photos_path, params: { city: 'NoSuchCity' }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('No cases match these filters')
    expect(response.body).to include('Clear filters')
  end

  it 'renders a neutral name card when the photo is removed' do
    create(:case, :memorial_photo_removed,
           title: 'Removed Case Name',
           city: 'Houston',
           state: state)

    get memorial_photos_path, params: { name: 'Removed' }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Removed Case Name')
    expect(response.body).not_to include('removed-photo.jpg')
  end
end
