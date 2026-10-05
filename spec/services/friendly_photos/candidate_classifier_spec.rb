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
        portrait_suitable: true,
        reasons: ['vision portrait'],
        score: 4,
        ai_used: true,
        failed: false
      )
    )

    result = described_class.call(hit: portrait_hit)

    expect(result.score).to be > 4
    expect(result.reasons).to include('vision portrait')
    expect(result.vision_ai_used).to be true
  end

  it 'downscores institutional metadata' do
    allow(FriendlyPhotos::VisionClassifier).to receive(:call).and_return(
      FriendlyPhotos::VisionClassifier::Result.new(
        portrait_suitable: true,
        reasons: [],
        score: 0,
        ai_used: false,
        failed: false
      )
    )
    institutional = FriendlyPhotos::WikimediaClient::Hit.new(
      source: portrait_hit.source,
      title: 'County jail intake',
      image_url: portrait_hit.image_url,
      page_url: portrait_hit.page_url,
      license: portrait_hit.license,
      author: portrait_hit.author,
      description: 'County jail intake image'
    )

    result = described_class.call(hit: institutional)

    expect(result.score).to be < 0
  end

  it 'flags historical homonyms' do
    allow(FriendlyPhotos::VisionClassifier).to receive(:call).and_return(
      FriendlyPhotos::VisionClassifier.skipped_result
    )
    homonym = FriendlyPhotos::WikimediaClient::Hit.new(
      source: portrait_hit.source,
      title: 'Sir Walter Scott',
      image_url: portrait_hit.image_url,
      page_url: portrait_hit.page_url,
      license: portrait_hit.license,
      author: portrait_hit.author,
      description: '19th century novelist'
    )

    result = described_class.call(hit: homonym, case_year: 2015)

    expect(result.likely_homonym).to be true
    expect(result.score).to be < 0
  end
end
