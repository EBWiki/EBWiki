# frozen_string_literal: true

require "eb_wiki/friendly_photos/hit"
require "eb_wiki/friendly_photos/source_policy"

RSpec.describe EbWiki::FriendlyPhotos::SourcePolicy do
  def hit(image_url:, page_url: "https://commons.wikimedia.org/wiki/File:Example.jpg", title: "Portrait",
    description: title, source: "wikimedia_commons")
    EbWiki::FriendlyPhotos::Hit.new(
      source: source,
      title: title,
      image_url: image_url,
      page_url: page_url,
      license: "CC BY-SA 4.0",
      author: "Editor",
      description: description
    )
  end

  describe ".allowed_image_url?" do
    it "allows Wikimedia and Flickr HTTPS images" do
      wiki = "https://upload.wikimedia.org/wikipedia/commons/a/ab/Example.jpg"
      flickr = "https://live.staticflickr.com/65535/example.jpg"

      expect(described_class.allowed_image_url?(wiki)).to be(true)
      expect(described_class.allowed_image_url?(flickr)).to be(true)
    end

    it "rejects mugshot farms and http URLs" do
      expect(described_class.allowed_image_url?("https://mugshots.com/a.jpg")).to be(false)
      expect(described_class.allowed_image_url?("http://upload.wikimedia.org/a.jpg")).to be(false)
    end
  end

  describe ".allowed_attach_url?" do
    it "allows the same HTTPS image hosts as allowed_image_url?" do
      wiki = "https://upload.wikimedia.org/wikipedia/commons/a/ab/Example.jpg"

      expect(described_class.allowed_attach_url?(wiki)).to be(true)
    end

    it "rejects mugshot URLs" do
      expect(described_class.allowed_attach_url?("https://mugshots.com/a.jpg")).to be(false)
    end
  end

  describe ".excluded_hit?" do
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
end
