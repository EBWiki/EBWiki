require 'rails_helper'

RSpec.describe FollowsController, type: :controller do
#this test is failing!
  describe "POST #create" do
    context 'with valid attributes' do
      before(:all) do
        FactoryGirl.create :follow
      end
      it 'creates the follow' do
        post :create, follows: attributes_for(:follow)
        expect(Follow.count).to eq(1)
      end
    end
  end

end
