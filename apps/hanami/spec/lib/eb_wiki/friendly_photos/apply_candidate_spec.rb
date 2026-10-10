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
end
