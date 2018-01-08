require 'rails_helper'

describe CalendarEventPolicy do
  subject { described_class.new(user, calendar_event) }

  let(:calendar_event) { CalendarEvent.create }

  context 'being a visitor' do
    let(:user) { nil }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'being a registered user' do
    let(:user) { FactoryBot.create(:user) }
    
    it { is_expected.to permit_action(:create) }
  end

  context 'being the owner of the calendar_event' do
    let(:user) { FactoryBot.create(:user) }
  let(:calendar_event) { CalendarEvent.create(user_id: user.id) }

  it { is_expected.to permit_action(:destroy) }
  end

  context 'not being the owner of the calendar_event' do
    pending
  end
end