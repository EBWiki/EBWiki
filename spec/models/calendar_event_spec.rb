# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CalendarEvent, type: :model do
  let(:texas) { FactoryBot.create(:state_texas) }
  let(:ohio) { FactoryBot.create(:state_ohio) }

  describe 'Validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:schedule) }
    it { should validate_presence_of(:description) }
  end

  describe '#location' do
    it 'creates a location object' do
      calendar_event = FactoryBot.create(
        :calendar_event,
        city: 'Worthington',
        state: ohio.name,
        street_address: '1867 Irving Road',
        zipcode: '43085'
      )

      expect(calendar_event.location).to be_a(Location)
      expect(calendar_event.location.city).to eq('Worthington')
      expect(calendar_event.location.street_location).to eq('1867 Irving Road')
      expect(calendar_event.location.zipcode).to eq('43085')
      expect(calendar_event.location.state).to eq('Ohio')
    end
  end

  describe '#location=' do
    let(:new_location) do
      Location.new(
        city: 'Houston',
        state: texas.name,
        street_location: '5555 Hermann Park Dr.',
        zipcode: '77030'
      )
    end

    it 'sets new location' do
      calendar_event = FactoryBot.create(
        :calendar_event,
        city: 'Worthington',
        state: ohio.name,
        street_address: '1867 Irving Road',
        zipcode: '43085'
      )

      calendar_event.location = new_location

      expect(calendar_event.location.city).to eq('Houston')
      expect(calendar_event.location.street_location).to eq('5555 Hermann Park Dr.')
      expect(calendar_event.location.zipcode).to eq('77030')
      expect(calendar_event.location.state).to eq('Texas')
    end
  end
end
