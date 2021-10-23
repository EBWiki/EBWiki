# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Organizations', type: :request do
  let(:user) { create(:user) }
  let(:admin) { create(:admin) }

  describe 'GET /organizations' do
    it 'works! (now write some real specs)' do
      get '/organizations'
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /edit' do
    let(:organization) { create(:organization) }

    context 'as non admin' do
      it 'fails ' do
        sign_in user
        get "/organizations/#{organization.id}/edit", params: {}, headers: {}
        expect(response).to redirect_to root_path
      end
    end

    context 'as admin' do
      it 'succeeds' do
        sign_in admin
        get "/organizations/#{organization.id}/edit", params: {}, headers: {}
        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'PUT /organizations/:id' do
    let(:old_name) { 'Old Name' }
    let(:organization) { create(:organization, name: old_name) }
    let(:new_name) { 'New Name' }

    context 'as non admin' do
      it 'fails to update' do
        sign_in user
        put "/organizations/#{organization.id}", params: { organization: { name: new_name } }, headers: {}
        expect(response).to redirect_to root_path
        expect(organization.reload.name).to eq old_name
      end
    end

    context 'as admin' do
      it 'successfully updates' do
        sign_in admin
        put "/organizations/#{organization.id}", params: { organization: { name: new_name } }, headers: {}
        expect(response).to redirect_to organization
        expect(organization.reload.name).to eq new_name
      end
    end
  end
end
