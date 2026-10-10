# frozen_string_literal: true

require "eb_wiki/friendly_photos/apply_candidate"
require "eb_wiki/friendly_photos/hit"

RSpec.describe EbWiki::FriendlyPhotos::ApplyCandidate do
  def hit(overrides = {})
    defaults = {
      source: "wikimedia_commons",
      title: "Family portrait",
      image_url: "https://upload.wikimedia.org/wikipedia/commons/a/ab/portrait.jpg",
      page_url: "https://commons.wikimedia.org/wiki/File:Portrait.jpg",
      license: "CC BY-SA 4.0",
      author: "Editor",
      description: "Family photo portrait",
      likely_mugshot: false
    }
    EbWiki::FriendlyPhotos::Hit.new(**defaults.merge(overrides))
  end

  it "allows an openly licensed Wikimedia portrait" do
    result = described_class.new.call(hit: hit)

    expect(result.success).to be(true)
    expect(result.error).to be_nil
  end

  it "refuses a likely mugshot and does not treat it as attachable" do
    result = described_class.new.call(hit: hit(
      title: "Booking photo",
      description: "County jail booking photo",
      likely_mugshot: true
    ))

    expect(result.success).to be(false)
    expect(result.error).to include("not a healthy profile picture")
  end

  it "refuses a photo with no recorded license" do
    result = described_class.new.call(hit: hit(license: ""))

    expect(result.success).to be(false)
    expect(result.error).to include("no recorded license or rights path")
  end

  it "refuses a photo hosted outside Wikimedia or Flickr" do
    result = described_class.new.call(hit: hit(
      image_url: "https://example.com/portrait.jpg",
      page_url: "https://example.com/portrait"
    ))

    expect(result.success).to be(false)
    expect(result.error).to include("not from an allowed Wikimedia or Openverse host")
  end

  it "refuses a plain http image address" do
    result = described_class.new.call(hit: hit(
      image_url: "http://upload.wikimedia.org/wikipedia/commons/a/ab/portrait.jpg"
    ))

    expect(result.success).to be(false)
    expect(result.error).not_to be_nil
  end
end
