# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FriendlyPhotos::OpenverseClient do
  let(:body) do
    {
      results: [
        {
          title: 'Jordan Doe family photo',
          url: 'https://live.staticflickr.com/65535/jordan.jpg',
          foreign_landing_url: 'https://www.flickr.com/photos/pat/jordan',
          license: 'by-sa',
          license_version: '4.0',
          license_url: 'https://creativecommons.org/licenses/by-sa/4.0/',
          creator: 'Pat',
          source: 'flickr',
          attribution: 'Pat'
        },
        {
          title: 'Booking photo',
          url: 'https://mugshots.com/jordan.jpg',
          foreign_landing_url: 'https://mugshots.com/jordan',
          license: 'by',
          license_version: '2.0',
          creator: 'Sheriff',
          source: 'mugshots'
        }
      ]
    }
  end

  before do
    stub_request(:get, %r{\Ahttps://api\.openverse\.org/v1/images/})
      .to_return(status: 200, body: body.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  it 'keeps licensed Flickr portraits and drops mugshot hosts' do
    hits = described_class.new.search(query: 'Jordan Doe')

    expect(hits.size).to eq(1)
    expect(hits.first.source).to eq('openverse')
    expect(hits.first.license).to include('BY-SA')
    expect(hits.first.license_url).to include('creativecommons.org')
    expect(hits.map(&:image_url)).not_to include('https://mugshots.com/jordan.jpg')
  end

  it 'returns fixture hits when e2e stubbing is on' do
    ENV['E2E_STUB_WIKIMEDIA'] = '1'

    hits = described_class.new.search(query: 'Jordan Doe')

    expect(hits.map(&:title)).to eq(['E2E openverse portrait'])
  ensure
    ENV.delete('E2E_STUB_WIKIMEDIA')
  end
end
