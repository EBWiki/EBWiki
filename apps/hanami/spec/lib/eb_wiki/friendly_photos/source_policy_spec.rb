# frozen_string_literal: true

require "eb_wiki/friendly_photos/hit"
require "eb_wiki/friendly_photos/source_policy"

RSpec.describe EbWiki::FriendlyPhotos::SourcePolicy do
  def hit(image_url:, page_url: "https://commons.wikimedia.org/wiki/File:Example.jpg", title: "Portrait")
    EbWiki::FriendlyPhotos::Hit.new(
      source: "wikimedia_commons",
      title: title,
      image_url: image_url,
      page_url: page_url,
      license: "CC BY-SA 4.0",
      author: "Editor",
      description: title
    )
  end

  it "allows Wikimedia Commons images" do
    expect(described_class.excluded_hit?(hit(
      image_url: "https://upload.wikimedia.org/wikipedia/commons/a/ab/portrait.jpg"
    ))).to be(false)
  end

  it "blocks mugshot-farm hosts" do
    expect(described_class.excluded_hit?(hit(
      image_url: "https://www.mugshots.com/photo.jpg",
      page_url: "https://www.mugshots.com/person"
    ))).to be(true)
  end
end
