require 'rails_helper'

RSpec.describe MailboxController, type: :controller do

  describe "GET #inbox" do
    it "returns http success" do
      get :inbox
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #sent" do
    it "returns http success" do
      get :sent
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #trash" do
    it "returns http success" do
      get :trash
      expect(response).to have_http_status(:success)
    end
  end

end
