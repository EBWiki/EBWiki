# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  describe 'GET #show' do
    it 'returns http success' do
      get :show, id: user.id
      expect(response).to have_http_status(:success)
    end
  end
end
