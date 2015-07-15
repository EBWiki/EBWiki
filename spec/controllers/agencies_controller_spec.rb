require 'rails_helper'

RSpec.describe AgenciesController, type: :controller do

  describe "GET #show" do
    let(:agency) {FactoryGirl.create(:agency)}
	  describe "GET #show" do
	    it "returns http success" do
	      get :show, id: agency.id
	      expect(response).to have_http_status(:success)
	    end
	  end
	end
end
