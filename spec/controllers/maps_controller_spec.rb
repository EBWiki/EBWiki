require 'rails_helper'

RSpec.describe MapsController, type: :controller do

  describe "GET #index" do
    
  	let!(:articles) {
  	  allow_any_instance_of(Article).to receive(:full_address).and_return("230 West 43rd St. New York City NY 10036")
  	  FactoryGirl.create_list(:article, 20) 
  	  
  	} 
  

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
