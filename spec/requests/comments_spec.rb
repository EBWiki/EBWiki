# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Comments', type: :request do
  describe 'GET /cases/:slug/comments' do
    let(:user) { create(:user) }
    let(:comment) { create(:comment, user: user) }
    let(:_case) { comment.commentable }

    context 'will get list of comments' do
      before { get "/cases/#{_case.slug}/comments", params: {}, headers: {} }

      it 'will return status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'will list the comment' do
        expect(response.body).to include(comment.content)
      end
    end
  end

  describe 'POST /cases/:slug/comments' do
    let(:user) { create(:user) }
    let(:comment) { { comment: attributes_for(:comment) } }
    let(:_case) { create(:case) }

    context 'will create comment' do
      before do
        sign_in user
        post "/cases/#{_case.slug}/comments", params: comment, headers: {}
      end

      it 'redirect to the case page' do
        expect(response).to redirect_to case_path(_case)
      end
    end
  end
end
