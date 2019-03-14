# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ahoy::Visit, type: :model do
  describe 'scopes' do
    it 'returns visits in the past month' do
      visit_one = FactoryBot.create(:visit, started_at: 31.days.ago)
      FactoryBot.create(:visit, started_at: 10.days.ago)
      expect(Ahoy::Visit.this_month.count).to eq(1)
      expect(Ahoy::Visit.this_month.to_a).not_to include(visit_one)
    end
  end

  describe 'scopes' do
    it 'returns visits in the past week' do
      visit_one = FactoryBot.create(:visit, started_at: 31.days.ago)
      FactoryBot.create(:visit, started_at: 4.days.ago)
      expect(Ahoy::Visit.this_week.count).to eq(1)
      expect(Ahoy::Visit.this_week.to_a).not_to include(visit_one)
    end

    it 'returns today"s visits' do
      visit_one = FactoryBot.create(:visit, started_at: 10.days.ago)
      FactoryBot.create(:visit)
      expect(Ahoy::Visit.today.count).to eq(1)
      expect(Ahoy::Visit.today.to_a).not_to include(visit_one)
    end

    it 'returns the most recent visits' do
      visit_one = FactoryBot.create(:visit, started_at: 50.days.ago)
      FactoryBot.create(:visit, started_at: 10.days.ago)
      expect(Ahoy::Visit.most_recent(45.days.ago).count).to eq(1)
      expect(Ahoy::Visit.most_recent(45.days.ago).to_a).not_to include(visit_one)
    end

    it 'returns visits sorted by landing page' do
      visit_one = FactoryBot.create(:visit,
                                    landing_page: 'https://blackopswiki.herokuapp.com/about')
      FactoryBot.create(:visit,
                        landing_page: 'https://blackopswiki.herokuapp.com/about')
      FactoryBot.create(:visit)
      FactoryBot.create(:visit)
      visit_five = FactoryBot.create(:visit,
                                     landing_page: 'https://blackopswiki.herokuapp.com/analytics/index')

      visits = Ahoy::Visit.sorted_by_hits 2
      expect(visits.count).to eq(2)
      expect(visits.to_a).not_to include [visit_five.landing_page, 1]
    end
  end
end

RSpec.describe Ahoy::Visit, type: :model do
  describe 'growth rate' do
    it 'returns the correct percentage' do
      FactoryBot.create(:visit, started_at: 31.days.ago)
      FactoryBot.create(:visit)
      expect(Ahoy::Visit.first.mom_visits_growth).to eq(0)
    end

    it 'returns 0 if no new visits' do
      FactoryBot.create(:visit, started_at: 31.days.ago)
      expect(Ahoy::Visit.first.mom_visits_growth).to eq(0)
    end

    it 'returns the correct percentage if previous 30 days period saw no visits' do
      FactoryBot.create(:visit)
      expect(Ahoy::Visit.first.mom_visits_growth).to eq(100)
    end
  end
end
