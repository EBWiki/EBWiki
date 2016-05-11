require 'rails_helper'

RSpec.describe MapsController, type: :controller do

  describe "GET #index" do
  	let!(:articles) { FactoryGirl.create_list(:article, 20) } 

  	before do
      get :index
  	end
  	
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'returns all articles' do
      expect(assigns[:articles].size).to eq 20
    end
  end

end
