require 'rails_helper'

RSpec.describe Agency, type: :model do
  it "is invalid without a name" do
    agency = build(:agency, name: nil)
    expect(agency).to be_invalid
  end

  it "is invalid without a state" do
    agency = build(:agency, state_id: nil)
    expect(agency).to be_invalid
  end

  it "must have a unique name" do
    agency = FactoryGirl.create(:agency, name: "Dallas Police Department")
    agency2 = build(:agency, name: "Dallas Police Department")

    expect(agency2).to be_invalid
  end

  it 'updates slug if agency title is updated' do
    agency = FactoryGirl.create(:agency, name: "The Title")
    agency.slug = nil
    agency.name = "Another Title"
    agency.save!
    agency.reload
    expect(agency.slug).to eq "another-title"
  end
  
  describe "geocoded" do
    it "generates longitude and latitude from city and state on save" do
      agency = FactoryGirl.create(:agency)
      expect(agency.latitude).to be_a(Float)
      expect(agency.longitude).to be_a(Float)
    end
    
    it "updates geocoded coordinates when relevant fields are updated" do
      agency = FactoryGirl.create(:agency)
      ohio = FactoryGirl.create(:state_ohio)
      
      expect{ agency.update_attributes({
        city: "Worthington", 
        state_id: ohio.id, 
        street_address: "1867 Irving Road", 
        zipcode: '43085'
      })}.to change{ agency.latitude }
    end
  end
end