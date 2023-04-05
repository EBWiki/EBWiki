# frozen_string_literal: true

require 'rails_helper'
# rubocop:disable Metrics/BlockLength.
RSpec.describe 'Cases', type: :request do
  describe 'GET /cases' do
    context 'will get list of cases' do
      before { get '/cases', params: {}, headers: {} }

      it 'will return status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'will return the list of cases' do
        expect(response.body).to include('cases')
      end
    end
  end

  describe 'GET /cases/:slug' do
    let(:_case) { create(:case) }

    context 'will get case page' do
      before { get "/cases/#{_case.slug}", params: {}, headers: {} }

      it 'will return status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'will return the case page' do
        expect(response.body).to include(_case.title)
      end
    end
  end

  describe 'GET /cases/new' do
    let(:user) { create(:user) }
    let(:redis) { MockRedis.new }

    before do
      sign_in user
      get '/cases/new', params: {}, headers: {}
    end

    it 'will return status code 200' do
      expect(response).to have_http_status(200)
    end

    it 'will return the agency form' do
      expect(response.body).to include('New Case')
    end
  end

  describe 'GET /cases/:slug/edit' do
    let(:user) { create(:user) }
    let(:_case) { create(:case) }

    before do
      sign_in user
      get "/cases/#{_case.slug}/edit", params: {}, headers: {}
    end

    it 'will return status code 200' do
      expect(response).to have_http_status(200)
    end

    it 'will return the case form' do
      expect(response.body).to include 'Summary'
    end
  end

  describe 'POST /cases' do
    let(:user) { create(:user) }
    let(:params) { { case: attributes_for(:case) } }
    let(:bad_params) { { case: { city: 'Beaumont' } } }

    context 'when the case is successfully saved' do
      before do
        sign_in user
        post '/cases', params: params, headers: {}
      end

      it 'will return status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'will navigate to the case show page' do
        expect(response.body).to include(params[:case][:title])
      end
    end

    context 'when the case has errors' do
      before do
        sign_in user
        post '/cases', params: bad_params, headers: {}
      end

      it 'will return status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'will navigate to the case form' do
        expect(response.body).to include('New Case')
      end
    end
  end

  describe 'PATCH /cases/:slug' do
    let(:user) { create(:user) }
    let(:_case) { create(:case) }
    let(:params) { { case: { city: 'Albany' } } }
    let(:bad_params) { { case: { date: Date.tomorrow } } }

    context 'when the case is successfully updated' do
      before do
        sign_in user
        patch "/cases/#{_case.slug}", params: params, headers: {}
      end

      it 'will redirect to the case show page' do
        expect(response).to be_redirect
      end
    end

    context 'when the case has errors' do
      before do
        sign_in user
        patch "/cases/#{_case.slug}", params: bad_params, headers: {}
      end

      it 'will return status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'will navigate to the case form' do
        expect(response.body).to include('Editing')
      end
    end
  end

  describe 'GET /cases/:slug/followers' do
    let(:users) { create_list(:user, 5) }
    let(:_case) { create(:case) }

    context 'will get followers page' do
      before do
        users.map { |user| user.follow(_case) }
        get "/cases/#{_case.slug}/followers"
      end

      it 'will return status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'will return a list of followers' do
        expect(response.body).to include('followers')
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength.
