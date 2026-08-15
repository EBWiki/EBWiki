# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PhotoCandidate do
  it 'requires a Wikimedia image host' do
    candidate = build(:photo_candidate, image_url: 'https://mugshots.com/photo.jpg')

    expect(candidate).not_to be_valid
    expect(candidate.errors[:image_url]).to include('must be a Wikimedia HTTPS image URL')
  end

  it 'is unique per case and image URL' do
    existing = create(:photo_candidate)
    duplicate = build(:photo_candidate, case: existing.case, image_url: existing.image_url)

    expect(duplicate).not_to be_valid
  end
end
