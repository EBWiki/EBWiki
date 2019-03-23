# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Statistics do

  def mom_changed_metric_growth(metric_at_start:, metric_at_end:)
    Statistics.mom_changed_metric_growth(metric_at_start: metric_at_start, metric_at_end: metric_at_end)
  end

  def mom_total_metric_growth(metric_at_start:, metric_at_end:)
    Statistics.mom_total_metric_growth(metric_at_start: metric_at_start, metric_at_end: metric_at_end)
  end

  def mom_unique_followers_growth(metric_at_start:, metric_at_end:)
    Statistics.mom_unique_followers_growth(metric_at_start: metric_at_start, metric_at_end: metric_at_end)
  end

  describe 'new visit growth rate' do
    it 'returns the correct percentage increase' do
      FactoryBot.create(:visit, started_at: 31.days.ago)
      FactoryBot.create(:visit)
      expect(mom_changed_metric_growth(metric_at_start: Ahoy::Visit.most_recent(60.days.ago),
                                       metric_at_end: Ahoy::Visit.this_month)).to eq(0)
    end

    it 'returns 0 if no new visits in last 30 days' do
      FactoryBot.create(:visit, started_at: 31.days.ago)
      expect(mom_changed_metric_growth(metric_at_start: Ahoy::Visit.most_recent(60.days.ago),
                                       metric_at_end: Ahoy::Visit.this_month)).to eq(0)
    end

    # What happens if there were new cases between 0-30 days ago but none 31-60 days ago?
    it 'returns correct percentage if previous 30 days period saw no new visits' do
      FactoryBot.create(:visit)
      expect(mom_changed_metric_growth(metric_at_start: Ahoy::Visit.most_recent(60.days.ago),
                                       metric_at_end: Ahoy::Visit.this_month)).to eq(100)
    end
  end

  describe 'total follow growth rate' do
    it 'returns the correct percentage increase' do
      FactoryBot.create(:follow)
      expect(mom_total_metric_growth(metric_at_start: Follow.all, metric_at_end: Follow.this_month)).to eq(100)
    end

    it 'returns 0 if no created cases in last 30 days' do
      FactoryBot.create(:follow, created_at: 31.days.ago)
      expect(mom_total_metric_growth(metric_at_start: Follow.all, metric_at_end: Follow.this_month)).to eq(0)
    end

    # What happens if all of the cases were created in the past 30 days?
    it 'returns correct percentage if all cases created in the past 30 days' do
      FactoryBot.create(:follow, created_at: 10.days.ago)
      FactoryBot.create(:follow, created_at: 15.days.ago)
      expect(mom_total_metric_growth(metric_at_start: Follow.all, metric_at_end: Follow.this_month)).to eq(200)
    end
  end

  describe 'updated case growth rate' do
    it 'returns the correct percentage increase' do
      case_one = FactoryBot.create(:case, updated_at: 41.days.ago)
      case_one.update(updated_at: 41.days.ago)
      FactoryBot.create(:case)
      expect(mom_changed_metric_growth(metric_at_start: Case.recently_updated(60.days.ago),
                                       metric_at_end: Case.recently_updated(30.days.ago))).to eq(0)
    end

    it 'returns 1 if no updates in last 30 days' do
      FactoryBot.create(:case, updated_at: 31.days.ago)
      expect(mom_changed_metric_growth(metric_at_start: Case.recently_updated(60.days.ago),
                                       metric_at_end: Case.recently_updated(30.days.ago))).to eq(100)
    end

    # What happens if there were updates between 0-30 days ago but none 31-60 days ago?
    it 'returns correct percentage if previous 30 days period saw no updates' do
      FactoryBot.create(:case, updated_at: 10.days.ago)
      expect(mom_changed_metric_growth(metric_at_start: Case.recently_updated(60.days.ago),
                                       metric_at_end: Case.recently_updated(30.days.ago))).to eq(100)
    end
  end

  describe 'unique follower growth rate' do
    it 'returns the correct percentage' do
      FactoryBot.create(:follow, follower_id: 1, created_at: 31.days.ago)
      FactoryBot.create(:follow, follower_id: 2, created_at: 10.days.ago)
      expect(mom_unique_followers_growth(metric_at_start: Follow.all,
                                         metric_at_end: Follow.this_month)).to eq(100)
    end

    it 'returns 0 if no distinct followers in last 30 days' do
      FactoryBot.create(:follow, follower_id: 1, created_at: 31.days.ago)
      expect(mom_unique_followers_growth(metric_at_start: Follow.all,
                                         metric_at_end: Follow.this_month)).to eq(0)
    end

    it 'returns 0 if no new distinct followers' do
      FactoryBot.create(:follow, created_at: 31.days.ago)
      expect(mom_unique_followers_growth(metric_at_start: Follow.all,
                                         metric_at_end: Follow.this_month)).to eq(0)
    end
  end
end