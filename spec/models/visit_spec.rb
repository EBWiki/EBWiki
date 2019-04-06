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
                                     landing_page: 'https://blackopswiki.herokuapp.com/analytics')

      visits = Ahoy::Visit.sorted_by_hits 2
      expect(visits.count).to eq(2)
      expect(visits.to_a).not_to include [visit_five.landing_page, 1]
    end

    it 'returns visits by occurrence date' do
      visit = FactoryBot.create(:visit, started_at: 17.days.ago)
      expect(Ahoy::Visit.occurring_by(15.days.ago).size).to eq 1
    end
  end
end
