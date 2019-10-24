# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EbwikiVisit do
  describe 'scopes' do
    it 'returns visits in the past month' do
      visit_one = FactoryBot.create(:visit, started_at: 31.days.ago)
      FactoryBot.create(:visit, started_at: 10.days.ago)
      expect(EbwikiVisit.this_month.count).to eq(1)
      expect(EbwikiVisit.this_month.to_a).not_to include(visit_one)
    end

    it 'returns visits in the past week' do
      visit_one = FactoryBot.create(:visit, started_at: 31.days.ago)
      FactoryBot.create(:visit, started_at: 4.days.ago)
      expect(EbwikiVisit.this_week.count).to eq(1)
      expect(EbwikiVisit.this_week.to_a).not_to include(visit_one)
    end

    it 'returns today"s visits' do
      visit_one = FactoryBot.create(:visit, started_at: 10.days.ago)
      FactoryBot.create(:visit)
      expect(EbwikiVisit.today.count).to eq(1)
      expect(EbwikiVisit.today.to_a).not_to include(visit_one)
    end

    it 'returns the most recent visits' do
      visit_one = FactoryBot.create(:visit, started_at: 50.days.ago)
      FactoryBot.create(:visit, started_at: 10.days.ago)
      expect(EbwikiVisit.most_recent(45.days.ago).count).to eq(1)
      expect(EbwikiVisit.most_recent(45.days.ago).to_a).not_to include(visit_one)
    end

    it 'returns visits by occurrence date' do
      FactoryBot.create(:visit, started_at: 17.days.ago)
      expect(EbwikiVisit.occurring_by(15.days.ago).size).to eq 1
    end
  end
end
