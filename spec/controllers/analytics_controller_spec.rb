# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AnalyticsController, type: :controller do

  describe 'GET #index without login' do
    it 'redirects to the sign in path' do
      get :index
      subject.should redirect_to new_user_session_path
    end
  end

  describe 'GET #index as admin' do
    login_admin

    it 'renders the :index view' do
      get :index
      expect(response).to render_template(:index)
    end

    # it "populates an array of visits" do
    #   visit = Factory(:visit)
    #   get :index
    #   assigns(:visits).should eq([visit])
    # end
  end
end
