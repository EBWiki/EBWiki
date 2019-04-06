# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FollowQuery do
  describe '#distinct_count' do
    subject(:distinct_count) { described_class.new.distinct_count}

    it 'returns the number of distinct followers' do
      FactoryBot.create(:follow, follower_id: 1, created_at: 31.days.ago)
      FactoryBot.create(:follow, follower_id: 1, created_at: 21.days.ago)
      FactoryBot.create(:follow, follower_id: 2, created_at: 10.days.ago)
      expect(distinct_count).to eq 2
    end
  end
end