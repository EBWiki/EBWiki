# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FriendlyPhotos::CommonsQuery do
  let(:mime) { 'image/jpeg' }
  let(:commons_body) do
    {
      query: {
        pages: {
          '1' => {
            title: 'File:Jordan Doe portrait.jpg',
            imageinfo: [{
              url: 'https://upload.wikimedia.org/wikipedia/commons/a/ab/portrait.jpg',
              thumburl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/portrait.jpg',
              descriptionurl: 'https://commons.wikimedia.org/wiki/File:Jordan_Doe_portrait.jpg',
              mime: mime,
              extmetadata: {
                LicenseShortName: { value: 'CC BY-SA 4.0' },
                LicenseUrl: { value: 'https://creativecommons.org/licenses/by-sa/4.0/' },
                Artist: { value: 'Pat' }
              }
            }]
          }
        }
      }
    }
  end

  before do
    stub_request(:get, %r{\Ahttps://commons\.wikimedia\.org/w/api\.php})
      .to_return(status: 200, body: commons_body.to_json,
                 headers: { 'Content-Type' => 'application/json' })
  end

  it 'keeps jpeg portraits with a license URL and excludes booking terms' do
    hits = described_class.new(FriendlyPhotos::WikimediaClient).search('Jordan Doe', 8)

    expect(hits.size).to eq(1)
    expect(hits.first.license).to eq('CC BY-SA 4.0')
    expect(hits.first.license_url).to include('creativecommons.org')
    expect(a_request(:get, %r{\Ahttps://commons\.wikimedia\.org/w/api\.php})
      .with(query: hash_including(
        gsrsearch: a_string_including('-mugshot', '-booking', '-inmate',
                                      '-filemime:application/pdf')
      ))).to have_been_made
  end

  context 'when Commons returns a PDF or DjVu scan' do
    let(:mime) { 'application/pdf' }

    it 'drops non-image files' do
      expect(described_class.new(FriendlyPhotos::WikimediaClient).search('Jordan Doe', 8))
        .to be_empty
    end
  end
end
