# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Follow, type: :model do
  describe 'growth rate' do
    it 'returns the correct percentage' do
      FactoryBot.create(:follow)
      expect(Follow.first.mom_follows_growth).to eq(100)
    end

    it 'returns 0 if no new follows' do
      FactoryBot.create(:follow, created_at: 31.days.ago)
      expect(Follow.first.mom_follows_growth).to eq(0)
    end

    it 'returns the correct percentage if all follows are within the past 30 days' do
      follow_one = FactoryBot.create(:follow, created_at: 10.days.ago)
      follow_two = FactoryBot.create(:follow, created_at: 15.days.ago)
      expect(Follow.first.mom_follows_growth).to eq(200)
    end
  end
end

RSpec.describe Follow, type: :model do
  describe 'distinct follower growth rate' do
    it 'returns the correct percentage' do
      FactoryBot.create(:follow, follower_id: 1, created_at: 31.days.ago)
      FactoryBot.create(:follow, follower_id: 2, created_at: 10.days.ago)
      expect(Follow.first.mom_unique_followers_growth).to eq(100)
    end

    it 'returns 0 if no distinct followers' do
      FactoryBot.create(:follow, follower_id: 1, created_at: 31.days.ago)
      FactoryBot.create(:follow, follower_id: 1, created_at: 10.days.ago)
      expect(Follow.first.mom_unique_followers_growth).to eq(0)
    end

    it 'returns 0 if no new distinct followers' do
      FactoryBot.create(:follow, created_at: 31.days.ago)
      expect(Follow.first.mom_unique_followers_growth).to eq(0)
    end
  end
end
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
