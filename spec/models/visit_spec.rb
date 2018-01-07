# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Visit, type: :model do
  describe 'scopes' do

    it 'returns visits in the past month' do
      visit_one = FactoryBot.create(:visit, started_at: 31.days.ago)
      visit_two = FactoryBot.create(:visit, started_at: 10.days.ago)
      expect(Visit.this_month.count).to eq(1)
      expect(Visit.this_month.to_a).not_to include(visit_one)
    end

    it 'returns the most recent visits' do
      visit_one = FactoryBot.create(:visit, started_at: 50.days.ago)
      visit_two = FactoryBot.create(:visit, started_at: 10.days.ago)
      expect(Visit.most_recent(45.days.ago).count).to eq(1)
      expect(Visit.most_recent(45.days.ago).to_a).not_to include(visit_one)
    end
  end

  describe 'growth rate' do
    it 'returns the correct percentage' do
      visit_one = FactoryBot.create(:visit, started_at: 31.days.ago)
      visit_two = FactoryBot.create(:visit)
      expect(Visit.first.mom_visits_growth).to eq(0)
    end

    it 'returns 0 if no new visits' do
      visit = FactoryBot.create(:visit, started_at: 31.days.ago)
      expect(Visit.first.mom_visits_growth).to eq(0)
    end

    it 'returns the correct percentage if previous 30 days period saw no visits' do
      visit = FactoryBot.create(:visit)
      expect(Visit.first.mom_visits_growth).to eq(100)
    end
  end
end
