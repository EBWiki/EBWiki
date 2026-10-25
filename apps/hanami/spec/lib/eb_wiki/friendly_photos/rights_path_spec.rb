# frozen_string_literal: true

require "eb_wiki/friendly_photos/hit"
require "eb_wiki/friendly_photos/rights_path"

RSpec.describe EbWiki::FriendlyPhotos::RightsPath do
  def hit(overrides = {})
    defaults = {
      source: "wikimedia_commons",
      title: "Family portrait",
      image_url: "https://upload.wikimedia.org/wikipedia/commons/a/ab/portrait.jpg",
      page_url: "https://commons.wikimedia.org/wiki/File:Portrait.jpg",
      license: "CC BY-SA 4.0",
      license_url: "https://creativecommons.org/licenses/by-sa/4.0/",
      author: "Editor",
      description: "Family photo portrait",
      likely_mugshot: false
    }
    EbWiki::FriendlyPhotos::Hit.new(**defaults.merge(overrides))
  end

  describe ".sanitize_url" do
    it "accepts allowed HTTPS page URLs" do
      url = "https://creativecommons.org/licenses/by-sa/4.0/"

      expect(described_class.sanitize_url(url)).to eq(url)
    end

    it "rejects javascript and non-HTTPS URLs" do
      expect(described_class.sanitize_url("javascript:alert(1)")).to be_nil
      expect(described_class.sanitize_url("http://creativecommons.org/licenses/by/4.0/")).to be_nil
    end
  end

  describe ".history_fragment" do
    it "includes both the license label and rights URL when present" do
      fragment = described_class.history_fragment(hit)

      expect(fragment).to eq(
        "CC BY-SA 4.0; https://creativecommons.org/licenses/by-sa/4.0/"
      )
    end

    it "includes only the rights URL when the label is blank" do
      fragment = described_class.history_fragment(hit(
        license: "",
        license_url: "https://creativecommons.org/licenses/by-sa/4.0/"
      ))

      expect(fragment).to eq("https://creativecommons.org/licenses/by-sa/4.0/")
    end
  end
end
