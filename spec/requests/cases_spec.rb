# frozen_string_literal: true

require 'rails_helper'
# rubocop:disable Metrics/BlockLength
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
    let(:html_blurb) { '<script>alert(1)</script>Hello <b>world</b>' }
    let(:params_with_html_blurb) do
      { case: attributes_for(:case).merge(blurb: html_blurb, state_id: create(:state).id) }
    end

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

    context 'when the blurb contains HTML' do
      before do
        sign_in user
        post '/cases', params: params_with_html_blurb, headers: {}
      end

      it 'stores the blurb without HTML tags' do
        saved_case = Case.find_by!(title: params_with_html_blurb[:case][:title])
        expect(saved_case.blurb).to eq('alert(1)Hello world')
        expect(saved_case.blurb).not_to match(/<[^>]+>/)
      end
    end
  end

  describe 'PATCH /cases/:slug' do
    let(:user) { create(:user) }
    let(:_case) { create(:case) }
    let(:params) { { case: { city: 'Buffalo' } } }
    let(:bad_params) { { case: { date: Date.tomorrow } } }

    context 'when the case is successfully updated' do
      before do
        sign_in user
        patch "/cases/#{_case.slug}", params: params, headers: {}
      end

      it 'will redirect to the case show page' do
        expect(response).to be_redirect
      end

      it 'persists the submitted change' do
        expect(_case.reload.city).to eq('Buffalo')
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

    context 'when the blurb contains HTML' do
      let(:html_blurb) { '<script>alert(1)</script>Hello <b>world</b>' }
      let(:params) { { case: { blurb: html_blurb, summary: 'Stripped HTML from blurb' } } }

      before do
        sign_in user
        patch "/cases/#{_case.slug}", params: params, headers: {}
      end

      it 'stores the blurb without HTML tags' do
        expect(_case.reload.blurb).to eq('alert(1)Hello world')
        expect(_case.reload.blurb).not_to match(/<[^>]+>/)
      end
    end

    context 'when follower email delivery fails after a successful save' do
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

      it 'logs the mail error class without the exception message' do
        expect(Rails.logger).to have_received(:error).with(
          "CasesController#update: follower email failed for case #{_case.id}: StandardError"
        )
      end
    end

    context 'when updating the case raises an error' do
      let(:params) { { case: { city: 'Buffalo' } } }

      before do
        allow(CaseMailer).to receive(:send_followers_email)
        allow(Rollbar).to receive(:error)
        allow_any_instance_of(Case).to receive(:update) do |record, attrs|
          record.assign_attributes(attrs)
          raise StandardError, 'save failed'
        end

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

      it 'does not send follower email' do
        expect(CaseMailer).not_to have_received(:send_followers_email)
      end

      it 'does not persist changes' do
        expect(_case.reload.city).to eq('Albany')
      end

      it 'keeps the editor submitted input on the form' do
        expect(response.body).to include('Buffalo')
      end
    end

    context 'when a title change triggers slug regeneration and save then raises' do
      let(:original_slug) { _case.slug }
      let(:params) do
        {
          case: {
            title: 'Renamed Case Title',
            city: 'Buffalo',
            summary: 'Retried after a save error'
          }
        }
      end

      before do
        original_slug
        allow(CaseMailer).to receive(:send_followers_email)
        allow(Rollbar).to receive(:error)
        allow_any_instance_of(Case).to receive(:geocode).and_raise(StandardError, 'geocode failed')

        sign_in user
        patch "/cases/#{original_slug}", params: params, headers: {}
      end

      it 'renders the edit form with the persisted slug in the form action' do
        expect(response.body).to include("action=\"/cases/#{original_slug}\"")
      end

      it 'keeps the editor submitted title on the form' do
        expect(response.body).to include('Renamed Case Title')
      end

      it 'allows a retry against the persisted slug' do
        allow_any_instance_of(Case).to receive(:geocode).and_return(true)

        patch "/cases/#{original_slug}",
              params: { case: { overview: 'Updated overview after error', summary: 'Second attempt' } },
              headers: {}

        expect(response).to redirect_to(case_path(_case))
        expect(_case.reload.overview).to eq('Updated overview after error')
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
# rubocop:enable Metrics/BlockLength
