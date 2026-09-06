# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FriendlyPhotos::SearchPlanner do
  let(:client) { instance_double(FriendlyPhotos::AiClient) }

  before do
    ENV.delete('OPENAI_API_KEY')
    ENV.delete('ANTHROPIC_API_KEY')
    ENV.delete('FRIENDLY_PHOTOS_STUB_AI')
  end

  after do
    ENV.delete('FRIENDLY_PHOTOS_STUB_AI')
  end

  it 'falls back to heuristic queries without an API key' do
    allow(client).to receive(:chat_json)

    result = described_class.new(client: client).call(name: 'Jordan Doe', city: 'Albany')

    expect(result.ai_used).to be false
    expect(result.queries).to include('Jordan Doe', 'Jordan Doe Albany')
    expect(client).not_to have_received(:chat_json)
  end

  it 'uses the LLM when OpenAI is configured' do
    ENV['OPENAI_API_KEY'] = 'test-key'
    allow(client).to receive(:chat_json).and_return(
      'queries' => ['Jordan Doe', 'Jordan Doe portrait', 'Jordan Doe family photo']
    )

    result = described_class.new(client: client).call(name: 'Jordan Doe', city: 'Albany')

    expect(result.ai_used).to be true
    expect(result.queries).to eq(
      ['Jordan Doe', 'Jordan Doe portrait', 'Jordan Doe family photo']
    )
  ensure
    ENV.delete('OPENAI_API_KEY')
  end

  it 'returns deterministic stub queries when FRIENDLY_PHOTOS_STUB_AI=1' do
    ENV['FRIENDLY_PHOTOS_STUB_AI'] = '1'

    result = described_class.new(client: client).call(name: 'Jordan Doe')

    expect(result.ai_used).to be true
    expect(result.queries).to include('Jordan Doe memorial portrait')
  end
end
