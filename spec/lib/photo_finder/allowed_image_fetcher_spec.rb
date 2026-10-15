# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PhotoFinder::AllowedImageFetcher do
  let(:openverse_thumb_url) do
    'https://api.openverse.org/v1/thumbs/610756ec-ae31-4d5e-8f03-8cc52f31b71d'
  end
  let(:wikimedia_file_url) do
    'https://upload.wikimedia.org/wikipedia/commons/3/3a/Example.jpg'
  end
  let(:png_body) { File.binread(Rails.root.join('app/assets/images/default-user-icon.png')) }

  it 'blocks a redirect to an unapproved host without requesting it' do
    evil_url = 'https://evil.example/photo.jpg'
    stub_request(:get, openverse_thumb_url)
      .to_return(status: 302, headers: { 'Location' => evil_url })

    expect do
      described_class.fetch(openverse_thumb_url)
    end.to raise_error(described_class::Error, /allowed Wikimedia Commons or Openverse/)

    expect(a_request(:get, evil_url)).not_to have_been_made
  end

  it 'blocks a redirect from HTTPS to HTTP' do
    insecure_url = 'http://upload.wikimedia.org/wikipedia/commons/3/3a/Example.jpg'
    stub_request(:get, openverse_thumb_url)
      .to_return(status: 302, headers: { 'Location' => insecure_url })

    expect do
      described_class.fetch(openverse_thumb_url)
    end.to raise_error(described_class::Error, /allowed Wikimedia Commons or Openverse/)

    expect(a_request(:get, insecure_url)).not_to have_been_made
  end

  it 'follows a redirect between approved HTTPS hosts' do
    stub_request(:get, openverse_thumb_url)
      .to_return(status: 302, headers: { 'Location' => wikimedia_file_url })
    stub_request(:get, wikimedia_file_url)
      .to_return(status: 200, body: png_body, headers: { 'Content-Type' => 'image/png' })

    response = described_class.fetch(openverse_thumb_url)

    expect(response.code).to eq(200)
    expect(response.body).to eq(png_body)
    expect(a_request(:get, openverse_thumb_url)).to have_been_made
    expect(a_request(:get, wikimedia_file_url)).to have_been_made
  end
end
