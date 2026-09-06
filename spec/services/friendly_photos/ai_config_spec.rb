# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FriendlyPhotos::AiConfig do
  after do
    ENV.delete('OPENAI_API_KEY')
    ENV.delete('ANTHROPIC_API_KEY')
    ENV.delete('FRIENDLY_PHOTOS_STUB_AI')
  end

  it 'prefers OpenAI when both keys are present' do
    ENV['OPENAI_API_KEY'] = 'sk-test'
    ENV['ANTHROPIC_API_KEY'] = 'sk-ant'

    expect(described_class.provider).to eq(:openai)
    expect(described_class.enabled?).to be true
  end

  it 'reports not configured without keys' do
    expect(described_class.enabled?).to be false
    expect(described_class.status_label).to include('not configured')
  end
end
