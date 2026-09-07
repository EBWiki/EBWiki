# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Staff tools', type: :request do
  let(:user) { create(:user) }
  let(:admin) { create(:admin) }

  describe 'GET /admin' do
    it 'redirects guests' do
      get '/admin'
      expect(response).to redirect_to root_path
      follow_redirect!
      expect(response.body).to include('You are not an admin')
    end

    it 'redirects non-admins' do
      sign_in user
      get '/admin'
      expect(response).to redirect_to root_path
    end

    it 'shows the users list to admins' do
      sign_in admin
      get '/admin'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Staff tools')
    end
  end

  describe 'PATCH /admin/users/:id' do
    it 'lets an admin grant admin' do
      sign_in admin
      patch "/admin/users/#{user.id}", params: { user: { admin: true } }
      expect(user.reload.admin?).to be true
    end
  end

  describe 'DELETE /admin/comments/:id' do
    let!(:comment) { create(:comment) }

    it 'lets an admin delete a comment' do
      sign_in admin
      expect do
        delete "/admin/comments/#{comment.id}"
      end.to change(Comment, :count).by(-1)
    end
  end

  describe 'GET /admin/states' do
    it 'lists states' do
      sign_in admin
      create(:state)
      get '/admin/states'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('States')
    end
  end
end
