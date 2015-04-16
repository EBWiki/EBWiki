require 'rails_helper'

describe Users::RegistrationsController, "#create", :type => :controller do
	before :each do
	  request.env['devise.mapping'] = Devise.mappings[:user]
	end
  describe "on success" do
  	before :each do
		   @attr = { :email => "user@example.com",
                  :password => "foobar01", :password_confirmation => "foobar01" }

		end

    it "should create a user if the gotcha is answered correctly" do
    	Gotcha.skip_validation = true
    	lambda do
        post :create, :user => @attr
        response.should redirect_to(root_path)
      end.should change(User, :count).by(1)
    end
  end
end