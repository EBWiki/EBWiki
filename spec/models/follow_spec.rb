# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Follow do
  describe 'scopes' do
    let(:user) { create(:user) }
    let(:test_case) { create(:case) }

    before(:each) { user.follow(test_case) }

    it 'returns follows occurring by a given date' do
      follow = Follow.first
      follow.update!(created_at: 17.days.ago)
      expect(Follow.occurring_by(15.days.ago).to_a).to include(follow)
    end
  end
end
