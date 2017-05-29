require "rails_helper"

RSpec.describe AgenciesHelper, :type => :helper do
  describe "#recently_updated_case_list" do
    it "displays title and date of articles" do
      agencies = FactoryGirl.create_list(:agency, 10)
      
      expect(helper.agencies_list).to include(Agency.first.name)
      expect(helper.agencies_list).to include(Agency.last.name)
      expect(helper.agencies_list).to include(edit_agency_path(Agency.last))
    end
  end
end