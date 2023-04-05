# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Case do
  describe 'validity' do
    it { should validate_presence_of(:city).with_message('Please add a city.') }

    it do
      should validate_presence_of(:overview)
        .with_message('An overview of the case is required')
    end

    it do
      should validate_presence_of(:summary).with_message('Please use the last field at the ' \
             'bottom of this form to summarize your edits to the case.')
    end

    it do
      should validate_presence_of(:state_id)
        .with_message('Please specify the state where this incident occurred before saving.')
    end

    it 'should not accept dates in the future' do
      this_case = build(:case, date: 10.days.from_now)
      expect(this_case).to be_invalid
      expect(this_case.errors.to_a).to include('Date must be in the past')
    end
  end

  describe 'blurb' do
    it { should validate_presence_of(:blurb).with_message('A blurb about the case is required.') }
    it { should validate_length_of(:blurb).is_at_most(Case::MAX_BLURB_CHARACTERS) }
  end
end
