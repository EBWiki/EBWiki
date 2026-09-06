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

  describe '#friendly_photos_search_mode_label' do
    after { ENV.delete('E2E_STUB_WIKIMEDIA') }

    it 'reports live search when stubs are off' do
      ENV.delete('E2E_STUB_WIKIMEDIA')
      expect(helper.friendly_photos_search_mode_label).to eq('live Wikimedia + Openverse')
    end

    it 'reports stub mode when E2E_STUB_WIKIMEDIA=1' do
      ENV['E2E_STUB_WIKIMEDIA'] = '1'
      expect(helper.friendly_photos_search_mode_label).to eq('stubbed (E2E fixtures only)')
    end
  end
end
