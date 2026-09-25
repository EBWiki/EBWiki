# frozen_string_literal: true

require 'rails_helper'

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

    ['https://youtube.com/watch?v=Mgn1r3_eM-s',
     'https://www.youtube.com/watch?v=Mgn1r3_eM-s',
     'https://m.youtube.com/watch?v=Mgn1r3_eM-s',
     'https://youtu.be/Mgn1r3_eM-s',
     'https://youtube-nocookie.com/embed/Mgn1r3_eM-s',
     'https://www.youtube-nocookie.com/embed/Mgn1r3_eM-s',
     'https://www.youtube.com/embed/Mgn1r3_eM-s'].each do |valid_youtube_url|
      it "returns a YouTube embed iframe for #{valid_youtube_url}" do
        expect(helper.embed(valid_youtube_url)).to eql(youtube_embed_iframe)
      end
    end

    ['https://notyoutube.com/watch?v=Mgn1r3_eM-s',
     'https://youtube.evil.com/watch?v=Mgn1r3_eM-s',
     'https://fakeyoutu.be/Mgn1r3_eM-s'].each do |invalid_youtube_url|
      it "does not treat #{invalid_youtube_url} as YouTube" do
        expect(helper.embed(invalid_youtube_url)).to eql(
          %(<iframe src="#{invalid_youtube_url}"></iframe>)
        )
      end
    end
  end
end
