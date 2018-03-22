# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FollowsController, type: :controller do
  # this test is failing!
  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates the follow' do
        @case = FactoryBot.create(:case)
        @follow = FactoryBot.create(:follow, followable_id: @case.id)
        expect(assigns(:followers)).to eq(@case.reload.followers.first)
      end
    end
  end
  describe '#DELETE destroy' do
    login_user
    it 'deletes a follow' do
      this_case = FactoryBot.create(:case)
      follow = FactoryBot.create(:follow, followable_id: this_case.id, follower_id: @user.id)
      expect { delete :destroy, id: follow.id, case_id: this_case.id }
        .to change { this_case.followers.count }.by(-1)
    end

    it 'deletes a follow throws an error when the follow does not exist' do
      follow_id = 9999
      @case_id = 9999
      expect { delete :destroy, id: follow_id, case_id: @case.id }
        .to raise_error(NoMethodError)
    end
  end
end
