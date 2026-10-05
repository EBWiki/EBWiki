# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FriendlyPhotos::MetadataScorer do
  describe '.call' do
    it 'flags institutional language' do
      result = described_class.call(text: 'County jail intake image inmate id')

      expect(result.score).to be < 0
      expect(result.reasons).to include('jail')
    end

    it 'boosts portrait language' do
      result = described_class.call(text: 'Family photo portrait yearbook')

      expect(result.score).to be > 0
    end

    it 'ranks portraits above news stills and institutional text' do
      portrait = described_class.call(text: 'Family photo portrait')
      news = described_class.call(text: 'Body cam incident photo')
      institutional = described_class.call(text: 'County jail intake inmate')

      expect(portrait.score).to be > news.score
      expect(news.score).to be > institutional.score
    end

    it 'returns an empty score for blank text' do
      result = described_class.call(text: '')

      expect(result.score).to eq(0)
      expect(result.reasons).to eq([])
    end
  end
end
