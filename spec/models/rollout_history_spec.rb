# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RolloutHistory do
  describe '#sanitize' do
    context 'for leading and trailing whitespace' do
      let(:rollout_history) { build(:rollout_history, change_description: 'desc ', author_name: ' name ') }

      it "strips those whitespaces" do
        rollout_history.validate
        expect(rollout_history.change_description).to eq 'desc'
        expect(rollout_history.author_name).to eq 'name'
      end
    end
  end
end
