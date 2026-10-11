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

    context 'when follower email delivery fails after a successful save' do
      let(:params) { { case: { city: 'Buffalo' } } }
      let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

      before do
        allow(CaseMailer).to receive(:send_followers_email).and_return(message_delivery)
        allow(message_delivery).to receive(:deliver_now).and_raise(StandardError, 'mail failed')
        allow(Rollbar).to receive(:error)
        allow(Rails.logger).to receive(:error)

        sign_in user
        patch "/cases/#{_case.slug}", params: params, headers: {}
      end

      it 'redirects to the case show page' do
        expect(response).to redirect_to(case_path(_case))
      end

      it 'sets the success flash' do
        expect(flash[:success]).to eq('Case was updated!')
      end

      it 'persists the update' do
        expect(_case.reload.city).to eq('Buffalo')
      end

      it 'reports the mail error to Rollbar' do
        expect(Rollbar).to have_received(:error).with(instance_of(StandardError))
      end

      it 'logs the mail error' do
        expect(Rails.logger).to have_received(:error).with(/follower email/i)
      end
    end

    context 'when updating the case raises an error' do
      before do
        allow_any_instance_of(Case).to receive(:update).and_raise(StandardError, 'save failed')
        allow(Rollbar).to receive(:error)

        sign_in user
        patch "/cases/#{_case.slug}", params: params, headers: {}
      end

      it 'renders the edit form' do
        expect(response.body).to include('Editing')
      end

      it 'returns unprocessable entity status' do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'sets an error flash' do
        expect(flash.now[:error]).to be_present
      end

      it 'reports the error to Rollbar' do
        expect(Rollbar).to have_received(:error).with(instance_of(StandardError))
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

  describe 'GET /cases/:slug/history' do
    let(:_case) { create(:case) }

    before { get "/cases/#{_case.slug}/history", params: {}, headers: {} }

    context 'will get history page' do
      it 'will return status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'will return the history of the case' do
        expect(response.body).to include('history')
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength.
