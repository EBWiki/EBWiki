# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Agency, type: :model do

  before(:each) do
    @texas = FactoryBot.create(:state_texas)
  end

  it 'is invalid without a name' do
    agency = build(:agency, name: nil, state_id: @texas.id)
    expect(agency).to be_invalid
  end

  it 'is invalid without a state' do
    agency = build(:agency, name: 'The Agency', state_id: nil)
    expect(agency).to be_invalid
  end

  it 'must have a unique name' do
    agency = FactoryBot.create(:agency,
                               name: 'Dallas Police Department',
                               state_id: @texas.id)
    agency2 = build(:agency,
                    name: 'Dallas Police Department',
                    state_id: @texas.id)

    expect(agency2).to be_invalid
  end

  it 'updates slug if agency title is updated' do
    agency = Agency.new(name: 'The Title', state_id: @texas.id)
    agency.slug = nil
    agency.name = 'Another Title'
    agency.save!
    agency.reload
    expect(agency.slug).to eq 'another-title'
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

  describe 'scopes' do
    it 'returns agencies by state' do
      new_york = FactoryBot.create(:state)

      tx_agency_one = FactoryBot.create(:agency,
                                        name: 'Houston Police Department',
                                        city: 'Houston',
                                        state_id: @texas.id)
      tx_agency_two = FactoryBot.create(:agency,
                                        name: 'Dallas Police Department',
                                        city: 'Dallas',
                                        state_id: @texas.id)
      ny_agency = FactoryBot.create(:agency,
                                    name: 'Buffalo Poice Department',
                                    city: 'Buffalo',
                                    state_id: new_york.id)

      texas_agencies = Agency.by_state(@texas.id)
      expect(texas_agencies.count).to be 2
      expect(texas_agencies.to_a).not_to include(ny_agency)
    end

    it 'returns agencies by jurisdiction' do
      dc = FactoryBot.create(:state_dc)
      louisiana = FactoryBot.create(:state_louisiana)

      local_agency = FactoryBot.create(:agency,
                                       name: 'Houston Police Department',
                                       city: 'Houston',
                                       state_id: @texas.id,
                                       jurisdiction: :local),
      state_agency = FactoryBot.create(:agency,
                                       name: 'Louisiana State Police',
                                       city: 'Baton Rouge',
                                       state_id: louisiana.id,
                                       jurisdiction: :state),
      national_agency = FactoryBot.create(:agency,
                                          name: 'United States Department of Justice',
                                          city: 'Washington',
                                          state_id: dc.id,
                                          jurisdiction: :federal)

      local_agencies = Agency.by_jurisdiction(:local)
      expect(local_agencies.count).to be 1
      expect(local_agencies.to_a).not_to include(state_agency)
      expect(local_agencies.to_a).not_to include(national_agency)
    end
  end
end
