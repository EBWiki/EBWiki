require 'rails_helper'

RSpec.describe FollowsController, type: :controller do

  describe "GET #create" do
    login_user

    context 'when valid' do
      let(:follow_attrs) { FactoryGirl.attributes_for(:follow) }

      it 'success' do
        post :create, {'follows': follow_attrs}
        expect(response).to redirect_to(article_path(Article.last))
      end
    end
  end

  describe "GET #destroy" do
    it "returns http success" do
      get :destroy
      expect(response).to have_http_status(:success)
    end
  end

end
