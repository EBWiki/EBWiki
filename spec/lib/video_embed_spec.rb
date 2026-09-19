# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VideoEmbed do
  let(:youtube_url) { I18n.t 'cases_helper.youtube_helper_url' }
  let(:vimeo_url) { I18n.t 'cases_helper.vimeo_helper_url' }
  let(:youtube_iframe_url) { I18n.t 'cases_helper.youtube_iframe_url' }
  let(:vimeo_iframe_url) { I18n.t 'cases_helper.vimeo_iframe_url' }

  describe '.iframe' do
    it 'returns an empty string if the video URL is blank' do
      expect(described_class.iframe('')).to eq('')
    end

    it 'returns a content tag if youtube video URL is provided' do
      expect(described_class.iframe(youtube_url)).to eql(youtube_iframe_url)
    end

    it 'returns a content tag if vimeo video URL is provided' do
      expect(described_class.iframe(vimeo_url)).to eql(vimeo_iframe_url)
    end

    it 'does not embed an arbitrary stored URL' do
      expect(described_class.iframe('javascript:alert(1)')).to eq('')
      expect(described_class.iframe('https://example.com/video.mp4')).to eq('')
    end

    it 'does not treat youtube.com or vimeo.com in the path as a host' do
      expect(described_class.iframe('https://evil.example/youtube.com?v=Mgn1r3_eM-s')).to eq('')
      expect(described_class.iframe('https://evil.example/vimeo.com/136536466')).to eq('')
    end
  end
end
