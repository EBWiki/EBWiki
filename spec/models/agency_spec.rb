require 'rails_helper'

RSpec.describe Agency, type: :model do
  it "is invalid without a name" do
    agency = build(:agency, name: nil)
    expect(agency).to be_invalid
  end

  it "must have a unique name" do
    agency = FactoryGirl.create(:agency, name: "Dallas Police Department")
    agency2 = build(:agency, name: "Dallas Police Department")

    expect(agency2).to be_invalid
  end

  it 'updates slug if article title is updated' do
    agency = FactoryGirl.create(:agency, name: "The Title")
    agency.slug = nil
    agency.name = "Another Title"
    agency.save!
    agency.reload
    expect(agency.slug).to eq "another-title"
  end
end