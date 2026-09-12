# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FriendlyPhotos::SourcePolicy do
  describe '.allowed_image_url?' do
    it 'allows Wikimedia and Flickr HTTPS images' do
      wiki = 'https://upload.wikimedia.org/wikipedia/commons/a/ab/Example.jpg'
      flickr = 'https://live.staticflickr.com/65535/example.jpg'

      expect(described_class.allowed_image_url?(wiki)).to be true
      expect(described_class.allowed_image_url?(flickr)).to be true
    end

    it 'rejects mugshot farms and http URLs' do
      expect(described_class.allowed_image_url?('https://mugshots.com/a.jpg')).to be false
      expect(described_class.allowed_image_url?('http://upload.wikimedia.org/a.jpg')).to be false
    end
  end

  describe '.excluded_hit?' do
    it 'excludes booking-database sources even when titled as a portrait' do
      hit = FriendlyPhotos::WikimediaClient::Hit.new(
        source: 'openverse',
        title: 'Portrait',
        image_url: 'https://mugshots.com/a.jpg',
        page_url: 'https://arrests.org/a',
        license: 'Unknown',
        author: nil,
        description: 'inmate lookup'
      )

      expect(described_class.excluded_hit?(hit)).to be true
    end
  end
end
