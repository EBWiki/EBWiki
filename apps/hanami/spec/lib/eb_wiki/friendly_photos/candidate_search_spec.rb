# frozen_string_literal: true

require "eb_wiki/friendly_photos/candidate_search"
require "eb_wiki/friendly_photos/hit"

RSpec.describe EbWiki::FriendlyPhotos::CandidateSearch do
  around do |example|
    previous = ENV["E2E_STUB_WIKIMEDIA"]
    ENV["E2E_STUB_WIKIMEDIA"] = "1"
    example.run
  ensure
    ENV["E2E_STUB_WIKIMEDIA"] = previous
  end

  it "returns no hits when the name is blank" do
    expect(described_class.new(name: "  ").call).to eq([])
  end

  it "annotates likely mugshots and keeps family portraits unflagged" do
    hits = described_class.new(name: "Walter Scott").call

    family = hits.find { |hit| hit.title == "E2E family portrait" }
    mugshot = hits.find { |hit| hit.title == "E2E institutional photo" }
    openverse = hits.find { |hit| hit.title == "E2E openverse portrait" }

    expect(family.likely_mugshot).to be(false)
    expect(mugshot.likely_mugshot).to be(true)
    expect(openverse.likely_mugshot).to be(false)
  end

  it "delegates live search to Wikimedia and Openverse clients" do
    wikimedia = instance_double(EbWiki::FriendlyPhotos::WikimediaSearchClient)
    openverse = instance_double(EbWiki::FriendlyPhotos::OpenverseSearchClient)
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("E2E_STUB_WIKIMEDIA").and_return(nil)

    wiki_hit = EbWiki::FriendlyPhotos::Hit.new(
      source: "wikipedia",
      title: "Live wiki",
      image_url: "https://upload.wikimedia.org/wikipedia/commons/x/x1/live.jpg",
      page_url: "https://en.wikipedia.org/wiki/Live",
      license: "CC BY",
      author: nil,
      description: "Live wiki"
    )
    openverse_hit = EbWiki::FriendlyPhotos::Hit.new(
      source: "openverse",
      title: "Live openverse",
      image_url: "https://live.staticflickr.com/x/live-openverse.jpg",
      page_url: "https://www.flickr.com/photos/live/live",
      license: "CC BY",
      author: "Creator",
      description: "Live openverse"
    )

    expect(wikimedia).to receive(:search).with("Ada Lovelace London").and_return([wiki_hit])
    expect(openverse).to receive(:search).with("Ada Lovelace London").and_return([openverse_hit])

    hits = described_class.new(
      name: "Ada Lovelace",
      city: "London",
      wikimedia: wikimedia,
      openverse: openverse
    ).call

    expect(hits.map(&:title)).to contain_exactly("Live wiki", "Live openverse")
    expect(hits).to all(have_attributes(likely_mugshot: false))
  end
end
