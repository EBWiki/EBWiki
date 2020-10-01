# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MapsHelper, type: :helper do
  describe '#fetch_cases' do
    before :each do
      $redis.set('cases', '')
    end
    it 'fetches cases from the database if they do not exist in the cache' do
      expect($redis.get('cases')).to be_empty
      FactoryBot.create(:case)
      helper.fetch_cases
      expect($redis.get('cases')).to eql('')
    end

    it 'fetches cases from the cache if they are present' do
      this_case = FactoryBot.create(:case)
      $redis.set('cases', this_case.to_json)
      expect($redis).not_to receive(:set)
      expect($redis).not_to receive(:expire)
      helper.fetch_cases
    end
  end
end
