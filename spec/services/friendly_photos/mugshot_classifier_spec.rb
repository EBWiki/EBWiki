# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FriendlyPhotos::MugshotClassifier do
  describe '.call' do
    it 'flags booking and mugshot language' do
      result = described_class.call(text: 'County jail booking photo mugshot')

      expect(result.likely_mugshot).to be true
      expect(result.reasons).to include('mugshot', 'booking photo', 'jail')
      expect(result.score).to be_negative
    end

    it 'boosts family portraits' do
      result = described_class.call(text: 'Family photo portrait of Jordan smiling')

      expect(result.likely_mugshot).to be false
      expect(result.score).to be_positive
    end

    it 'accepts an array of metadata fields' do
      result = described_class.call(
        text: ['Yearbook photograph of', 'https://example.com/portrait.jpg']
      )

      expect(result.likely_mugshot).to be false
      expect(result.score).to be_positive
    end
  end
end
