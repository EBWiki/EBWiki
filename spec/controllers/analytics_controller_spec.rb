require 'rails_helper'

RSpec.describe AnalyticsController, type: :controller do

  describe "GET #show" do
    it "redirects to the sign in path" do
      get :show
      subject.should redirect_to new_user_session_path
    end
  end

  describe "GET #index" do
    it "redirects to the sign in path" do
      get :index
      subject.should redirect_to new_user_session_path
    end
  end

end
