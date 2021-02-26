# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Agency do
  before(:each) do
    @texas = FactoryBot.create(:state_texas)
  end

  it_behaves_like 'a sanatized_record'

  it { should validate_presence_of(:name).with_message('Please enter a name.') }

  it do
    should validate_presence_of(:state_id)
      .with_message('You must specify the state in which the agency is located.')
  end

  it do
    FactoryBot.create(:agency)
    should validate_uniqueness_of(:name).ignoring_case_sensitivity
                                        .with_message('An agency with this name already exists '\
              'and can be found. If you want to create a new agency, it must have a unique name.')
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
                                 state_id: @texas.id)
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

  describe '#location' do
    it 'creates a location object' do
      ohio = FactoryBot.create(:state_ohio)
      agency = FactoryBot.create(
        :agency,
        city: 'Worthington',
        state_id: ohio.id,
        street_address: '1867 Irving Road',
        zipcode: '43085',
      )

      expect(location).to be_a(Location)
      expect(location.city).to eq('Worthington')
      expect(location.street_location).to eq('1867 Irving Road')
      expect(location.zipcode).to eq('43085')
    end
  end

  describe '#location=' do
    let(:new_location) do
      Location.new(
        city: 'Houston',
        state: @texas.name,
        street_location: '5555 Hermann Park Dr.',
        zipcode: '77030'
      )
    end

    it 'sets new location' do
      ohio = FactoryBot.create(:state_ohio)
      agency = FactoryBot.create(
        :agency,
        city: 'Worthington',
        state_id: ohio.id,
        street_address: '1867 Irving Road',
        zipcode: '43085',
      )

      agency.location = new_location

      expect(agency.location.city).to eq('Houston')
      expect(agency.location.street_location).to eq('5555 Hermann Park Dr.')
      expect(agency.location.zipcode).to eq('77030')
    end
  end
end
