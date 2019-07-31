# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Follows', type: :request do
  let(:_case) { create(:case) }
  let(:user) { create(:user) }

  describe 'POST /cases/:slug/follows' do
    context 'will make the user a follower of a case' do
      before do
        sign_in user
        post "/cases/#{_case.slug}/follows", params: {}, headers: {}
      end

      it 'will redirect to the case page' do
        expect(response).to redirect_to case_path(_case)
      end
    end
  end

  describe 'DELETE /cases/:slug/follows' do
    context 'will unfollow a case for a user' do
      before do
        sign_in user
        user.follow(_case)
        delete "/cases/#{_case.slug}/follows", params: {}, headers: {}
      end

      it 'will redirect to the case page' do
        expect(response).to redirect_to case_path(_case)
      end
    end
  end
end
