# frozen_string_literal: true

require 'rails_helper'

VALID_YOUTUBE_URLS = ['https://youtube.com/watch?v=Mgn1r3_eM-s',
                      'https://www.youtube.com/watch?v=Mgn1r3_eM-s',
                      'https://m.youtube.com/watch?v=Mgn1r3_eM-s',
                      'https://youtu.be/Mgn1r3_eM-s',
                      'https://www.youtube.com/v/Mgn1r3_eM-s',
                      'https://www.youtube.com/shorts/Mgn1r3_eM-s',
                      'https://m.youtube.com/live/Mgn1r3_eM-s',
                      'https://youtube-nocookie.com/embed/Mgn1r3_eM-s',
                      'https://www.youtube-nocookie.com/embed/Mgn1r3_eM-s',
                      'https://www.youtube.com/embed/Mgn1r3_eM-s'].freeze

INVALID_YOUTUBE_URLS = ['https://notyoutube.com/watch?v=Mgn1r3_eM-s',
                        'https://youtube.evil.com/watch?v=Mgn1r3_eM-s',
                        'https://fakeyoutu.be/Mgn1r3_eM-s',
                        'javascript://youtube.com/%0Aalert(1)'].freeze
DUPLICATE_YOUTUBE_URL = 'https://www.youtube.com/watch?v=Mgn1r3_eM-s&v=ignored'
LOOKALIKE_VIMEO_URL = 'https://evil.com/?next=vimeo.com/136536466'
NON_VIDEO_VIMEO_URL = 'https://vimeo.com/channels/staffpicks'

def passthrough_iframe(video_url)
  %(<iframe src="#{video_url}"></iframe>)
end

RSpec.describe CasesHelper, type: :helper do
  let(:youtube_url) { I18n.t 'cases_helper.youtube_helper_url' }
  let(:vimeo_url) { I18n.t 'cases_helper.vimeo_helper_url' }
  let(:youtube_iframe_url) { I18n.t 'cases_helper.youtube_iframe_url' }
  let(:vimeo_iframe_url) { I18n.t 'cases_helper.vimeo_iframe_url' }
  let(:youtube_id) { 'Mgn1r3_eM-s' }
  let(:youtube_embed_url) { "//www.youtube.com/embed/#{youtube_id}" }
  let(:youtube_embed_iframe) { %(<iframe src="#{youtube_embed_url}"></iframe>) }

  describe '#embed' do
    it 'returns an empty string if the video URL is blank' do
      expect(helper.embed(youtube_url)).to eql(youtube_iframe_url)
    end

    it 'returns a content tag if vimeo video URL is provided' do
      expect(helper.embed(vimeo_url)).to eql(vimeo_iframe_url)
    end

    it 'returns a content tag for a YouTube URL with duplicate video query parameters' do
      expect(helper.embed(DUPLICATE_YOUTUBE_URL)).to eql(youtube_embed_iframe)
    end

    it 'does not treat a lookalike Vimeo URL as Vimeo' do
      expect(helper.embed(LOOKALIKE_VIMEO_URL)).to eql(passthrough_iframe(LOOKALIKE_VIMEO_URL))
    end

    it 'does not treat a non-video Vimeo URL as Vimeo' do
      expect(helper.embed(NON_VIDEO_VIMEO_URL)).to eql(passthrough_iframe(NON_VIDEO_VIMEO_URL))
    end

    it 'returns a YouTube embed iframe for supported query and path URL formats' do
      VALID_YOUTUBE_URLS.each do |valid_youtube_url|
        expect(helper.embed(valid_youtube_url)).to eql(youtube_embed_iframe)
      end
    end

    it 'does not treat lookalike or unsafe YouTube URLs as YouTube' do
      INVALID_YOUTUBE_URLS.each do |invalid_youtube_url|
        expect(helper.embed(invalid_youtube_url)).to eql(passthrough_iframe(invalid_youtube_url))
      end
    end
  end
end
