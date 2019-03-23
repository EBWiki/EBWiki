# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Follow, type: :model do
  describe 'scopes' do
    it 'returns follows from the past month' do
      follow_one = FactoryBot.create(:follow, created_at: 40.days.ago)
      FactoryBot.create(:follow, created_at: 15.days.ago)
      expect(Follow.this_month.count).to eq(1)
      expect(Follow.this_month.to_a).not_to include(follow_one)
    end
  end
end
