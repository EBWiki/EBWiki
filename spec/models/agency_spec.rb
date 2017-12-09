# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Agency, type: :model do
  it 'is invalid without a name' do
    agency = build(:agency, name: nil)
    expect(agency).to be_invalid
  end

  it 'is invalid without a state' do
    agency = build(:agency, state_id: nil)
    expect(agency).to be_invalid
  end

  it 'must have a unique name' do
    agency = FactoryBot.create(:agency, name: 'Dallas Police Department')
    agency2 = build(:agency, name: 'Dallas Police Department')

    expect(agency2).to be_invalid
  end

  it 'updates slug if agency title is updated' do
    agency = FactoryBot.create(:agency, name: 'The Title')
    agency.slug = nil
    agency.name = 'Another Title'
    agency.save!
    agency.reload
    expect(agency.slug).to eq 'another-title'
  end

  describe 'geocoded' do
    it 'generates longitude and latitude from city and state on save' do
      agency = FactoryBot.create(:agency)
      expect(agency.latitude).to be_a(Float)
      expect(agency.longitude).to be_a(Float)
    end

    it 'updates geocoded coordinates when relevant fields are updated' do
      agency = FactoryBot.create(:agency)
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
      texas = FactoryBot.create(:state_texas)
      new_york = FactoryBot.create(:state)

      tx_agency_one = FactoryBot.create(:agency,
                                        name: 'Houston Police Department',
                                        street_address: nil,
                                        city: 'Houston',
                                        state_id: texas.id,
                                        zipcode: nil)
      tx_agency_two = FactoryBot.create(:agency,
                                        name: 'Dallas Police Department',
                                        street_address: nil,
                                        city: 'Dallas',
                                        state_id: texas.id,
                                        zipcode: nil)
      ny_agency = FactoryBot.create(:agency,
                                    name: 'Buffalo Poice Department',
                                    street_address: nil,
                                    city: 'Buffalo',
                                    state_id: new_york.id,
                                    zipcode: nil)

      texas_agencies = Agency.by_state(texas.id)
      expect(texas_agencies.count).to be 2
      expect(texas_agencies.to_a).not_to include(ny_agency)
    end

    it 'returns agencies by jurisdiction' do
      dc = FactoryBot.create(:state_dc)
      louisiana = FactoryBot.create(:state_louisiana)
      texas = FactoryBot.create(:state_texas)

      local_agency = FactoryBot.create(:agency,
                                       name: 'Houston Police Department',
                                       street_address: nil,
                                       city: 'Houston',
                                       state_id: texas.id,
                                       zipcode: nil,
                                       jurisdiction: :local),
      state_agency = FactoryBot.create(:agency,
                                       name: 'Louisiana State Police',
                                       street_address: nil,
                                       city: 'Baton Rouge',
                                       state_id: louisiana.id,
                                       zipcode: nil,
                                       jurisdiction: :state),
      national_agency = FactoryBot.create(:agency,
                                          name: 'United States Departmen of Justice',
                                          street_address: nil,
                                          city: 'Washington',
                                          state_id: dc.id,
                                          zipcode: nil,
                                          jurisdiction: :federal)

      local_agencies = Agency.by_jurisdiction(:local)
      expect(local_agencies.count).to be 1
      expect(local_agencies.to_a).not_to include(state_agency)
      expect(local_agencies.to_a).not_to include(national_agency)
    end
  end
end
