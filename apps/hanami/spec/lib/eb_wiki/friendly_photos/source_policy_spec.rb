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

  describe ".allowed_page_url?" do
    it "allows Wikimedia, Wikipedia, Openverse, and Flickr page hosts" do
      expect(described_class.allowed_page_url?("https://commons.wikimedia.org/wiki/File:Example.jpg")).to be(true)
      expect(described_class.allowed_page_url?("https://en.wikipedia.org/wiki/Example")).to be(true)
      expect(described_class.allowed_page_url?("https://openverse.org/image/example")).to be(true)
      expect(described_class.allowed_page_url?("https://www.flickr.com/photos/example/1")).to be(true)
      expect(described_class.allowed_page_url?("https://subdomain.flickr.com/photos/example/1")).to be(true)
    end

    it "rejects mugshot farms and non-HTTPS URLs" do
      expect(described_class.allowed_page_url?("https://arrests.org/person")).to be(false)
      expect(described_class.allowed_page_url?("http://en.wikipedia.org/wiki/Example")).to be(false)
    end
  end

  describe ".allowed_attach_url?" do
    it "allows the same HTTPS image hosts as allowed_image_url?" do
      wiki = "https://upload.wikimedia.org/wikipedia/commons/a/ab/Example.jpg"
      flickr = "https://live.staticflickr.com/65535/example.jpg"

      expect(described_class.allowed_attach_url?(wiki)).to be(true)
      expect(described_class.allowed_attach_url?(flickr)).to be(true)
    end

    it "rejects page-only hosts and mugshot URLs" do
      expect(described_class.allowed_attach_url?("https://en.wikipedia.org/wiki/Example")).to be(false)
      expect(described_class.allowed_attach_url?("https://mugshots.com/a.jpg")).to be(false)
    end
  end

  describe ".allowed_hit?" do
    it "requires both allowed image and page URLs" do
      expect(described_class.allowed_hit?(hit(
        image_url: "https://upload.wikimedia.org/wikipedia/commons/a/ab/portrait.jpg",
        page_url: "https://commons.wikimedia.org/wiki/File:Portrait.jpg"
      ))).to be(true)
    end

    it "rejects when either URL fails the allow helpers" do
      expect(described_class.allowed_hit?(hit(
        image_url: "https://mugshots.com/photo.jpg",
        page_url: "https://commons.wikimedia.org/wiki/File:Portrait.jpg"
      ))).to be(false)

      expect(described_class.allowed_hit?(hit(
        image_url: "https://upload.wikimedia.org/wikipedia/commons/a/ab/portrait.jpg",
        page_url: "https://arrests.org/person"
      ))).to be(false)
    end

    it "keeps hits with booking-database text when URLs are on the allowlist" do
      expect(described_class.excluded_hit?(hit(
        source: "openverse",
        image_url: "https://live.staticflickr.com/65535/example.jpg",
        page_url: "https://www.flickr.com/photos/example/1",
        title: "Portrait",
        description: "inmate lookup"
      ))).to be(true)

      expect(described_class.allowed_hit?(hit(
        source: "openverse",
        image_url: "https://live.staticflickr.com/65535/example.jpg",
        page_url: "https://www.flickr.com/photos/example/1",
        title: "Portrait",
        description: "inmate lookup"
      ))).to be(true)
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

    it "excludes booking-database sources even when titled as a portrait" do
      expect(described_class.excluded_hit?(hit(
        source: "openverse",
        image_url: "https://mugshots.com/a.jpg",
        page_url: "https://arrests.org/a",
        title: "Portrait",
        description: "inmate lookup"
      ))).to be(true)
    end
  end
end
