# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PhotoFinder::AllowedImageDownload do
  it 'allows Wikimedia Commons upload URLs over HTTPS' do
    url = 'https://upload.wikimedia.org/wikipedia/commons/3/3a/Example.jpg'
    expect(described_class.permitted?(url)).to be(true)
  end

  it 'allows Openverse thumbnail URLs over HTTPS' do
    url = 'https://api.openverse.org/v1/thumbs/610756ec-ae31-4d5e-8f03-8cc52f31b71d'
    expect(described_class.permitted?(url)).to be(true)
  end

  it 'rejects HTTP URLs' do
    url = 'http://upload.wikimedia.org/wikipedia/commons/3/3a/Example.jpg'
    expect(described_class.permitted?(url)).to be(false)
  end

  it 'rejects arbitrary third-party image hosts' do
    url = 'https://evil.example/photo.jpg'
    expect(described_class.permitted?(url)).to be(false)
  end

  it 'rejects Openverse API JSON endpoints that are not thumbnails' do
    url = 'https://api.openverse.org/v1/images/610756ec-ae31-4d5e-8f03-8cc52f31b71d'
    expect(described_class.permitted?(url)).to be(false)
  end
end
