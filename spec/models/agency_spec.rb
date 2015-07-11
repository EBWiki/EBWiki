require 'rails_helper'

RSpec.describe Agency, type: :model do
  describe Agency do
	it { should have_many(:articles) }
  end

  it "must have a unique name" do
    agency = build(:agency, name: 'LAPD')
    agency.save
    agency2 = build(:agency, name: 'LAPD')
    expect(agency2).to be_invalid
  end
end
