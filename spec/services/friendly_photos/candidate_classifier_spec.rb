# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FriendlyPhotos::CandidateClassifier do
  let(:portrait_hit) do
    FriendlyPhotos::WikimediaClient::Hit.new(
      source: 'wikimedia_commons',
      title: 'Family portrait',
      image_url: 'https://upload.wikimedia.org/wikipedia/commons/a/ab/portrait.jpg',
      page_url: 'https://commons.wikimedia.org/wiki/File:Portrait.jpg',
      license: 'CC BY 4.0',
      author: 'Family',
      description: 'Family photo portrait'
    )
  end

  it 'combines metadata and vision signals' do
    allow(FriendlyPhotos::VisionClassifier).to receive(:call).and_return(
      FriendlyPhotos::VisionClassifier::Result.new(
        likely_mugshot: false,
        reasons: ['vision portrait'],
        score: 4,
        ai_used: true
      )
    )

    result = described_class.call(hit: portrait_hit)

    expect(result.likely_mugshot).to be false
    expect(result.score).to be > 4
    expect(result.reasons).to include('vision portrait')
    expect(result.ai_used).to be true
  end

  it 'hard-blocks when either layer flags a mugshot' do
    allow(FriendlyPhotos::VisionClassifier).to receive(:call).and_return(
      FriendlyPhotos::VisionClassifier::Result.new(
        likely_mugshot: false,
        reasons: [],
        score: 0,
        ai_used: false
      )
    )
    mugshot = FriendlyPhotos::WikimediaClient::Hit.new(
      source: portrait_hit.source,
      title: 'Booking mugshot',
      image_url: portrait_hit.image_url,
      page_url: portrait_hit.page_url,
      license: portrait_hit.license,
      author: portrait_hit.author,
      description: 'County jail booking photo'
    )

    result = described_class.call(hit: mugshot)

    expect(result.likely_mugshot).to be true
  end
end
