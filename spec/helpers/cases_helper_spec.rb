# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CasesHelper, type: :helper do
  let(:youtube_url) { I18n.t 'cases_helper.youtube_helper_url' }
  let(:vimeo_url) { I18n.t 'cases_helper.vimeo_helper_url' }
  let(:youtube_iframe_url) { I18n.t 'cases_helper.youtube_iframe_url' }
  let(:vimeo_iframe_url) { I18n.t 'cases_helper.vimeo_iframe_url' }
  describe '#embed' do
    it 'returns an empty string if the video URL is blank' do
      expect(helper.embed(youtube_url)).to eql(youtube_iframe_url)
    end

    it 'returns a content tag if youtube video URL is provided' do
      expect(helper.embed(youtube_url)).to eql(youtube_iframe_url)
    end

    it 'returns a content tag if vimeo video URL is provided' do
      expect(helper.embed(vimeo_url)).to eql(vimeo_iframe_url)
    end
  end
end
