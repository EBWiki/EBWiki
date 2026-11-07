# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PhotoFinder::MugshotFilter do
  def candidate(**attrs)
    PhotoFinder::Candidate.new(
      image_url: attrs.fetch(:image_url, 'https://example.com/photo.jpg'),
      source_page_url: attrs.fetch(:source_page_url, 'https://example.com/story'),
      source_name: 'openverse',
      license_label: 'CC BY',
      license_url: nil,
      title: attrs.fetch(:title, 'Community portrait'),
      description: attrs.fetch(:description, nil)
    )
  end

  it 'blocks mugshot hosts' do
    row = candidate(image_url: 'https://county-mugshots.example/booking/123.jpg')
    expect(described_class.mugshot?(row)).to be(true)
  end

  it 'blocks booking language in titles' do
    row = candidate(title: 'Official booking photograph')
    expect(described_class.mugshot?(row)).to be(true)
  end

  it 'allows dignified news-style metadata' do
    row = candidate(title: 'Memorial portrait at community vigil')
    expect(described_class.mugshot?(row)).to be(false)
  end
end
