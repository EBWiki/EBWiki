# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FriendlyPhotos::VisionClassifier do
  let(:hit) do
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
  let(:client) { instance_double(FriendlyPhotos::AiClient) }

  before do
    ENV.delete('OPENAI_API_KEY')
    ENV.delete('ANTHROPIC_API_KEY')
    ENV.delete('FRIENDLY_PHOTOS_STUB_AI')
  end

  after do
    ENV.delete('FRIENDLY_PHOTOS_STUB_AI')
    ENV.delete('OPENAI_API_KEY')
  end

  it 'skips vision when no AI key is configured' do
    result = described_class.new(client: client).call(hit: hit)

    expect(result.ai_used).to be false
    expect(result.likely_mugshot).to be false
  end

  it 'uses the LLM when OpenAI is configured' do
    ENV['OPENAI_API_KEY'] = 'test-key'
    allow(client).to receive(:chat_json).and_return(
      'likely_mugshot' => false,
      'score' => 8,
      'reasons' => ['family portrait']
    )

    result = described_class.new(client: client).call(hit: hit)

    expect(result.ai_used).to be true
    expect(result.score).to eq(8)
    expect(result.reasons).to include('family portrait')
  end

  it 'raises when OpenAI is configured but vision returns nothing' do
    ENV['OPENAI_API_KEY'] = 'test-key'
    allow(client).to receive(:chat_json).and_return(nil)

    expect do
      described_class.new(client: client).call(hit: hit)
    end.to raise_error(FriendlyPhotos::AiError, /Vision classifier/)
  end

  it 'returns stub vision output when FRIENDLY_PHOTOS_STUB_AI=1' do
    ENV['FRIENDLY_PHOTOS_STUB_AI'] = '1'
    mugshot = FriendlyPhotos::WikimediaClient::Hit.new(
      source: hit.source,
      title: hit.title,
      image_url: hit.image_url,
      page_url: hit.page_url,
      license: hit.license,
      author: hit.author,
      description: 'County jail booking photo'
    )

    result = described_class.new(client: client).call(hit: mugshot)

    expect(result.ai_used).to be true
    expect(result.likely_mugshot).to be true
    expect(result.reasons).to include('stub vision')
  end
end
