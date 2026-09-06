# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FriendlyPhotos::WikimediaClient do
  describe '.allowed_image_url?' do
    it 'allows Wikimedia HTTPS uploads' do
      url = 'https://upload.wikimedia.org/wikipedia/commons/a/ab/Example.jpg'
      expect(described_class.allowed_image_url?(url)).to be true
    end

    it 'rejects mugshot farms and http URLs' do
      expect(described_class.allowed_image_url?('https://mugshots.com/a.jpg')).to be false
      expect(described_class.allowed_image_url?('http://upload.wikimedia.org/a.jpg')).to be false
    end
  end

  describe '#search' do
    let(:commons_body) do
      {
        query: {
          pages: {
            '1' => {
              title: 'File:Jordan Doe portrait.jpg',
              imageinfo: [{
                url: 'https://upload.wikimedia.org/wikipedia/commons/a/ab/portrait.jpg',
                thumburl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/portrait.jpg',
                descriptionurl: 'https://commons.wikimedia.org/wiki/File:Jordan_Doe_portrait.jpg',
                mime: 'image/jpeg',
                extmetadata: {
                  LicenseShortName: { value: 'CC BY-SA 4.0' },
                  Artist: { value: '<a href="https://example.com">Pat</a>' },
                  ImageDescription: { value: 'Portrait of Jordan Doe' }
                }
              }]
            }
          }
        }
      }
    end

    let(:wikipedia_search_body) do
      { query: { search: [{ title: 'Jordan Doe' }] } }
    end

    let(:wikipedia_image_body) do
      {
        query: {
          pages: {
            '2' => {
              title: 'Jordan Doe',
              fullurl: 'https://en.wikipedia.org/wiki/Jordan_Doe',
              pageimage: 'Jordan_Doe.jpg',
              original: {
                source: 'https://upload.wikimedia.org/wikipedia/commons/j/jd/Jordan_Doe.jpg'
              }
            }
          }
        }
      }
    end

    before do
      stub_request(:get, %r{\Ahttps://commons\.wikimedia\.org/w/api\.php})
        .to_return(status: 200, body: commons_body.to_json, headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, %r{\Ahttps://en\.wikipedia\.org/w/api\.php})
        .with(query: hash_including('list' => 'search'))
        .to_return(status: 200, body: wikipedia_search_body.to_json, headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, %r{\Ahttps://en\.wikipedia\.org/w/api\.php})
        .with(query: hash_including('prop' => 'pageimages|info'))
        .to_return(status: 200, body: wikipedia_image_body.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns fixture hits when e2e stubbing is on' do
      ENV['E2E_STUB_WIKIMEDIA'] = '1'

      hits = described_class.new.search(query: 'Jordan Doe')

      expect(hits.map(&:title)).to include('E2E family portrait', 'E2E booking mugshot')
    ensure
      ENV.delete('E2E_STUB_WIKIMEDIA')
    end

    it 'returns Wikimedia and Wikipedia hits' do
      hits = described_class.new.search(query: 'Jordan Doe')

      expect(hits.map(&:source)).to contain_exactly('wikipedia', 'wikimedia_commons')
      expect(hits.map(&:image_url)).to all(match(%r{\Ahttps://upload\.wikimedia\.org/}))
      expect(hits.find { |hit| hit.source == 'wikimedia_commons' }.author).to eq('Pat')
    end
  end
end
