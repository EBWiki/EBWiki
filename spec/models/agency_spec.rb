# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Agency, type: :model do

  before(:each) do
    @texas = FactoryBot.create(:state_texas)
  end

  it { should validate_presence_of(:name).with_message('Please enter a name.') }

  it do
   should validate_presence_of(:state_id)
   .with_message('You must specify the state in which the agency is located.') 
  end

  it 'removes leading white space from name' do
    agency = FactoryBot.create(:agency, name: "  Fake agency", state_id: @texas.id)
    expect(agency.name).to eql("Fake agency")
  end

  it 'updates slug if agency title is updated' do
    agency = Agency.new(name: 'The Title', state_id: @texas.id)
    agency.slug = nil
    agency.name = 'Another Title'
    agency.save!
    agency.reload
    expect(agency.slug).to eq 'another-title'
  end

   it 'is invalid without listed jurisdiction type' do
    jurisdiction_type = %w(none state local federal university private)
    agency = build(:agency, name: 'the title', state_id: @texas.id, jurisdiction_type: 'Unlisted Jurisdiction Type')
    expect(agency).to be_invalid
  end

  describe 'geocoded' do
    it 'generates longitude and latitude from city and state on save' do
      agency = FactoryBot.create(:agency,
                                 city: 'Houston',
                                 state_id: @texas.id )
      expect(agency.latitude).to be_a(Float)
      expect(agency.longitude).to be_a(Float)
    end

    it 'updates geocoded coordinates when relevant fields are updated' do
      agency = FactoryBot.create(:agency, state_id: @texas.id)
      ohio = FactoryBot.create(:state_ohio)

      expect do
        agency.update_attributes(city: 'Worthington',
                                 state_id: ohio.id,
                                 street_address: '1867 Irving Road',
                                 zipcode: '43085')
      end.to change { agency.latitude }
    end
  end

  it 'retrieves the state of the agency' do
    agency = FactoryBot.create(:agency, state_id: @texas.id)
    agency_state = agency.retrieve_state
    expect(agency_state).to eq @texas.name
  end

end
