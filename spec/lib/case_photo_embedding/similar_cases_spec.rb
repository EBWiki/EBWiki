# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CasePhotoEmbedding::SimilarCases do
  def unit_vector(seed:)
    Array.new(CasePhotoEmbedding::EMBEDDING_DIMENSIONS) do |index|
      ((index + seed) % 7).zero? ? 1.0 : 0.0
    end
  end

  describe '.ranked_by_embedding' do
    it 'returns the same case first when queried with its own embedding' do
      anchor_vector = unit_vector(seed: 3)
      anchor = create(:case, photo_status: 'shown', photo_url: 'https://example.com/a.jpg')
      anchor.update_column(:photo_embedding, anchor_vector)

      neighbor_vector = unit_vector(seed: 9)
      create(:case, photo_status: 'shown', photo_url: 'https://example.com/b.jpg',
                    photo_embedding: neighbor_vector)

      results = described_class.ranked_by_embedding(anchor_vector, limit: 5)

      expect(results.first).to eq(anchor)
    end

    it 'excludes cases without shown photos' do
      vector = unit_vector(seed: 1)
      shown = create(:case, photo_status: 'shown', photo_url: 'https://example.com/c.jpg')
      shown.update_column(:photo_embedding, vector)
      create(:case, photo_status: 'hidden', photo_url: 'https://example.com/hidden.jpg',
                    photo_embedding: vector)

      results = described_class.ranked_by_embedding(vector, limit: 10)

      expect(results.map(&:id)).to eq([shown.id])
    end
  end

  describe '.more_like_this' do
    it 'does not include the source case' do
      vector = unit_vector(seed: 4)
      source = create(:case, photo_status: 'shown', photo_url: 'https://example.com/source.jpg')
      source.update_column(:photo_embedding, vector)
      other = create(:case, photo_status: 'shown', photo_url: 'https://example.com/other.jpg')
      other.update_column(:photo_embedding, unit_vector(seed: 11))

      results = described_class.more_like_this(source, limit: 5)

      expect(results).to include(other)
      expect(results).not_to include(source)
    end
  end
end
