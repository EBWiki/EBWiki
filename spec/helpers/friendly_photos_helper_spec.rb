# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FriendlyPhotosHelper do
  describe '#friendly_photo_source_link' do
    it 'links to Wikimedia source pages' do
      candidate = build(
        :photo_candidate,
        page_url: 'https://commons.wikimedia.org/wiki/File:Example.jpg'
      )

      expect(helper.friendly_photo_source_link(candidate)).to include('Source page')
    end

    it 'omits mugshot-farm pages' do
      candidate = build(:photo_candidate, page_url: 'https://mugshots.com/photo')

      expect(helper.friendly_photo_source_link(candidate)).to be_nil
    end
  end
end
