# frozen_string_literal: true

require "json"
require "webmock/rspec"
require "eb_wiki/friendly_photos/candidate_search"

FIXTURE_ROOT = SPEC_ROOT.join("fixtures/friendly_photos")
WIKIPEDIA_API = %r{\Ahttps://en\.wikipedia\.org/w/api\.php}
COMMONS_API = %r{\Ahttps://commons\.wikimedia\.org/w/api\.php}
OPENVERSE_API = %r{\Ahttps://api\.openverse\.org/v1/images/}

RSpec.describe EbWiki::FriendlyPhotos::CandidateSearch do
  def fixture(name)
    JSON.parse(FIXTURE_ROOT.join(name).read)
  end

  def stub_live_provider_fixtures(
    wikipedia: "wikipedia_pageimages.json",
    commons_rights: "commons_rights_success.json",
    commons_search: "commons_search_empty.json",
    openverse: "openverse_empty.json"
  )
    stub_request(:get, WIKIPEDIA_API)
      .to_return(status: 200, body: fixture(wikipedia).to_json, headers: {"Content-Type" => "application/json"})

    stub_request(:get, COMMONS_API)
      .with(query: hash_including("titles" => "File:Jane_Doe_portrait.jpg"))
      .to_return(status: 200, body: fixture(commons_rights).to_json, headers: {"Content-Type" => "application/json"})

    stub_request(:get, COMMONS_API)
      .with(query: hash_including("generator" => "search"))
      .to_return(status: 200, body: fixture(commons_search).to_json, headers: {"Content-Type" => "application/json"})

    stub_request(:get, OPENVERSE_API)
      .to_return(status: 200, body: fixture(openverse).to_json, headers: {"Content-Type" => "application/json"})
  end

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

  context "with recorded provider responses", :aggregate_failures do
    around do |example|
      previous_stub = ENV.delete("E2E_STUB_WIKIMEDIA")
      WebMock.disable_net_connect!
      example.run
    ensure
      ENV["E2E_STUB_WIKIMEDIA"] = previous_stub if previous_stub
      WebMock.allow_net_connect!
      WebMock.reset!
    end

    it "requests the pageimage file name and enriches Wikipedia hits from Commons metadata" do
      stub_live_provider_fixtures

      hits = described_class.new(name: "Jane Doe").call
      wikipedia_hit = hits.find { |hit| hit.source == "wikipedia" }

      expect(wikipedia_hit).not_to be_nil
      expect(wikipedia_hit.license).to eq("CC BY 4.0")
      expect(wikipedia_hit.license_url).to eq("https://creativecommons.org/licenses/by/4.0/")

      expect(WebMock).to have_requested(:get, WIKIPEDIA_API)
        .with(query: hash_including("piprop" => "original|name"))
      expect(WebMock).to have_requested(:get, COMMONS_API)
        .with(query: hash_including("titles" => "File:Jane_Doe_portrait.jpg"))
    end

    it "keeps Wikipedia candidates when Commons rights metadata is missing" do
      stub_live_provider_fixtures(commons_rights: "commons_rights_empty.json")
      allow(EbWiki::Observability).to receive(:report)

      hits = described_class.new(name: "Jane Doe").call
      wikipedia_hit = hits.find { |hit| hit.source == "wikipedia" }

      expect(hits).not_to be_empty
      expect(wikipedia_hit.license).to eq("Wikipedia page image")
      expect(wikipedia_hit.license_url).to be_nil
      expect(EbWiki::Observability).to have_received(:report).with(
        hash_including(event: "commons_rights_empty_response")
      )
    end

    it "keeps Wikipedia candidates when Commons rights lookup errors" do
      stub_request(:get, WIKIPEDIA_API)
        .to_return(status: 200, body: fixture("wikipedia_pageimages.json").to_json, headers: {"Content-Type" => "application/json"})
      stub_request(:get, COMMONS_API)
        .with(query: hash_including("titles" => "File:Jane_Doe_portrait.jpg"))
        .to_return(status: 200, body: fixture("commons_rights_malformed.json").to_json, headers: {"Content-Type" => "application/json"})
      stub_request(:get, COMMONS_API)
        .with(query: hash_including("generator" => "search"))
        .to_return(status: 200, body: fixture("commons_search_empty.json").to_json, headers: {"Content-Type" => "application/json"})
      stub_request(:get, OPENVERSE_API)
        .to_return(status: 200, body: fixture("openverse_empty.json").to_json, headers: {"Content-Type" => "application/json"})

      allow(EbWiki::Observability).to receive(:report)

      hits = described_class.new(name: "Jane Doe").call
      wikipedia_hit = hits.find { |hit| hit.source == "wikipedia" }

      expect(hits).not_to be_empty
      expect(wikipedia_hit.license).to eq("Wikipedia page image")
      expect(EbWiki::Observability).to have_received(:report).with(
        hash_including(
          event: "commons_rights_lookup_failed",
          error: instance_of(NoMethodError)
        )
      )
    end
  end
end
