# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Statistics do

  def mom_metric_growth(start_metric:, end_metric:)
    Statistics.mom_metric_growth(start_metric: start_metric, end_metric: end_metric)
  end

  def mom_unique_followers_growth(start_metric:, end_metric:)
    Statistics.mom_unique_followers_growth(start_metric: start_metric, end_metric: end_metric)
  end

  describe 'new visit growth rate' do
    it 'returns the correct percentage increase' do
      visit = FactoryBot.create(:visit)
      visit.update({ started_at: 41.days.ago })
      FactoryBot.create(:visit)
      expect(mom_metric_growth(start_metric: Ahoy::Visit.occurring_by(30.days.ago),
                               end_metric: Ahoy::Visit.occurring_by(Date.current))).to eq(100)
    end

    it 'returns the correct percentage decrease' do
      visit = FactoryBot.create(:visit)
      visit.update({ started_at: 41.days.ago })
      expect(mom_metric_growth(start_metric: Ahoy::Visit.occurring_by(30.days.ago),
                               end_metric: Ahoy::Visit.occurring_by(Date.current))).to eq(0)
    end
  end

  describe 'unique follower growth rate' do
    it 'returns the correct percentage' do
      FactoryBot.create(:follow, follower_id: 1, created_at: 31.days.ago)
      FactoryBot.create(:follow, follower_id: 2, created_at: 10.days.ago)
      expect(mom_unique_followers_growth(start_metric: Follow.occurring_by(30.days.ago),
                                         end_metric: Follow.occurring_by(Date.current))).to eq(100)
    end

    it 'returns 0 if no distinct followers in last 30 days' do
      FactoryBot.create(:follow, follower_id: 1, created_at: 31.days.ago)
      expect(mom_unique_followers_growth(start_metric: Follow.occurring_by(30.days.ago),
                                         end_metric: Follow.occurring_by(Date.current))).to eq(0)
    end
  end
end