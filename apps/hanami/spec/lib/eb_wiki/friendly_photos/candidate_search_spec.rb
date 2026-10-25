# frozen_string_literal: true

require "eb_wiki/friendly_photos/candidate_search"

RSpec.describe EbWiki::FriendlyPhotos::CandidateSearch do
  around do |example|
    previous = ENV["E2E_STUB_WIKIMEDIA"]
    ENV["E2E_STUB_WIKIMEDIA"] = "1"
    example.run
  ensure
    ENV["E2E_STUB_WIKIMEDIA"] = previous
  end

  it "captures license labels and rights path URLs on stubbed candidates" do
    hits = described_class.new(name: "Walter Scott").call

    portrait = hits.find { |hit| hit.title == "E2E family portrait" }
    openverse = hits.find { |hit| hit.title == "E2E openverse portrait" }

    expect(portrait.license).to eq("CC BY-SA 4.0")
    expect(portrait.license_url).to eq("https://creativecommons.org/licenses/by-sa/4.0/")
    expect(openverse.license).to eq("CC BY 4.0")
    expect(openverse.license_url).to eq("https://creativecommons.org/licenses/by/4.0/")
  end
end
