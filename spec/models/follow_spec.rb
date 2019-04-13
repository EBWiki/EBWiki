# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Follow do
  describe 'scopes' do
    it 'returns follows occurring by a given date' do
      follow = FactoryBot.create(:follow)
      follow.update(created_at: 17.days.ago)
      expect(Follow.occurring_by(15.days.ago).to_a).to include(follow)
    end
  end
end
