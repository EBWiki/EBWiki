require 'rails_helper'

RSpec.describe FollowsController, type: :controller do
#this test is failing!
  describe "POST #create" do
    context 'with valid attributes' do
      # before(:all) do
      #   article = FactoryGirl.create(:article)
      # end
      it 'creates the follow' do
        @article = FactoryGirl.create(:article)
        @follow = FactoryGirl.create(:follow, followable_id: @article.id)
        expect(assigns(:followers)).to eq(@article.reload.followers.first)            
      end
    end
  end
  describe '#DELETE destroy' do
    login_user
    it 'deletes a follow' do
      @article = FactoryGirl.create(:article)
      follow = FactoryGirl.create(:follow, followable_id: @article.id)
      expect{delete :destroy, id: follow.id, article_id: @article.id}.
      to change{@article.followers.count}.by(-1)
    end

    it 'deletes a follow throws an error when the follow does not exist' do
      follow_id = 9999
      @article_id = 9999
      expect{delete :destroy, id: follow_id, article_id: @article.id}.
      to raise_error
    end
  end  
end
