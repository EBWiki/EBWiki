# frozen_string_literal: true

require "eb_wiki/friendly_photos/candidate_search"
require "eb_wiki/friendly_photos/hit"
require "eb_wiki/friendly_photos/source_policy"

RSpec.describe EbWiki::FriendlyPhotos::CandidateSearch do
  around do |example|
    previous = ENV["E2E_STUB_WIKIMEDIA"]
    ENV["E2E_STUB_WIKIMEDIA"] = "1"
    example.run
  ensure
    ENV["E2E_STUB_WIKIMEDIA"] = previous
  end

  describe "#call" do
    it "returns no hits when the name is blank" do
      expect(described_class.new(name: "  ").call).to eq([])
    end

    it "keeps stub hits on allowed Wikimedia, Flickr, and Openverse URLs" do
      hits = described_class.new(name: "Walter Scott", case_year: 2015).call

      expect(hits.map(&:title)).to contain_exactly(
        "E2E family portrait",
        "E2E institutional photo",
        "E2E openverse portrait",
        "Portrait of Sir Walter Scott, novelist"
      )
    end

    it "flags likely homonyms without dropping allowed-source hits" do
      hits = described_class.new(name: "Walter Scott", case_year: 2015).call
      homonym = hits.find { |hit| hit.title == "Portrait of Sir Walter Scott, novelist" }

      expect(homonym.likely_homonym).to be(true)
      expect(EbWiki::FriendlyPhotos::SourcePolicy.allowed_hit?(homonym)).to be(true)
    end

    it "flags likely mugshots without dropping allowed-source hits" do
      hits = described_class.new(name: "Walter Scott").call
      mugshot = hits.find { |hit| hit.title == "E2E institutional photo" }

      expect(mugshot.likely_mugshot).to be(true)
      expect(EbWiki::FriendlyPhotos::SourcePolicy.allowed_hit?(mugshot)).to be(true)
    end

    it "drops hits whose image or page URL fails SourcePolicy allow helpers" do
      search = described_class.new(name: "Walter Scott")
      blocked = EbWiki::FriendlyPhotos::Hit.new(
        source: "openverse",
        title: "Portrait",
        image_url: "https://mugshots.com/photo.jpg",
        page_url: "https://www.flickr.com/photos/example/1",
        license: "CC BY 4.0",
        author: "Editor",
        description: "Family photo"
      )
      allowed = EbWiki::FriendlyPhotos::Hit.new(
        source: "wikimedia_commons",
        title: "Allowed portrait",
        image_url: "https://upload.wikimedia.org/wikipedia/commons/a/ab/portrait.jpg",
        page_url: "https://commons.wikimedia.org/wiki/File:Portrait.jpg",
        license: "CC BY-SA 4.0",
        author: "Editor",
        description: "Family photo"
      )

      allow(search).to receive(:stubbed?).and_return(true)
      allow(search).to receive(:stub_hits).and_return([blocked, allowed])

      hits = search.call

      expect(hits.map(&:title)).to eq(["Allowed portrait"])
    end
  end
end
