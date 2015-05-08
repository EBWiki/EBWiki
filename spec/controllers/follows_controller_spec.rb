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

end
