require 'rails_helper'

RSpec.describe OfficersController, type: :controller do

  describe "GET #show" do
    it "returns show view" do
      officer = Officer.create(first_name: "David", id: 1)
      get :show, id: 1
      expect(response).to render_template("show")
    end
  end

end
