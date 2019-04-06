# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Statistics do

  def mom_metric_growth(metric_at_start:, metric_at_end:)
    Statistics.mom_metric_growth(metric_at_start: metric_at_start, metric_at_end: metric_at_end)
  end

  def mom_unique_followers_growth(metric_at_start:, metric_at_end:)
    Statistics.mom_unique_followers_growth(metric_at_start: metric_at_start, metric_at_end: metric_at_end)
  end

  describe 'new visit growth rate' do
    it 'returns the correct percentage increase' do
      visit = FactoryBot.create(:visit)
      visit.update({ started_at: 41.days.ago })
      FactoryBot.create(:visit)
      expect(mom_metric_growth(metric_at_start: Ahoy::Visit.occurring_by(30.days.ago),
                               metric_at_end: Ahoy::Visit.occurring_by(Date.current))).to eq(100)
    end

    it 'returns the correct percentage decrease' do
      visit = FactoryBot.create(:visit)
      visit.update({ started_at: 41.days.ago })
      expect(mom_metric_growth(metric_at_start: Ahoy::Visit.occurring_by(30.days.ago),
                               metric_at_end: Ahoy::Visit.occurring_by(Date.current))).to eq(0)
    end
  end

  describe 'unique follower growth rate' do
    it 'returns the correct percentage' do
      FactoryBot.create(:follow, follower_id: 1, created_at: 31.days.ago)
      FactoryBot.create(:follow, follower_id: 2, created_at: 10.days.ago)
      expect(mom_unique_followers_growth(metric_at_start: Follow.occurring_by(30.days.ago),
                                         metric_at_end: Follow.occurring_by(Date.current))).to eq(100)
    end

    it 'returns 0 if no distinct followers in last 30 days' do
      FactoryBot.create(:follow, follower_id: 1, created_at: 31.days.ago)
      expect(mom_unique_followers_growth(metric_at_start: Follow.occurring_by(30.days.ago),
                                         metric_at_end: Follow.occurring_by(Date.current))).to eq(0)
    end
  end
end