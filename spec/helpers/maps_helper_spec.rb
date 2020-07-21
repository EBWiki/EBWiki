# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MapsHelper, type: :helper do
  describe '#fetch_cases' do
    it 'fetches cases from the database if they do not exist in the cache' do
<<<<<<< HEAD
      $redis.set('cases', '')
      expect($redis.get('cases')).to be_empty
      this_case = FactoryBot.create(:case)
      helper.fetch_cases
      expect($redis.get('cases')).to eql([this_case['latitude'], this_case['longitude']].to_json)
=======
      expect($redis.get('cases')).to be_nil
      FactoryBot.create(:case)
      helper.fetch_cases
      expect(JSON.parse($redis.get('cases')).size).to eq(1)
>>>>>>> Initial maps controller #851
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
