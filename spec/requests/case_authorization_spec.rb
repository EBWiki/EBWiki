# frozen_string_literal: true

require 'rails_helper'
# rubocop:disable Metrics/BlockLength
RSpec.describe 'Case authorization', type: :request do
  let(:regular_user) { create(:user) }
  let(:admin_user) { create(:user, admin: true) }
  let(:this_case) { create(:case) }
  let(:update_params) { { case: { city: 'Albany', summary: 'Authorization spec edit summary' } } }

  shared_examples 'denies non-admin case mutation' do |http_method, path_proc|
    context 'when signed out' do
      before do
        public_send(http_method, path_proc.call(this_case), params: update_params, headers: {})
      end

      it 'redirects to sign in' do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when signed in as a non-admin' do
      before do
        sign_in regular_user
        public_send(http_method, path_proc.call(this_case), params: update_params, headers: {})
      end

      it 'redirects with an authorization alert' do
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('You are not authorized to perform this action.')
      end
    end
  end

  describe 'GET /cases/:slug/edit' do
    include_examples 'denies non-admin case mutation', :get, ->(c) { "/cases/#{c.slug}/edit" }

    context 'when signed in as admin' do
      before do
        sign_in admin_user
        get "/cases/#{this_case.slug}/edit", params: {}, headers: {}
      end

      it 'returns the edit form' do
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Summary')
      end
    end
  end

  describe 'PATCH /cases/:slug' do
    include_examples 'denies non-admin case mutation', :patch, ->(c) { "/cases/#{c.slug}" }

    context 'when signed in as admin' do
      before do
        sign_in admin_user
        patch "/cases/#{this_case.slug}", params: update_params, headers: {}
      end

      it 'updates the case' do
        expect(response).to redirect_to(case_path(this_case))
        expect(this_case.reload.city).to eq('Albany')
      end
    end
  end

  describe 'DELETE /cases/:slug' do
    context 'when signed in as a non-admin' do
      before do
        sign_in regular_user
        delete "/cases/#{this_case.slug}", params: {}, headers: {}
      end

      it 'does not destroy the case' do
        expect(Case.exists?(this_case.id)).to be true
      end

      it 'redirects with an authorization alert' do
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('You are not authorized to perform this action.')
      end
    end

    context 'when signed in as admin' do
      before do
        sign_in admin_user
        delete "/cases/#{this_case.slug}", params: {}, headers: {}
      end

      it 'removes the case' do
        expect(Case.exists?(this_case.id)).to be false
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
