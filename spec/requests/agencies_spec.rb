require 'rails_helper'

RSpec.describe "Agencies", type: :request do
  describe "GET /agencies" do
    it "works! (now write some real specs)" do
      get agencies_path
      expect(response).to have_http_status(200)
    end
  end
end
