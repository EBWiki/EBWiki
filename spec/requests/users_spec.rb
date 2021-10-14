# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let!(:user) { create(:user) }

  before { sign_in(user) }

  describe 'GET /users/:id' do
    before { get "/users/#{user.id}" }

    it 'will return status code 200' do
      expect(response).to have_http_status(200)
    end

    it 'will return a user info' do
      expect(response.body).to include(user.name)
    end
  end

  describe 'GET /users/:id/edit' do
    before { get "/users/#{user.id}/edit" }

    it 'will return status code 200' do
      expect(response).to have_http_status(200)
    end

    it 'will return a user info' do
      expect(response.body).to include(user.name)
    end
  end

  describe 'PUT /users/:id' do
    context 'when params are valid' do
      let(:new_name) { Faker::Name.name }

      before { put "/users/#{user.id}", params: { user: { name: new_name } } }

      it 'will return a redirect to the user page' do
        expect(response).to redirect_to user_path(user)
      end

      it 'will update the users name' do
        expect(user.reload.name).to eq new_name
      end
    end

    context 'when params are invalid' do
      before { put "/users/#{user.id}", params: { user: { name: '' } } }

      it 'will show a validation error' do
        expect(response.body).to include('Please add a name.')
      end
    end
  end
end
