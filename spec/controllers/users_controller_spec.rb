# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }
  describe 'GET #show' do
    it 'returns http success' do
      get :show, id: user.id
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit' do
    it 'returns http success' do
      get :edit, id: user.id
      expect(response).to have_http_status(:success)
    end
  end
end
