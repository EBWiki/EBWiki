# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Agencies', type: :request do # rubocop:todo Metrics/BlockLength
  describe 'GET /agencies' do
    context 'will get list of agencies' do
      before { get '/agencies', params: {}, headers: {} }

      it 'will return status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'will return the list of agencies' do
        expect(response.body).to include('Agencies')
      end
    end
  end

  describe 'GET /agencies/:id' do
    let(:agency) { create(:agency, name: 'My Agency') }

    context 'will get agency page' do
      before { get "/agencies/#{agency.id}", params: {}, headers: {} }

      it 'will return status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'will return the agency page' do
        expect(response.body).to include(agency.name)
      end
    end
  end

  describe 'GET /agencies/new' do
    let(:user) { create(:user) }

    context 'when authenticated' do
      before do
        sign_in user
        get '/agencies/new', params: {}, headers: {}
      end

      it 'will return status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'will return the agency form' do
        expect(response.body).to include('New Agency')
      end
    end

    context 'when not authenticated' do
      before { get '/agencies/new', params: {}, headers: {} }

      it 'will return a redirect to the login page' do
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'GET /agencies/:id/edit' do
    let(:user) { create(:user) }
    let(:agency) { create(:agency) }

    context 'when authenticated' do
      before do
        sign_in user
        get "/agencies/#{agency.id}/edit", params: {}, headers: {}
      end

      it 'will return status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'will return the agency form' do
        expect(response.body).to include('Editing Agency')
      end
    end
  end

  describe 'POST /agencies' do
    let(:user) { create(:user) }
    let(:params) { { agency: attributes_for(:agency) } }
    let(:bad_params) { { agency: { city: 'Beaumont' } } }

    context 'when the agency is successfully saved' do
      before do
        sign_in user
        post '/agencies', params: params, headers: {}
      end

      it 'will return status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'will navigate to the agency show page' do
        expect(response.body).to include(params[:agency][:name])
      end
    end

    context 'when the agency has errors' do
      before do
        sign_in user
        post '/agencies', params: bad_params, headers: {}
      end

      it 'will return status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'will navigate to the agency form' do
        expect(response.body).to include('New Agency')
      end
    end
  end

  describe 'PATCH /agencies/:id' do
    let(:user) { create(:user) }
    let(:agency) { create(:agency) }
    let(:params) { { agency: { email: 'president@example.com' } } }

    context 'when the agency is successfully updated' do
      before do
        sign_in user
        patch "/agencies/#{agency.id}", params: params, headers: {}
      end

      it 'will redirect to to the agency show page' do
        expect(response).to redirect_to agency_path(agency)
      end
    end
  end

  describe 'PUT /agencies/:id' do
    let(:user) { create(:user) }
    let(:agency) { create(:agency) }
    let(:params) { { agency: attributes_for(:agency)  } }

    context 'when the agency is successfully updated' do
      before do
        sign_in user
        put "/agencies/#{agency.id}", params: params, headers: {}
      end

      it 'will redirect to the agency show page' do
        expect(response).to redirect_to agency_path(agency)
      end
    end
  end

  describe 'DELETE /agencies/:id' do
    let(:user) { create(:user) }
    let(:agency) { create(:agency) }

    context 'when the agency is successfully deleted' do
      before do
        sign_in user
        delete "/agencies/#{agency.id}", params: {}, headers: {}
      end

      it 'will delete the agency' do
        expect(Agency.find_by(id: agency.id)).to be_nil
      end

      it 'will redirect to the index page' do
        expect(response).to redirect_to agencies_path
      end
    end
  end
end
