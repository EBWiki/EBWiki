# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FollowQuery do
  describe '#distinct_count' do
    let(:test_case) { create(:case) }
    let(:users) { create_pair(:user) }

    before(:each) do
      users.each { |u| u.follow(test_case) }
      users[0].follow(test_case)
    end

    subject(:distinct_count) { described_class.new.distinct_count }

    it 'returns the number of distinct followers' do
      expect(distinct_count).to eq 2
    end
  end
end
