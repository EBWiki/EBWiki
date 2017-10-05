# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  # describe "GET #index" do
  #   it "returns http success" do
  #     get :index
  #     expect(response).to have_http_status(:success)
  #   end
  # end

  # describe "GET #new" do
  #   it "returns http success" do
  #     get :new
  #     expect(response).to have_http_status(:success)
  #   end
  # end
  describe 'Article comments' do
    let(:article) { FactoryGirl.create(:article) }
    let(:comment) { article.comments.create(content: 'a pithy comment') }
    login_user

    subject { comment }

    it { should be_valid }

    it { should respond_to(:content) }
    it { should respond_to(:commentable_type) }
    it { should respond_to(:commentable_id) }

    it 'creates a new comment with valid attributes' do
      comment_attr = attributes_for(:comment)
      article = Article.last || create(:article)

      expect do
        post :create, comment: comment_attr, article_id: article.id
      end.to change(Comment, :count).by(1)
    end

    it 'deletes comments when associated Article object is destroyed' do
      article.save
      comment.save
      article.destroy
      expect(Comment.all).not_to include comment
    end
  end
end
