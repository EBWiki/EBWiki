# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MpvPhotoImport::MugshotUrlRejector do
  it 'rejects mugshot and booking-site hosts' do
    expect(described_class.rejected?('https://mugshots.example.org/photo.jpg')).to be(true)
    expect(described_class.rejected?('https://example.com/x.jpg', source_page_url: 'https://jailbase.example/item')).to be(true)
    expect(described_class.rejected?('https://booking.example.com/photo.jpg')).to be(true)
  end

  it 'allows ordinary news and archive URLs' do
    expect(described_class.rejected?('https://example.com/photos/victim.jpg')).to be(false)
  end
end
