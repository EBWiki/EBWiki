# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe 'PATCH /users/:id' do
    let(:user) { FactoryBot.create(:user) }
    let(:different_user) { FactoryBot.create(:user) }
    let(:params) { { name: "New name" } }
    let(:invalid_params) { { followers: 15 } }

    it 'returns success when request is correct and user is authorized' do
      sign_in user
      patch "/users/#{user.id}", user: params, headers: {}
      expect(response).to redirect_to(user_path(user))
    end

    it 'returns error when request is correct and user is not authorized' do
      sign_in different_user
      patch "/users/#{user.id}", user: params, headers: {}
      expect(response).to redirect_to(root_path)
    end

    it 'returns error when request is incorrect and user is authorized' do
      sign_in user
      patch "/users/#{user.id}", user: invalid_params, headers: {}
      expect(response).to redirect_to(user_path(user))
    end
  end
end